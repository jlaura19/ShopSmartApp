# SmartShop

A Flutter business management app with Firebase Auth, Firestore database, and real-time inventory tracking. Features user authentication (email/password & Google Sign-In), product management, sales tracking, expense logging, and analytics dashboard. Built for small business owners.

## Features

- ✅ **User Authentication**
  - Email/Password registration & login with validation
  - Google Sign-In (iOS/Android/Web)
  - Secure Firebase Auth integration
  - Password strength requirements
  - Automatic auth state management
  - User-friendly error messages

- 📴 **Offline Support**
  - Firestore offline persistence (unlimited cache)
  - Work without internet connection
  - Automatic sync when connection restored
  - Offline indicator banner
  - Connectivity monitoring

- 💱 **Multi-Currency Support**
  - 10 supported currencies (USD, EUR, GBP, JPY, KES, UGX, TZS, NGN, ZAR, INR)
  - Currency selector in settings
  - Locale-aware number formatting
  - Persistent currency preference

- 🔄 **Real-time Database**
  - Cloud Firestore for data persistence
  - Automatic sync across devices
  - Real-time updates
  - Offline-first architecture

- 📊 **Business Management**
  - Product inventory tracking
  - Sales transaction logging
  - Expense management
  - Analytics dashboard with KPI cards
  - Revenue vs expenses charts
  - Top products tracking

- 🎨 **Modern UI**
  - Clean Material Design interface
  - Dark mode support
  - Responsive layouts
  - Smooth navigation
  - Form validation with visual feedback

## Tech Stack

- **Frontend:** Flutter 3.35.6, Dart 3.9.2
- **Backend:** Firebase (Auth, Firestore, Storage)
- **State Management:** Provider
- **Charts:** FL Chart
- **Logging:** Logger
- **Connectivity:** Connectivity Plus
- **Internationalization:** Intl
- **Build Tools:** Gradle, CocoaPods

### Key Dependencies
- `firebase_core: ^3.5.0`
- `firebase_auth: ^5.3.0`
- `cloud_firestore: ^5.4.0`
- `provider: ^6.0.5`
- `fl_chart: ^0.68.0`
- `google_sign_in: ^6.2.1`
- `logger: ^2.0.2`
- `connectivity_plus: ^6.0.5`
- `intl: ^0.19.0`

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
│   ├── auth_service.dart     # Firebase Auth service
│   └── connectivity_service.dart  # Network monitoring
├── models/
│   └── user_model.dart       # User data model
├── providers/
│   ├── user_provider.dart    # User state management
│   ├── currency_provider.dart # Currency state management
│   └── connectivity_provider.dart # Connectivity state
├── widgets/
│   ├── kpi_card.dart         # Dashboard KPI cards
│   └── offline_indicator.dart # Offline status banner
└── utils/
    ├── constants.dart        # App constants
    ├── logger.dart           # Logging utility
    └── currency_formatter.dart # Currency formatting
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

2. **Set up Firebase credentials:**
   
   The `lib/firebase_options.dart` file is not included in the repository for security reasons. You need to create it:
   
   **Option A: Using FlutterFire CLI (Recommended)**
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   
   **Option B: Manual Setup**
   - Copy `lib/firebase_options.dart.example` to `lib/firebase_options.dart`
   - Get credentials from Firebase Console → Project Settings
   - Fill in your actual API keys and project IDs
   
   ⚠️ **NEVER commit `lib/firebase_options.dart` to version control!**

3. **Install dependencies:**
   ```bash
   flutter pub get
   ```

4. **Configure Firebase:**
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place in `android/app/` and `ios/Runner/` respectively

5. **Enable Firebase Authentication:**
   - Firebase Console → Authentication → Sign-in method
   - Enable "Email/Password" provider
   - Enable "Google" provider (for Google Sign-In)

6. **Run the app:**
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

### Change Currency
1. Go to Settings (Profile tab)
2. Select preferred currency from dropdown
3. All amounts update automatically

### Offline Mode
- App works without internet
- Orange banner shows when offline
- Changes sync automatically when online

### Logout
- Tap "Logout" button in Settings

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

### Completed ✅
- [x] User authentication (Email/Password & Google Sign-In)
- [x] Firestore collections (products, sales, expenses)
- [x] Product management screens
- [x] Sales tracking dashboard
- [x] Expense logging
- [x] Analytics with KPI cards and charts
- [x] User profile management
- [x] Dark mode support
- [x] Offline sync capability
- [x] Multi-currency support
- [x] Input validation
- [x] Professional logging system

### In Progress 🚧
- [ ] Complete currency formatting across all screens
- [ ] Add pagination for large datasets
- [ ] Comprehensive error handling

### Planned 📋
- [ ] Push notifications
- [ ] Multi-language support
- [ ] Data export (CSV, PDF)
- [ ] Barcode scanning for products
- [ ] Receipt printing
- [ ] Advanced analytics and reports
- [ ] User roles and permissions

---

**Last Updated:** December 29, 2025  
**Status:** Active Development
