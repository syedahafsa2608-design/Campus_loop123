import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/campus_background.dart';
import '../widgets/glass_card.dart';

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;

  String _category = 'Electronics';
  String _condition = 'Good';

  bool _isPosting = false;
  bool _isPickingImage = false;

  final List<String> _categories = [
    'Electronics',
    'Study',
    'Books',
    'Room',
    'Clothing',
    'Accessories',
    'Sports',
    'Other',
  ];

  final List<String> _conditions = [
    'Like New',
    'Good',
    'Fair',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> _pickImage() async {
    if (_isPickingImage) return;

    setState(() {
      _isPickingImage = true;
    });

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (pickedFile == null) {
        return;
      }

      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Could not select the photo. Please check gallery permission.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  // ============================================================
  // UPLOAD IMAGE TO FIREBASE STORAGE
  // ============================================================

  Future<String?> _uploadImage(String userId) async {
    if (_selectedImage == null) {
      return null;
    }

    final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    final Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('campusloop')
        .child('item_images')
        .child(userId)
        .child(fileName);

    try {
      final UploadTask uploadTask = storageRef.putFile(
        _selectedImage!,
        SettableMetadata(
          contentType: 'image/jpeg',
        ),
      );

      final TaskSnapshot snapshot = await uploadTask;

      if (snapshot.state != TaskState.success) {
        throw FirebaseException(
          plugin: 'firebase_storage',
          code: 'upload-failed',
          message: 'The image upload did not complete.',
        );
      }

      return await snapshot.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      debugPrint(
        'Firebase Storage error: ${e.code}',
      );

      if (e.code == 'unauthorized') {
        throw Exception(
          'Firebase Storage permission denied.',
        );
      }

      if (e.code == 'canceled') {
        throw Exception(
          'Image upload was cancelled.',
        );
      }

      throw Exception(
        'Could not upload the image.',
      );
    }
  }

  // ============================================================
  // POST ITEM
  // ============================================================

  Future<void> _postItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(
        'Please log in before posting an item.',
        isError: true,
      );
      return;
    }

    final double? price = double.tryParse(
      _priceController.text.trim(),
    );

    if (price == null || price < 0) {
      _showMessage(
        'Please enter a valid price.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      // --------------------------------------------------------
      // 1. Upload image
      // --------------------------------------------------------

      final String? imageUrl = await _uploadImage(user.uid);

      // --------------------------------------------------------
      // 2. Create Firestore listing
      // --------------------------------------------------------

      await FirebaseFirestore.instance.collection('items').add({
        // IMPORTANT:
        // Separates CampusLoop data from your old Servora data.
        'app': 'campusloop',

        'title': _titleController.text.trim(),

        'description': _descriptionController.text.trim(),

        'price': price,

        'image': imageUrl ?? '',

        'category': _category,

        'condition': _condition,

        'userId': user.uid,

        'userName': user.displayName ?? user.email ?? 'Student',

        'userEmail': user.email ?? '',

        'status': 'available',

        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your item has been posted successfully!',
          ),
          backgroundColor: Color(0xFF3AAE9E),
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      String message = 'Could not post your item.';

      if (e.code == 'permission-denied') {
        message = 'Firebase denied access. Check your Firestore rules.';
      } else if (e.code == 'unauthorized') {
        message = 'Firebase Storage denied the image upload.';
      } else if (e.code == 'canceled') {
        message = 'Image upload was cancelled.';
      }

      setState(() {
        _isPosting = false;
      });

      _showMessage(
        message,
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isPosting = false;
      });

      _showMessage(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
        isError: true,
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF3AAE9E),
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String hint,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.white38,
      ),
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: Colors.white.withOpacity(.055),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(.08),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(.08),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(
          color: Color(0xFF57C7B6),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CampusBackground(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(22),
              children: [
                const _Header(
                  title: 'Sell Something',
                  subtitle: 'Give your unused things a new home on campus.',
                ),
                const SizedBox(height: 25),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Item photo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ------------------------------------------------
                      // PHOTO BOX
                      // ------------------------------------------------

                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            color: Colors.white.withOpacity(.045),
                            border: Border.all(
                              color: Colors.white.withOpacity(.09),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _selectedImage == null
                              ? _isPickingImage
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF57C7B6),
                                      ),
                                    )
                                  : const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate_outlined,
                                          size: 42,
                                          color: Colors.white54,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          'Add a photo',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          'A clear photo helps buyers.',
                                          style: TextStyle(
                                            color: Colors.white30,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    )
                              : Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black54,
                                        ),
                                        child: IconButton(
                                          onPressed: () {
                                            setState(
                                              () {
                                                _selectedImage = null;
                                              },
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 12,
                                      bottom: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 7,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          'Tap to change photo',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      const Text(
                        'What are you selling?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 9),

                      TextFormField(
                        controller: _titleController,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        decoration: _inputDecoration(
                          hint: 'e.g. Scientific Calculator',
                          prefixIcon: const Icon(
                            Icons.inventory_2_outlined,
                            color: Color(0xFF8EE8D8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter what you are selling';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'Selling price',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 9),

                      TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        decoration: _inputDecoration(
                          hint: 'Enter your price',
                          prefixIcon: const Icon(
                            Icons.currency_rupee,
                            color: Color(0xFF8EE8D8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter a price';
                          }

                          if (double.tryParse(value.trim()) == null) {
                            return 'Enter a valid price';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 9),

                      DropdownButtonFormField<String>(
                        value: _category,
                        dropdownColor: const Color(0xFF182622),
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        decoration: _inputDecoration(
                          hint: 'Category',
                          prefixIcon: const Icon(
                            Icons.category_outlined,
                            color: Color(0xFF8EE8D8),
                          ),
                        ),
                        items: _categories.map(
                          (category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          },
                        ).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _category = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'Condition',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 9),

                      DropdownButtonFormField<String>(
                        value: _condition,
                        dropdownColor: const Color(0xFF182622),
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        decoration: _inputDecoration(
                          hint: 'Condition',
                          prefixIcon: const Icon(
                            Icons.verified_outlined,
                            color: Color(0xFF8EE8D8),
                          ),
                        ),
                        items: _conditions.map(
                          (condition) {
                            return DropdownMenuItem(
                              value: condition,
                              child: Text(condition),
                            );
                          },
                        ).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _condition = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 9),

                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        decoration: _inputDecoration(
                          hint: 'Describe your item...',
                        ),
                      ),

                      const SizedBox(height: 22),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isPosting ? null : _postItem,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF57C7B6),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.white24,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: _isPosting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Post for Sale',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// HEADER
// ============================================================

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;

  const _Header({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          padding: EdgeInsets.zero,
          alignment: Alignment.centerLeft,
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0x73FFFFFF),
          ),
        ),
      ],
    );
  }
}
