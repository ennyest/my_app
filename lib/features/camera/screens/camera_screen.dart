import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_button.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isCameraInitialized = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // TODO: Initialize camera
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isCameraInitialized = true;
    });
  }

  Future<void> _capturePhoto() async {
    setState(() {
      _isCapturing = true;
    });

    // TODO: Capture photo
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isCapturing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo captured! Processing...'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () {
              // TODO: Switch camera
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Camera switch coming soon!'),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview Placeholder
          if (_isCameraInitialized)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey[900],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 80,
                      color: Colors.white54,
                    ),
                    SizedBox(height: AppConstants.defaultPadding),
                    Text(
                      'Camera Preview',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: AppConstants.smallPadding),
                    Text(
                      'Face detection will be shown here',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: AppConstants.defaultPadding),
                  Text(
                    'Initializing Camera...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

          // Face Detection Overlay
          if (_isCameraInitialized)
            Positioned(
              top: 100,
              left: 50,
              right: 50,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    'Face Detection Area',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(AppConstants.largePadding),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Gallery Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.photo_library_outlined,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () {
                          // TODO: Open gallery
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Gallery coming soon!'),
                            ),
                          );
                        },
                      ),
                      
                      // Capture Button
                      GestureDetector(
                        onTap: _isCapturing ? null : _capturePhoto,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isCapturing ? Colors.grey : Colors.white,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 4,
                            ),
                          ),
                          child: _isCapturing
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                )
                              : const Icon(
                                  Icons.camera_alt,
                                  color: AppColors.primary,
                                  size: 30,
                                ),
                        ),
                      ),
                      
                      // Settings Button
                      IconButton(
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () {
                          // TODO: Open settings
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Camera settings coming soon!'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppConstants.defaultPadding),
                  
                  // AI Analysis Button
                  CustomButton(
                    text: 'Analyze with AI',
                    onPressed: _isCameraInitialized ? () {
                      // TODO: Start AI analysis
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('AI analysis coming soon!'),
                        ),
                      );
                    } : null,
                    backgroundColor: AppColors.primary,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
