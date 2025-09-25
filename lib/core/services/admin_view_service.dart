import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage admin interface switching
/// Allows admins to toggle between admin view and user view
class AdminViewService extends ChangeNotifier {
  static const String _adminViewKey = 'admin_view_enabled';
  
  bool _isAdminViewEnabled = true;
  bool _isLoading = false;
  
  bool get isAdminViewEnabled => _isAdminViewEnabled;
  bool get isLoading => _isLoading;
  
  AdminViewService() {
    _loadAdminViewPreference();
  }
  
  /// Load the admin view preference from shared preferences
  Future<void> _loadAdminViewPreference() async {
    try {
      _setLoading(true);
      final prefs = await SharedPreferences.getInstance();
      _isAdminViewEnabled = prefs.getBool(_adminViewKey) ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading admin view preference: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Toggle between admin view and user view
  Future<void> toggleAdminView() async {
    try {
      _setLoading(true);
      final prefs = await SharedPreferences.getInstance();
      _isAdminViewEnabled = !_isAdminViewEnabled;
      await prefs.setBool(_adminViewKey, _isAdminViewEnabled);
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling admin view: $e');
      // Revert the change if saving failed
      _isAdminViewEnabled = !_isAdminViewEnabled;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }
  
  /// Enable admin view
  Future<void> enableAdminView() async {
    if (!_isAdminViewEnabled) {
      await toggleAdminView();
    }
  }
  
  /// Enable user view
  Future<void> enableUserView() async {
    if (_isAdminViewEnabled) {
      await toggleAdminView();
    }
  }
  
  /// Reset to admin view (useful for logout/login scenarios)
  Future<void> resetToAdminView() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAdminViewEnabled = true;
      await prefs.setBool(_adminViewKey, true);
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting to admin view: $e');
    }
  }
  
  /// Get current view mode as string
  String get currentViewMode => _isAdminViewEnabled ? 'Admin View' : 'User View';
  
  /// Get current view description
  String get currentViewDescription => _isAdminViewEnabled 
      ? 'You are currently viewing the admin interface'
      : 'You are currently viewing the user interface';
  
  /// Get toggle button text
  String get toggleButtonText => _isAdminViewEnabled 
      ? 'Switch to User View' 
      : 'Switch to Admin View';
  
  /// Get toggle button icon
  IconData get toggleButtonIcon => _isAdminViewEnabled 
      ? Icons.person_outline 
      : Icons.admin_panel_settings;
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  /// Clear all preferences (useful for logout)
  Future<void> clearPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_adminViewKey);
      _isAdminViewEnabled = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing admin view preferences: $e');
    }
  }
}