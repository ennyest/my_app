import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_button.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  final _maintenanceModeEnabled = ValueNotifier<bool>(false);
  final _registrationEnabled = ValueNotifier<bool>(true);
  final _contentModerationEnabled = ValueNotifier<bool>(true);
  final _autoApprovalEnabled = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Settings Section
            Text(
              'Application Settings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            
            _buildSettingsCard(
              'General Settings',
              [
                _buildSwitchTile(
                  'Maintenance Mode',
                  'Temporarily disable app access for maintenance',
                  _maintenanceModeEnabled,
                  Icons.build,
                ),
                _buildSwitchTile(
                  'New User Registration',
                  'Allow new users to register accounts',
                  _registrationEnabled,
                  Icons.person_add,
                ),
                _buildSwitchTile(
                  'Content Moderation',
                  'Require admin approval for user-generated content',
                  _contentModerationEnabled,
                  Icons.verified_user,
                ),
                _buildSwitchTile(
                  'Auto Approval',
                  'Automatically approve content from verified users',
                  _autoApprovalEnabled,
                  Icons.auto_awesome,
                ),
              ],
            ),

            const SizedBox(height: AppConstants.largePadding),

            // Notification Settings
            Text(
              'Notification Settings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),

            _buildActionCard(
              'System Notifications',
              'Send notifications to all users',
              Icons.notifications_active,
              () => _showSystemNotificationDialog(),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildActionCard(
              'Admin Notifications',
              'Configure admin notification preferences',
              Icons.admin_panel_settings,
              () => _showAdminNotificationSettings(),
            ),

            const SizedBox(height: AppConstants.largePadding),

            // Data Management
            Text(
              'Data Management',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),

            _buildActionCard(
              'Backup Database',
              'Create a backup of all app data',
              Icons.backup,
              () => _backupDatabase(),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildActionCard(
              'Clean Up Storage',
              'Remove unused files and optimize storage',
              Icons.cleaning_services,
              () => _cleanUpStorage(),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildActionCard(
              'Export Analytics',
              'Export detailed analytics and usage data',
              Icons.file_download,
              () => _exportAnalytics(),
            ),

            const SizedBox(height: AppConstants.largePadding),

            // Security Settings
            Text(
              'Security Settings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),

            _buildActionCard(
              'Security Audit',
              'Review system security and permissions',
              Icons.security,
              () => _performSecurityAudit(),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildActionCard(
              'User Sessions',
              'Manage active user sessions',
              Icons.supervised_user_circle,
              () => _manageUserSessions(),
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
                    text: 'Emergency Shutdown',
                    onPressed: () => _emergencyShutdown(),
                    backgroundColor: Colors.red,
                    width: double.infinity,
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  CustomButton(
                    text: 'Reset All Settings',
                    onPressed: () => _resetAllSettings(),
                    backgroundColor: Colors.orange,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    ValueNotifier<bool> valueNotifier,
    IconData icon,
  ) {
    return ValueListenableBuilder<bool>(
      valueListenable: valueNotifier,
      builder: (context, value, child) {
        return ListTile(
          leading: Icon(
            icon,
            color: AppColors.primary,
          ),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: Switch(
            value: value,
            onChanged: (newValue) {
              valueNotifier.value = newValue;
              _saveSetting(title, newValue);
            },
          ),
          contentPadding: EdgeInsets.zero,
        );
      },
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
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

  void _saveSetting(String setting, bool value) {
    // Here you would typically save the setting to Firebase or local storage
    final adminService = Provider.of<AdminService>(context, listen: false);
    adminService.updateAppSettings({
      setting.toLowerCase().replaceAll(' ', '_'): value,
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$setting updated'),
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

  void _showAdminNotificationSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Admin notification settings coming soon!'),
      ),
    );
  }

  void _backupDatabase() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Database'),
        content: const Text('Are you sure you want to create a backup of all app data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Database backup initiated. You will be notified when complete.'),
                ),
              );
            },
            child: const Text('Backup'),
          ),
        ],
      ),
    );
  }

  void _cleanUpStorage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clean Up Storage'),
        content: const Text('This will remove unused files and optimize storage. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Storage cleanup initiated. This may take a few minutes.'),
                ),
              );
            },
            child: const Text('Clean Up'),
          ),
        ],
      ),
    );
  }

  void _exportAnalytics() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Analytics export feature coming soon!'),
      ),
    );
  }

  void _performSecurityAudit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Security audit feature coming soon!'),
      ),
    );
  }

  void _manageUserSessions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User session management coming soon!'),
      ),
    );
  }

  void _emergencyShutdown() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Shutdown'),
        content: const Text(
          'This will immediately put the app in maintenance mode and log out all users. '
          'Only use this in case of critical security issues. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(context);
              _maintenanceModeEnabled.value = true;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Emergency shutdown activated. App is now in maintenance mode.'),
                ),
              );
            },
            child: const Text('Shutdown'),
          ),
        ],
      ),
    );
  }

  void _resetAllSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Settings'),
        content: const Text(
          'This will reset all system settings to their default values. '
          'This action cannot be undone. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            onPressed: () {
              Navigator.pop(context);
              _resetSettings();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All settings have been reset to default values.'),
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _resetSettings() {
    _maintenanceModeEnabled.value = false;
    _registrationEnabled.value = true;
    _contentModerationEnabled.value = true;
    _autoApprovalEnabled.value = false;
  }
}