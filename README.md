# Digital Khata

A Flutter application designed to manage digital ledgers and transaction records efficiently.

## Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

Make sure you have the following installed on your system:
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (Latest stable version recommended)
* [Dart SDK](https://dart.dev/get-started)
* Android Studio or VS Code with Flutter & Dart extensions
* An Android emulator or a physical Android device with **USB Debugging** enabled

### Installation & Setup

Install dependencies:
    Bash
    
    flutter pub get

📱 Running on Android Devices
Step 1: Connect your Android Device / Start Emulator

  Physical Device: Enable Developer Options and USB Debugging on your phone, then connect it to your PC via a USB cable. Run flutter devices in your terminal to verify your device is recognized.

  Emulator: Open Android Studio, launch the Device Manager, and start an Android Virtual Device (AVD).

Step 2: Run the App

Execute the following command in your terminal from the root directory:
    Bash
    
    flutter run
    
If you have multiple devices connected, specify your target device:
    Bash
    
    flutter run -d <device_id>
    flutter run -d chrome

Step 3: Build an Android APK (Optional)

To generate a release-ready APK file for testing on Android:
    Bash
    
    flutter build apk --release

The output APK will be generated at build/app/outputs/flutter-apk/app-release.apk.


<FollowUp label="Want me to show you how to configure Firebase or local storage for this project?" query="Yes, show me how to configure Firebase or local storage for this digital khata Flutter project."/>
