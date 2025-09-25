import 'package:cloud_firestore/cloud_firestore.dart';

class UserGallery {
  final String userId;
  final List<String> savedStyles; // styleIds
  final List<String> customUploads; // styleIds
  final List<TryOnHistory> tryOnHistory;

  UserGallery({
    required this.userId,
    required this.savedStyles,
    required this.customUploads,
    required this.tryOnHistory,
  });

  factory UserGallery.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserGallery(
      userId: doc.id,
      savedStyles: List<String>.from(data['savedStyles'] ?? []),
      customUploads: List<String>.from(data['customUploads'] ?? []),
      tryOnHistory: (data['tryOnHistory'] as List<dynamic>?)
          ?.map((item) => TryOnHistory.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'savedStyles': savedStyles,
      'customUploads': customUploads,
      'tryOnHistory': tryOnHistory.map((item) => item.toMap()).toList(),
    };
  }

  UserGallery copyWith({
    String? userId,
    List<String>? savedStyles,
    List<String>? customUploads,
    List<TryOnHistory>? tryOnHistory,
  }) {
    return UserGallery(
      userId: userId ?? this.userId,
      savedStyles: savedStyles ?? this.savedStyles,
      customUploads: customUploads ?? this.customUploads,
      tryOnHistory: tryOnHistory ?? this.tryOnHistory,
    );
  }
}

class TryOnHistory {
  final String id;
  final String styleId;
  final String imageUrl;
  final DateTime timestamp;
  final double? satisfactionRating;
  final String? notes;

  TryOnHistory({
    required this.id,
    required this.styleId,
    required this.imageUrl,
    required this.timestamp,
    this.satisfactionRating,
    this.notes,
  });

  factory TryOnHistory.fromMap(Map<String, dynamic> map) {
    return TryOnHistory(
      id: map['id'] ?? '',
      styleId: map['styleId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      satisfactionRating: map['satisfactionRating']?.toDouble(),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'styleId': styleId,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'satisfactionRating': satisfactionRating,
      'notes': notes,
    };
  }

  TryOnHistory copyWith({
    String? id,
    String? styleId,
    String? imageUrl,
    DateTime? timestamp,
    double? satisfactionRating,
    String? notes,
  }) {
    return TryOnHistory(
      id: id ?? this.id,
      styleId: styleId ?? this.styleId,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      satisfactionRating: satisfactionRating ?? this.satisfactionRating,
      notes: notes ?? this.notes,
    );
  }
}

class GalleryFilter {
  final String? category;
  final List<String>? tags;
  final String? difficulty;
  final String? length;
  final String? searchQuery;
  final bool? isPreloaded;

  GalleryFilter({
    this.category,
    this.tags,
    this.difficulty,
    this.length,
    this.searchQuery,
    this.isPreloaded,
  });

  GalleryFilter copyWith({
    String? category,
    List<String>? tags,
    String? difficulty,
    String? length,
    String? searchQuery,
    bool? isPreloaded,
  }) {
    return GalleryFilter(
      category: category ?? this.category,
      tags: tags ?? this.tags,
      difficulty: difficulty ?? this.difficulty,
      length: length ?? this.length,
      searchQuery: searchQuery ?? this.searchQuery,
      isPreloaded: isPreloaded ?? this.isPreloaded,
    );
  }

  bool get isEmpty {
    return category == null &&
        (tags == null || tags!.isEmpty) &&
        difficulty == null &&
        length == null &&
        (searchQuery == null || searchQuery!.isEmpty) &&
        isPreloaded == null;
  }
}
