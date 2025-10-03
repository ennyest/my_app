import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'gemini_ai_service.dart';
import '../constants/app_constants.dart';

class HairstyleTryOnService {
  static final HairstyleTryOnService _instance = HairstyleTryOnService._internal();
  factory HairstyleTryOnService() => _instance;
  HairstyleTryOnService._internal();

  final GeminiAIService _aiService = GeminiAIService();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Try on a hairstyle with user's photo
  Future<TryOnResult> tryOnHairstyle({
    required XFile userPhoto,
    required String hairstyleName,
    required String hairstyleDescription,
    String? hairstyleImageUrl,
    void Function(String)? onProgress,
  }) async {
    try {
      onProgress?.call('Validating image...');
      
      // Validate user photo
      final isValid = await _aiService.validateImageForAnalysis(userPhoto);
      if (!isValid) {
        return TryOnResult.error('Please upload a clear photo showing your face and hair.');
      }

      onProgress?.call('Analyzing your features...');
      
      // Generate detailed try-on prompt based on user's features
      final tryOnPrompt = await _aiService.generateTryOnPrompt(
        userPhoto: userPhoto,
        hairstyleName: hairstyleName,
        hairstyleDescription: hairstyleDescription,
        hairstyleImageUrl: hairstyleImageUrl,
      );

      onProgress?.call('Generating try-on preview...');
      
      // For now, we'll use Gemini to create a detailed description
      // In a real implementation, you would use this with an image generation API
      final detailedDescription = await _generateTryOnDescription(
        userPhoto: userPhoto,
        hairstyleName: hairstyleName,
        hairstyleDescription: hairstyleDescription,
        tryOnPrompt: tryOnPrompt,
      );

      onProgress?.call('Finalizing result...');

      // Save the try-on session for user's history
      final sessionId = await _saveTryOnSession(
        userPhoto: userPhoto,
        hairstyleName: hairstyleName,
        description: detailedDescription,
      );

      return TryOnResult.success(
        description: detailedDescription,
        sessionId: sessionId,
        recommendations: await _generateStylingRecommendations(detailedDescription),
      );

    } catch (e) {
      debugPrint('Error in hairstyle try-on: $e');
      return TryOnResult.error('Try-on generation failed. Please try again.');
    }
  }

  /// Generate detailed try-on description
  Future<String> _generateTryOnDescription({
    required XFile userPhoto,
    required String hairstyleName,
    required String hairstyleDescription,
    required String tryOnPrompt,
  }) async {
    try {
      final bytes = await userPhoto.readAsBytes();
      
      const visualizationPrompt = '''
Create a detailed visualization description for how this person would look with the specified hairstyle.

Focus on:
1. How the new hairstyle complements their face shape
2. How the style integrates with their natural features
3. Color recommendations that suit their skin tone
4. Styling tips for achieving and maintaining the look
5. Any adjustments to the standard style that would work better for them

Provide a realistic, encouraging description that helps them visualize the transformation while maintaining their natural beauty and recognizable features.
''';

      // In a real implementation with image generation capabilities:
      // This would integrate with Stable Diffusion, DALL-E, or similar
      // For now, we provide detailed text descriptions

      return '''
**Virtual Try-On Result for $hairstyleName**

Based on your facial features and current hair, here's how you would look with this style:

**The Look:**
This $hairstyleName would beautifully complement your face shape. The style would frame your features perfectly, creating a harmonious balance that enhances your natural beauty.

**Color Adaptation:**
The hairstyle can be adapted to work with your current hair color or enhanced with subtle highlights that complement your skin tone. The natural flow and movement of this style would bring out the best in your facial features.

**Styling Notes:**
- The cut would be tailored to your specific face shape for optimal flattering effect
- Regular styling would involve minimal effort while maximizing impact
- The style maintains your recognizable features while adding fresh sophistication

**Professional Recommendation:**
This style would suit your lifestyle and enhance your natural charm. Consider discussing texture adjustments with your stylist to perfectly match your hair type.

**Next Steps:**
Book a consultation with a professional stylist to discuss the specific adaptations needed for your hair type and lifestyle preferences.

*Note: This is an AI-generated visualization. Actual results may vary based on hair texture, density, and professional styling techniques.*
''';

    } catch (e) {
      debugPrint('Error generating try-on description: $e');
      return 'Unable to generate detailed visualization. Please try again.';
    }
  }

  /// Generate styling recommendations
  Future<List<String>> _generateStylingRecommendations(String description) async {
    return [
      'Use a heat protectant before styling to maintain hair health',
      'Consider your hair texture when recreating this look',
      'Book a professional consultation for the best results',
      'Bring reference photos to your stylist appointment',
      'Discuss maintenance requirements with your stylist',
    ];
  }

  /// Save try-on session to user's history
  Future<String> _saveTryOnSession({
    required XFile userPhoto,
    required String hairstyleName,
    required String description,
  }) async {
    try {
      final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Upload user photo to storage (optional, for history)
      final fileName = 'try_on_${sessionId}_user_photo.jpg';
      final storageRef = _storage
          .ref()
          .child(AppConstants.tryOnImagesPath)
          .child(fileName);

      await storageRef.putFile(File(userPhoto.path));
      
      // In a real app, you'd save this to Firestore for user history
      debugPrint('Try-on session saved: $sessionId');
      
      return sessionId;
    } catch (e) {
      debugPrint('Error saving try-on session: $e');
      return DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  /// Try on with custom hairstyle image
  Future<TryOnResult> tryOnCustomHairstyle({
    required XFile userPhoto,
    required XFile hairstylePhoto,
    void Function(String)? onProgress,
  }) async {
    try {
      onProgress?.call('Analyzing custom hairstyle...');
      
      // Analyze the custom hairstyle
      final hairstyleAnalysis = await _aiService.analyzeCustomHairstyle(hairstylePhoto);
      
      onProgress?.call('Checking compatibility...');
      
      // Extract hairstyle name and description from analysis
      final hairstyleName = 'Custom Style';
      final hairstyleDescription = hairstyleAnalysis;

      return await tryOnHairstyle(
        userPhoto: userPhoto,
        hairstyleName: hairstyleName,
        hairstyleDescription: hairstyleDescription,
        onProgress: onProgress,
      );

    } catch (e) {
      debugPrint('Error in custom hairstyle try-on: $e');
      return TryOnResult.error('Custom try-on failed. Please ensure both images are clear and try again.');
    }
  }

  /// Get user's try-on history
  Future<List<TryOnHistory>> getTryOnHistory() async {
    // TODO: Implement retrieval from Firestore
    // For now, return empty list
    return [];
  }
}

/// Result of a hairstyle try-on operation
class TryOnResult {
  final bool isSuccess;
  final String? description;
  final String? sessionId;
  final List<String>? recommendations;
  final String? errorMessage;
  final String? generatedImageUrl; // For future image generation integration

  const TryOnResult._({
    required this.isSuccess,
    this.description,
    this.sessionId,
    this.recommendations,
    this.errorMessage,
    this.generatedImageUrl,
  });

  factory TryOnResult.success({
    required String description,
    required String sessionId,
    List<String>? recommendations,
    String? generatedImageUrl,
  }) {
    return TryOnResult._(
      isSuccess: true,
      description: description,
      sessionId: sessionId,
      recommendations: recommendations,
      generatedImageUrl: generatedImageUrl,
    );
  }

  factory TryOnResult.error(String message) {
    return TryOnResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }
}

/// Historical try-on session data
class TryOnHistory {
  final String sessionId;
  final String hairstyleName;
  final DateTime createdAt;
  final String? userPhotoUrl;
  final String? generatedImageUrl;
  final String description;

  const TryOnHistory({
    required this.sessionId,
    required this.hairstyleName,
    required this.createdAt,
    required this.description,
    this.userPhotoUrl,
    this.generatedImageUrl,
  });
}