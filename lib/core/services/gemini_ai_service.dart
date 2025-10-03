import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import '../config/app_config.dart';

class GeminiAIService {
  static const String _apiKey = AppConfig.geminiApiKey;
  late final GenerativeModel _model;
  late final GenerativeModel _visionModel;
  
  static final GeminiAIService _instance = GeminiAIService._internal();
  factory GeminiAIService() => _instance;
  
  GeminiAIService._internal() {
    if (_apiKey == 'YOUR_GEMINI_API_KEY_HERE' || _apiKey.isEmpty) {
      throw Exception(AppConfig.apiKeyMissingError);
    }
    
    _model = GenerativeModel(
      model: AppConfig.defaultModel,
      apiKey: _apiKey,
    );
    
    _visionModel = GenerativeModel(
      model: AppConfig.visionModel,
      apiKey: _apiKey,
    );
  }

  /// System prompt for hairstyle analysis
  static const String _hairstyleAnalysisPrompt = '''
You are an expert hair stylist and beauty consultant AI. Analyze the provided photo and provide detailed, personalized hairstyle recommendations.

ANALYSIS REQUIREMENTS:
1. Face Shape Analysis: Identify the person's face shape (oval, round, square, heart, diamond, oblong)
2. Current Hair Assessment: Describe current hair length, texture, color, and condition
3. Facial Features: Note key features that influence hairstyle choices (forehead size, jawline, cheekbones)
4. Skin Tone Analysis: Determine warm, cool, or neutral undertones for color recommendations

RECOMMENDATIONS FORMAT:
- Provide 3-5 specific hairstyle recommendations
- For each recommendation, explain WHY it would work well for their face shape and features
- Include styling tips and maintenance requirements
- Suggest hair colors that would complement their skin tone
- Consider lifestyle factors (professional vs. casual)

TONE: Professional, encouraging, and detailed. Focus on enhancing natural beauty while providing practical advice.
''';

  /// System prompt for hairstyle try-on generation
  static const String _tryOnGenerationPrompt = '''
You are an AI hairstyle visualization expert. Your task is to help generate realistic hairstyle try-on images.

CRITICAL REQUIREMENTS:
1. PRESERVE IDENTITY: The person must remain completely recognizable - same face, same features, same facial structure
2. NATURAL INTEGRATION: The new hairstyle must look naturally integrated with the person's head shape and size
3. REALISTIC LIGHTING: Match lighting, shadows, and color temperature of the original photo
4. MAINTAIN QUALITY: Preserve photo quality and resolution
5. PRESERVE BACKGROUND: Keep the original background unchanged

HAIRSTYLE APPLICATION RULES:
- Respect natural hairline and head shape
- Ensure proper hair density and volume
- Match hair color to complement skin tone unless specifically requested otherwise
- Consider face shape when applying the style
- Maintain realistic hair physics and flow

WHAT TO AVOID:
- Changing facial features, skin tone, or bone structure
- Unrealistic hair colors or impossible styles
- Poor blending or obvious editing artifacts
- Changing the person's apparent age or identity
- Modifying anything other than the hair

PROCESS:
1. Analyze the person's face shape, skin tone, and current features
2. Adapt the reference hairstyle to suit their specific features
3. Apply the hairstyle while preserving all original facial characteristics
4. Ensure seamless integration and natural appearance
''';

  /// System prompt for hair color analysis
  static const String _colorAnalysisPrompt = '''
You are a professional hair colorist AI. Analyze the person's features to recommend optimal hair colors.

ANALYSIS FOCUS:
1. Skin Undertones: Determine warm, cool, or neutral undertones
2. Eye Color Coordination: Consider how hair colors will complement eye color
3. Complexion Enhancement: Choose colors that brighten and flatter the complexion
4. Lifestyle Considerations: Factor in maintenance requirements

RECOMMENDATIONS:
- Primary color suggestions with detailed reasoning
- Highlight and lowlight options
- Seasonal color variations
- Maintenance schedules and care tips
- Professional vs. at-home application advice

Always prioritize colors that enhance natural beauty and are achievable for the person's starting hair color and condition.
''';

  /// Analyze user's photo for hairstyle recommendations
  Future<String> analyzeHairAndFace(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      
      final content = [
        Content.multi([
          TextPart(_hairstyleAnalysisPrompt),
          DataPart('image/jpeg', bytes),
        ])
      ];

      final response = await _visionModel.generateContent(content);
      return response.text ?? 'Unable to analyze the image. Please try again.';
      
    } catch (e) {
      debugPrint('Error analyzing hair and face: $e');
      return 'Analysis failed. Please ensure you have a clear photo showing your face and try again.';
    }
  }

  /// Generate hairstyle try-on description for image generation
  Future<String> generateTryOnPrompt({
    required XFile userPhoto,
    required String hairstyleName,
    required String hairstyleDescription,
    String? hairstyleImageUrl,
  }) async {
    try {
      final bytes = await userPhoto.readAsBytes();
      
      final analysisPrompt = '''
Analyze this person's features and create a detailed prompt for generating a realistic hairstyle try-on.

TARGET HAIRSTYLE: $hairstyleName
DESCRIPTION: $hairstyleDescription

Create a detailed generation prompt that:
1. Describes how to apply this specific hairstyle to this person
2. Ensures their facial features remain unchanged
3. Provides specific technical details for realistic application
4. Considers their face shape and current features

Format as a clear, technical prompt for image generation.
''';

      final content = [
        Content.multi([
          TextPart(analysisPrompt),
          DataPart('image/jpeg', bytes),
        ])
      ];

      final response = await _visionModel.generateContent(content);
      return response.text ?? 'Unable to generate try-on prompt.';
      
    } catch (e) {
      debugPrint('Error generating try-on prompt: $e');
      return 'Failed to create try-on visualization prompt.';
    }
  }

  /// Analyze hair color compatibility
  Future<String> analyzeHairColorOptions(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      
      final content = [
        Content.multi([
          TextPart(_colorAnalysisPrompt),
          DataPart('image/jpeg', bytes),
        ])
      ];

      final response = await _visionModel.generateContent(content);
      return response.text ?? 'Unable to analyze hair color options.';
      
    } catch (e) {
      debugPrint('Error analyzing hair color: $e');
      return 'Color analysis failed. Please try again with a clear photo.';
    }
  }

  /// Get personalized hairstyle recommendations based on preferences
  Future<String> getPersonalizedRecommendations({
    required XFile userPhoto,
    required String preferences,
    required String lifestyle,
    required String hairGoals,
  }) async {
    try {
      final bytes = await userPhoto.readAsBytes();
      
      final personalizedPrompt = '''
$_hairstyleAnalysisPrompt

ADDITIONAL CONTEXT:
User Preferences: $preferences
Lifestyle: $lifestyle
Hair Goals: $hairGoals

Provide highly personalized recommendations that align with their stated preferences and lifestyle.
''';

      final content = [
        Content.multi([
          TextPart(personalizedPrompt),
          DataPart('image/jpeg', bytes),
        ])
      ];

      final response = await _visionModel.generateContent(content);
      return response.text ?? 'Unable to generate personalized recommendations.';
      
    } catch (e) {
      debugPrint('Error getting personalized recommendations: $e');
      return 'Failed to generate personalized recommendations. Please try again.';
    }
  }

  /// Generate detailed hairstyle description for custom uploads
  Future<String> analyzeCustomHairstyle(XFile hairstyleImage) async {
    try {
      final bytes = await hairstyleImage.readAsBytes();
      
      const customAnalysisPrompt = '''
Analyze this hairstyle image and provide a detailed description that could be used for try-on generation.

DESCRIBE:
1. Hair length and layers
2. Styling technique and texture
3. Volume and movement patterns
4. Color and highlights/lowlights
5. Face shapes this style would suit
6. Styling requirements and maintenance
7. Professional vs. casual appropriateness

Provide a comprehensive description that would help recreate this style on different people.
''';

      final content = [
        Content.multi([
          TextPart(customAnalysisPrompt),
          DataPart('image/jpeg', bytes),
        ])
      ];

      final response = await _visionModel.generateContent(content);
      return response.text ?? 'Unable to analyze the hairstyle image.';
      
    } catch (e) {
      debugPrint('Error analyzing custom hairstyle: $e');
      return 'Failed to analyze the hairstyle. Please try again with a clear image.';
    }
  }

  /// Generate hair care recommendations
  Future<String> generateHairCareAdvice({
    required XFile userPhoto,
    required String currentRoutine,
    required String concerns,
  }) async {
    try {
      final bytes = await userPhoto.readAsBytes();
      
      final carePrompt = '''
As a professional hair care specialist, analyze this person's hair and provide personalized care recommendations.

CURRENT ROUTINE: $currentRoutine
HAIR CONCERNS: $concerns

Provide specific advice on:
1. Daily care routine optimization
2. Product recommendations for their hair type
3. Treatment suggestions for their concerns
4. Protective styling options
5. Frequency for cuts and treatments
6. Seasonal care adjustments

Focus on practical, achievable recommendations that address their specific concerns.
''';

      final content = [
        Content.multi([
          TextPart(carePrompt),
          DataPart('image/jpeg', bytes),
        ])
      ];

      final response = await _visionModel.generateContent(content);
      return response.text ?? 'Unable to generate hair care advice.';
      
    } catch (e) {
      debugPrint('Error generating hair care advice: $e');
      return 'Failed to generate care recommendations. Please try again.';
    }
  }

  /// Validate if image is suitable for hair analysis
  Future<bool> validateImageForAnalysis(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      
      const validationPrompt = '''
Analyze if this image is suitable for hair and face analysis. 

Check for:
1. Clear visibility of face and hair
2. Good lighting and image quality
3. Face is not obscured by objects/hands
4. Image orientation is correct
5. Single person in focus

Respond with only "VALID" if suitable for analysis, or "INVALID: [reason]" if not suitable.
''';

      final content = [
        Content.multi([
          TextPart(validationPrompt),
          DataPart('image/jpeg', bytes),
        ])
      ];

      final response = await _visionModel.generateContent(content);
      final result = response.text ?? 'INVALID: Unable to analyze';
      
      return result.toUpperCase().startsWith('VALID');
      
    } catch (e) {
      debugPrint('Error validating image: $e');
      return false;
    }
  }
}