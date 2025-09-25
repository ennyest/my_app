import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/user_model.dart';
import '../constants/app_constants.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    if (user != null) {
      await _loadUserModel();
    } else {
      _userModel = null;
    }
    notifyListeners();
  }

  Future<void> _loadUserModel() async {
    if (_user == null) return;
    
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_user!.uid)
          .get();
      
      if (doc.exists) {
        _userModel = UserModel.fromFirestore(doc);
      } else {
        // Create new user model if it doesn't exist
        await _createUserModel();
      }
    } catch (e) {
      debugPrint('Error loading user model: $e');
    }
  }

  Future<void> _createUserModel() async {
    if (_user == null) return;

    final userModel = UserModel(
      userId: _user!.uid,
      email: _user!.email ?? '',
      displayName: _user!.displayName ?? '',
      profileImage: _user!.photoURL,
      preferences: UserPreferences(
        hairType: 'straight',
        preferredLength: 'medium',
        colorPreferences: [],
        faceShape: 'oval',
        skinTone: 'neutral',
      ),
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
    );

    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_user!.uid)
          .set(userModel.toFirestore());
      
      _userModel = userModel;
    } catch (e) {
      debugPrint('Error creating user model: $e');
    }
  }

  Future<String?> signInWithEmail(String email, String password) async {
    try {
      _setLoading(true);
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _getAuthErrorMessage(e);
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> signUpWithEmail(String email, String password, String displayName) async {
    try {
      _setLoading(true);
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        await credential.user!.updateDisplayName(displayName);
        await _createUserModel();
      }
      
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _getAuthErrorMessage(e);
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> signInWithGoogle() async {
    // TODO: Implement Google Sign-In
    // This would require google_sign_in package
    return 'Google Sign-In not implemented yet';
  }

  Future<String?> signInWithApple() async {
    // TODO: Implement Apple Sign-In
    // This would require sign_in_with_apple package
    return 'Apple Sign-In not implemented yet';
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  Future<void> updateUserPreferences(UserPreferences preferences) async {
    if (_userModel == null) return;

    try {
      _setLoading(true);
      final updatedUser = _userModel!.copyWith(
        preferences: preferences,
        lastActive: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_user!.uid)
          .update(updatedUser.toFirestore());

      _userModel = updatedUser;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating user preferences: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? profileImage,
  }) async {
    if (_userModel == null) return;

    try {
      _setLoading(true);
      final updatedUser = _userModel!.copyWith(
        displayName: displayName ?? _userModel!.displayName,
        profileImage: profileImage ?? _userModel!.profileImage,
        lastActive: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_user!.uid)
          .update(updatedUser.toFirestore());

      _userModel = updatedUser;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteAccount() async {
    if (_user == null) return;

    try {
      _setLoading(true);
      // Delete user data from Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_user!.uid)
          .delete();
      
      // Delete user account
      await _user!.delete();
    } catch (e) {
      debugPrint('Error deleting account: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Invalid email address. Please check your email.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
