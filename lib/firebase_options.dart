import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// DefaultFirebaseOptions contains Firebase configuration for all platforms.
/// Generated from smartshop-app-juliet Firebase project.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    if (Platform.isAndroid) {
      return android;
    }
    if (Platform.isWindows) {
      return windows;
    }
    throw UnsupportedError('DefaultFirebaseOptions not supported for this platform.');
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDZw9HIKKGstMFQaU9GB-g0mt_Vi9LR6PQ',
    appId: '1:133183948041:android:17fa47c70629e815b7ffd8',
    messagingSenderId: '133183948041',
    projectId: 'smartshop-app-juliet',
    storageBucket: 'smartshop-app-juliet.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDZw9HIKKGstMFQaU9GB-g0mt_Vi9LR6PQ',
    appId: '1:133183948041:web:ca5b0dc5078fe720b7ffd8',
    messagingSenderId: '133183948041',
    projectId: 'smartshop-app-juliet',
    storageBucket: 'smartshop-app-juliet.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDZw9HIKKGstMFQaU9GB-g0mt_Vi9LR6PQ',
    appId: '1:133183948041:web:ca5b0dc5078fe720b7ffd8',
    messagingSenderId: '133183948041',
    projectId: 'smartshop-app-juliet',
    storageBucket: 'smartshop-app-juliet.firebasestorage.app',
  );
}
