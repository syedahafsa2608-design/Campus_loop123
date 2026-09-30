import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/campus_background.dart';
import '../widgets/glass_card.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSellBookSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF151126),
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return _SellBookSheet(
          firestore: _firestore,
          auth: _auth,
        );
      },
    );
  }

  bool _matchesSearch(Map<String, dynamic> book) {
    if (_searchText.isEmpty) return true;

    final title = (book['title'] ?? '').toString().toLowerCase();

    final author = (book['author'] ?? '').toString().toLowerCase();

    final category = (book['category'] ?? '').toString().toLowerCase();

    return title.contains(_searchText) ||
        author.contains(_searchText) ||
        category.contains(_searchText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CampusBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
                child: _Header(
                  title: 'Books',
                  subtitle:
                      'Buy and sell second-hand books within your campus.',
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.055),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withOpacity(.09),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      icon: Icon(
                        Icons.search_rounded,
                        color: Colors.white60,
                      ),
                      hintText: 'Search books, authors...',
                      hintStyle: TextStyle(
                        color: Colors.white38,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _firestore
                      .collection('books')
                      .where(
                        'status',
                        isEqualTo: 'available',
                      )
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF57C7B6),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(25),
                          child: Text(
                            'Unable to load books.\n\n${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white60,
                            ),
                          ),
                        ),
                      );
                    }

                    final docs = snapshot.data?.docs ?? [];

                    final books = docs.where((doc) {
                      return _matchesSearch(doc.data());
                    }).toList();

                    books.sort((a, b) {
                      final aTime = a.data()['createdAt'];
                      final bTime = b.data()['createdAt'];

                      if (aTime is Timestamp && bTime is Timestamp) {
                        return bTime.compareTo(aTime);
                      }

                      return 0;
                    });

                    if (books.isEmpty) {
                      return _EmptyBooksState(
                        isSearching: _searchText.isNotEmpty,
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        22,
                        5,
                        22,
                        110,
                      ),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final doc = books[index];

                        return _BookCard(
                          bookId: doc.id,
                          book: doc.data(),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => _BookDetailsScreen(
                                  bookId: doc.id,
                                  book: doc.data(),
                                  firestore: _firestore,
                                  auth: _auth,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF57C7B6),
        foregroundColor: Colors.white,
        onPressed: _showSellBookSheet,
        icon: const Icon(Icons.add),
        label: const Text(
          'Sell a Book',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SELL BOOK SHEET
// ============================================================

class _SellBookSheet extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const _SellBookSheet({
    required this.firestore,
    required this.auth,
  });

  @override
  State<_SellBookSheet> createState() => _SellBookSheetState();
}

class _SellBookSheetState extends State<_SellBookSheet> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _condition = 'Good';
  String _category = 'Engineering';

  bool _isPosting = false;

  final List<String> _conditions = [
    'Like New',
    'Good',
    'Fair',
  ];

  final List<String> _categories = [
    'Engineering',
    'Medical',
    'Science',
    'Commerce',
    'Arts',
    'Competitive Exams',
    'School',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _originalPriceController.dispose();
    _sellingPriceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _postBook() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = widget.auth.currentUser;

    if (user == null) {
      _showMessage(
        'Please log in before selling a book.',
        isError: true,
      );
      return;
    }

    final sellingPrice = double.tryParse(_sellingPriceController.text.trim());

    final originalPrice = double.tryParse(_originalPriceController.text.trim());

    if (sellingPrice == null || sellingPrice < 0) {
      _showMessage(
        'Enter a valid selling price.',
        isError: true,
      );
      return;
    }

    if (originalPrice != null &&
        originalPrice > 0 &&
        sellingPrice > originalPrice) {
      _showMessage(
        'Selling price cannot be higher than the original price.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      await widget.firestore.collection('books').add({
        'title': _titleController.text.trim(),
        'author': _authorController.text.trim(),
        'originalPrice': originalPrice,
        'price': sellingPrice,
        'condition': _condition,
        'category': _category,
        'description': _descriptionController.text.trim(),
        'image': '',
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
            'Your book has been posted successfully.',
          ),
          backgroundColor: Color(0xFF3AAE9E),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isPosting = false;
      });

      _showMessage(
        'Could not post the book. Please try again.',
        isError: true,
      );
    }
  }

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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.white38,
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(.055),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(.08),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(.08),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF57C7B6),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        22,
        25,
        22,
        MediaQuery.of(context).viewInsets.bottom + 25,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Sell your book',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Give your old books a new reader and earn some money.',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 22),
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Book title'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter the book title';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _authorController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Author name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter the author name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _originalPriceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(
                      'Original price',
                    ).copyWith(
                      prefixText: '₹ ',
                      prefixStyle: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _sellingPriceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(
                      'Selling price',
                    ).copyWith(
                      prefixText: '₹ ',
                      prefixStyle: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }

                      if (double.tryParse(value.trim()) == null) {
                        return 'Invalid';
                      }

                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _condition,
                    dropdownColor: const Color(0xFF211B38),
                    decoration: _inputDecoration('Condition'),
                    items: _conditions.map((condition) {
                      return DropdownMenuItem(
                        value: condition,
                        child: Text(condition),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _condition = value;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _category,
                    dropdownColor: const Color(0xFF211B38),
                    decoration: _inputDecoration('Category'),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(
                          category,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _category = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                'Describe the book (optional)',
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isPosting ? null : _postBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF57C7B6),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.white24,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                child: _isPosting
                    ? const SizedBox(
                        width: 23,
                        height: 23,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Post Book for Sale',
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
    );
  }
}

// ============================================================
// BOOK CARD
// ============================================================

class _BookCard extends StatelessWidget {
  final String bookId;
  final Map<String, dynamic> book;
  final VoidCallback onTap;

  const _BookCard({
    required this.bookId,
    required this.book,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = book['title'] ?? 'Untitled Book';
    final author = book['author'] ?? 'Unknown author';
    final price = book['price'];
    final condition = book['condition'] ?? 'Good';
    final category = book['category'] ?? 'Other';

    final image = book['image'] ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          child: Row(
            children: [
              Container(
                width: 68,
                height: 82,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF4CC5B4),
                      Color(0xFF637CFF),
                    ],
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: image.toString().isNotEmpty
                    ? Image.network(
                        image.toString(),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return const Icon(
                            Icons.menu_book_rounded,
                            color: Colors.white,
                            size: 29,
                          );
                        },
                      )
                    : const Icon(
                        Icons.menu_book_rounded,
                        color: Colors.white,
                        size: 29,
                      ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toString(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      author.toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0x73FFFFFF),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Text(
                          '₹${_formatPrice(price)}',
                          style: const TextStyle(
                            color: Color(0xFF8EE8D8),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.06),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            condition.toString(),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.toString(),
                      style: const TextStyle(
                        color: Colors.white30,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: Colors.white30,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatPrice(dynamic value) {
    if (value == null) return '0';

    if (value is num) {
      if (value % 1 == 0) {
        return value.toInt().toString();
      }

      return value.toString();
    }

    return value.toString();
  }
}

// ============================================================
// BOOK DETAILS
// ============================================================

class _BookDetailsScreen extends StatefulWidget {
  final String bookId;
  final Map<String, dynamic> book;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const _BookDetailsScreen({
    required this.bookId,
    required this.book,
    required this.firestore,
    required this.auth,
  });

  @override
  State<_BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<_BookDetailsScreen> {
  bool _sendingRequest = false;

  Future<void> _requestToBuy() async {
    final buyer = widget.auth.currentUser;

    if (buyer == null) {
      _showMessage(
        'Please log in first.',
        isError: true,
      );
      return;
    }

    final sellerId = widget.book['userId']?.toString() ?? '';

    final title = widget.book['title']?.toString() ?? 'this book';

    final sellerName = widget.book['userName']?.toString() ?? 'Student';

    if (sellerId.isEmpty) {
      _showMessage(
        'Seller information is unavailable.',
        isError: true,
      );
      return;
    }

    if (sellerId == buyer.uid) {
      _showMessage(
        'You cannot request your own book.',
        isError: true,
      );
      return;
    }

    setState(() {
      _sendingRequest = true;
    });

    try {
      final existing = await widget.firestore
          .collection('requests')
          .where(
            'type',
            isEqualTo: 'book_purchase',
          )
          .where(
            'itemId',
            isEqualTo: widget.bookId,
          )
          .where(
            'fromUserId',
            isEqualTo: buyer.uid,
          )
          .where(
            'status',
            isEqualTo: 'pending',
          )
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        if (!mounted) return;

        setState(() {
          _sendingRequest = false;
        });

        _showMessage(
          'You already sent a request for this book.',
        );
        return;
      }

      await widget.firestore.collection('requests').add({
        'type': 'book_purchase',
        'itemId': widget.bookId,
        'itemTitle': title,
        'price': widget.book['price'],
        'fromUserId': buyer.uid,
        'fromUserName': buyer.displayName ?? buyer.email ?? 'Student',
        'toUserId': sellerId,
        'toUserName': sellerName,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await widget.firestore.collection('notifications').add({
        'userId': sellerId,
        'type': 'book_purchase',
        'itemId': widget.bookId,
        'itemTitle': title,
        'fromUserId': buyer.uid,
        'fromUserName': buyer.displayName ?? buyer.email ?? 'Student',
        'message':
            '${buyer.displayName ?? 'A student'} wants to buy your book "$title".',
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        _sendingRequest = false;
      });

      _showMessage(
        'Purchase request sent to $sellerName.',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _sendingRequest = false;
      });

      _showMessage(
        'Could not send the request. Please try again.',
        isError: true,
      );
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final title = widget.book['title']?.toString() ?? 'Untitled Book';

    final author = widget.book['author']?.toString() ?? 'Unknown author';

    final category = widget.book['category']?.toString() ?? 'Other';

    final condition = widget.book['condition']?.toString() ?? 'Good';

    final description = widget.book['description']?.toString() ?? '';

    final seller = widget.book['userName']?.toString() ?? 'Student';

    final image = widget.book['image']?.toString() ?? '';

    final price = widget.book['price'];

    final originalPrice = widget.book['originalPrice'];

    final currentUser = widget.auth.currentUser;

    final isOwner =
        currentUser != null && widget.book['userId'] == currentUser.uid;

    return Scaffold(
      body: CampusBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              22,
              10,
              22,
              30,
            ),
            children: [
              IconButton(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                height: 230,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF4CC5B4),
                      Color(0xFF637CFF),
                    ],
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: image.isNotEmpty
                    ? Image.network(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return const Icon(
                            Icons.menu_book_rounded,
                            color: Colors.white,
                            size: 75,
                          );
                        },
                      )
                    : const Icon(
                        Icons.menu_book_rounded,
                        color: Colors.white,
                        size: 75,
                      ),
              ),
              const SizedBox(height: 25),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'by $author',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    '₹${_BookCard._formatPrice(price)}',
                    style: const TextStyle(
                      color: Color(0xFF8EE8D8),
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (originalPrice != null)
                    Text(
                      'Original ₹${_BookCard._formatPrice(originalPrice)}',
                      style: const TextStyle(
                        color: Colors.white30,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    icon: Icons.auto_stories_outlined,
                    text: category,
                  ),
                  _InfoChip(
                    icon: Icons.check_circle_outline,
                    text: condition,
                  ),
                ],
              ),
              const SizedBox(height: 25),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      description.isEmpty
                          ? 'No description provided by the seller.'
                          : description,
                      style: const TextStyle(
                        color: Colors.white60,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              GlassCard(
                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(.07),
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Seller',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          seller,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isOwner || _sendingRequest ? null : _requestToBuy,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF57C7B6),
                    disabledBackgroundColor: Colors.white12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _sendingRequest
                      ? const SizedBox(
                          width: 23,
                          height: 23,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isOwner ? 'This is Your Book' : 'Request to Buy',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// INFO CHIP
// ============================================================

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.055),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.white54,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _EmptyBooksState extends StatelessWidget {
  final bool isSearching;

  const _EmptyBooksState({
    required this.isSearching,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF57C7B6).withOpacity(.10),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 38,
                color: Color(0xFF57C7B6),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isSearching ? 'No books found' : 'No books for sale yet',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              isSearching
                  ? 'Try another title, author, or category.'
                  : 'Be the first student to sell a second-hand book.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white54,
                height: 1.4,
              ),
            ),
          ],
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
