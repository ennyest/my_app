import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/gallery_service.dart';
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

  @override
  void initState() {
    super.initState();
    // Delay the initial load to ensure authentication is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          final galleryService = Provider.of<GalleryService>(context, listen: false);
          galleryService.loadHairstyles();
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    final galleryService = Provider.of<GalleryService>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GalleryFilterBottomSheet(
        selectedCategory: galleryService.selectedCategory,
        selectedDifficulty: galleryService.selectedDifficulty,
        selectedLength: galleryService.selectedLength,
        onApplyFilters: (category, difficulty, length) {
          galleryService.updateFilters(
            category: category,
            difficulty: difficulty,
            length: length,
          );
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final galleryService = Provider.of<GalleryService>(context, listen: false);
              galleryService.loadHairstyles();
            },
          ),
        ],
      ),
      body: Consumer<GalleryService>(
        builder: (context, galleryService, child) {
          if (galleryService.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (galleryService.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  Text(
                    'Error loading hairstyles',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Text(
                    galleryService.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  CustomButton(
                    text: 'Retry',
                    onPressed: () => galleryService.loadHairstyles(),
                  ),
                ],
              ),
            );
          }

          return Column(
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
                    galleryService.updateSearchQuery(value);
                  },
                ),
              ),
              
              // Category Chips
              _buildCategoryChips(galleryService),
              
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Gallery Grid
              Expanded(
                child: _buildGalleryGrid(galleryService),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please use Admin Dashboard to add hairstyles'),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        tooltip: 'Add Hairstyle',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryChips(GalleryService galleryService) {
    const categories = ['All', 'Braids', 'Curls', 'Natural', 'Updos', 'Bobs'];
    
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: categories.map((category) {
          final isSelected = galleryService.selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: AppConstants.smallPadding),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                galleryService.updateFilters(
                  category: selected ? category : 'All',
                );
              },
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGalleryGrid(GalleryService galleryService) {
    final hairstyles = galleryService.hairstyles;
    
    if (hairstyles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.style_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'No hairstyles found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              'Try adjusting your search or filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            CustomButton(
              text: 'Clear Filters',
              onPressed: () {
                galleryService.clearFilters();
                _searchController.clear();
              },
              isOutlined: true,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: AppConstants.defaultPadding,
        mainAxisSpacing: AppConstants.defaultPadding,
      ),
      itemCount: hairstyles.length,
      itemBuilder: (context, index) {
        final hairstyle = hairstyles[index];
        return HairstyleCard(
          id: hairstyle.styleId,
          name: hairstyle.name,
          imageUrl: hairstyle.imageUrl,
          category: hairstyle.category,
          difficulty: hairstyle.difficulty,
          likes: hairstyle.likes,
          onTap: () {
            // TODO: Navigate to hairstyle detail screen
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Viewing ${hairstyle.name}'),
              ),
            );
          },
          onLike: () {
            // TODO: Implement like functionality
            galleryService.likeHairstyle(hairstyle.styleId, true);
          },
          onSave: () {
            // TODO: Implement save functionality
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${hairstyle.name} saved to favorites'),
              ),
            );
          },
        );
      },
    );
  }
}
