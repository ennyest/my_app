import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/image_upload_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/models/hairstyle_model.dart';

class AddHairstyleScreen extends StatefulWidget {
  const AddHairstyleScreen({super.key});

  @override
  State<AddHairstyleScreen> createState() => _AddHairstyleScreenState();
}

class _AddHairstyleScreenState extends State<AddHairstyleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _tagsController = TextEditingController();
  
  final ImageUploadService _imageUploadService = ImageUploadService();
  
  String _selectedCategory = HairCategories.all.first;
  String _selectedDifficulty = DifficultyLevels.all.first;
  String _selectedLength = HairLengths.all.first;
  
  XFile? _selectedImage;
  String? _uploadedImageUrl;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _videoUrlController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Hairstyle'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Upload Section
              _buildImageUploadSection(),
              
              const SizedBox(height: AppConstants.largePadding),
              
              // Basic Information
              Text(
                'Basic Information',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Hairstyle Name *',
                  hintText: 'Enter hairstyle name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a hairstyle name';
                  }
                  if (value.trim().length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Describe the hairstyle',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  if (value.trim().length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppConstants.largePadding),
              
              // Categories Section
              Text(
                'Categories & Properties',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Category Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: HairCategories.all.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              
              const SizedBox(height: AppConstants.defaultPadding),
              
              Row(
                children: [
                  // Difficulty Dropdown
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedDifficulty,
                      decoration: const InputDecoration(
                        labelText: 'Difficulty',
                        border: OutlineInputBorder(),
                      ),
                      items: DifficultyLevels.all.map((difficulty) {
                        return DropdownMenuItem<String>(
                          value: difficulty,
                          child: Text(difficulty.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDifficulty = value!;
                        });
                      },
                    ),
                  ),
                  
                  const SizedBox(width: AppConstants.defaultPadding),
                  
                  // Length Dropdown
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedLength,
                      decoration: const InputDecoration(
                        labelText: 'Hair Length',
                        border: OutlineInputBorder(),
                      ),
                      items: HairLengths.all.map((length) {
                        return DropdownMenuItem<String>(
                          value: length,
                          child: Text(length.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedLength = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Tags Field
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                  hintText: 'e.g., braids, protective, summer',
                  border: OutlineInputBorder(),
                ),
              ),
              
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Video URL Field (Optional)
              TextFormField(
                controller: _videoUrlController,
                decoration: const InputDecoration(
                  labelText: 'Tutorial Video URL (optional)',
                  hintText: 'https://youtube.com/watch?v=...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final uri = Uri.tryParse(value);
                    if (uri == null || !uri.hasAbsolutePath) {
                      return 'Please enter a valid URL';
                    }
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppConstants.largePadding * 2),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: _isSubmitting ? 'Adding Hairstyle...' : 'Add Hairstyle',
                  onPressed: _isSubmitting ? null : _submitHairstyle,
                  backgroundColor: AppColors.primary,
                ),
              ),
              
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Cancel',
                  onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                  isOutlined: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outline),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hairstyle Image *',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          if (_selectedImage != null) ...[
            // Show selected image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              child: Image.file(
                File(_selectedImage!.path),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            if (_isUploading) ...[
              LinearProgressIndicator(value: _uploadProgress),
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                'Uploading... ${(_uploadProgress * 100).toInt()}%',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
            
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Change Image',
                    onPressed: _isUploading ? null : _selectImage,
                    isOutlined: true,
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: CustomButton(
                    text: 'Remove',
                    onPressed: _isUploading ? null : () {
                      setState(() {
                        _selectedImage = null;
                        _uploadedImageUrl = null;
                      });
                    },
                    backgroundColor: Colors.red,
                    isOutlined: true,
                  ),
                ),
              ],
            ),
          ] else ...[
            // Show upload button
            InkWell(
              onTap: _selectImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  border: Border.all(
                    color: AppColors.outline,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload,
                      size: 48,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    Text(
                      'Tap to select image',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    Text(
                      'JPEG, PNG, WebP formats supported',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _selectImage() async {
    final XFile? image = await _imageUploadService.showImageSourceDialog(context);
    
    if (image != null) {
      // Validate image
      if (!_imageUploadService.validateImageFile(image)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a valid image file (JPEG, PNG, WebP)'),
            ),
          );
        }
        return;
      }

      // Check file size
      final double sizeInMB = await _imageUploadService.getFileSizeInMB(image);
      if (sizeInMB > 10) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image size must be less than 10MB'),
            ),
          );
        }
        return;
      }

      setState(() {
        _selectedImage = image;
      });

      // Upload image immediately
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final String? imageUrl = await _imageUploadService.uploadHairstyleImage(
        _selectedImage!,
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
          });
        },
      );

      if (imageUrl != null) {
        setState(() {
          _uploadedImageUrl = imageUrl;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image uploaded successfully!'),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload image. Please try again.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
          ),
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _submitHairstyle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_uploadedImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload an image for the hairstyle'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.userModel;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Parse tags
      final List<String> tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      // Create hairstyle model
      final hairstyle = HairstyleModel(
        styleId: '', // Will be set by Firestore
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: _uploadedImageUrl!,
        videoUrl: _videoUrlController.text.trim().isNotEmpty 
            ? _videoUrlController.text.trim() 
            : null,
        category: _selectedCategory,
        tags: tags,
        difficulty: _selectedDifficulty,
        length: _selectedLength,
        isPreloaded: true, // Admin uploaded styles are preloaded
        uploadedBy: user.userId,
        likes: 0,
        createdAt: DateTime.now(),
        isApproved: true, // Admin uploads are auto-approved
        isRejected: false,
        rejectionReason: null,
        approvedAt: DateTime.now(),
        rejectedAt: null,
      );

      // Add to Firestore
      await FirebaseFirestore.instance
          .collection(AppConstants.hairstylesCollection)
          .add(hairstyle.toFirestore());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hairstyle added successfully!'),
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding hairstyle: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}