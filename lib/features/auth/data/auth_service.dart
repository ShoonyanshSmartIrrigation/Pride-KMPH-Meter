import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class AuthService {
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
  bool get isAnonymous => currentUser?.isAnonymous ?? true;

  /// Ensures user is signed in (anonymously if needed) for Firestore permissions
  Future<void> ensureSignedIn() async {
    if (!isFirebaseAvailable) return;
    try {
      if (currentUser == null) {
        await signInAnonymously();
      }
    } catch (e) {
      debugPrint('[AuthService] Auto sign-in error: $e');
    }
  }

  /// Signs in anonymously for seamless out-of-the-box hardware testing
  Future<UserCredential?> signInAnonymously() async {
    if (!isFirebaseAvailable) return null;
    try {
      final credential = await FirebaseAuth.instance.signInAnonymously();
      debugPrint(
        '[AuthService] Signed in anonymously with UID: ${credential.user?.uid}',
      );
      return credential;
    } catch (e) {
      debugPrint('[AuthService] Anonymous sign-in failed: $e');
      return null;
    }
  }

  /// Links or upgrades account with Email & Password
  Future<UserCredential?> linkWithEmailPassword(
    String email,
    String password,
  ) async {
    if (!isFirebaseAvailable) return null;
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      if (currentUser != null && currentUser!.isAnonymous) {
        return await currentUser!.linkWithCredential(credential);
      } else {
        return await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
    } catch (e) {
      debugPrint('[AuthService] Account upgrade error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (!isFirebaseAvailable) return;
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
  }
}
