import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for Firebase Authentication and user management
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream controllers for auth state
  final StreamController<User?> _userController =
      StreamController<User?>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  // Public streams
  Stream<User?> get userStream => _userController.stream;
  Stream<String> get errorStream => _errorController.stream;

  // Current user getter
  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null;

  /// Initialize the auth service
  void initialize() {
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      _userController.add(user);
      if (kDebugMode) {
        print('AuthService: Auth state changed - ${user?.email ?? 'No user'}');
      }
    });
  }

  /// Sign up with email and password
  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Create user account
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user != null) {
        // Update display name
        await user.updateDisplayName(name);

        // Create user document in Firestore
        await _createUserDocument(user, name);

        if (kDebugMode) {
          print('AuthService: User signed up successfully - ${user.email}');
        }

        return user;
      }
    } on FirebaseAuthException catch (e) {
      final errorMsg = _getAuthErrorMessage(e);
      _errorController.add(errorMsg);
      if (kDebugMode) {
        print('AuthService: Sign up error - $errorMsg');
      }
    } catch (e) {
      final errorMsg = 'Error inesperado durante el registro: $e';
      _errorController.add(errorMsg);
      if (kDebugMode) {
        print('AuthService: Unexpected sign up error - $e');
      }
    }
    return null;
  }

  /// Sign in with email and password
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user != null) {
        // Update last sign in time
        await _updateUserLastSignIn(user);

        if (kDebugMode) {
          print('AuthService: User signed in successfully - ${user.email}');
        }

        return user;
      }
    } on FirebaseAuthException catch (e) {
      final errorMsg = _getAuthErrorMessage(e);
      _errorController.add(errorMsg);
      if (kDebugMode) {
        print('AuthService: Sign in error - $errorMsg');
      }
    } catch (e) {
      final errorMsg = 'Error inesperado durante el inicio de sesión: $e';
      _errorController.add(errorMsg);
      if (kDebugMode) {
        print('AuthService: Unexpected sign in error - $e');
      }
    }
    return null;
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      if (kDebugMode) {
        print('AuthService: User signed out successfully');
      }
    } catch (e) {
      final errorMsg = 'Error al cerrar sesión: $e';
      _errorController.add(errorMsg);
      if (kDebugMode) {
        print('AuthService: Sign out error - $e');
      }
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (kDebugMode) {
        print('AuthService: Password reset email sent to $email');
      }
      return true;
    } on FirebaseAuthException catch (e) {
      final errorMsg = _getAuthErrorMessage(e);
      _errorController.add(errorMsg);
      if (kDebugMode) {
        print('AuthService: Password reset error - $errorMsg');
      }
      return false;
    } catch (e) {
      final errorMsg = 'Error al enviar email de recuperación: $e';
      _errorController.add(errorMsg);
      if (kDebugMode) {
        print('AuthService: Unexpected password reset error - $e');
      }
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      // Update Firestore document
      await _firestore.collection('users').doc(user.uid).update({
        if (displayName != null) 'name': displayName,
        if (photoURL != null) 'photoURL': photoURL,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('AuthService: User profile updated successfully');
      }
      return true;
    } catch (e) {
      final errorMsg = 'Error al actualizar perfil: $e';
      _errorController.add(errorMsg);
      if (kDebugMode) {
        print('AuthService: Update profile error - $e');
      }
      return false;
    }
  }

  /// Create user document in Firestore
  Future<void> _createUserDocument(User user, String name) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'lastSignInAt': FieldValue.serverTimestamp(),
        'photoURL': user.photoURL,
      });
    } catch (e) {
      if (kDebugMode) {
        print('AuthService: Error creating user document - $e');
      }
      // Don't throw here as the auth was successful
    }
  }

  /// Update user last sign in time
  Future<void> _updateUserLastSignIn(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update({
        'lastSignInAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('AuthService: Error updating last sign in - $e');
      }
      // Don't throw here as the auth was successful
    }
  }

  /// Get user-friendly error message from FirebaseAuthException
  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'La contraseña es muy débil. Debe tener al menos 6 caracteres.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este email.';
      case 'invalid-email':
        return 'El formato del email no es válido.';
      case 'user-not-found':
        return 'No existe una cuenta con este email.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Intenta más tarde.';
      case 'operation-not-allowed':
        return 'Operación no permitida. Contacta al soporte.';
      case 'invalid-credential':
        return 'Credenciales inválidas. Verifica tu email y contraseña.';
      default:
        return 'Error de autenticación: ${e.message ?? e.code}';
    }
  }

  /// Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      if (kDebugMode) {
        print('AuthService: Error getting user data - $e');
      }
      return null;
    }
  }

  /// Dispose of the service
  void dispose() {
    _userController.close();
    _errorController.close();
  }
}
