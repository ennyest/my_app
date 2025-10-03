import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/services/admin_view_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_button.dart';
import '../widgets/profile_option_tile.dart';
import '../../admin/screens/admin_dashboard_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Consumer2<AuthService, AdminViewService>(
        builder: (context, authService, adminViewService, child) {
          // Handle loading state
          if (authService.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading profile...'),
                ],
              ),
            );
          }

          // Handle no user state
          if (authService.user == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No user logged in'),
                ],
              ),
            );
          }

          // Handle missing user model (create fallback)
          if (authService.userModel == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning, size: 64, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text('Profile data not found'),
                  const Text('This might be a temporary issue.'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          // Try to reload user data
                          final user = authService.user;
                          if (user != null) {
                            // Force reload user model
                            authService.notifyListeners();
                          }
                        },
                        child: const Text('Retry'),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton(
                        onPressed: () async {
                          await authService.signOut();
                        },
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          final user = authService.userModel!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.largePadding),
            child: Column(
              children: [
                // Profile Header
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
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        backgroundImage: user.profileImage != null && user.profileImage!.isNotEmpty
                            ? NetworkImage(user.profileImage!)
                            : null,
                        child: user.profileImage == null || user.profileImage!.isEmpty
                            ? Icon(Icons.person, size: 50, color: AppColors.primary)
                            : null,
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      Text(
                        user.displayName.isNotEmpty ? user.displayName : 'No Name',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        user.email.isNotEmpty ? user.email : 'No Email',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      // Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.defaultPadding,
                          vertical: AppConstants.smallPadding,
                        ),
                        decoration: BoxDecoration(
                          color: user.isAdmin ? Colors.red : AppColors.primary,
                          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              user.isAdmin ? Icons.admin_panel_settings : Icons.person,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: AppConstants.smallPadding),
                            Text(
                              user.role.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      CustomButton(
                        text: 'Edit Profile',
                        isOutlined: true,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Edit profile coming soon!')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppConstants.largePadding * 2),
                
                // Admin Section (only visible to admins)
                if (user.isAdmin) ...[
                  // Admin View Toggle Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.withOpacity(0.1),
                          Colors.purple.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              adminViewService.isAdminViewEnabled 
                                  ? Icons.admin_panel_settings 
                                  : Icons.person_outline,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: AppConstants.smallPadding),
                            Text(
                              'Interface Mode',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.smallPadding),
                        Text(
                          adminViewService.currentViewDescription,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: AppConstants.defaultPadding),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.defaultPadding,
                                  vertical: AppConstants.smallPadding,
                                ),
                                decoration: BoxDecoration(
                                  color: adminViewService.isAdminViewEnabled 
                                      ? Colors.red.withOpacity(0.1) 
                                      : Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                                  border: Border.all(
                                    color: adminViewService.isAdminViewEnabled 
                                        ? Colors.red.withOpacity(0.3) 
                                        : Colors.green.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      adminViewService.isAdminViewEnabled 
                                          ? Icons.admin_panel_settings 
                                          : Icons.person,
                                      color: adminViewService.isAdminViewEnabled 
                                          ? Colors.red 
                                          : Colors.green,
                                      size: 16,
                                    ),
                                    const SizedBox(width: AppConstants.smallPadding),
                                    Text(
                                      adminViewService.currentViewMode,
                                      style: TextStyle(
                                        color: adminViewService.isAdminViewEnabled 
                                            ? Colors.red 
                                            : Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: AppConstants.defaultPadding),
                            CustomButton(
                              text: adminViewService.isLoading 
                                  ? 'Switching...' 
                                  : 'Switch',
                              onPressed: adminViewService.isLoading 
                                  ? null 
                                  : () async {
                                      await adminViewService.toggleAdminView();
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Switched to ${adminViewService.currentViewMode}',
                                            ),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                              backgroundColor: Colors.blue,
                              isOutlined: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppConstants.defaultPadding),
                  // Admin Controls (only show if admin view is enabled)
                  if (adminViewService.isAdminViewEnabled) ...[
                    Text(
                      'Administrator',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    Container(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: ProfileOptionTile(
                        icon: Icons.admin_panel_settings,
                        title: 'Admin Dashboard',
                        subtitle: 'Access administrator controls',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChangeNotifierProvider(
                                create: (context) => AdminService(),
                                child: const AdminDashboardScreen(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: AppConstants.largePadding * 2),
                ],
                
                // Hair Preferences Section
                Text(
                  'Hair Preferences',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                Container(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    children: [
                      _buildPreferenceRow('Hair Type', user.preferences.hairType.isNotEmpty ? user.preferences.hairType : 'Not set'),
                      const Divider(),
                      _buildPreferenceRow('Preferred Length', user.preferences.preferredLength.isNotEmpty ? user.preferences.preferredLength : 'Not set'),
                      const Divider(),
                      _buildPreferenceRow('Face Shape', user.preferences.faceShape.isNotEmpty ? user.preferences.faceShape : 'Not set'),
                      const Divider(),
                      _buildPreferenceRow('Skin Tone', user.preferences.skinTone.isNotEmpty ? user.preferences.skinTone : 'Not set'),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppConstants.largePadding * 2),
                
                // App Features
                Text(
                  'App Features',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                
                ProfileOptionTile(
                  icon: Icons.palette,
                  title: 'Hair Preferences',
                  subtitle: 'Update your hair type and style preferences',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Hair preferences settings coming soon!')),
                    );
                  },
                ),
                ProfileOptionTile(
                  icon: Icons.favorite_outline,
                  title: 'Saved Styles',
                  subtitle: 'View your saved hairstyles',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Saved styles coming soon!')),
                    );
                  },
                ),
                
                ProfileOptionTile(
                  icon: Icons.history,
                  title: 'Try-On History',
                  subtitle: 'View your virtual try-on history',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Try-on history coming soon!')),
                    );
                  },
                ),
                
                ProfileOptionTile(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'Get help and contact support',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Help & support coming soon!')),
                    );
                  },
                ),
                
                ProfileOptionTile(
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'App version and information',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'HairStyle AI',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(
                        Icons.face_retouching_natural,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: AppConstants.largePadding * 2),
                
                // Sign Out Button
                CustomButton(
                  text: 'Sign Out',
                  onPressed: () async {
                    await authService.signOut();
                  },
                  backgroundColor: AppColors.error,
                  width: double.infinity,
                ),
                
                const SizedBox(height: AppConstants.largePadding),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreferenceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.smallPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}