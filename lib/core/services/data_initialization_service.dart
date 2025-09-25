import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';
import '../../shared/models/hairstyle_model.dart';

class DataInitializationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize sample data for new installations
  static Future<void> initializeSampleData() async {
    try {
      // Check if hairstyles collection already has data
      final QuerySnapshot existingHairstyles = await _firestore
          .collection(AppConstants.hairstylesCollection)
          .limit(1)
          .get();

      if (existingHairstyles.docs.isNotEmpty) {
        debugPrint('Sample data already exists, skipping initialization');
        return;
      }

      debugPrint('Initializing sample hairstyle data...');

      // Sample hairstyles to add
      final List<Map<String, dynamic>> sampleHairstyles = [
        {
          'name': 'Classic Box Braids',
          'description': 'Traditional protective style perfect for all occasions. Easy to maintain and stylish.',
          'imageUrl': 'https://images.unsplash.com/photo-1594736797933-d0801ba2fe65?w=400&h=600&fit=crop',
          'category': 'braids',
          'tags': ['protective', 'classic', 'versatile'],
          'difficulty': 'medium',
          'length': 'long',
          'isPreloaded': true,
          'uploadedBy': null,
          'likes': 150,
          'isApproved': true,
          'isRejected': false,
          'approvedAt': DateTime.now(),
        },
        {
          'name': 'Natural Afro',
          'description': 'Embrace your natural texture with this beautiful afro style. Perfect for showcasing your natural hair.',
          'imageUrl': 'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=400&h=600&fit=crop',
          'category': 'natural',
          'tags': ['natural', 'afro', 'textured'],
          'difficulty': 'easy',
          'length': 'medium',
          'isPreloaded': true,
          'uploadedBy': null,
          'likes': 234,
          'isApproved': true,
          'isRejected': false,
          'approvedAt': DateTime.now(),
        },
        {
          'name': 'Elegant Updo',
          'description': 'Sophisticated updo perfect for formal events and special occasions.',
          'imageUrl': 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=400&h=600&fit=crop',
          'category': 'updos',
          'tags': ['formal', 'elegant', 'special-occasion'],
          'difficulty': 'hard',
          'length': 'long',
          'isPreloaded': true,
          'uploadedBy': null,
          'likes': 167,
          'isApproved': true,
          'isRejected': false,
          'approvedAt': DateTime.now(),
        },
        {
          'name': 'Curly Bob',
          'description': 'Chic and modern bob with beautiful curls. Perfect for a trendy, manageable style.',
          'imageUrl': 'https://images.unsplash.com/photo-1487412912498-0447578fcca8?w=400&h=600&fit=crop',
          'category': 'bobs',
          'tags': ['curly', 'modern', 'chic'],
          'difficulty': 'easy',
          'length': 'short',
          'isPreloaded': true,
          'uploadedBy': null,
          'likes': 89,
          'isApproved': true,
          'isRejected': false,
          'approvedAt': DateTime.now(),
        },
        {
          'name': 'Twist Out',
          'description': 'Beautiful defined curls achieved through the twist-out method. Great for natural hair.',
          'imageUrl': 'https://images.unsplash.com/photo-1580618672591-eb180b1a973f?w=400&h=600&fit=crop',
          'category': 'curls',
          'tags': ['twist-out', 'natural', 'defined-curls'],
          'difficulty': 'medium',
          'length': 'medium',
          'isPreloaded': true,
          'uploadedBy': null,
          'likes': 198,
          'isApproved': true,
          'isRejected': false,
          'approvedAt': DateTime.now(),
        },
        {
          'name': 'High Ponytail',
          'description': 'Sleek and stylish high ponytail. Perfect for both casual and formal settings.',
          'imageUrl': 'https://images.unsplash.com/photo-1520975661595-6453be3f7070?w=400&h=600&fit=crop',
          'category': 'ponytails',
          'tags': ['sleek', 'high', 'versatile'],
          'difficulty': 'easy',
          'length': 'long',
          'isPreloaded': true,
          'uploadedBy': null,
          'likes': 145,
          'isApproved': true,
          'isRejected': false,
          'approvedAt': DateTime.now(),
        },
      ];

      // Add each sample hairstyle to Firestore
      final batch = _firestore.batch();
      
      for (final hairstyleData in sampleHairstyles) {
        final docRef = _firestore.collection(AppConstants.hairstylesCollection).doc();
        
        final hairstyleMap = {
          ...hairstyleData,
          'createdAt': Timestamp.now(),
          'approvedAt': Timestamp.now(),
        };
        
        batch.set(docRef, hairstyleMap);
      }

      await batch.commit();
      debugPrint('Sample hairstyle data initialized successfully');

    } catch (e) {
      debugPrint('Error initializing sample data: $e');
      // Don\\'t throw error as this is not critical for app functionality
    }
  }

  /// Check if app needs initialization (no data exists)
  static Future<bool> needsInitialization() async {
    try {
      final QuerySnapshot hairstyles = await _firestore
          .collection(AppConstants.hairstylesCollection)
          .limit(1)
          .get();

      return hairstyles.docs.isEmpty;
    } catch (e) {
      debugPrint('Error checking if initialization needed: $e');
      return false;
    }
  }
}