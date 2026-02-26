---
name: "flutter-architecture"
description: "Configure Flutter SDK on the user's machine, setup IDEs, and diagnose CLI errors."
metadata:
  urls:
    - "https://docs.flutter.dev/app-architecture"
    - "https://docs.flutter.dev/app-architecture/concepts"
    - "https://docs.flutter.dev/app-architecture/guide"
    - "https://docs.flutter.dev/resources/architectural-overview"
    - "https://docs.flutter.dev/app-architecture/recommendations"
    - "https://docs.flutter.dev/app-architecture/design-patterns"
    - "https://docs.flutter.dev/app-architecture/case-study"
    - "https://docs.flutter.dev/app-architecture/case-study/data-layer"
    - "https://docs.flutter.dev/app-architecture/design-patterns/key-value-data"
    - "https://docs.flutter.dev/learn/pathway/how-flutter-works"
  model: "models/gemini-3.1-pro-preview"
  last_modified: "Thu, 26 Feb 2026 23:04:35 GMT"

---
# flutter-app-architecture

## Goal
Architects, refactors, and structures scalable Flutter applications using the recommended MVVM layered architecture. It enforces strict separation of concerns across UI, Domain, and Data layers, ensuring unidirectional data flow, immutable state management, and robust error handling using Result objects and the Command pattern. Assumes a multi-package or feature-first directory structure and relies on standard dependency injection and routing mechanisms.

## Decision Logic
When implementing a new feature, use the following decision tree to place logic correctly:
1. Does the code interact with an external API, database, or platform plugin?
   - **Yes:** Place in a **Service** (Data Layer).
2. Does the code manage the source of truth, cache data, or transform raw API models into Domain models?
   - **Yes:** Place in a **Repository** (Data Layer).
3. Does the feature require combining data from multiple repositories or contain exceedingly complex business logic reused across multiple screens?
   - **Yes:** Place in a **Use-Case** (Domain Layer).
   - **No:** Proceed to ViewModel.
4. Does the code format data for the UI, maintain view state, or handle user interaction events?
   - **Yes:** Place in a **ViewModel** (UI Layer).
5. Does the code define the visual layout, animations, or routing?
   - **Yes:** Place in a **View** (UI Layer).

## Instructions

1. **Define the Feature Structure**
   Organize the feature directory strictly by layer.
   ```text
   lib/
     src/
       feature_name/
         data/
           models/
           repositories/
           services/
         domain/
           models/
           use_cases/
         ui/
           view_models/
           views/
           widgets/
   ```

2. **Implement the Data Layer: Services**
   Create stateless service classes to wrap external APIs. Return raw API models wrapped in a `Result` type.
   ```dart
   class ApiClient {
     Future<Result<UserApiModel>> getUser(String id) async {
       try {
         // Implementation details...
         return Result.ok(userApiModel);
       } on Exception catch (e) {
         return Result.error(e);
       }
     }
   }
   ```

3. **Implement the Data Layer: Repositories**
   Create repositories as the single source of truth. Inject services via the constructor. Map API models to immutable Domain models.
   ```dart
   abstract class UserRepository {
     Future<Result<User>> getUser(String id);
     Stream<User?> observeCurrentUser();
   }

   class UserRepositoryImpl implements UserRepository {
     UserRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;
     
     final ApiClient _apiClient;
     final _userController = StreamController<User?>.broadcast();

     @override
     Future<Result<User>> getUser(String id) async {
       final result = await _apiClient.getUser(id);
       if (result is Error<UserApiModel>) {
         return Result.error(result.error);
       }
       final domainUser = User.fromApiModel(result.asOk.value);
       _userController.add(domainUser);
       return Result.ok(domainUser);
     }

     @override
     Stream<User?> observeCurrentUser() => _userController.stream;
   }
   ```

4. **Evaluate Domain Layer Necessity**
   **STOP AND ASK THE USER:** "Does this feature require complex business logic or data aggregation from multiple repositories that should be abstracted into a Use-Case?"
   - If the user says **Yes**, implement a Use-Case class that takes Repositories as dependencies and exposes a single `execute` method.
   - If the user says **No**, proceed to the ViewModel.

5. **Implement the UI Layer: ViewModels**
   Create ViewModels extending `ChangeNotifier`. Use the Command pattern for user interactions to handle loading/error states automatically.
   ```dart
   class UserViewModel extends ChangeNotifier {
     UserViewModel({required UserRepository userRepository}) 
         : _userRepository = userRepository {
       loadUser = Command1<String, void>(_loadUser);
     }

     final UserRepository _userRepository;
     User? _currentUser;
     User? get currentUser => _currentUser;

     late final Command1<String, void> loadUser;

     Future<Result<void>> _loadUser(String id) async {
       final result = await _userRepository.getUser(id);
       if (result is Ok<User>) {
         _currentUser = result.value;
         notifyListeners();
       }
       return result;
     }
   }
   ```

6. **Implement the UI Layer: Views**
   Create Views using `ListenableBuilder` or `Consumer` to react to ViewModel changes. Bind UI events to ViewModel Commands.
   ```dart
   class UserScreen extends StatelessWidget {
     const UserScreen({super.key, required this.viewModel});
     final UserViewModel viewModel;

     @override
     Widget build(BuildContext context) {
       return ListenableBuilder(
         listenable: viewModel,
         builder: (context, _) {
           if (viewModel.loadUser.isRunning) {
             return const CircularProgressIndicator();
           }
           final user = viewModel.currentUser;
           if (user == null) {
             return const Text('No user found');
           }
           return Text('User: ${user.name}');
         },
       );
     }
   }
   ```

7. **Wire Dependencies**
   Inject dependencies at the feature boundary or app root using a provider mechanism.
   ```dart
   MultiProvider(
     providers: [
       Provider<ApiClient>(create: (_) => ApiClient()),
       ProxyProvider<ApiClient, UserRepository>(
         update: (_, api, __) => UserRepositoryImpl(apiClient: api),
       ),
       ChangeNotifierProxyProvider<UserRepository, UserViewModel>(
         create: (context) => UserViewModel(
           userRepository: context.read<UserRepository>(),
         ),
         update: (_, repo, viewModel) => viewModel!,
       ),
     ],
     child: const MyApp(),
   )
   ```

8. **Validate-and-Fix Loop**
   After generating the architecture, verify:
   - Are there any direct Service calls from the ViewModel? (If yes, refactor to route through a Repository).
   - Does the View contain any business logic or state mutation? (If yes, move to ViewModel).
   - Are data models immutable? (If no, implement `freezed` or `built_value` patterns).

## Constraints
*   **Strict Layer Isolation:** The UI layer must never know about the Data layer's Services or API models. It only interacts with ViewModels, Use-Cases, Repositories, and Domain models.
*   **No Logic in Views:** Views must only contain layout logic, animations, and simple routing. All state mutations must occur in the ViewModel.
*   **Unidirectional Data Flow:** Data must flow strictly downwards (Data -> Domain -> UI), and events must flow strictly upwards (UI -> Domain -> Data).
*   **Single Source of Truth:** Repositories are the only classes permitted to mutate or cache application data.
*   **Stateless Services:** Services must not hold any state. They are strictly wrappers for external calls.
*   **Immutable Models:** Domain models must be immutable. Use code generation tools (like `freezed`) where applicable.
