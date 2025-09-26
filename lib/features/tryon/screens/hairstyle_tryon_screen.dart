import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/hairstyle_tryon_service.dart';
import '../../../core/services/image_upload_service.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/models/hairstyle_model.dart';

class HairstyleTryOnScreen extends StatefulWidget {
  final HairstyleModel? selectedHairstyle;
  final XFile? customHairstyleImage;

  const HairstyleTryOnScreen({
    super.key,
    this.selectedHairstyle,
    this.customHairstyleImage,
  });

  @override
  State<HairstyleTryOnScreen> createState() => _HairstyleTryOnScreenState();
}

class _HairstyleTryOnScreenState extends State<HairstyleTryOnScreen> {
  final HairstyleTryOnService _tryOnService = HairstyleTryOnService();
  final ImageUploadService _imageService = ImageUploadService();
  
  XFile? _userPhoto;
  bool _isGenerating = false;
  String _progressMessage = '';
  TryOnResult? _result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedHairstyle?.name ?? 'Custom Style Try-On'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected Hairstyle Info
            if (widget.selectedHairstyle != null) _buildHairstyleInfo(),
            if (widget.customHairstyleImage != null) _buildCustomHairstyleInfo(),
            
            const SizedBox(height: AppConstants.largePadding),
            
            // User Photo Section
            _buildUserPhotoSection(),
            
            const SizedBox(height: AppConstants.largePadding),
            
            // Try On Button
            if (_userPhoto != null && !_isGenerating)
              CustomButton(
                text: 'Generate Try-On',
                onPressed: _startTryOn,
                backgroundColor: AppColors.primary,
                width: double.infinity,
                icon: Icons.auto_awesome,
              ),
            
            // Progress Indicator
            if (_isGenerating) _buildProgressIndicator(),
            
            // Results Section
            if (_result != null) _buildResultsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHairstyleInfo() {
    final hairstyle = widget.selectedHairstyle!;
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Hairstyle',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          
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
                      color: AppColors.surfaceVariant,
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hairstyle.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildInfoChip('Category', hairstyle.category),
                        _buildInfoChip('Difficulty', hairstyle.difficulty),
                        _buildInfoChip('Length', hairstyle.length),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomHairstyleInfo() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Custom Hairstyle',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            child: Image.file(
              File(widget.customHairstyleImage!.path),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          
          Text(
            'Your custom hairstyle will be analyzed and applied to your photo.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildUserPhotoSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Photo',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          
          if (_userPhoto != null)
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  child: Image.file(
                    File(_userPhoto!.path),
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Change Photo',
                        onPressed: _selectUserPhoto,
                        isOutlined: true,
                      ),
                    ),
                    const SizedBox(width: AppConstants.defaultPadding),
                    Expanded(
                      child: CustomButton(
                        text: 'Remove',
                        onPressed: () {
                          setState(() {
                            _userPhoto = null;
                            _result = null;
                          });
                        },
                        backgroundColor: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(
                      color: AppColors.outline,
                      style: BorderStyle.solid,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      Text(
                        'Add your photo to try on the hairstyle',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        'Make sure your face and hair are clearly visible',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Take Photo',
                        onPressed: () => _selectUserPhoto(useCamera: true),
                        icon: Icons.camera_alt,
                      ),
                    ),
                    const SizedBox(width: AppConstants.defaultPadding),
                    Expanded(
                      child: CustomButton(
                        text: 'Choose from Gallery',
                        onPressed: () => _selectUserPhoto(useCamera: false),
                        icon: Icons.photo_library,
                        isOutlined: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'Generating your try-on...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            _progressMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    if (_result == null) return const SizedBox.shrink();
    
    if (!_result!.isSuccess) {
      return Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 48,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'Try-On Failed',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              _result!.errorMessage ?? 'An error occurred',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            CustomButton(
              text: 'Try Again',
              onPressed: _startTryOn,
              backgroundColor: AppColors.error,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 24,
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Text(
                'Try-On Complete!',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          
          Text(
            _result!.description ?? '',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          
          if (_result!.recommendations?.isNotEmpty == true) ...[
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'Recommendations:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            ..._result!.recommendations!.map((recommendation) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            )),
          ],
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Try Another Style',
                  onPressed: () => Navigator.pop(context),
                  isOutlined: true,
                ),
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              Expanded(
                child: CustomButton(
                  text: 'Save Result',
                  onPressed: _saveResult,
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectUserPhoto({bool? useCamera}) async {
    try {
      XFile? image;
      
      if (useCamera == null) {
        // Show dialog to choose
        image = await _imageService.showImageSourceDialog(context);
      } else if (useCamera) {
        image = await _imageService.pickImageFromCamera();
      } else {
        image = await _imageService.pickImageFromGallery();
      }

      if (image != null) {
        setState(() {
          _userPhoto = image;
          _result = null; // Clear previous results
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting photo: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _startTryOn() async {
    if (_userPhoto == null) return;

    setState(() {
      _isGenerating = true;
      _progressMessage = 'Starting try-on process...';
      _result = null;
    });

    try {
      TryOnResult result;

      if (widget.selectedHairstyle != null) {
        result = await _tryOnService.tryOnHairstyle(
          userPhoto: _userPhoto!,
          hairstyleName: widget.selectedHairstyle!.name,
          hairstyleDescription: widget.selectedHairstyle!.description,
          hairstyleImageUrl: widget.selectedHairstyle!.imageUrl,
          onProgress: (message) {
            if (mounted) {
              setState(() {
                _progressMessage = message;
              });
            }
          },
        );
      } else if (widget.customHairstyleImage != null) {
        result = await _tryOnService.tryOnCustomHairstyle(
          userPhoto: _userPhoto!,
          hairstylePhoto: widget.customHairstyleImage!,
          onProgress: (message) {
            if (mounted) {
              setState(() {
                _progressMessage = message;
              });
            }
          },
        );
      } else {
        result = TryOnResult.error('No hairstyle selected');
      }

      if (mounted) {
        setState(() {
          _isGenerating = false;
          _result = result;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _result = TryOnResult.error('Try-on generation failed: $e');
        });
      }
    }
  }

  Future<void> _saveResult() async {
    if (_result?.isSuccess != true) return;

    try {
      // TODO: Implement saving to user's history
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Result saved to your history!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving result: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}