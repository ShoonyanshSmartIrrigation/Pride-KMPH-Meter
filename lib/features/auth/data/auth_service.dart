import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final SharedPreferences? _prefs;

  AuthService({SharedPreferences? prefs}) : _prefs = prefs;

  static const String _rememberMeKey = 'auth_remember_me';
  static const String _savedEmailKey = 'auth_saved_email';

  bool get isFirebaseAvailable {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  User? get currentUser {
    if (!isFirebaseAvailable) return null;
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }

  String get currentUserId {
    return currentUser?.uid ?? 'local_device_user';
  }

  bool get isAuthenticated => currentUser != null;
  bool get isAnonymous => currentUser?.isAnonymous ?? false;

  Stream<User?> get authStateChanges {
    if (!isFirebaseAvailable) {
      return Stream.value(null);
    }
    return FirebaseAuth.instance.authStateChanges();
  }

  bool get rememberMe => _prefs?.getBool(_rememberMeKey) ?? true;

  Future<void> setRememberMe(bool value) async {
    await _prefs?.setBool(_rememberMeKey, value);
  }

  String get savedEmail => _prefs?.getString(_savedEmailKey) ?? '';

  Future<void> setSavedEmail(String email) async {
    await _prefs?.setString(_savedEmailKey, email);
  }

  /// Sign In with Email & Password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (!isFirebaseAvailable) {
      throw 'Firebase is not initialized. Please check network connection.';
    }

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (rememberMe) {
        await setSavedEmail(email.trim());
      } else {
        await setSavedEmail('');
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw 'Sign in failed: $e';
    }
  }

  /// Register / Create Account with Email, Password & Full Name
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    if (!isFirebaseAvailable) {
      throw 'Firebase is not initialized. Please check network connection.';
    }

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = credential.user;
      if (user != null) {
        // Update user display name
        await user.updateDisplayName(fullName.trim());

        // Try writing user record into Cloud Firestore
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'uid': user.uid,
            'fullName': fullName.trim(),
            'email': email.trim(),
            'createdAt': FieldValue.serverTimestamp(),
            'lastLogin': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (dbError) {
          debugPrint('[AuthService] Firestore user record warning: $dbError');
        }
      }

      if (rememberMe) {
        await setSavedEmail(email.trim());
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw 'Registration failed: $e';
    }
  }

  /// Send password reset link to user's email
  Future<void> sendPasswordResetEmail(String email) async {
    if (!isFirebaseAvailable) {
      throw 'Firebase is not initialized. Please check network connection.';
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw 'Could not send reset email: $e';
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    if (!isFirebaseAvailable) return;
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('[AuthService] Sign out error: $e');
    }
  }

  /// Ensure signed in anonymously if needed for offline / test runs
  Future<void> ensureSignedIn() async {
    if (!isFirebaseAvailable) return;
    try {
      if (currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
    } catch (e) {
      debugPrint('[AuthService] Anonymous sign-in warning: $e');
    }
  }

  /// Friendly human-readable error messages for Firebase Auth exception codes
  String _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address. Please sign up first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again or tap Forgot Password.';
      case 'invalid-credential':
        return 'Invalid email or password credentials. Please verify your details.';
      case 'invalid-email':
        return 'The email address format is not valid.';
      case 'email-already-in-use':
        return 'An account already exists for this email. Please log in.';
      case 'weak-password':
        return 'Password must be at least 6 characters long.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many unsuccessful attempts. Please try again in a few minutes.';
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet connection.';
      case 'operation-not-allowed':
        return 'Email/Password sign in is currently not enabled in Firebase Console.';
      default:
        return e.message ?? 'An authentication error occurred (${e.code}).';
    }
  }
}
