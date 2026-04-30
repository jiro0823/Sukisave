# SukiSave

SukiSave is a Flutter mobile app for discovering discounted local food and essentials, adding products to a cart, checking out selected items, and viewing past purchases. The app uses local SQLite storage for user accounts and order history.

## Tech Stack

- Flutter / Dart
- Material UI
- SQLite via `sqflite`
- `shared_preferences` for session storage
- `flutter_map` for map UI

## Requirements

- Flutter SDK installed
- Android Studio or VS Code with Flutter/Dart extensions
- Android emulator, iOS simulator, or a physical device
- Git

Check your local setup:

```bash
flutter doctor
```

## Installation

Clone the repository:

```bash
git clone https://github.com/jiro0823/Sukisave.git
cd Sukisave
```

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

## Useful Commands

```bash
flutter analyze
flutter test
flutter clean
flutter pub get
```

## Project Notes

- Do not commit generated folders such as `build/`, `.dart_tool/`, or `node_modules/`.
- Local app data is stored on-device using SQLite and shared preferences.
- If the app database schema changes during development, uninstall the app or clear app storage before testing again.
