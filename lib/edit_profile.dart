import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfilePage extends StatefulWidget {
  final String uid;
  final String currentName;

  const EditProfilePage({
    super.key,
    required this.uid,
    required this.currentName,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final nameController = TextEditingController();
  File? selectedImage;
  String? currentPhotoUrl;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.currentName;

    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get()
        .then((doc) {
      if (doc.exists) {
        setState(() {
          currentPhotoUrl = (doc.data() as Map<String, dynamic>?)?['photo_url'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Color(0xFF1D1D1F),
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1D1D1F)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          const SizedBox(height: 12),

          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFE8950A),
                shape: BoxShape.circle,
              ),
              child: selectedImage != null
                  ? ClipOval(
                child: Image.file(
                  selectedImage!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              )
                  : currentPhotoUrl != null && currentPhotoUrl!.isNotEmpty
                  ? ClipOval(
                child: Image.network(
                  currentPhotoUrl!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Text(
                      widget.currentName.isNotEmpty
                          ? widget.currentName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
                  : Center(
                child: Text(
                  widget.currentName.isNotEmpty
                      ? widget.currentName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: TextButton(
              onPressed: () async {
                // Pick image from gallery
                final pickedImage = await ImagePicker()
                    .pickImage(source: ImageSource.gallery);
                if (pickedImage != null) {
                  setState(() {
                    selectedImage = File(pickedImage.path);
                  });
                }
              },
              child: const Text(
                'Change photo',
                style: TextStyle(
                  color: Color(0xFFE8950A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                labelStyle: TextStyle(color: Color(0xFF6E6E73)),
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: Color(0xFFAEAEB2),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8950A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () async {
                var newName = nameController.text.trim();

                if (newName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name cannot be empty.')),
                  );
                  return;
                }

                try {
                  String? uploadedPhotoUrl;

                  if (selectedImage != null) {
                    String fileName = widget.uid;
                    Reference storageRef = FirebaseStorage.instance
                        .ref()
                        .child('profile_images')
                        .child('$fileName.jpg');
                    await storageRef.putFile(selectedImage!);
                    uploadedPhotoUrl = await storageRef.getDownloadURL();
                  }

                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.uid)
                      .update({
                    'fullname': newName,
                    if (uploadedPhotoUrl != null) 'photo_url': uploadedPhotoUrl,
                  });

                  await FirebaseAuth.instance.currentUser
                      ?.updateDisplayName(newName);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated!')),
                  );

                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}