import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  void initState() {
    super.initState();
    nameController.text = widget.currentName;
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

          // users avatar
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFE8950A),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // change photo btn
          Center(
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Change photo is coming soon!')),
                );
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

          // name
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

          // save
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
                var newName = nameController.text;

                if (newName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name cannot be empty.')),
                  );
                  return;
                }

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.uid)
                    .update({'fullname': newName});

                await FirebaseAuth.instance.currentUser
                    ?.updateDisplayName(newName);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated!')),
                );

                Navigator.pop(context);
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