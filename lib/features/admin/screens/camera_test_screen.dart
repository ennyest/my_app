import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/services/image_upload_service.dart';

class CameraTestScreen extends StatefulWidget {
  const CameraTestScreen({super.key});

  @override
  State<CameraTestScreen> createState() => _CameraTestScreenState();
}

class _CameraTestScreenState extends State<CameraTestScreen> {
  final ImageUploadService _imageUploadService = ImageUploadService();
  String _status = 'Ready to test camera and gallery access';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera & Gallery Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Status:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(_status),
            ),
            
            const SizedBox(height: 32),
            
            ElevatedButton.icon(
              onPressed: _testCameraAccess,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Test Camera Access'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: _testGalleryAccess,
              icon: const Icon(Icons.photo_library),
              label: const Text('Test Gallery Access'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: _testImagePicker,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Test Image Picker Dialog'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            
            const SizedBox(height: 32),
            
            ElevatedButton.icon(
              onPressed: _checkAllPermissions,
              icon: const Icon(Icons.check_circle),
              label: const Text('Check All Permissions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testCameraAccess() async {
    setState(() {
      _status = 'Testing camera access...';
    });

    try {
      final hasPermission = await PermissionService.checkAndRequestPermission(
        context,
        permission: Permission.camera,
        permissionName: 'Camera',
      );

      if (hasPermission) {
        final image = await _imageUploadService.pickImageFromCamera();
        setState(() {
          _status = image != null 
              ? 'Camera access successful! Image captured: ${image.name}'
              : 'Camera access granted but no image captured';
        });
      } else {
        setState(() {
          _status = 'Camera permission denied';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Camera test failed: $e';
      });
    }
  }

  Future<void> _testGalleryAccess() async {
    setState(() {
      _status = 'Testing gallery access...';
    });

    try {
      final permission = await _getStoragePermission();
      final hasPermission = await PermissionService.checkAndRequestPermission(
        context,
        permission: permission,
        permissionName: 'Gallery',
      );

      if (hasPermission) {
        final image = await _imageUploadService.pickImageFromGallery();
        setState(() {
          _status = image != null 
              ? 'Gallery access successful! Image selected: ${image.name}'
              : 'Gallery access granted but no image selected';
        });
      } else {
        setState(() {
          _status = 'Gallery permission denied';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Gallery test failed: $e';
      });
    }
  }

  Future<void> _testImagePicker() async {
    setState(() {
      _status = 'Testing image picker dialog...';
    });

    try {
      final image = await _imageUploadService.showImageSourceDialog(context);
      setState(() {
        _status = image != null 
            ? 'Image picker successful! Selected: ${image.name}'
            : 'Image picker opened but no image selected';
      });
    } catch (e) {
      setState(() {
        _status = 'Image picker test failed: $e';
      });
    }
  }

  Future<void> _checkAllPermissions() async {
    setState(() {
      _status = 'Checking all permissions...';
    });

    try {
      final cameraStatus = await Permission.camera.status;
      final storagePermission = await _getStoragePermission();
      final storageStatus = await storagePermission.status;

      setState(() {
        _status = '''
Permission Status:
• Camera: ${cameraStatus.name}
• Storage/Photos: ${storageStatus.name}

Camera granted: ${cameraStatus.isGranted}
Storage granted: ${storageStatus.isGranted}
        ''';
      });
    } catch (e) {
      setState(() {
        _status = 'Permission check failed: $e';
      });
    }
  }

  Future<Permission> _getStoragePermission() async {
    try {
      // Try to determine if we're on Android 13+ by checking if photos permission exists
      await Permission.photos.status;
      return Permission.photos;
    } catch (e) {
      // Fallback to storage permission for older Android versions
      return Permission.storage;
    }
  }
}