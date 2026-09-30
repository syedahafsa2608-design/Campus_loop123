import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/campus_background.dart';
import '../widgets/glass_card.dart';

class BuyScreen extends StatefulWidget {
  const BuyScreen({super.key});

  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      if (!mounted) return;

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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1716),
      body: CampusBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              22,
              18,
              22,
              35,
            ),
            children: [
              const _Header(
                title: 'Buy Something',
                subtitle: 'Find useful things from people around campus.',
              ),

              const SizedBox(height: 22),

              // ==================================================
              // SEARCH
              // ==================================================

              Container(
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
                  decoration: InputDecoration(
                    icon: const Icon(
                      Icons.search,
                      color: Color(0xFF9D8AFF),
                    ),
                    hintText: 'Search for something...',
                    hintStyle: const TextStyle(
                      color: Colors.white38,
                    ),
                    border: InputBorder.none,
                    suffixIcon: _searchText.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                            },
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white38,
                            ),
                          )
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Available items',
                style: TextStyle(
                  color: Color(0xFFE5ECE8),
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Items posted by students',
                style: TextStyle(
                  color: Color(0xFF81938B),
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 14),

              // ==================================================
              // FIRESTORE
              // ==================================================

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('items')
                    .where(
                      'app',
                      isEqualTo: 'campusloop',
                    )
                    .where(
                      'status',
                      isEqualTo: 'available',
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  // ------------------------------------------------
                  // LOADING
                  // ------------------------------------------------

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 45),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF57C7B6),
                        ),
                      ),
                    );
                  }

                  // ------------------------------------------------
                  // ERROR
                  // ------------------------------------------------

                  if (snapshot.hasError) {
                    debugPrint(
                      'BUY FIRESTORE ERROR: '
                      '${snapshot.error}',
                    );

                    return const _EmptyState(
                      icon: Icons.error_outline,
                      title: 'Could not load items',
                      subtitle: 'There was a problem connecting to Firebase.',
                    );
                  }

                  final documents = snapshot.data?.docs ?? [];

                  // ------------------------------------------------
                  // SORT NEWEST FIRST
                  // ------------------------------------------------

                  documents.sort((a, b) {
                    final dataA = a.data() as Map<String, dynamic>;

                    final dataB = b.data() as Map<String, dynamic>;

                    final Timestamp? timeA = dataA['createdAt'] as Timestamp?;

                    final Timestamp? timeB = dataB['createdAt'] as Timestamp?;

                    if (timeA == null && timeB == null) {
                      return 0;
                    }

                    if (timeA == null) {
                      return 1;
                    }

                    if (timeB == null) {
                      return -1;
                    }

                    return timeB.compareTo(timeA);
                  });

                  // ------------------------------------------------
                  // SEARCH
                  // ------------------------------------------------

                  final filteredItems = documents.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    final title =
                        (data['title'] ?? '').toString().toLowerCase();

                    final category =
                        (data['category'] ?? '').toString().toLowerCase();

                    final description =
                        (data['description'] ?? '').toString().toLowerCase();

                    return title.contains(
                          _searchText,
                        ) ||
                        category.contains(
                          _searchText,
                        ) ||
                        description.contains(
                          _searchText,
                        );
                  }).toList();

                  // ------------------------------------------------
                  // EMPTY
                  // ------------------------------------------------

                  if (filteredItems.isEmpty) {
                    return _EmptyState(
                      icon: Icons.shopping_bag_outlined,
                      title: _searchText.isEmpty
                          ? 'No items for sale yet'
                          : 'No matching items',
                      subtitle: _searchText.isEmpty
                          ? 'Items posted by students will appear here.'
                          : 'Try searching for something else.',
                    );
                  }

                  // ------------------------------------------------
                  // ITEMS
                  // ------------------------------------------------

                  return Column(
                    children: filteredItems.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;

                      return _ProductCard(
                        itemId: doc.id,
                        title: (data['title'] ?? 'Untitled item').toString(),
                        description: (data['description'] ?? '').toString(),
                        price: _formatPrice(
                          data['price'],
                        ),
                        category: (data['category'] ?? 'Other').toString(),
                        condition:
                            (data['condition'] ?? 'Not specified').toString(),
                        image: (data['image'] ?? '').toString(),
                        sellerId: (data['userId'] ?? '').toString(),
                        sellerName: (data['userName'] ?? 'Student').toString(),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FORMAT PRICE
  // ============================================================

  String _formatPrice(dynamic value) {
    if (value == null) {
      return '₹0';
    }

    if (value is num) {
      if (value % 1 == 0) {
        return '₹${value.toInt()}';
      }

      return '₹${value.toStringAsFixed(2)}';
    }

    return '₹$value';
  }
}

// ================================================================
// PRODUCT CARD
// ================================================================

class _ProductCard extends StatelessWidget {
  final String itemId;
  final String title;
  final String description;
  final String price;
  final String category;
  final String condition;
  final String image;
  final String sellerId;
  final String sellerName;

  const _ProductCard({
    required this.itemId,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.condition,
    required this.image,
    required this.sellerId,
    required this.sellerName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _ItemDetailsScreen(
                itemId: itemId,
                title: title,
                description: description,
                price: price,
                category: category,
                condition: condition,
                image: image,
                sellerId: sellerId,
                sellerName: sellerName,
              ),
            ),
          );
        },
        child: GlassCard(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              _ItemImage(
                image: image,
                category: category,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      category,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      price,
                      style: const TextStyle(
                        color: Color(0xFFBBA5FF),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      condition,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
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
}

// ================================================================
// ITEM IMAGE
// ================================================================

class _ItemImage extends StatelessWidget {
  final String image;
  final String category;

  const _ItemImage({
    required this.image,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    if (image.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.network(
          image,
          width: 65,
          height: 65,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _PlaceholderIcon(
              category: category,
            );
          },
        ),
      );
    }

    return _PlaceholderIcon(
      category: category,
    );
  }
}

// ================================================================
// PLACEHOLDER ICON
// ================================================================

class _PlaceholderIcon extends StatelessWidget {
  final String category;

  const _PlaceholderIcon({
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;

    switch (category.toLowerCase()) {
      case 'electronics':
        icon = Icons.devices_other_outlined;
        break;

      case 'books':
      case 'study':
        icon = Icons.menu_book_outlined;
        break;

      case 'clothing':
        icon = Icons.checkroom_outlined;
        break;

      case 'room':
        icon = Icons.chair_outlined;
        break;

      case 'sports':
        icon = Icons.sports_soccer_outlined;
        break;

      default:
        icon = Icons.shopping_bag_outlined;
    }

    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(.07),
      ),
      child: Icon(
        icon,
        size: 29,
        color: const Color(0xFF9D8AFF),
      ),
    );
  }
}

// ================================================================
// ITEM DETAILS SCREEN
// ================================================================

class _ItemDetailsScreen extends StatelessWidget {
  final String itemId;
  final String title;
  final String description;
  final String price;
  final String category;
  final String condition;
  final String image;
  final String sellerId;
  final String sellerName;

  const _ItemDetailsScreen({
    required this.itemId,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.condition,
    required this.image,
    required this.sellerId,
    required this.sellerName,
  });

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    final bool isOwner = currentUser != null && currentUser.uid == sellerId;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1716),
      body: CampusBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              22,
              18,
              22,
              35,
            ),
            children: [
              IconButton(
                alignment: Alignment.centerLeft,
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFFA7B7B0),
                ),
              ),

              const SizedBox(height: 10),

              // ------------------------------------------------
              // IMAGE
              // ------------------------------------------------

              Container(
                height: 230,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.white.withOpacity(.05),
                  border: Border.all(
                    color: Colors.white.withOpacity(.08),
                  ),
                ),
                child: image.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.network(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return const Icon(
                              Icons.image_not_supported_outlined,
                              size: 55,
                              color: Colors.white30,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.shopping_bag_outlined,
                        size: 60,
                        color: Color(0xFF9D8AFF),
                      ),
              ),

              const SizedBox(height: 24),

              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                price,
                style: const TextStyle(
                  color: Color(0xFFBBA5FF),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Flexible(
                    child: _Tag(
                      icon: Icons.category_outlined,
                      text: category,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: _Tag(
                      icon: Icons.verified_outlined,
                      text: condition,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              const Text(
                'About this item',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 9),

              Text(
                description.isEmpty ? 'No description provided.' : description,
                style: const TextStyle(
                  color: Colors.white60,
                  height: 1.5,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Seller',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              GlassCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(
                        0xFF9D8AFF,
                      ).withOpacity(.15),
                      child: const Icon(
                        Icons.person_outline,
                        color: Color(0xFFBBA5FF),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        sellerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ------------------------------------------------
              // REQUEST BUTTON
              // ------------------------------------------------

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: isOwner
                      ? null
                      : () => _requestToBuy(
                            context,
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9D8AFF),
                    disabledBackgroundColor: Colors.white12,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    isOwner ? 'This is Your Listing' : 'Request to Buy',
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

  // ============================================================
  // REQUEST TO BUY
  // ============================================================

  Future<void> _requestToBuy(BuildContext context) async {
    final User? buyer = FirebaseAuth.instance.currentUser;

    if (buyer == null) {
      _showMessage(
        context,
        'Please log in to request this item.',
      );
      return;
    }

    if (buyer.uid == sellerId) {
      _showMessage(
        context,
        'You cannot request your own item.',
      );
      return;
    }

    // ----------------------------------------------------------
    // SHOW LOADING DIALOG
    // ----------------------------------------------------------

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF9D8AFF),
          ),
        );
      },
    );

    try {
      // --------------------------------------------------------
      // CHECK EXISTING REQUEST
      // --------------------------------------------------------

      final QuerySnapshot existingRequest = await FirebaseFirestore.instance
          .collection('requests')
          .where(
            'app',
            isEqualTo: 'campusloop',
          )
          .where(
            'itemId',
            isEqualTo: itemId,
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

      if (existingRequest.docs.isNotEmpty) {
        if (context.mounted) {
          Navigator.pop(context);
        }

        _showMessage(
          context,
          'You have already requested this item.',
        );
        return;
      }

      // --------------------------------------------------------
      // CREATE REQUEST
      // --------------------------------------------------------

      await FirebaseFirestore.instance.collection('requests').add({
        'app': 'campusloop',
        'type': 'item_purchase',
        'itemId': itemId,
        'itemTitle': title,
        'price': price,
        'fromUserId': buyer.uid,
        'fromUserName': buyer.displayName ?? buyer.email ?? 'Student',
        'toUserId': sellerId,
        'toUserName': sellerName,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // --------------------------------------------------------
      // SELLER NOTIFICATION
      // --------------------------------------------------------

      await FirebaseFirestore.instance.collection('notifications').add({
        'app': 'campusloop',
        'userId': sellerId,
        'type': 'item_purchase',
        'itemId': itemId,
        'itemTitle': title,
        'fromUserId': buyer.uid,
        'fromUserName': buyer.displayName ?? buyer.email ?? 'Student',
        'message':
            '${buyer.displayName ?? 'A student'} wants to buy your $title.',
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;

      Navigator.pop(context);

      _showMessage(
        context,
        'Purchase request sent to the seller.',
      );
    } on FirebaseException catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
      }

      debugPrint(
        'BUY REQUEST ERROR: ${e.code}',
      );

      String message = 'Could not send the request.';

      if (e.code == 'permission-denied') {
        message = 'Firebase denied this request.';
      }

      _showMessage(
        context,
        message,
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
      }

      debugPrint(
        'BUY REQUEST ERROR: $e',
      );

      _showMessage(
        context,
        'Could not send the request. Please try again.',
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF243B36),
        ),
      );
  }
}

// ================================================================
// TAG
// ================================================================

class _Tag extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Tag({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: const Color(0xFFBBA5FF),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// EMPTY STATE
// ================================================================

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 50,
        left: 15,
        right: 15,
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 52,
            color: Colors.white24,
          ),
          const SizedBox(height: 15),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// HEADER
// ================================================================

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
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFFA7B7B0),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFE5ECE8),
            fontSize: 29,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF81938B),
          ),
        ),
      ],
    );
  }
}
