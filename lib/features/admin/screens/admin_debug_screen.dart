import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_button.dart';

class AdminDebugScreen extends StatefulWidget {
  const AdminDebugScreen({super.key});

  @override
  State<AdminDebugScreen> createState() => _AdminDebugScreenState();
}

class _AdminDebugScreenState extends State<AdminDebugScreen> {
  Map<String, dynamic> debugInfo = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    setState(() => isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.userModel;

      debugInfo = {
        'isAuthenticated': authService.isAuthenticated,
        'userEmail': authService.user?.email ?? 'No Email',
        'userUid': authService.user?.uid ?? 'No UID',
        'userRole': user?.role?.displayName ?? 'No Role',
        'isAdmin': user?.isAdmin ?? false,
        'isAdminEmail': AdminService.isAdminEmail(authService.user?.email ?? ''),
        'userModelExists': user != null,
        'userModelData': user?.toFirestore(),
        'adminServiceExists': true,
      };

      // Test Firestore connection
      try {
        final testDoc = await FirebaseFirestore.instance
            .collection('test')
            .doc('connection')
            .get();
        debugInfo['firestoreConnected'] = true;
      } catch (e) {
        debugInfo['firestoreConnected'] = false;
        debugInfo['firestoreError'] = e.toString();
      }

      // Test hairstyles collection access
      try {
        final hairstylesQuery = await FirebaseFirestore.instance
            .collection(AppConstants.hairstylesCollection)
            .limit(1)
            .get();
        debugInfo['hairstylesAccessible'] = true;
        debugInfo['hairstylesCount'] = hairstylesQuery.docs.length;
      } catch (e) {
        debugInfo['hairstylesAccessible'] = false;
        debugInfo['hairstylesError'] = e.toString();
      }

    } catch (e) {
      debugInfo['error'] = e.toString();
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Debug'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDebugInfo,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Debug Information',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),

                  // Authentication Status
                  _buildSection('Authentication', {
                    'Is Authenticated': debugInfo['isAuthenticated']?.toString() ?? 'Unknown',
                    'User Email': debugInfo['userEmail']?.toString() ?? 'Unknown',
                    'User UID': debugInfo['userUid']?.toString() ?? 'Unknown',
                    'User Role': debugInfo['userRole']?.toString() ?? 'Unknown',
                    'Is Admin': debugInfo['isAdmin']?.toString() ?? 'Unknown',
                    'Is Admin Email': debugInfo['isAdminEmail']?.toString() ?? 'Unknown',
                    'User Model Exists': debugInfo['userModelExists']?.toString() ?? 'Unknown',
                  }),

                  const SizedBox(height: AppConstants.defaultPadding),

                  // Firebase Status
                  _buildSection('Firebase', {
                    'Firestore Connected': debugInfo['firestoreConnected']?.toString() ?? 'Unknown',
                    'Hairstyles Accessible': debugInfo['hairstylesAccessible']?.toString() ?? 'Unknown',
                    'Hairstyles Count': debugInfo['hairstylesCount']?.toString() ?? 'Unknown',
                  }),

                  if (debugInfo['firestoreError'] != null) ...[
                    const SizedBox(height: AppConstants.smallPadding),
                    Container(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Firestore Error:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          Text(debugInfo['firestoreError'].toString()),
                        ],
                      ),
                    ),
                  ],

                  if (debugInfo['hairstylesError'] != null) ...[
                    const SizedBox(height: AppConstants.smallPadding),
                    Container(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hairstyles Error:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          Text(debugInfo['hairstylesError'].toString()),
                        ],
                      ),
                    ),
                  ],

                  if (debugInfo['error'] != null) ...[
                    const SizedBox(height: AppConstants.smallPadding),
                    Container(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'General Error:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          Text(debugInfo['error'].toString()),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: AppConstants.largePadding),

                  // Test Actions
                  Text(
                    'Test Actions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),

                  CustomButton(
                    text: 'Test Admin Functions',
                    onPressed: _testAdminFunctions,
                    backgroundColor: AppColors.primary,
                    width: double.infinity,
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  CustomButton(
                    text: 'Force Admin Role',
                    onPressed: _forceAdminRole,
                    backgroundColor: Colors.orange,
                    width: double.infinity,
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  CustomButton(
                    text: 'Test Hairstyle Upload',
                    onPressed: _testHairstyleUpload,
                    backgroundColor: Colors.green,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSection(String title, Map<String, String> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outline),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          ...data.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    '${entry.key}:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      color: entry.value.contains('true') 
                          ? Colors.green 
                          : entry.value.contains('false') 
                              ? Colors.red 
                              : null,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Future<void> _testAdminFunctions() async {
    try {
      final adminService = Provider.of<AdminService>(context, listen: false);
      await adminService.loadAppStats();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin functions test completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Admin functions test failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _forceAdminRole() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.user;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .update({
          'role': 'admin',
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Admin role forced successfully! Please restart the app.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Force admin role failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _testHairstyleUpload() async {
    try {
      // Test creating a simple hairstyle document
      await FirebaseFirestore.instance
          .collection(AppConstants.hairstylesCollection)
          .add({
        'name': 'Test Hairstyle',
        'description': 'This is a test hairstyle created by the debug screen',
        'imageUrl': 'https://via.placeholder.com/300',
        'category': 'test',
        'tags': ['test', 'debug'],
        'difficulty': 'easy',
        'length': 'medium',
        'isPreloaded': true,
        'uploadedBy': Provider.of<AuthService>(context, listen: false).user?.uid,
        'likes': 0,
        'createdAt': Timestamp.now(),
        'isApproved': true,
        'isRejected': false,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test hairstyle uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test hairstyle upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}