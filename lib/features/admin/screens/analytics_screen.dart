import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
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
        title: const Text('Analytics & Reports'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final adminService = Provider.of<AdminService>(context, listen: false);
              adminService.loadAppStats();
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

          final stats = adminService.appStats;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview Section
                Text(
                  'Overview',
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
                  childAspectRatio: 1.2,
                  children: [
                    _buildMetricCard(
                      'Total Users',
                      '${stats['totalUsers'] ?? 0}',
                      Icons.people,
                      AppColors.primary,
                      'All registered users',
                    ),
                    _buildMetricCard(
                      'Active Users',
                      '${stats['activeUsers'] ?? 0}',
                      Icons.person_outline,
                      Colors.green,
                      'Currently active users',
                    ),
                    _buildMetricCard(
                      'Total Styles',
                      '${stats['totalStyles'] ?? 0}',
                      Icons.style,
                      AppColors.accent,
                      'All hairstyles in database',
                    ),
                    _buildMetricCard(
                      'Pending Approval',
                      '${stats['pendingStyles'] ?? 0}',
                      Icons.pending,
                      Colors.orange,
                      'Styles awaiting approval',
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.largePadding * 2),

                // User Analytics Section
                Text(
                  'User Analytics',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                
                _buildAnalyticsCard(
                  'User Statistics',
                  [
                    _buildStatRow('Total Users', '${stats['totalUsers'] ?? 0}'),
                    _buildStatRow('Active Users', '${stats['activeUsers'] ?? 0}'),
                    _buildStatRow('Inactive Users', '${(stats['totalUsers'] ?? 0) - (stats['activeUsers'] ?? 0)}'),
                    _buildStatRow('Admin Users', '${stats['adminUsers'] ?? 0}'),
                  ],
                ),

                const SizedBox(height: AppConstants.defaultPadding),

                // Content Analytics Section
                Text(
                  'Content Analytics',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                
                _buildAnalyticsCard(
                  'Content Statistics',
                  [
                    _buildStatRow('Total Styles', '${stats['totalStyles'] ?? 0}'),
                    _buildStatRow('Approved Styles', '${stats['approvedStyles'] ?? 0}'),
                    _buildStatRow('Pending Styles', '${stats['pendingStyles'] ?? 0}'),
                    _buildStatRow('User Galleries', '${stats['totalGalleries'] ?? 0}'),
                  ],
                ),

                const SizedBox(height: AppConstants.defaultPadding),

                // Engagement Metrics
                _buildAnalyticsCard(
                  'Engagement Metrics',
                  [
                    _buildStatRow('Approval Rate', _calculateApprovalRate(stats)),
                    _buildStatRow('Active User Rate', _calculateActiveUserRate(stats)),
                    _buildStatRow('Content Per User', _calculateContentPerUser(stats)),
                    _buildStatRow('Admin Ratio', _calculateAdminRatio(stats)),
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
                    _buildActionCard(
                      'Export User Data',
                      'Download user statistics as CSV',
                      Icons.download,
                      () => _exportUserData(),
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    _buildActionCard(
                      'Export Content Data',
                      'Download content statistics as CSV',
                      Icons.file_download,
                      () => _exportContentData(),
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    _buildActionCard(
                      'Generate Report',
                      'Create comprehensive analytics report',
                      Icons.assessment,
                      () => _generateReport(),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, String subtitle) {
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
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, List<Widget> children) {
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

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.smallPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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

  String _calculateApprovalRate(Map<String, dynamic> stats) {
    final total = stats['totalStyles'] ?? 0;
    final approved = stats['approvedStyles'] ?? 0;
    
    if (total == 0) return '0%';
    
    final rate = (approved / total * 100).round();
    return '$rate%';
  }

  String _calculateActiveUserRate(Map<String, dynamic> stats) {
    final total = stats['totalUsers'] ?? 0;
    final active = stats['activeUsers'] ?? 0;
    
    if (total == 0) return '0%';
    
    final rate = (active / total * 100).round();
    return '$rate%';
  }

  String _calculateContentPerUser(Map<String, dynamic> stats) {
    final totalUsers = stats['totalUsers'] ?? 0;
    final totalGalleries = stats['totalGalleries'] ?? 0;
    
    if (totalUsers == 0) return '0';
    
    final ratio = (totalGalleries / totalUsers).toStringAsFixed(1);
    return ratio;
  }

  String _calculateAdminRatio(Map<String, dynamic> stats) {
    final total = stats['totalUsers'] ?? 0;
    final admins = stats['adminUsers'] ?? 0;
    
    if (total == 0) return '0%';
    
    final ratio = (admins / total * 100).toStringAsFixed(1);
    return '$ratio%';
  }

  void _exportUserData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User data export feature coming soon!'),
      ),
    );
  }

  void _exportContentData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Content data export feature coming soon!'),
      ),
    );
  }

  void _generateReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report generation feature coming soon!'),
      ),
    );
  }
}