import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../utils/logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Register new user
  Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      appLogger.i('User registered successfully: ${result.user?.email}');
      return {'success': true, 'user': result.user, 'error': null};
    } on FirebaseAuthException catch (e) {
      appLogger.e('Registration failed', error: e, stackTrace: StackTrace.current);
      return {'success': false, 'user': null, 'error': _getErrorMessage(e.code)};
    } catch (e) {
      appLogger.e('Unexpected registration error', error: e, stackTrace: StackTrace.current);
      return {'success': false, 'user': null, 'error': 'An unexpected error occurred. Please try again.'};
    }
  }

  // Login existing user
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      appLogger.i('User logged in successfully: ${result.user?.email}');
      return {'success': true, 'user': result.user, 'error': null};
    } on FirebaseAuthException catch (e) {
      appLogger.e('Login failed', error: e, stackTrace: StackTrace.current);
      return {'success': false, 'user': null, 'error': _getErrorMessage(e.code)};
    } catch (e) {
      appLogger.e('Unexpected login error', error: e, stackTrace: StackTrace.current);
      return {'success': false, 'user': null, 'error': 'An unexpected error occurred. Please try again.'};
    }
  }

  // Google Sign-In (works on iOS, Android, and Web)
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        appLogger.w('Google Sign-In canceled by user');
        return {'success': false, 'user': null, 'error': 'Sign-in canceled'};
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential result = await _auth.signInWithCredential(credential);
      appLogger.i('Google Sign-In successful: ${result.user?.email}');
      return {'success': true, 'user': result.user, 'error': null};
    } on FirebaseAuthException catch (e) {
      appLogger.e('Google Sign-In failed', error: e, stackTrace: StackTrace.current);
      return {'success': false, 'user': null, 'error': _getErrorMessage(e.code)};
    } catch (e) {
      appLogger.e('Unexpected Google Sign-In error', error: e, stackTrace: StackTrace.current);
      return {'success': false, 'user': null, 'error': 'Failed to sign in with Google. Please try again.'};
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      appLogger.i('User logged out successfully');
    } catch (e) {
      appLogger.e('Logout error', error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  // Stream for auth state changes
  Stream<User?> get userStream => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Helper method to convert Firebase error codes to user-friendly messages
  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please login instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please contact support.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'user-not-found':
        return 'No account found with this email. Please register first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in method.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}


