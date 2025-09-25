import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Request camera permission
  static Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting camera permission: $e');
      return false;
    }
  }

  /// Request storage/photos permission
  static Future<bool> requestStoragePermission() async {
    try {
      PermissionStatus status;
      
      // For Android 13+ (API 33+), use photos permission
      if (await _isAndroid13OrHigher()) {
        status = await Permission.photos.request();
      } else {
        // For older Android versions, use storage permission
        status = await Permission.storage.request();
      }
      
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting storage permission: $e');
      return false;
    }
  }

  /// Check if camera permission is granted
  static Future<bool> isCameraPermissionGranted() async {
    try {
      final status = await Permission.camera.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('Error checking camera permission: $e');
      return false;
    }
  }

  /// Check if storage permission is granted
  static Future<bool> isStoragePermissionGranted() async {
    try {
      PermissionStatus status;
      
      if (await _isAndroid13OrHigher()) {
        status = await Permission.photos.status;
      } else {
        status = await Permission.storage.status;
      }
      
      return status.isGranted;
    } catch (e) {
      debugPrint('Error checking storage permission: $e');
      return false;
    }
  }

  /// Request both camera and storage permissions
  static Future<Map<String, bool>> requestCameraAndStoragePermissions() async {
    try {
      Map<Permission, PermissionStatus> statuses;
      
      if (await _isAndroid13OrHigher()) {
        statuses = await [
          Permission.camera,
          Permission.photos,
        ].request();
      } else {
        statuses = await [
          Permission.camera,
          Permission.storage,
        ].request();
      }

      return {
        'camera': statuses[Permission.camera]?.isGranted ?? false,
        'storage': (statuses[Permission.photos]?.isGranted ?? 
                   statuses[Permission.storage]?.isGranted) ?? false,
      };
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      return {'camera': false, 'storage': false};
    }
  }

  /// Show permission denied dialog
  static void showPermissionDeniedDialog(
    BuildContext context, {
    required String permission,
    required VoidCallback onOpenSettings,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permission Permission Required'),
        content: Text(
          'This app needs $permission permission to function properly. '
          'Please grant the permission in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onOpenSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Open app settings
  static Future<void> openSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      debugPrint('Error opening app settings: $e');
    }
  }

  /// Check if we're running on Android 13 or higher
  static Future<bool> _isAndroid13OrHigher() async {
    try {
      // Try to access photos permission - if it exists, we're likely on Android 13+
      // On older Android versions, this permission doesn't exist
      final status = await Permission.photos.status;
      return true; // If we can check photos permission, we're on Android 13+
    } catch (e) {
      // If photos permission doesn't exist, we're on older Android
      return false;
    }
  }

  /// Handle permission permanently denied scenario
  static Future<void> handlePermissionPermanentlyDenied(
    BuildContext context,
    String permissionName,
  ) async {
    final shouldOpenSettings = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permissionName Access Denied'),
        content: Text(
          'You have permanently denied $permissionName permission. '
          'To use this feature, please enable it in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );

    if (shouldOpenSettings == true) {
      await openSettings();
    }
  }

  /// Check and request permission with user-friendly flow
  static Future<bool> checkAndRequestPermission(
    BuildContext context, {
    required Permission permission,
    required String permissionName,
  }) async {
    // Check current status
    final status = await permission.status;

    switch (status) {
      case PermissionStatus.granted:
        return true;

      case PermissionStatus.denied:
        // Request permission
        final newStatus = await permission.request();
        return newStatus.isGranted;

      case PermissionStatus.permanentlyDenied:
        // Handle permanently denied
        if (context.mounted) {
          await handlePermissionPermanentlyDenied(context, permissionName);
        }
        return false;

      case PermissionStatus.restricted:
        // Handle restricted (iOS)
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$permissionName access is restricted on this device'),
            ),
          );
        }
        return false;

      default:
        return false;
    }
  }
}