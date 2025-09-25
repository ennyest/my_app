import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/user_model.dart';
import '../../shared/models/hairstyle_model.dart';
import '../constants/app_constants.dart';
import 'data_initialization_service.dart';

class AdminService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = false;
  List<UserModel> _allUsers = [];
  List<HairstyleModel> _pendingStyles = [];
  Map<String, dynamic> _appStats = {};

  bool get isLoading => _isLoading;
  List<UserModel> get allUsers => _allUsers;
  List<HairstyleModel> get pendingStyles => _pendingStyles;
  Map<String, dynamic> get appStats => _appStats;

  // Admin Constants
  static const String adminEmail = 'eniolaakande04@gmail.com';

  // User Management
  Future<void> loadAllUsers() async {
    try {
      _setLoading(true);
      final QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .orderBy('createdAt', descending: true)
          .get();

      _allUsers = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading users: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> promoteToAdmin(String userId) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({'role': 'admin'});
      
      await loadAllUsers(); // Refresh the list
      return true;
    } catch (e) {
      debugPrint('Error promoting user to admin: $e');
      return false;
    }
  }

  Future<bool> demoteFromAdmin(String userId) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({'role': 'user'});
      
      await loadAllUsers(); // Refresh the list
      return true;
    } catch (e) {
      debugPrint('Error demoting user from admin: $e');
      return false;
    }
  }

  Future<bool> toggleUserActiveStatus(String userId, bool isActive) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({'isActive': isActive});
      
      await loadAllUsers(); // Refresh the list
      return true;
    } catch (e) {
      debugPrint('Error updating user status: $e');
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      // Delete user document
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .delete();
      
      // Delete user's galleries
      final galleriesQuery = await _firestore
          .collection(AppConstants.userGalleriesCollection)
          .where('userId', isEqualTo: userId)
          .get();
      
      for (var doc in galleriesQuery.docs) {
        await doc.reference.delete();
      }
      
      await loadAllUsers(); // Refresh the list
      return true;
    } catch (e) {
      debugPrint('Error deleting user: $e');
      return false;
    }
  }

  // Content Management
  Future<void> loadPendingStyles() async {
    try {
      _setLoading(true);
      final QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.hairstylesCollection)
          .where('isApproved', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      _pendingStyles = snapshot.docs
          .map((doc) => HairstyleModel.fromFirestore(doc))
          .toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading pending styles: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> approveHairstyle(String styleId) async {
    try {
      await _firestore
          .collection(AppConstants.hairstylesCollection)
          .doc(styleId)
          .update({
        'isApproved': true,
        'approvedAt': Timestamp.now(),
      });
      
      await loadPendingStyles(); // Refresh the list
      return true;
    } catch (e) {
      debugPrint('Error approving hairstyle: $e');
      return false;
    }
  }

  Future<bool> rejectHairstyle(String styleId, String reason) async {
    try {
      await _firestore
          .collection(AppConstants.hairstylesCollection)
          .doc(styleId)
          .update({
        'isRejected': true,
        'rejectionReason': reason,
        'rejectedAt': Timestamp.now(),
      });
      
      await loadPendingStyles(); // Refresh the list
      return true;
    } catch (e) {
      debugPrint('Error rejecting hairstyle: $e');
      return false;
    }
  }

  Future<bool> deleteHairstyle(String styleId) async {
    try {
      await _firestore
          .collection(AppConstants.hairstylesCollection)
          .doc(styleId)
          .delete();
      
      await loadPendingStyles(); // Refresh the list
      return true;
    } catch (e) {
      debugPrint('Error deleting hairstyle: $e');
      return false;
    }
  }

  // Analytics and Statistics
  Future<void> loadAppStats() async {
    try {
      _setLoading(true);
      
      // Check if we need to initialize sample data
      if (await DataInitializationService.needsInitialization()) {
        debugPrint('Initializing sample data for new installation...');
        await DataInitializationService.initializeSampleData();
      }
      
      // Get user statistics
      final usersSnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .get();
      
      final totalUsers = usersSnapshot.docs.length;
      final activeUsers = usersSnapshot.docs
          .where((doc) => (doc.data() as Map<String, dynamic>)['isActive'] == true)
          .length;
      final adminUsers = usersSnapshot.docs
          .where((doc) => (doc.data() as Map<String, dynamic>)['role'] == 'admin')
          .length;

      // Get hairstyle statistics
      final stylesSnapshot = await _firestore
          .collection(AppConstants.hairstylesCollection)
          .get();
      
      final totalStyles = stylesSnapshot.docs.length;
      final approvedStyles = stylesSnapshot.docs
          .where((doc) => (doc.data() as Map<String, dynamic>)['isApproved'] == true)
          .length;
      final pendingStyles = stylesSnapshot.docs
          .where((doc) => (doc.data() as Map<String, dynamic>)['isApproved'] == false)
          .length;

      // Get gallery statistics
      final galleriesSnapshot = await _firestore
          .collection(AppConstants.userGalleriesCollection)
          .get();
      
      final totalGalleries = galleriesSnapshot.docs.length;

      _appStats = {
        'totalUsers': totalUsers,
        'activeUsers': activeUsers,
        'adminUsers': adminUsers,
        'totalStyles': totalStyles,
        'approvedStyles': approvedStyles,
        'pendingStyles': pendingStyles,
        'totalGalleries': totalGalleries,
      };
      
      debugPrint('App stats loaded: $_appStats');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading app stats: $e');
      // Set default stats if there's an error
      _appStats = {
        'totalUsers': 0,
        'activeUsers': 0,
        'adminUsers': 0,
        'totalStyles': 0,
        'approvedStyles': 0,
        'pendingStyles': 0,
        'totalGalleries': 0,
      };
    } finally {
      _setLoading(false);
    }
  }

  // System Management
  Future<bool> sendSystemNotification(String title, String message, {List<String>? userIds}) async {
    try {
      final notification = {
        'title': title,
        'message': message,
        'createdAt': Timestamp.now(),
        'isSystemNotification': true,
        'targetUsers': userIds ?? [], // Empty array means all users
      };

      await _firestore
          .collection('systemNotifications')
          .add(notification);
      
      return true;
    } catch (e) {
      debugPrint('Error sending system notification: $e');
      return false;
    }
  }

  Future<bool> updateAppSettings(Map<String, dynamic> settings) async {
    try {
      await _firestore
          .collection('appSettings')
          .doc('general')
          .set(settings, SetOptions(merge: true));
      
      return true;
    } catch (e) {
      debugPrint('Error updating app settings: $e');
      return false;
    }
  }

  // Utility Methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<bool> initializeAdmin(String email) async {
    try {
      // Find user by email
      final QuerySnapshot userQuery = await _firestore
          .collection(AppConstants.usersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        final userDoc = userQuery.docs.first;
        await userDoc.reference.update({'role': 'admin'});
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error initializing admin: $e');
      return false;
    }
  }

  // Check if user is admin by email
  static bool isAdminEmail(String email) {
    return email.toLowerCase() == adminEmail.toLowerCase();
  }
}