import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/hairstyle_model.dart';
import '../../../shared/widgets/custom_button.dart';
import 'add_hairstyle_screen.dart';

class HairstyleManagementScreen extends StatefulWidget {
  const HairstyleManagementScreen({super.key});

  @override
  State<HairstyleManagementScreen> createState() => _HairstyleManagementScreenState();
}

class _HairstyleManagementScreenState extends State<HairstyleManagementScreen> {
  List<HairstyleModel> _hairstyles = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadHairstyles();
  }

  Future<void> _loadHairstyles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(AppConstants.hairstylesCollection)
          .orderBy('createdAt', descending: true)
          .get();

      _hairstyles = snapshot.docs
          .map((doc) => HairstyleModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading hairstyles: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<HairstyleModel> get _filteredHairstyles {
    return _hairstyles.where((style) {
      final matchesSearch = _searchQuery.isEmpty ||
          style.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          style.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesCategory = _selectedCategory == null ||
          style.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hairstyle Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHairstyles,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddHairstyleScreen(),
            ),
          ).then((result) {
            if (result == true) {
              _loadHairstyles();
            }
          });
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            color: AppColors.surface,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search hairstyles...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                DropdownButtonFormField<String?>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Category',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All Categories'),
                    ),
                    ...HairCategories.all.map((category) => 
                      DropdownMenuItem<String?>(
                        value: category,
                        child: Text(category.toUpperCase()),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
              ],
            ),
          ),

          // Results Summary
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
              vertical: AppConstants.smallPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredHairstyles.length} hairstyles found',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_searchQuery.isNotEmpty || _selectedCategory != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _selectedCategory = null;
                      });
                    },
                    child: const Text('Clear Filters'),
                  ),
              ],
            ),
          ),

          // Hairstyles List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredHairstyles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.style,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _hairstyles.isEmpty 
                                  ? 'No hairstyles found'
                                  : 'No hairstyles match your filters',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            const Text('Try adjusting your search criteria'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppConstants.defaultPadding),
                        itemCount: _filteredHairstyles.length,
                        itemBuilder: (context, index) {
                          final hairstyle = _filteredHairstyles[index];
                          return _buildHairstyleCard(hairstyle);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHairstyleCard(HairstyleModel hairstyle) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  child: Image.network(
                    hairstyle.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: AppColors.outline,
                        child: const Icon(Icons.error),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hairstyle.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        hairstyle.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Row(
                        children: [
                          _buildInfoChip(hairstyle.category, Colors.blue),
                          const SizedBox(width: AppConstants.smallPadding),
                          _buildInfoChip(hairstyle.difficulty, Colors.orange),
                          const SizedBox(width: AppConstants.smallPadding),
                          _buildInfoChip(hairstyle.length, Colors.green),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // Status and Stats
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            hairstyle.isApproved 
                                ? Icons.check_circle 
                                : hairstyle.isRejected 
                                    ? Icons.cancel 
                                    : Icons.pending,
                            size: 16,
                            color: hairstyle.isApproved 
                                ? Colors.green 
                                : hairstyle.isRejected 
                                    ? Colors.red 
                                    : Colors.orange,
                          ),
                          const SizedBox(width: AppConstants.smallPadding),
                          Text(
                            hairstyle.isApproved 
                                ? 'Approved' 
                                : hairstyle.isRejected 
                                    ? 'Rejected' 
                                    : 'Pending',
                            style: TextStyle(
                              color: hairstyle.isApproved 
                                  ? Colors.green 
                                  : hairstyle.isRejected 
                                      ? Colors.red 
                                      : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        '${hairstyle.likes} likes • ${_formatDate(hairstyle.createdAt)}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    onSelected: (action) => _handleAction(action, hairstyle),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility),
                            SizedBox(width: 8),
                            Text('View Details'),
                          ],
                        ),
                      ),
                      if (!hairstyle.isApproved)
                        const PopupMenuItem(
                          value: 'approve',
                          child: Row(
                            children: [
                              Icon(Icons.check, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Approve'),
                            ],
                          ),
                        ),
                      if (!hairstyle.isRejected)
                        const PopupMenuItem(
                          value: 'reject',
                          child: Row(
                            children: [
                              Icon(Icons.cancel, color: Colors.orange),
                              SizedBox(width: 8),
                              Text('Reject'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleAction(String action, HairstyleModel hairstyle) async {
    switch (action) {
      case 'view':
        _showHairstyleDetails(hairstyle);
        break;
      case 'approve':
        await _approveHairstyle(hairstyle);
        break;
      case 'reject':
        await _rejectHairstyle(hairstyle);
        break;
      case 'delete':
        await _deleteHairstyle(hairstyle);
        break;
    }
  }

  void _showHairstyleDetails(HairstyleModel hairstyle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(hairstyle.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                child: Image.network(
                  hairstyle.imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Text('Description:', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(hairstyle.description),
              const SizedBox(height: AppConstants.defaultPadding),
              Text('Category:', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(hairstyle.category),
              const SizedBox(height: AppConstants.defaultPadding),
              Text('Tags:', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(hairstyle.tags.join(', ')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _approveHairstyle(HairstyleModel hairstyle) async {
    final adminService = Provider.of<AdminService>(context, listen: false);
    final success = await adminService.approveHairstyle(hairstyle.styleId);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hairstyle approved successfully!')),
      );
      _loadHairstyles();
    }
  }

  Future<void> _rejectHairstyle(HairstyleModel hairstyle) async {
    final reasonController = TextEditingController();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Hairstyle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Why are you rejecting "${hairstyle.name}"?'),
            const SizedBox(height: AppConstants.defaultPadding),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Reason for rejection...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true && reasonController.text.isNotEmpty) {
      final adminService = Provider.of<AdminService>(context, listen: false);
      final success = await adminService.rejectHairstyle(
        hairstyle.styleId,
        reasonController.text,
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hairstyle rejected successfully!')),
        );
        _loadHairstyles();
      }
    }
  }

  Future<void> _deleteHairstyle(HairstyleModel hairstyle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Hairstyle'),
        content: Text('Are you sure you want to permanently delete "${hairstyle.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final adminService = Provider.of<AdminService>(context, listen: false);
      final success = await adminService.deleteHairstyle(hairstyle.styleId);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hairstyle deleted successfully!')),
        );
        _loadHairstyles();
      }
    }
  }
}