import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class WriteReviewPage extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;

  const WriteReviewPage({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
  });

  @override
  State<WriteReviewPage> createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends State<WriteReviewPage> {
  final reviewController = TextEditingController();
  int selectedRating = 0;
  bool isAnonymous = false;
  File? selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1D1D1F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Write a review',
          style: TextStyle(
            color: Color(0xFF1D1D1F),
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        shrinkWrap: true,
        children: [

          Text(
            widget.restaurantName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D1D1F),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'YOUR RATING',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6E6E73),
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () {
                  setState(() {
                    selectedRating = index + 1;
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  index < selectedRating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: const Color(0xFFE8950A),
                  size: 36,
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          const Text(
            'YOUR REVIEW',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6E6E73),
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: reviewController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Share your experience...',
                hintStyle: TextStyle(color: Color(0xFFAEAEB2)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Photo upload
          const Text(
            'ADD PHOTO',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6E6E73),
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 10),

          TextButton(
            onPressed: () async {
              final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
              if (pickedImage != null) {
                setState(() {
                  selectedImage = File(pickedImage.path);
                });
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xFFE5E5EA)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.photo_outlined, color: Color(0xFFE8950A)),
                SizedBox(width: 8),
                Text('Choose from gallery', style: TextStyle(color: Color(0xFFE8950A), fontWeight: FontWeight.w600)),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Preview selected image
          if (selectedImage != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(
                selectedImage!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
          ],

          const SizedBox(height: 6),

          // Anonymous checkbox
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              onTap: () {
                setState(() {
                  isAnonymous = !isAnonymous;
                });
              },
              leading: Checkbox(
                value: isAnonymous,
                activeColor: const Color(0xFFE8950A),
                onChanged: (value) {
                  setState(() {
                    isAnonymous = value ?? false;
                  });
                },
              ),
              title: const Text(
                'Post as Anonymous',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1D1D1F),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8950A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () async {
                var content = reviewController.text.trim();

                if (selectedRating == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a rating!')),
                  );
                  return;
                }

                if (content.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please write a review!')),
                  );
                  return;
                }

                try {
                  String? uploadedImageUrl;

                  // Upload image to Firebase Storage
                  if (selectedImage != null) {
                    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
                    Reference storageRef = FirebaseStorage.instance
                        .ref()
                        .child('review_images')
                        .child('$fileName.jpg');
                    await storageRef.putFile(selectedImage!);
                    uploadedImageUrl = await storageRef.getDownloadURL();
                  }

                  await FirebaseFirestore.instance.collection('reviews').add({
                    'restaurant_id': widget.restaurantId,
                    'user_id': isAnonymous
                        ? 'Anonymous'
                        : FirebaseAuth.instance.currentUser!.uid,
                    'rating': selectedRating,
                    'content': content,
                    'photo_url': uploadedImageUrl ?? '',
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Review submitted!')),
                  );

                  Navigator.pop(context);
                } on FirebaseAuthException catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.message.toString()}')),
                  );
                }
              },
              child: const Text(
                'Submit review',
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