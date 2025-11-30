import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Register new user
  Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return {'success': true, 'user': result.user, 'error': null};
    } on FirebaseAuthException catch (e) {
      print("Registration Error: ${e.code} - ${e.message}");
      return {'success': false, 'user': null, 'error': e.message ?? e.code};
    } catch (e) {
      print("Registration Error: $e");
      return {'success': false, 'user': null, 'error': e.toString()};
    }
  }

  // Login existing user
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return {'success': true, 'user': result.user, 'error': null};
    } on FirebaseAuthException catch (e) {
      print("Login Error: ${e.code} - ${e.message}");
      return {'success': false, 'user': null, 'error': e.message ?? e.code};
    } catch (e) {
      print("Login Error: $e");
      return {'success': false, 'user': null, 'error': e.toString()};
    }
  }

  // Google Sign-In (using Firebase built-in)
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Create a new credential with Google OAuth
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      
      final result = await _auth.signInWithPopup(googleProvider);
      return {'success': true, 'user': result.user, 'error': null};
    } on FirebaseAuthException catch (e) {
      print("Google Sign-In Error: ${e.code} - ${e.message}");
      return {'success': false, 'user': null, 'error': e.message ?? e.code};
    } catch (e) {
      print("Google Sign-In Error: $e");
      return {'success': false, 'user': null, 'error': e.toString()};
    }
  }

  // Logout user
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Stream for auth state changes
  Stream<User?> get userStream => _auth.authStateChanges();
}

