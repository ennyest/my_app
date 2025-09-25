import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_button.dart';

class GalleryFilterBottomSheet extends StatefulWidget {
  final String selectedCategory;
  final String selectedDifficulty;
  final String selectedLength;
  final Function(String, String, String) onApplyFilters;

  const GalleryFilterBottomSheet({
    super.key,
    required this.selectedCategory,
    required this.selectedDifficulty,
    required this.selectedLength,
    required this.onApplyFilters,
  });

  @override
  State<GalleryFilterBottomSheet> createState() => _GalleryFilterBottomSheetState();
}

class _GalleryFilterBottomSheetState extends State<GalleryFilterBottomSheet> {
  late String _selectedCategory;
  late String _selectedDifficulty;
  late String _selectedLength;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _selectedDifficulty = widget.selectedDifficulty;
    _selectedLength = widget.selectedLength;
  }

  void _applyFilters() {
    widget.onApplyFilters(_selectedCategory, _selectedDifficulty, _selectedLength);
    Navigator.of(context).pop();
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = 'All';
      _selectedDifficulty = 'All';
      _selectedLength = 'All';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: AppConstants.largePadding,
          right: AppConstants.largePadding,
          top: AppConstants.defaultPadding,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppConstants.largePadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            const SizedBox(height: AppConstants.largePadding),
            
            // Title
            Text(
              'Filter Hairstyles',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: AppConstants.largePadding),
            
            // Category Filter
            Text(
              'Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: AppConstants.smallPadding),
            
            Wrap(
              spacing: AppConstants.smallPadding,
              runSpacing: AppConstants.smallPadding,
              children: [
                'All',
                'Braids',
                'Curls',
                'Natural',
                'Updos',
                'Bobs',
                'Pixie',
                'Ponytails',
                'Bangs',
              ].map((category) {
                final isSelected = _selectedCategory == category;
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category : 'All';
                    });
                  },
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  checkmarkColor: AppColors.primary,
                );
              }).toList(),
            ),
            
            const SizedBox(height: AppConstants.largePadding),
            
            // Difficulty Filter
            Text(
              'Difficulty',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: AppConstants.smallPadding),
            
            Wrap(
              spacing: AppConstants.smallPadding,
              runSpacing: AppConstants.smallPadding,
              children: [
                'All',
                'Easy',
                'Medium',
                'Hard',
              ].map((difficulty) {
                final isSelected = _selectedDifficulty == difficulty;
                return FilterChip(
                  label: Text(difficulty),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedDifficulty = selected ? difficulty : 'All';
                    });
                  },
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  checkmarkColor: AppColors.primary,
                );
              }).toList(),
            ),
            
            const SizedBox(height: AppConstants.largePadding),
            
            // Length Filter
            Text(
              'Length',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: AppConstants.smallPadding),
            
            Wrap(
              spacing: AppConstants.smallPadding,
              runSpacing: AppConstants.smallPadding,
              children: [
                'All',
                'Short',
                'Medium',
                'Long',
              ].map((length) {
                final isSelected = _selectedLength == length;
                return FilterChip(
                  label: Text(length),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedLength = selected ? length : 'All';
                    });
                  },
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  checkmarkColor: AppColors.primary,
                );
              }).toList(),
            ),
            
            const SizedBox(height: AppConstants.largePadding * 2),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Reset',
                    isOutlined: true,
                    onPressed: _resetFilters,
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: CustomButton(
                    text: 'Apply Filters',
                    onPressed: _applyFilters,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
