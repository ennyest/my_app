class AppConstants {
  // App Information
  static const String appName = 'HairStyle AI';
  static const String appVersion = '1.0.0';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String hairstylesCollection = 'hairstyles';
  static const String userGalleriesCollection = 'userGalleries';
  static const String postsCollection = 'posts';
  
  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String hairstyleImagesPath = 'hairstyle_images';
  static const String tryOnImagesPath = 'try_on_images';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Image Sizes
  static const double profileImageSize = 120.0;
  static const double thumbnailSize = 80.0;
  static const double galleryImageHeight = 200.0;
  
  // Camera Settings
  static const double cameraAspectRatio = 4/3;
  static const int maxImageSize = 2048;
  static const int imageQuality = 85;
  
  // AI Settings
  static const int maxRecommendations = 10;
  static const double minCompatibilityScore = 0.3;
  
  // Social Features
  static const int maxPostLength = 500;
  static const int maxCommentLength = 200;
  
  // Error Messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String unknownError = 'An unknown error occurred.';
  static const String authError = 'Authentication failed. Please try again.';
  static const String cameraError = 'Camera access denied. Please enable camera permissions.';
  static const String storageError = 'Failed to save image. Please try again.';
}

class HairTypes {
  static const String curly = 'curly';
  static const String straight = 'straight';
  static const String kinky = 'kinky';
  static const String wavy = 'wavy';
  
  static const List<String> all = [curly, straight, kinky, wavy];
}

class HairLengths {
  static const String short = 'short';
  static const String medium = 'medium';
  static const String long = 'long';
  
  static const List<String> all = [short, medium, long];
}

class FaceShapes {
  static const String oval = 'oval';
  static const String round = 'round';
  static const String square = 'square';
  static const String heart = 'heart';
  static const String diamond = 'diamond';
  
  static const List<String> all = [oval, round, square, heart, diamond];
}

class SkinTones {
  static const String warm = 'warm';
  static const String cool = 'cool';
  static const String neutral = 'neutral';
  
  static const List<String> all = [warm, cool, neutral];
}

class DifficultyLevels {
  static const String easy = 'easy';
  static const String medium = 'medium';
  static const String hard = 'hard';
  
  static const List<String> all = [easy, medium, hard];
}

class HairCategories {
  static const String braids = 'braids';
  static const String curls = 'curls';
  static const String natural = 'natural';
  static const String updos = 'updos';
  static const String bobs = 'bobs';
  static const String pixie = 'pixie';
  static const String ponytails = 'ponytails';
  static const String bangs = 'bangs';
  
  static const List<String> all = [
    braids, curls, natural, updos, 
    bobs, pixie, ponytails, bangs
  ];
}
