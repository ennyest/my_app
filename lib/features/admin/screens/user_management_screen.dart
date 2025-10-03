import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/widgets/custom_button.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String _searchQuery = '';
  UserRole? _filterRole;
  bool? _filterActiveStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminService = Provider.of<AdminService>(context, listen: false);
      adminService.loadAllUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final adminService = Provider.of<AdminService>(context, listen: false);
              adminService.loadAllUsers();
            },
          ),
        ],
      ),
      body: Consumer<AdminService>(
        builder: (context, adminService, child) {
          if (adminService.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final filteredUsers = _filterUsers(adminService.allUsers);

          return Column(
            children: [
              // Search and Filter Section
              Container(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                color: AppColors.surface,
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search users by name or email...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<UserRole?>(
                            initialValue: _filterRole,
                            decoration: const InputDecoration(
                              labelText: 'Role',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<UserRole?>(
                                value: null,
                                child: Text('All Roles'),
                              ),
                              ...UserRole.values.map((role) => 
                                DropdownMenuItem<UserRole?>(
                                  value: role,
                                  child: Text(role.displayName),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _filterRole = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: AppConstants.defaultPadding),
                        Expanded(
                          child: DropdownButtonFormField<bool?>(
                            initialValue: _filterActiveStatus,
                            decoration: const InputDecoration(
                              labelText: 'Status',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem<bool?>(
                                value: null,
                                child: Text('All Status'),
                              ),
                              DropdownMenuItem<bool?>(
                                value: true,
                                child: Text('Active'),
                              ),
                              DropdownMenuItem<bool?>(
                                value: false,
                                child: Text('Inactive'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _filterActiveStatus = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Users List
              Expanded(
                child: filteredUsers.isEmpty
                    ? const Center(
                        child: Text('No users found'),
                      )
                    : ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return _buildUserTile(user, adminService);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<UserModel> _filterUsers(List<UserModel> users) {
    return users.where((user) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final matchesSearch = user.displayName.toLowerCase().contains(_searchQuery) ||
            user.email.toLowerCase().contains(_searchQuery);
        if (!matchesSearch) return false;
      }

      // Role filter
      if (_filterRole != null && user.role != _filterRole) {
        return false;
      }

      // Active status filter
      if (_filterActiveStatus != null && user.isActive != _filterActiveStatus) {
        return false;
      }

      return true;
    }).toList();
  }

  Widget _buildUserTile(UserModel user, AdminService adminService) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: user.profileImage != null
                      ? NetworkImage(user.profileImage!)
                      : null,
                  child: user.profileImage == null
                      ? Icon(
                          Icons.person,
                          color: AppColors.primary,
                        )
                      : null,
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          _buildRoleBadge(user.role),
                        ],
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Row(
                        children: [
                          _buildStatusBadge(user.isActive),
                          const SizedBox(width: AppConstants.defaultPadding),
                          Text(
                            'Created: ${_formatDate(user.createdAt)}',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: user.isActive ? 'Deactivate' : 'Activate',
                    onPressed: () => _toggleUserStatus(user, adminService),
                    backgroundColor: user.isActive ? Colors.orange : Colors.green,
                    isOutlined: true,
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: CustomButton(
                    text: user.role == UserRole.admin ? 'Demote' : 'Promote',
                    onPressed: user.email == AdminService.adminEmail
                        ? null // Can't demote the main admin
                        : () => _toggleUserRole(user, adminService),
                    backgroundColor: user.role == UserRole.admin ? Colors.blue : AppColors.primary,
                    isOutlined: true,
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: CustomButton(
                    text: 'Delete',
                    onPressed: user.email == AdminService.adminEmail
                        ? null // Can't delete the main admin
                        : () => _deleteUser(user, adminService),
                    backgroundColor: Colors.red,
                    isOutlined: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge(UserRole role) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: role == UserRole.admin ? Colors.red : AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role.displayName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.grey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _toggleUserStatus(UserModel user, AdminService adminService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user.isActive ? 'Deactivate' : 'Activate'} User'),
        content: Text(
          'Are you sure you want to ${user.isActive ? 'deactivate' : 'activate'} ${user.displayName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await adminService.toggleUserActiveStatus(
                user.userId,
                !user.isActive,
              );
              
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success 
                        ? 'User status updated successfully!'
                        : 'Failed to update user status',
                    ),
                  ),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _toggleUserRole(UserModel user, AdminService adminService) {
    final isPromoting = user.role != UserRole.admin;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${isPromoting ? 'Promote' : 'Demote'} User'),
        content: Text(
          'Are you sure you want to ${isPromoting ? 'promote' : 'demote'} ${user.displayName} ${isPromoting ? 'to' : 'from'} admin?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = isPromoting
                  ? await adminService.promoteToAdmin(user.userId)
                  : await adminService.demoteFromAdmin(user.userId);
              
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success 
                        ? 'User role updated successfully!'
                        : 'Failed to update user role',
                    ),
                  ),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _deleteUser(UserModel user, AdminService adminService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'Are you sure you want to permanently delete ${user.displayName}? This action cannot be undone.',
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
            onPressed: () async {
              final success = await adminService.deleteUser(user.userId);
              
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success 
                        ? 'User deleted successfully!'
                        : 'Failed to delete user',
                    ),
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}