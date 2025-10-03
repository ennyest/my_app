import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/services/admin_view_service.dart';
import '../../gallery/screens/gallery_screen.dart';
import '../../camera/screens/camera_screen.dart';
import '../../ai_consultant/screens/ai_consultant_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../admin/screens/admin_dashboard_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const GalleryScreen(),
    const CameraScreen(),
    const AIConsultantScreen(),
    const ProfileScreen(),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view,
      label: 'Gallery',
    ),
    NavigationItem(
      icon: Icons.camera_alt_outlined,
      activeIcon: Icons.camera_alt,
      label: 'Camera',
    ),
    NavigationItem(
      icon: Icons.psychology_outlined,
      activeIcon: Icons.psychology,
      label: 'AI Consultant',
    ),
    NavigationItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthService, AdminViewService>(
      builder: (context, authService, adminViewService, child) {
        final user = authService.userModel;
        final showAdminFab = user?.isAdmin == true && adminViewService.isAdminViewEnabled;
        
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          floatingActionButton: showAdminFab ? FloatingActionButton(
            onPressed: () {
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
            backgroundColor: Colors.red,
            child: const Icon(
              Icons.admin_panel_settings,
              color: Colors.white,
            ),
          ) : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSurface
                  : AppColors.surface,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 12,
              ),
              items: _navigationItems.map((item) {
                final index = _navigationItems.indexOf(item);
                final isSelected = _currentIndex == index;
                
                return BottomNavigationBarItem(
                  icon: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    size: 24,
                  ),
                  label: item.label,
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
