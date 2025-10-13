# SmartShop (scaffold)

This folder contains a scaffold for the SmartShop Flutter app.

What I created:
- `lib/main.dart` — app entry
- `lib/screens/auth/login_screen.dart` — simple login screen
- `lib/firebase_options.dart` — placeholder (generate with FlutterFire)
- `pubspec.yaml` — dependencies added
- basic `lib/` modular folders: models, services, providers, widgets, utils

Notes & next steps:
1. Install the Flutter SDK and add it to your PATH (required to run Flutter commands).
2. From this folder run:

```powershell
flutter pub get
flutter run
```

3. To enable Firebase, run the FlutterFire CLI in this project to generate `lib/firebase_options.dart`:

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

4. Alternatively, if you prefer the official generated Android/iOS files, run `flutter create .` inside this folder after installing Flutter to generate platform folders properly.

If you'd like, I can initialize git here and create the remaining starter files (models/services/widgets). Just say the word.
