import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/gemini_ai_service.dart';
import '../../../core/services/image_upload_service.dart';
import '../../../shared/widgets/custom_button.dart';

class AIConsultantScreen extends StatefulWidget {
  const AIConsultantScreen({super.key});

  @override
  State<AIConsultantScreen> createState() => _AIConsultantScreenState();
}

class _AIConsultantScreenState extends State<AIConsultantScreen> {
  final GeminiAIService _aiService = GeminiAIService();
  final ImageUploadService _imageService = ImageUploadService();
  
  bool _isAnalyzing = false;
  String _analysisResult = '';
  XFile? _selectedImage;
  String _analysisType = 'general'; // general, color, personalized

  Future<void> _startAnalysis() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a photo first'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisResult = '';
    });

    try {
      String result;
      
      switch (_analysisType) {
        case 'color':
          result = await _aiService.analyzeHairColorOptions(_selectedImage!);
          break;
        case 'personalized':
          result = await _aiService.getPersonalizedRecommendations(
            userPhoto: _selectedImage!,
            preferences: 'Modern, low-maintenance styles',
            lifestyle: 'Professional, active',
            hairGoals: 'Easy styling with versatile looks',
          );
          break;
        default:
          result = await _aiService.analyzeHairAndFace(_selectedImage!);
      }

      setState(() {
        _isAnalyzing = false;
        _analysisResult = result;
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _analysisResult = 'Analysis failed. Please try again with a clear photo showing your face and hair.';
      });
    }
  }

  Future<void> _selectImage({bool useCamera = false}) async {
    try {
      XFile? image;
      
      if (useCamera) {
        image = await _imageService.pickImageFromCamera();
      } else {
        image = await _imageService.pickImageFromGallery();
      }

      if (image != null) {
        // Validate image for analysis
        final isValid = await _aiService.validateImageForAnalysis(image);
        
        if (isValid) {
          setState(() {
            _selectedImage = image;
            _analysisResult = ''; // Clear previous results
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select a clear photo showing your face and hair'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Hair Consultant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: Show analysis history
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Analysis history coming soon!'),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
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
                  Icon(
                    Icons.psychology,
                    size: 60,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  Text(
                    'Your Personal Hair AI',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Text(
                    'Get personalized hairstyle recommendations based on your face shape, hair type, and preferences.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppConstants.largePadding * 2),
            
            // Analysis Section
            Text(
              'Start Analysis',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            Text(
              'Upload a photo or use your camera to get started with AI-powered hair analysis.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            
            const SizedBox(height: AppConstants.largePadding),
            
            // Action Buttons
            if (_selectedImage != null) ...[
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Change Photo',
                      icon: Icons.edit,
                      isOutlined: true,
                      onPressed: _isAnalyzing ? null : () => _selectImage(),
                    ),
                  ),
                  const SizedBox(width: AppConstants.defaultPadding),
                  Expanded(
                    child: CustomButton(
                      text: 'Analyze',
                      icon: Icons.psychology,
                      onPressed: _isAnalyzing ? null : _startAnalysis,
                      isLoading: _isAnalyzing,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Take Photo',
                      icon: Icons.camera_alt,
                      onPressed: _isAnalyzing ? null : () => _selectImage(useCamera: true),
                    ),
                  ),
                  const SizedBox(width: AppConstants.defaultPadding),
                  Expanded(
                    child: CustomButton(
                      text: 'Upload Photo',
                      icon: Icons.photo_library,
                      isOutlined: true,
                      onPressed: _isAnalyzing ? null : () => _selectImage(),
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: AppConstants.largePadding),
            
            // Quick Analysis Button (only show if image is selected)
            if (_selectedImage != null)
              CustomButton(
                text: _isAnalyzing ? 'Analyzing...' : 'Start $_analysisType Analysis',
                onPressed: _isAnalyzing ? null : _startAnalysis,
                backgroundColor: AppColors.accent,
                width: double.infinity,
                isLoading: _isAnalyzing,
              ),
            
            if (_analysisResult.isNotEmpty) ...[
              const SizedBox(height: AppConstants.largePadding * 2),
              
              // Results Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.largePadding),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  border: Border.all(
                    color: AppColors.success.withOpacity(0.3),
                  ),
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
                          'Analysis Complete',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    Text(
                      _analysisResult,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: AppConstants.largePadding * 2),
            
            // Features Section
            Text(
              'AI Features',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            _buildFeatureCard(
              icon: Icons.face_retouching_natural,
              title: 'Face Shape Analysis',
              description: 'AI analyzes your face shape to recommend the most flattering hairstyles.',
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            _buildFeatureCard(
              icon: Icons.color_lens,
              title: 'Color Matching',
              description: 'Get personalized hair color recommendations based on your skin tone.',
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            _buildFeatureCard(
              icon: Icons.auto_awesome,
              title: 'Style Recommendations',
              description: 'Receive curated hairstyle suggestions that match your preferences.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.smallPadding),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
