import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../utils/logger.dart';

/// Provider for managing user authentication state and user data
class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = false;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _firebaseUser != null;

  UserProvider() {
    _initAuthListener();
  }

  /// Initialize auth state listener
  void _initAuthListener() {
    _authService.userStream.listen((User? user) async {
      _firebaseUser = user;
      
      if (user != null) {
        appLogger.i('Auth state changed: User logged in - ${user.email}');
        await _loadUserData(user.uid);
      } else {
        appLogger.i('Auth state changed: User logged out');
        _userModel = null;
      }
      
      notifyListeners();
    });
  }

  /// Load user data from Firestore
  Future<void> _loadUserData(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _userModel = await _firestoreService.getUser(userId);
      
      // If user document doesn't exist, create it
      if (_userModel == null && _firebaseUser != null) {
        appLogger.i('Creating new user document for ${_firebaseUser!.email}');
        _userModel = UserModel(
          uid: userId,
          email: _firebaseUser!.email ?? '',
          displayName: _firebaseUser!.displayName,
          profileImageUrl: _firebaseUser!.photoURL,
          preferredCurrency: 'USD', // Default currency
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _firestoreService.createUser(_userModel!);
      }

      appLogger.d('User data loaded: ${_userModel?.email}');
    } catch (e) {
      appLogger.e('Error loading user data', error: e, stackTrace: StackTrace.current);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh user data from Firestore
  Future<void> refreshUserData() async {
    if (_firebaseUser != null) {
      await _loadUserData(_firebaseUser!.uid);
    }
  }

  /// Update user profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    if (_firebaseUser == null) return false;

    try {
      _isLoading = true;
      notifyListeners();

      await _firestoreService.updateUser(_firebaseUser!.uid, {
        ...data,
        'updatedAt': DateTime.now(),
      });

      await refreshUserData();
      appLogger.i('User profile updated successfully');
      return true;
    } catch (e) {
      appLogger.e('Error updating profile', error: e, stackTrace: StackTrace.current);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _authService.logout();
      _firebaseUser = null;
      _userModel = null;
      notifyListeners();
    } catch (e) {
      appLogger.e('Error during logout', error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }
}
