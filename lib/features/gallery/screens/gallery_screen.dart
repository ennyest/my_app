import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../widgets/hairstyle_card.dart';
import '../widgets/gallery_filter_bottom_sheet.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedDifficulty = 'All';
  String _selectedLength = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GalleryFilterBottomSheet(
        selectedCategory: _selectedCategory,
        selectedDifficulty: _selectedDifficulty,
        selectedLength: _selectedLength,
        onApplyFilters: (category, difficulty, length) {
          setState(() {
            _selectedCategory = category;
            _selectedDifficulty = difficulty;
            _selectedLength = length;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hair Gallery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: CustomTextField(
              controller: _searchController,
              labelText: 'Search hairstyles...',
              hintText: 'Search hairstyles...',
              prefixIcon: Icons.search,
              onChanged: (value) {
                // TODO: Implement search functionality
              },
            ),
          ),
          
          // Category Chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryChip('All', _selectedCategory == 'All'),
                const SizedBox(width: AppConstants.smallPadding),
                _buildCategoryChip('Braids', _selectedCategory == 'Braids'),
                const SizedBox(width: AppConstants.smallPadding),
                _buildCategoryChip('Curls', _selectedCategory == 'Curls'),
                const SizedBox(width: AppConstants.smallPadding),
                _buildCategoryChip('Natural', _selectedCategory == 'Natural'),
                const SizedBox(width: AppConstants.smallPadding),
                _buildCategoryChip('Updos', _selectedCategory == 'Updos'),
                const SizedBox(width: AppConstants.smallPadding),
                _buildCategoryChip('Bobs', _selectedCategory == 'Bobs'),
              ],
            ),
          ),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          // Gallery Grid
          Expanded(
            child: _buildGalleryGrid(),
          ),
        ],
      ),
      floatingActionButton: CustomFloatingActionButton(
        icon: Icons.add,
        tooltip: 'Add Hairstyle',
        onPressed: () {
          // TODO: Navigate to add hairstyle screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add hairstyle feature coming soon!'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? label : 'All';
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildGalleryGrid() {
    // TODO: Replace with actual data from Firestore
    final List<Map<String, dynamic>> sampleHairstyles = [
      {
        'id': '1',
        'name': 'Elegant Braids',
        'imageUrl': 'https://via.placeholder.com/300x400',
        'category': 'Braids',
        'difficulty': 'Medium',
        'likes': 150,
      },
      {
        'id': '2',
        'name': 'Curly Bob',
        'imageUrl': 'https://via.placeholder.com/300x400',
        'category': 'Bobs',
        'difficulty': 'Easy',
        'likes': 89,
      },
      {
        'id': '3',
        'name': 'Natural Afro',
        'imageUrl': 'https://via.placeholder.com/300x400',
        'category': 'Natural',
        'difficulty': 'Easy',
        'likes': 234,
      },
      {
        'id': '4',
        'name': 'Elegant Updo',
        'imageUrl': 'https://via.placeholder.com/300x400',
        'category': 'Updos',
        'difficulty': 'Hard',
        'likes': 167,
      },
      {
        'id': '5',
        'name': 'Wavy Layers',
        'imageUrl': 'https://via.placeholder.com/300x400',
        'category': 'Curls',
        'difficulty': 'Medium',
        'likes': 98,
      },
      {
        'id': '6',
        'name': 'Pixie Cut',
        'imageUrl': 'https://via.placeholder.com/300x400',
        'category': 'Bobs',
        'difficulty': 'Easy',
        'likes': 145,
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: AppConstants.defaultPadding,
        mainAxisSpacing: AppConstants.defaultPadding,
      ),
      itemCount: sampleHairstyles.length,
      itemBuilder: (context, index) {
        final hairstyle = sampleHairstyles[index];
        return HairstyleCard(
          id: hairstyle['id'],
          name: hairstyle['name'],
          imageUrl: hairstyle['imageUrl'],
          category: hairstyle['category'],
          difficulty: hairstyle['difficulty'],
          likes: hairstyle['likes'],
          onTap: () {
            // TODO: Navigate to hairstyle detail screen
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Viewing ${hairstyle['name']}'),
              ),
            );
          },
        );
      },
    );
  }
}
