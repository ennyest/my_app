class AppConfig {
  // Gemini AI Configuration
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
  
  // TODO: In production, use environment variables or secure storage
  // Example: const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
  
  // Development configuration
  static const bool isDevelopment = true;
  static const bool enableLogging = true;
  
  // AI Model Configuration
  static const String defaultModel = 'gemini-2.0-flash-exp';
  static const String visionModel = 'gemini-2.0-flash-exp';
  
  // Image Analysis Configuration
  static const int maxImageSize = 4 * 1024 * 1024; // 4MB
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  
  // Try-on Configuration
  static const int maxTryOnHistoryItems = 50;
  static const Duration analysisTimeout = Duration(minutes: 2);
  
  // Error Messages
  static const String apiKeyMissingError = 
      'Gemini API key is not configured. Please add your API key to continue.';
  static const String networkError = 
      'Network connection failed. Please check your internet connection.';
  static const String imageAnalysisError = 
      'Failed to analyze image. Please try again with a clear photo.';
}