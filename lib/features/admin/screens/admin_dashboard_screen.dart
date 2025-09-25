import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_button.dart';
import 'user_management_screen.dart';
import 'content_management_screen.dart';
import 'analytics_screen.dart';
import 'system_settings_screen.dart';
import 'add_hairstyle_screen.dart';
import 'hairstyle_management_screen.dart';
import 'camera_test_screen.dart';
import 'admin_debug_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminService = Provider.of<AdminService>(context, listen: false);
      adminService.loadAppStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Consumer<AdminService>(
        builder: (context, adminService, child) {
          if (adminService.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final stats = adminService.appStats;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.largePadding),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.accent.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.admin_panel_settings,
                        size: 48,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      Text(
                        'Administrator Panel',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        'Manage users, content, and system settings',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.largePadding * 2),

                // Statistics Cards
                Text(
                  'System Overview',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: AppConstants.defaultPadding),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: AppConstants.defaultPadding,
                  mainAxisSpacing: AppConstants.defaultPadding,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard(
                      'Total Users',
                      '${stats['totalUsers'] ?? 0}',
                      Icons.people,
                      AppColors.primary,
                    ),
                    _buildStatCard(
                      'Active Users',
                      '${stats['activeUsers'] ?? 0}',
                      Icons.person_outline,
                      Colors.green,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddHairstyleScreen(),
                          ),
                        ).then((result) {
                          if (result == true) {
                            final adminService = Provider.of<AdminService>(context, listen: false);
                            adminService.loadAppStats();
                          }
                        });
                      },
                      child: _buildStatCard(
                        'Total Styles',
                        '${stats['totalStyles'] ?? 0}',
                        Icons.style,
                        AppColors.accent,
                      ),
                    ),
                    _buildStatCard(
                      'Pending Approval',
                      '${stats['pendingStyles'] ?? 0}',
                      Icons.pending,
                      Colors.orange,
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.largePadding * 2),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: AppConstants.defaultPadding),

                Column(
                  children: [
                    _buildActionTile(
                      'Add New Hairstyle',
                      'Upload new hairstyles to the gallery',
                      Icons.add_photo_alternate,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddHairstyleScreen(),
                          ),
                        ).then((result) {
                          if (result == true) {
                            // Refresh stats if hairstyle was added
                            final adminService = Provider.of<AdminService>(context, listen: false);
                            adminService.loadAppStats();
                          }
                        });
                      },
                    ),
                    _buildActionTile(
                      'User Management',
                      'Manage user accounts and permissions',
                      Icons.people_outline,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserManagementScreen(),
                          ),
                        );
                      },
                    ),
                    _buildActionTile(
                      'Hairstyle Management',
                      'Manage all hairstyles in the system',
                      Icons.style,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HairstyleManagementScreen(),
                          ),
                        );
                      },
                    ),
                    _buildActionTile(
                      'Content Management',
                      'Review and moderate user-generated content',
                      Icons.content_paste,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ContentManagementScreen(),
                          ),
                        );
                      },
                    ),
                    _buildActionTile(
                      'Analytics & Reports',
                      'View detailed analytics and generate reports',
                      Icons.analytics,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AnalyticsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildActionTile(
                      'System Settings',
                      'Configure app settings and notifications',
                      Icons.settings,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SystemSettingsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildActionTile(
                      'Test Camera & Gallery',
                      'Test camera and gallery permissions',
                      Icons.bug_report,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CameraTestScreen(),
                          ),
                        );
                      },
                    ),
                    _buildActionTile(
                      'Admin Debug',
                      'Debug admin functionality and permissions',
                      Icons.settings_applications,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminDebugScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.largePadding),

                // Emergency Actions
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: AppConstants.smallPadding),
                          Text(
                            'Emergency Actions',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      CustomButton(
                        text: 'Send System Notification',
                        onPressed: () => _showSystemNotificationDialog(),
                        backgroundColor: Colors.red,
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(
            icon,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  void _showSystemNotificationDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send System Notification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final adminService = Provider.of<AdminService>(context, listen: false);
              final success = await adminService.sendSystemNotification(
                titleController.text,
                messageController.text,
              );
              
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success 
                        ? 'Notification sent successfully!'
                        : 'Failed to send notification',
                    ),
                  ),
                );
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}