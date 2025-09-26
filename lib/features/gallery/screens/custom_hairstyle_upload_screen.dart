import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/gemini_ai_service.dart';
import '../../../core/services/image_upload_service.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../tryon/screens/hairstyle_tryon_screen.dart';

class CustomHairstyleUploadScreen extends StatefulWidget {
  const CustomHairstyleUploadScreen({super.key});

  @override
  State<CustomHairstyleUploadScreen> createState() => _CustomHairstyleUploadScreenState();
}

class _CustomHairstyleUploadScreenState extends State<CustomHairstyleUploadScreen> {
  final GeminiAIService _aiService = GeminiAIService();
  final ImageUploadService _imageService = ImageUploadService();
  
  XFile? _hairstyleImage;
  bool _isAnalyzing = false;
  String _analysisResult = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Custom Hairstyle'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instructions
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: AppConstants.smallPadding),
                      Text(
                        'Custom Hairstyle Try-On',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  Text(
                    'Upload a photo of any hairstyle you like, and our AI will analyze it and help you try it on!',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Text(
                    'Tips for best results:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...[
                    '• Choose images with clear, visible hairstyles',
                    '• Avoid heavily filtered or low-quality images',
                    '• Front-facing hairstyle photos work best',
                    '• Ensure good lighting in the reference image',
                  ].map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      tip,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )),
                ],
              ),
            ),
            
            const SizedBox(height: AppConstants.largePadding),
            
            // Hairstyle Image Upload Section
            _buildHairstyleUploadSection(),
            
            const SizedBox(height: AppConstants.largePadding),
            
            // Analysis Results
            if (_analysisResult.isNotEmpty) _buildAnalysisSection(),
            
            const SizedBox(height: AppConstants.largePadding),
            
            // Action Buttons
            if (_hairstyleImage != null && _analysisResult.isEmpty && !_isAnalyzing)
              CustomButton(
                text: 'Analyze Hairstyle',
                onPressed: _analyzeHairstyle,
                backgroundColor: AppColors.primary,
                width: double.infinity,
                icon: Icons.psychology,
              ),
            
            if (_analysisResult.isNotEmpty)
              CustomButton(
                text: 'Try On This Style',
                onPressed: _navigateToTryOn,
                backgroundColor: AppColors.accent,
                width: double.infinity,
                icon: Icons.face_retouching_natural,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHairstyleUploadSection() {
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
            'Hairstyle Reference Photo',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          
          if (_hairstyleImage != null)
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  child: Image.file(
                    File(_hairstyleImage!.path),
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Change Photo',
                        onPressed: _selectHairstyleImage,
                        isOutlined: true,
                      ),
                    ),
                    const SizedBox(width: AppConstants.defaultPadding),
                    Expanded(
                      child: CustomButton(
                        text: 'Remove',
                        onPressed: () {
                          setState(() {
                            _hairstyleImage = null;
                            _analysisResult = '';
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
                  height: 250,
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
                        Icons.add_photo_alternate,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      Text(
                        'Upload a hairstyle photo',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        'Choose from your gallery or take a new photo',
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
                        onPressed: () => _selectHairstyleImage(useCamera: true),
                        icon: Icons.camera_alt,
                      ),
                    ),
                    const SizedBox(width: AppConstants.defaultPadding),
                    Expanded(
                      child: CustomButton(
                        text: 'Choose from Gallery',
                        onPressed: () => _selectHairstyleImage(useCamera: false),
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

  Widget _buildAnalysisSection() {
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
                'Hairstyle Analysis Complete',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          
          SingleChildScrollView(
            child: Text(
              _analysisResult,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Expanded(
                  child: Text(
                    'Ready to try on this style! Our AI will adapt it to your unique features.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectHairstyleImage({bool? useCamera}) async {
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
          _hairstyleImage = image;
          _analysisResult = ''; // Clear previous analysis
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

  Future<void> _analyzeHairstyle() async {
    if (_hairstyleImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _analysisResult = '';
    });

    try {
      final result = await _aiService.analyzeCustomHairstyle(_hairstyleImage!);
      
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _analysisResult = result;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _analysisResult = 'Analysis failed. Please try again with a clear hairstyle image.';
        });
      }
    }
  }

  void _navigateToTryOn() {
    if (_hairstyleImage == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HairstyleTryOnScreen(
          customHairstyleImage: _hairstyleImage,
        ),
      ),
    );
  }
}