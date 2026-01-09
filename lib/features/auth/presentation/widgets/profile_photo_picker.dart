import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePhotoPicker extends StatelessWidget {
  final File? currentPhoto;
  final Function(File?) onPhotoSelected;

  const ProfilePhotoPicker({
    super.key,
    this.currentPhoto,
    required this.onPhotoSelected,
  });

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        onPhotoSelected(File(pickedFile.path));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161B22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF30363D),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Profile Photo(Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF0F6FC),
                ),
              ),
            ),

            const Divider(color: Color(0xFF30363D), height: 1),

            // Camera option
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF539BF5)),
              title: const Text(
                'Take Photo',
                style: TextStyle(color: Color(0xFFF0F6FC), fontSize: 15),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.camera);
              },
            ),

            // Gallery option
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF539BF5)),
              title: const Text(
                'Choose from Gallery',
                style: TextStyle(color: Color(0xFFF0F6FC), fontSize: 15),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.gallery);
              },
            ),

            // Remove photo option (if photo exists)
            if (currentPhoto != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Color(0xFFDA3633)),
                title: const Text(
                  'Remove Photo',
                  style: TextStyle(color: Color(0xFFDA3633), fontSize: 15),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onPhotoSelected(null);
                },
              ),

            // Cancel
            ListTile(
              leading: const Icon(Icons.close, color: Color(0xFF7D8590)),
              title: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF7D8590), fontSize: 15),
              ),
              onTap: () => Navigator.pop(context),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPhotoOptions(context),
      child: Stack(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF21262D),
              border: Border.all(
                color: const Color(0xFF30363D),
                width: 2,
              ),
              image: currentPhoto != null
                  ? DecorationImage(
                image: FileImage(currentPhoto!),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: currentPhoto == null
                ? const Icon(
              Icons.person,
              size: 48,
              color: Color(0xFF7D8590),
            )
                : null,
          ),

          // Edit button
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF238636),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF0D1117),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}