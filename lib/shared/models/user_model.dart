import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String email;
  final String displayName;
  final String? profileImage;
  final UserPreferences preferences;
  final DateTime createdAt;
  final DateTime lastActive;

  UserModel({
    required this.userId,
    required this.email,
    required this.displayName,
    this.profileImage,
    required this.preferences,
    required this.createdAt,
    required this.lastActive,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      userId: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      profileImage: data['profileImage'],
      preferences: UserPreferences.fromMap(data['preferences'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastActive: (data['lastActive'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'profileImage': profileImage,
      'preferences': preferences.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
    };
  }

  UserModel copyWith({
    String? userId,
    String? email,
    String? displayName,
    String? profileImage,
    UserPreferences? preferences,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      profileImage: profileImage ?? this.profileImage,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}

class UserPreferences {
  final String hairType; // curly, straight, kinky, wavy
  final String preferredLength; // short, medium, long
  final List<String> colorPreferences;
  final String faceShape; // oval, round, square, heart, diamond
  final String skinTone; // warm, cool, neutral

  UserPreferences({
    required this.hairType,
    required this.preferredLength,
    required this.colorPreferences,
    required this.faceShape,
    required this.skinTone,
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      hairType: map['hairType'] ?? 'straight',
      preferredLength: map['preferredLength'] ?? 'medium',
      colorPreferences: List<String>.from(map['colorPreferences'] ?? []),
      faceShape: map['faceShape'] ?? 'oval',
      skinTone: map['skinTone'] ?? 'neutral',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hairType': hairType,
      'preferredLength': preferredLength,
      'colorPreferences': colorPreferences,
      'faceShape': faceShape,
      'skinTone': skinTone,
    };
  }

  UserPreferences copyWith({
    String? hairType,
    String? preferredLength,
    List<String>? colorPreferences,
    String? faceShape,
    String? skinTone,
  }) {
    return UserPreferences(
      hairType: hairType ?? this.hairType,
      preferredLength: preferredLength ?? this.preferredLength,
      colorPreferences: colorPreferences ?? this.colorPreferences,
      faceShape: faceShape ?? this.faceShape,
      skinTone: skinTone ?? this.skinTone,
    );
  }
}
