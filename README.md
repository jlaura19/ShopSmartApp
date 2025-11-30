# SmartShop

A Flutter business management app with Firebase Auth, Firestore database, and real-time inventory tracking. Features user authentication (email/password & Google Sign-In), product management, sales tracking, expense logging, and analytics dashboard. Built for small business owners.

## Features

- ✅ **User Authentication**
  - Email/Password registration & login
  - Google Sign-In (iOS/Android ready)
  - Secure Firebase Auth integration
  - Detailed error messages for better UX

- 🔄 **Real-time Database**
  - Cloud Firestore for data persistence
  - Automatic sync across devices
  - Real-time updates

- 📊 **Business Management**
  - Product inventory tracking
  - Sales transaction logging
  - Expense management
  - Analytics dashboard with fl_chart

- 🎨 **Modern UI**
  - Clean Material Design interface
  - Responsive layouts
  - Smooth navigation between screens

## Tech Stack

- **Frontend:** Flutter 3.35.6, Dart 3.9.2
- **Backend:** Firebase (Auth, Firestore, Storage)
- **State Management:** Provider
- **Charts:** FL Chart
- **Build Tools:** Gradle, CocoaPods

## Project Structure

```
lib/
├── main.dart                 # App entry point, Firebase initialization
├── firebase_options.dart     # Platform-specific Firebase config
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart      # Login UI with Google Sign-In button
│   │   └── register_screen.dart    # User registration
│   └── home/
│       └── home_screen.dart        # Dashboard after login
├── services/
│   └── auth_service.dart     # Firebase Auth service
├── models/
│   └── user_model.dart       # User data model
├── providers/
│   └── auth_provider.dart    # State management for auth
├── widgets/
│   └── custom_button.dart    # Reusable UI components
└── utils/
    └── constants.dart        # App constants
```

## Getting Started

### Prerequisites

- Flutter SDK: 3.35.6+ ([Install Flutter](https://flutter.dev/docs/get-started/install))
- Dart SDK: 3.9.2+ (included with Flutter)
- Android SDK: API 21+
- Firebase project ([Create here](https://console.firebase.google.com))

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/jlaura19/ShopSmartApp.git
   cd ShopSmartApp
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place in `android/app/` and `ios/Runner/` respectively

4. **Enable Firebase Authentication:**
   - Firebase Console → Authentication → Sign-in method
   - Enable "Email/Password" provider

5. **Run the app:**
   ```bash
   flutter run
   ```

## Configuration

### Firebase Setup

1. **Enable Email/Password Auth:**
   - Firebase Console → Authentication → Sign-in method
   - Toggle "Email/Password" to ON

2. **Configure Android SHA1 (for Google Sign-In):**
   ```bash
   cd android && ./gradlew signingReport
   ```
   - Add SHA1 to Firebase Console → Project Settings

## Usage

### Register
1. Tap "Don't have an account? Register"
2. Enter email and password
3. Tap "Register"

### Login
1. Enter credentials
2. Tap "Login" or "Sign in with Google"
3. Access Home screen on success

### Logout
- Tap "Logout" button on Home screen

## Build

### Android APK
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios
```

### Web
```bash
flutter build web
```

## Troubleshooting

### Firebase CONFIGURATION_NOT_FOUND
- Ensure `google-services.json` is in `android/app/`
- Verify Email/Password auth is enabled in Firebase Console

### Gradle Out of Memory
- Edit `android/gradle.properties`: `org.gradle.jvmargs=-Xmx4g`

### Wireless ADB Connection Failed
- Ensure same WiFi network
- Enable Developer Mode on Windows (Settings → System → For developers)

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## Author

**jlaura19** - [GitHub](https://github.com/jlaura19)

## Roadmap

- [ ] Firestore collections (products, sales, expenses)
- [ ] Product management screens
- [ ] Sales tracking dashboard
- [ ] Expense logging
- [ ] Analytics with charts
- [ ] User profile management
- [ ] Dark mode support
- [ ] Offline sync capability
- [ ] Push notifications
- [ ] Multi-language support

---

**Last Updated:** November 30, 2025  
**Status:** Active Development
