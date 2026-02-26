---
name: "flutter-environment-setup-macos"
description: "Set up a macOS environment for Flutter development"
metadata:
  urls:
    - "https://docs.flutter.dev/platform-integration/macos/setup"
    - "https://docs.flutter.dev/install/add-to-path"
    - "https://docs.flutter.dev/install/troubleshoot"
    - "https://docs.flutter.dev/install"
    - "https://docs.flutter.dev/install/quick"
    - "https://docs.flutter.dev/platform-integration/ios/setup"
    - "https://docs.flutter.dev/platform-integration/macos"
  model: "models/gemini-3.1-pro-preview"
  last_modified: "Thu, 26 Feb 2026 23:03:44 GMT"

---
# Flutter macOS Environment Setup

## Goal
Configures a macOS development environment to run, build, and deploy Flutter applications for macOS devices. Validates tooling dependencies including Xcode and CocoaPods, and ensures the local machine is recognized as a valid macOS deployment target. Assumes the host operating system is macOS and the user has administrative privileges.

## Decision Logic
*   **Is Flutter installed?** 
    *   Yes: Proceed to Xcode validation.
    *   No: Halt and instruct the user to complete the standard Flutter installation first.
*   **Is Xcode installed?**
    *   Yes: Proceed to configure command-line tools.
    *   No: Halt and instruct the user to install Xcode from the Mac App Store.
*   **Does `flutter doctor` report Xcode issues?**
    *   Yes: Execute the Validate-and-Fix loop, resolving specific missing components, then re-run `flutter doctor -v`.
    *   No: Proceed to device validation.

## Instructions

1. **Verify Flutter Installation**
   Run the following command to ensure Flutter is installed and accessible in the current environment:
   ```bash
   flutter --version
   ```
   **STOP AND ASK THE USER:** If Flutter is not installed, instruct the user to complete the base Flutter installation guide before proceeding.

2. **Verify Xcode Installation**
   Check if Xcode is installed on the system.
   ```bash
   xcodebuild -version
   ```
   **STOP AND ASK THE USER:** If Xcode is not installed, instruct the user to download and install the latest version of Xcode from the Mac App Store, then return to continue the setup.

3. **Configure Xcode Command-Line Tools**
   Link the Xcode command-line tools to the installed version of Xcode and trigger the first-launch setup. Execute the following command:
   ```bash
   sudo sh -c 'xcode-select -s /Applications/Xcode.app/Contents/Developer && xcodebuild -runFirstLaunch'
   ```
   *Note: If the user installed Xcode in a custom directory, replace `/Applications/Xcode.app` with the correct path.*

4. **Agree to Xcode Licenses**
   The Xcode license agreements must be accepted before compilation can occur.
   ```bash
   sudo xcodebuild -license
   ```
   **STOP AND ASK THE USER:** Instruct the user to read through the prompts in their terminal and type "agree" to accept the necessary Apple licenses.

5. **Install CocoaPods**
   CocoaPods is required to support Flutter plugins that utilize native macOS code. Instruct the user to install CocoaPods via their preferred Ruby package manager (e.g., Homebrew or RubyGems).
   ```bash
   sudo gem install cocoapods
   ```
   *Note: If using Homebrew, the command is `brew install cocoapods`.*

6. **Validate Setup (Validate-and-Fix Loop)**
   Run the Flutter diagnostic tool to check for any remaining issues with the macOS development setup.
   ```bash
   flutter doctor -v
   ```
   Analyze the output under the **Xcode** section. If there are missing components or errors, provide the user with the specific commands to resolve them, then re-run `flutter doctor -v` to verify the fix.

7. **Verify macOS Device Availability**
   Ensure Flutter can find and connect to the macOS desktop device.
   ```bash
   flutter devices
   ```
   Confirm that at least one entry in the output lists "macos" as the platform.

## Constraints
*   Do NOT proceed to subsequent steps if a dependency (Flutter, Xcode) is missing; halt and wait for user confirmation.
*   Always use `sudo` exactly as specified for Xcode configuration commands, as these modify system-level directories.
*   Do not attempt to bypass the Xcode license agreement step; it requires manual user intervention.
*   Assume the user is using the default `/Applications/Xcode.app` path unless they explicitly state otherwise.
