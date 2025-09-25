import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'permission_service.dart';

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Pick an image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      // Check and request storage permission
      final hasPermission = await PermissionService.requestStoragePermission();
      if (!hasPermission) {
        debugPrint('Storage permission denied');
        return null;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Pick an image from camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      // Check and request camera permission
      final hasPermission = await PermissionService.requestCameraPermission();
      if (!hasPermission) {
        debugPrint('Camera permission denied');
        return null;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Error taking photo: $e');
      return null;
    }
  }

  /// Upload image to Firebase Storage
  Future<String?> uploadHairstyleImage(
    XFile imageFile, {
    String? customFileName,
    void Function(double)? onProgress,
  }) async {
    try {
      final String fileName = customFileName ?? 
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      
      final Reference ref = _storage
          .ref()
          .child('hairstyle_images')
          .child(fileName);

      final File file = File(imageFile.path);
      final UploadTask uploadTask = ref.putFile(file);

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (onProgress != null) {
          final double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        }
      });

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      debugPrint('Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  /// Delete image from Firebase Storage
  Future<bool> deleteHairstyleImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      debugPrint('Image deleted successfully: $imageUrl');
      return true;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }

  /// Show image source selection dialog
  Future<XFile?> showImageSourceDialog(BuildContext context) async {
    XFile? selectedImage;
    
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Image Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        
                        // Check permission before attempting to use camera
                        final hasPermission = await PermissionService.checkAndRequestPermission(
                          context,
                          permission: Permission.camera,
                          permissionName: 'Camera',
                        );
                        
                        if (hasPermission) {
                          selectedImage = await pickImageFromCamera();
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Camera permission is required to take photos'),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        
                        // Check permission before attempting to access gallery
                        final permission = await _getStoragePermission();
                        final hasPermission = await PermissionService.checkAndRequestPermission(
                          context,
                          permission: permission,
                          permissionName: 'Storage',
                        );
                        
                        if (hasPermission) {
                          selectedImage = await pickImageFromGallery();
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Storage permission is required to access gallery'),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );

    return selectedImage;
  }

  /// Get appropriate storage permission based on Android version
  Future<Permission> _getStoragePermission() async {
    try {
      // Try to determine if we're on Android 13+ by checking if photos permission exists
      final photosStatus = await Permission.photos.status;
      return Permission.photos;
    } catch (e) {
      // Fallback to storage permission for older Android versions
      return Permission.storage;
    }
  }

  /// Validate image file
  bool validateImageFile(XFile imageFile) {
    // Check file extension
    final String extension = path.extension(imageFile.path).toLowerCase();
    const List<String> allowedExtensions = ['.jpg', '.jpeg', '.png', '.webp'];
    
    if (!allowedExtensions.contains(extension)) {
      return false;
    }

    return true;
  }

  /// Get file size in MB
  Future<double> getFileSizeInMB(XFile file) async {
    final int bytes = await file.length();
    return bytes / (1024 * 1024);
  }

  /// Compress image if needed (placeholder for future implementation)
  Future<XFile?> compressImageIfNeeded(XFile imageFile) async {
    final double sizeInMB = await getFileSizeInMB(imageFile);
    
    // If image is larger than 5MB, we might want to compress it
    if (sizeInMB > 5.0) {
      debugPrint('Image size is ${sizeInMB.toStringAsFixed(2)}MB, consider compression');
      // TODO: Implement image compression using image package
    }
    
    return imageFile;
  }
}