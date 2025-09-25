import 'package:cloud_firestore/cloud_firestore.dart';

class HairstyleModel {
  final String styleId;
  final String name;
  final String description;
  final String imageUrl;
  final String? videoUrl;
  final String category;
  final List<String> tags;
  final String difficulty; // easy, medium, hard
  final String length; // short, medium, long
  final bool isPreloaded;
  final String? uploadedBy; // userId if user-uploaded
  final int likes;
  final DateTime createdAt;

  HairstyleModel({
    required this.styleId,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.videoUrl,
    required this.category,
    required this.tags,
    required this.difficulty,
    required this.length,
    required this.isPreloaded,
    this.uploadedBy,
    required this.likes,
    required this.createdAt,
  });

  factory HairstyleModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return HairstyleModel(
      styleId: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      videoUrl: data['videoUrl'],
      category: data['category'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      difficulty: data['difficulty'] ?? 'easy',
      length: data['length'] ?? 'medium',
      isPreloaded: data['isPreloaded'] ?? false,
      uploadedBy: data['uploadedBy'],
      likes: data['likes'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'category': category,
      'tags': tags,
      'difficulty': difficulty,
      'length': length,
      'isPreloaded': isPreloaded,
      'uploadedBy': uploadedBy,
      'likes': likes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  HairstyleModel copyWith({
    String? styleId,
    String? name,
    String? description,
    String? imageUrl,
    String? videoUrl,
    String? category,
    List<String>? tags,
    String? difficulty,
    String? length,
    bool? isPreloaded,
    String? uploadedBy,
    int? likes,
    DateTime? createdAt,
  }) {
    return HairstyleModel(
      styleId: styleId ?? this.styleId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      difficulty: difficulty ?? this.difficulty,
      length: length ?? this.length,
      isPreloaded: isPreloaded ?? this.isPreloaded,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class StyleRecommendation {
  final HairstyleModel hairstyle;
  final double compatibilityScore; // 0.0 to 1.0
  final List<String> reasons;
  final String? colorSuggestion;

  StyleRecommendation({
    required this.hairstyle,
    required this.compatibilityScore,
    required this.reasons,
    this.colorSuggestion,
  });
}

class StyleEvaluation {
  final double overallScore; // 0.0 to 1.0
  final double faceShapeMatch;
  final double hairTypeCompatibility;
  final double colorHarmony;
  final List<String> strengths;
  final List<String> improvements;
  final String? alternativeSuggestion;

  StyleEvaluation({
    required this.overallScore,
    required this.faceShapeMatch,
    required this.hairTypeCompatibility,
    required this.colorHarmony,
    required this.strengths,
    required this.improvements,
    this.alternativeSuggestion,
  });
}

class ColorRecommendation {
  final String primaryColor;
  final List<String> complementaryColors;
  final String skinToneMatch;
  final String reasoning;

  ColorRecommendation({
    required this.primaryColor,
    required this.complementaryColors,
    required this.skinToneMatch,
    required this.reasoning,
  });
}
