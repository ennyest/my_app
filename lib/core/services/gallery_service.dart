import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/hairstyle_model.dart';
import '../constants/app_constants.dart';

class GalleryService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<HairstyleModel> _hairstyles = [];
  List<HairstyleModel> _filteredHairstyles = [];
  bool _isLoading = false;
  String? _error;
  
  // Filter options
  String _selectedCategory = 'All';
  String _selectedDifficulty = 'All';
  String _selectedLength = 'All';
  String _searchQuery = '';

  // Getters
  List<HairstyleModel> get hairstyles => _filteredHairstyles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  String get selectedDifficulty => _selectedDifficulty;
  String get selectedLength => _selectedLength;
  String get searchQuery => _searchQuery;

  /// Load all approved hairstyles from Firestore
  Future<void> loadHairstyles() async {
    try {
      _setLoading(true);
      _error = null;

      // Wait a bit to ensure user authentication is complete
      await Future.delayed(const Duration(milliseconds: 500));

      final QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.hairstylesCollection)
          .where('isApproved', isEqualTo: true)
          .where('isRejected', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      _hairstyles = snapshot.docs
          .map((doc) => HairstyleModel.fromFirestore(doc))
          .toList();

      debugPrint('Loaded ${_hairstyles.length} hairstyles from Firestore');
      _applyFilters();
    } catch (e) {
      debugPrint('Error loading hairstyles: $e');
      
      // Handle permission denied errors gracefully
      if (e.toString().contains('permission-denied')) {
        _error = 'Please wait while we set up your account. If this persists, try signing out and back in.';
        // Try again after a delay
        Future.delayed(const Duration(seconds: 3), () {
          if (_hairstyles.isEmpty) {
            loadHairstyles();
          }
        });
      } else {
        _error = 'Failed to load hairstyles. Please check your internet connection.';
      }
      
      // Set empty list to show "no hairstyles" message instead of loading
      _hairstyles = [];
      _applyFilters();
    } finally {
      _setLoading(false);
    }
  }

  /// Apply filters and search to hairstyles
  void _applyFilters() {
    _filteredHairstyles = _hairstyles.where((hairstyle) {
      // Category filter
      bool categoryMatch = _selectedCategory == 'All' || 
          hairstyle.category.toLowerCase() == _selectedCategory.toLowerCase();

      // Difficulty filter
      bool difficultyMatch = _selectedDifficulty == 'All' || 
          hairstyle.difficulty.toLowerCase() == _selectedDifficulty.toLowerCase();

      // Length filter
      bool lengthMatch = _selectedLength == 'All' || 
          hairstyle.length.toLowerCase() == _selectedLength.toLowerCase();

      // Search filter
      bool searchMatch = _searchQuery.isEmpty ||
          hairstyle.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          hairstyle.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          hairstyle.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));

      return categoryMatch && difficultyMatch && lengthMatch && searchMatch;
    }).toList();

    notifyListeners();
  }

  /// Update search query
  void updateSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  /// Update filters
  void updateFilters({
    String? category,
    String? difficulty,
    String? length,
  }) {
    if (category != null) _selectedCategory = category;
    if (difficulty != null) _selectedDifficulty = difficulty;
    if (length != null) _selectedLength = length;
    
    _applyFilters();
  }

  /// Clear all filters
  void clearFilters() {
    _selectedCategory = 'All';
    _selectedDifficulty = 'All';
    _selectedLength = 'All';
    _searchQuery = '';
    _applyFilters();
  }

  /// Like a hairstyle
  Future<void> likeHairstyle(String hairstyleId, bool isLiked) async {
    try {
      // Find the hairstyle in our local list
      final hairstyleIndex = _hairstyles.indexWhere((h) => h.styleId == hairstyleId);
      if (hairstyleIndex == -1) return;

      final hairstyle = _hairstyles[hairstyleIndex];
      final newLikes = isLiked ? hairstyle.likes + 1 : hairstyle.likes - 1;

      // Update Firestore
      await _firestore
          .collection(AppConstants.hairstylesCollection)
          .doc(hairstyleId)
          .update({'likes': newLikes});

      // Update local data
      _hairstyles[hairstyleIndex] = hairstyle.copyWith(likes: newLikes);
      _applyFilters();
    } catch (e) {
      debugPrint('Error liking hairstyle: $e');
    }
  }

  /// Get popular hairstyles (top liked)
  List<HairstyleModel> getPopularHairstyles({int limit = 10}) {
    final sortedHairstyles = List<HairstyleModel>.from(_hairstyles)
      ..sort((a, b) => b.likes.compareTo(a.likes));
    
    return sortedHairstyles.take(limit).toList();
  }

  /// Get hairstyles by category
  List<HairstyleModel> getHairstylesByCategory(String category) {
    if (category == 'All') return _hairstyles;
    
    return _hairstyles
        .where((hairstyle) => hairstyle.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  /// Get recommended hairstyles based on user preferences
  List<HairstyleModel> getRecommendedHairstyles({
    String? preferredCategory,
    String? preferredDifficulty,
    String? preferredLength,
    int limit = 5,
  }) {
    List<HairstyleModel> recommended = List<HairstyleModel>.from(_hairstyles);

    // Filter by preferences if provided
    if (preferredCategory != null && preferredCategory != 'All') {
      recommended = recommended
          .where((h) => h.category.toLowerCase() == preferredCategory.toLowerCase())
          .toList();
    }

    if (preferredDifficulty != null && preferredDifficulty != 'All') {
      recommended = recommended
          .where((h) => h.difficulty.toLowerCase() == preferredDifficulty.toLowerCase())
          .toList();
    }

    if (preferredLength != null && preferredLength != 'All') {
      recommended = recommended
          .where((h) => h.length.toLowerCase() == preferredLength.toLowerCase())
          .toList();
    }

    // Sort by likes and return limited results
    recommended.sort((a, b) => b.likes.compareTo(a.likes));
    return recommended.take(limit).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}