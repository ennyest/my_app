import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_button.dart';
import '../widgets/profile_option_tile.dart';

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
              // TODO: Open settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings coming soon!'),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          if (authService.userModel == null) {
            return const Center(
              child: CircularProgressIndicator(),
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
                      // Profile Picture
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        backgroundImage: user.profileImage != null
                            ? NetworkImage(user.profileImage!)
                            : null,
                        child: user.profileImage == null
                            ? Icon(
                                Icons.person,
                                size: 50,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                      
                      const SizedBox(height: AppConstants.defaultPadding),
                      
                      // Name
                      Text(
                        user.displayName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: AppConstants.smallPadding),
                      
                      // Email
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      
                      const SizedBox(height: AppConstants.defaultPadding),
                      
                      // Edit Profile Button
                      CustomButton(
                        text: 'Edit Profile',
                        isOutlined: true,
                        onPressed: () {
                          // TODO: Navigate to edit profile
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Edit profile coming soon!'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppConstants.largePadding * 2),
                
                // Preferences Section
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
                      _buildPreferenceRow('Hair Type', user.preferences.hairType),
                      const Divider(),
                      _buildPreferenceRow('Preferred Length', user.preferences.preferredLength),
                      const Divider(),
                      _buildPreferenceRow('Face Shape', user.preferences.faceShape),
                      const Divider(),
                      _buildPreferenceRow('Skin Tone', user.preferences.skinTone),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppConstants.largePadding * 2),
                
                // Menu Options
                ProfileOptionTile(
                  icon: Icons.favorite_outline,
                  title: 'Saved Styles',
                  subtitle: 'View your saved hairstyles',
                  onTap: () {
                    // TODO: Navigate to saved styles
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Saved styles coming soon!'),
                      ),
                    );
                  },
                ),
                
                ProfileOptionTile(
                  icon: Icons.history,
                  title: 'Try-On History',
                  subtitle: 'View your virtual try-on history',
                  onTap: () {
                    // TODO: Navigate to try-on history
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Try-on history coming soon!'),
                      ),
                    );
                  },
                ),
                
                ProfileOptionTile(
                  icon: Icons.analytics_outlined,
                  title: 'AI Analysis History',
                  subtitle: 'View your AI analysis results',
                  onTap: () {
                    // TODO: Navigate to analysis history
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Analysis history coming soon!'),
                      ),
                    );
                  },
                ),
                
                ProfileOptionTile(
                  icon: Icons.share_outlined,
                  title: 'Share App',
                  subtitle: 'Share HairStyle AI with friends',
                  onTap: () {
                    // TODO: Implement share functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Share functionality coming soon!'),
                      ),
                    );
                  },
                ),
                
                ProfileOptionTile(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'Get help and contact support',
                  onTap: () {
                    // TODO: Navigate to help & support
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Help & support coming soon!'),
                      ),
                    );
                  },
                ),
                
                ProfileOptionTile(
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'App version and information',
                  onTap: () {
                    // TODO: Show about dialog
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
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
