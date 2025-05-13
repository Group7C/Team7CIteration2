import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../usser/usserObject.dart';

class ProfilePhotoWidget extends StatefulWidget {
  final Uint8List? initialImage;

  const ProfilePhotoWidget({super.key, this.initialImage});

  @override
  State<ProfilePhotoWidget> createState() => _ProfilePhotoWidgetState();
}

class _ProfilePhotoWidgetState extends State<ProfilePhotoWidget> {
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _imageBytes = widget.initialImage;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);

    if (picked != null) {
      final bytes = await picked.readAsBytes();

      setState(() {
        _imageBytes = bytes;
      });

      print(bytes);

      // Convert Uint8List to string
      final stringVersion = bytes.toString();

      // Update the user's profile picture in the provider
      final usser = Provider.of<Usser>(context, listen: false);
      usser.profilePic = stringVersion;
      usser.notifyListeners(); // Optional, only if you want UI to react elsewhere

      print('Profile picture updated and stored as string');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: _imageBytes != null ? MemoryImage(_imageBytes!) : null,
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.edit),
          label: const Text('Edit'),
          onPressed: _pickImage,
        ),
      ],
    );
  }
}