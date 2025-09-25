import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  user,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.user:
        return 'User';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'user':
      default:
        return UserRole.user;
    }
  }
}

class UserModel {
  final String userId;
  final String email;
  final String displayName;
  final String? profileImage;
  final UserPreferences preferences;
  final DateTime createdAt;
  final DateTime lastActive;
  final UserRole role;
  final bool isActive;

  UserModel({
    required this.userId,
    required this.email,
    required this.displayName,
    this.profileImage,
    required this.preferences,
    required this.createdAt,
    required this.lastActive,
    this.role = UserRole.user,
    this.isActive = true,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
    
    return UserModel(
      userId: doc.id,
      email: data['email'] ?? 'No Email',
      displayName: data['displayName'] ?? 'No Name',
      profileImage: data['profileImage'],
      preferences: UserPreferences.fromMap(data['preferences'] ?? {}),
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      lastActive: data['lastActive'] != null 
          ? (data['lastActive'] as Timestamp).toDate() 
          : DateTime.now(),
      role: UserRole.fromString(data['role'] ?? 'user'),
      isActive: data['isActive'] ?? true,
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
      'role': role.name,
      'isActive': isActive,
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
    UserRole? role,
    bool? isActive,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      profileImage: profileImage ?? this.profileImage,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
    );
  }

  bool get isAdmin => role == UserRole.admin;
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
      hairType: map['hairType']?.toString() ?? 'straight',
      preferredLength: map['preferredLength']?.toString() ?? 'medium',
      colorPreferences: map['colorPreferences'] != null 
          ? List<String>.from(map['colorPreferences']) 
          : [],
      faceShape: map['faceShape']?.toString() ?? 'oval',
      skinTone: map['skinTone']?.toString() ?? 'neutral',
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
