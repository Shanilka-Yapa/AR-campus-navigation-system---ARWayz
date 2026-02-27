# How to Run ARWayz

This document provides instructions on how to run the ARWayz application in both Android Studio and Visual Studio Code.

## Prerequisites

1.  **Flutter SDK:** Make sure you have the Flutter SDK installed. For instructions on how to install Flutter, see the [official Flutter documentation](https://flutter.dev/docs/get-started/install).
2.  **Android SDK:** Ensure you have the Android SDK installed and configured, along with an Android emulator or a physical device set up for development.
3.  **IDE with Flutter Plugin:** You'll need either Android Studio with the Flutter and Dart plugins, or Visual Studio Code with the Flutter extension.
4.  **Project Dependencies:** Open a terminal in the project's root directory (`arwayz`) and run the following command to fetch the project's dependencies:
    ```bash
    flutter pub get
    ```

## Running in Android Studio

1.  **Open the project:** Open the `arwayz` project directory in Android Studio.
2.  **Install plugins:** Ensure you have the Flutter and Dart plugins installed. You can install them from `File -> Settings -> Plugins`.
3.  **Select a device:** Choose a connected Android device or an emulator from the device dropdown in the toolbar.
4.  **Run the app:** Click the **Run 'main.dart'** button (the green play icon) in the toolbar.

## Running in VS Code

1.  **Open the project:** Open the `arwayz` project folder in Visual Studio Code.
2.  **Install extension:** Make sure you have the official Flutter extension installed from the Extensions view.
3.  **Select a device:** Click on the device name in the bottom-right of the status bar to select a connected device or an emulator.
4.  **Run the app:**
    *   Press `F5` to start debugging.
    *   Alternatively, open the Command Palette (`Ctrl+Shift+P` or `Cmd+Shift+P` on Mac) and type `Flutter: Launch Emulator` to start an emulator, then `Flutter: Run Flutter` to run the app.
