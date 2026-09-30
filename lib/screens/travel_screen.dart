import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/campus_background.dart';
import '../widgets/glass_card.dart';

class TravelScreen extends StatefulWidget {
  const TravelScreen({super.key});

  @override
  State<TravelScreen> createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _destinationSearchController =
      TextEditingController();

  final TextEditingController _dateSearchController = TextEditingController();

  final TextEditingController _timeSearchController = TextEditingController();

  String _searchDestination = '';
  String _searchDate = '';
  String _searchTime = '';

  @override
  void dispose() {
    _destinationSearchController.dispose();
    _dateSearchController.dispose();
    _timeSearchController.dispose();
    super.dispose();
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void _searchTrips() {
    setState(() {
      _searchDestination =
          _destinationSearchController.text.trim().toLowerCase();

      _searchDate = _dateSearchController.text.trim().toLowerCase();

      _searchTime = _timeSearchController.text.trim().toLowerCase();
    });
  }

  void _clearSearch() {
    _destinationSearchController.clear();
    _dateSearchController.clear();
    _timeSearchController.clear();

    setState(() {
      _searchDestination = '';
      _searchDate = '';
      _searchTime = '';
    });
  }

  bool _matchesSearch(Map<String, dynamic> data) {
    final destination = data['destination']?.toString().toLowerCase() ?? '';

    final date = data['date']?.toString().toLowerCase() ?? '';

    final time = data['time']?.toString().toLowerCase() ?? '';

    final destinationMatches =
        _searchDestination.isEmpty || destination.contains(_searchDestination);

    final dateMatches = _searchDate.isEmpty || date.contains(_searchDate);

    final timeMatches = _searchTime.isEmpty || time.contains(_searchTime);

    return destinationMatches && dateMatches && timeMatches;
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
              100,
            ),
            children: [
              const _Header(
                title: 'Travel with a Friend',
                subtitle: 'Going somewhere? Find someone going your way.',
              ),

              const SizedBox(height: 24),

              // ==================================================
              // SEARCH CARD
              // ==================================================

              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Find a trip',
                      style: TextStyle(
                        color: Color(0xFFE1EAE5),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Find students travelling in your direction.',
                      style: TextStyle(
                        color: Color(0xFF82958C),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _SearchField(
                      controller: _destinationSearchController,
                      icon: Icons.location_on_outlined,
                      hint: 'Destination',
                    ),
                    const SizedBox(height: 12),
                    _SearchField(
                      controller: _dateSearchController,
                      icon: Icons.calendar_today_outlined,
                      hint: 'Date',
                    ),
                    const SizedBox(height: 12),
                    _SearchField(
                      controller: _timeSearchController,
                      icon: Icons.access_time_rounded,
                      hint: 'Time',
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _searchTrips,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFF176B68,
                                ),
                                foregroundColor: const Color(
                                  0xFFE8F0EC,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    17,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Find Trips',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (_searchDestination.isNotEmpty ||
                            _searchDate.isNotEmpty ||
                            _searchTime.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: _clearSearch,
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFF17302C),
                              padding: const EdgeInsets.all(14),
                            ),
                            icon: const Icon(
                              Icons.clear_rounded,
                              color: Color(0xFFA8B8B1),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Trips you might join',
                style: TextStyle(
                  color: Color(0xFFE0E9E4),
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 5),

              // ==================================================
              // FIRESTORE TRIPS
              // ==================================================

              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _firestore
                    .collection('trips')
                    .orderBy(
                      'createdAt',
                      descending: true,
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF6F8F7A),
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: GlassCard(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: Colors.redAccent,
                              size: 38,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Could not load trips.',
                              style: TextStyle(
                                color: Color(0xFFE3ECE7),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF82958C),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final documents = snapshot.data?.docs ?? [];

                  final filteredDocuments = documents.where((document) {
                    return _matchesSearch(
                      document.data(),
                    );
                  }).toList();

                  // ==================================================
                  // EMPTY STATE
                  // ==================================================

                  if (filteredDocuments.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: GlassCard(
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF176B68,
                                ).withOpacity(.15),
                                borderRadius: BorderRadius.circular(
                                  18,
                                ),
                              ),
                              child: const Icon(
                                Icons.directions_car_outlined,
                                size: 30,
                                color: Color(0xFF80AAA0),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              documents.isEmpty
                                  ? 'No trips posted yet'
                                  : 'No matching trips',
                              style: const TextStyle(
                                color: Color(0xFFE3ECE7),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              documents.isEmpty
                                  ? 'Be the first student to post a trip.'
                                  : 'Try changing your search filters.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF71847B),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '${filteredDocuments.length} '
                        '${filteredDocuments.length == 1 ? 'trip' : 'trips'} available',
                        style: const TextStyle(
                          color: Color(0xFF71847B),
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...filteredDocuments.map(
                        (document) {
                          final data = document.data();

                          final seats = data['seats'] ?? 0;

                          final price = data['price'] ?? 0;

                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: 14,
                            ),
                            child: _TripCard(
                              tripId: document.id,
                              destination:
                                  data['destination']?.toString() ?? '',
                              route: data['route']?.toString() ?? '',
                              date: data['date']?.toString() ?? '',
                              time: data['time']?.toString() ?? '',
                              price: '₹$price / person',
                              seats: '$seats seats',
                              ownerId: data['userId']?.toString() ?? '',
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),

      // ==========================================================
      // POST TRIP BUTTON
      // ==========================================================

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF176B68),
        foregroundColor: const Color(0xFFE7F0EC),
        elevation: 5,
        onPressed: () {
          _showPostTrip(context);
        },
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: const Text(
          'Post a Trip',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // POST TRIP
  // ============================================================

  void _showPostTrip(BuildContext context) {
    final destinationController = TextEditingController();

    final routeController = TextEditingController();

    final seatsController = TextEditingController();

    final priceController = TextEditingController();

    final dateController = TextEditingController();

    final timeController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF10201D),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 22,
            right: 22,
            top: 25,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 25,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF70847B),
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Post your trip',
                  style: TextStyle(
                    color: Color(0xFFE4ECE8),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Let other students know about your journey.',
                  style: TextStyle(
                    color: Color(0xFF82958C),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                _InputField(
                  controller: destinationController,
                  icon: Icons.location_on_outlined,
                  hint: 'Where are you going?',
                ),
                const SizedBox(height: 12),
                _InputField(
                  controller: routeController,
                  icon: Icons.route_rounded,
                  hint: 'Starting point → destination',
                ),
                const SizedBox(height: 12),
                _InputField(
                  controller: dateController,
                  icon: Icons.calendar_today_outlined,
                  hint: 'Date',
                ),
                const SizedBox(height: 12),
                _InputField(
                  controller: timeController,
                  icon: Icons.access_time_rounded,
                  hint: 'Time',
                ),
                const SizedBox(height: 12),
                _InputField(
                  controller: seatsController,
                  icon: Icons.people_outline_rounded,
                  hint: 'How many people can join?',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _InputField(
                  controller: priceController,
                  icon: Icons.currency_rupee_rounded,
                  hint: 'Estimated cost per person',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      final destination = destinationController.text.trim();

                      final route = routeController.text.trim();

                      final date = dateController.text.trim();

                      final time = timeController.text.trim();

                      final seats = seatsController.text.trim();

                      final price = priceController.text.trim();

                      if (destination.isEmpty ||
                          route.isEmpty ||
                          date.isEmpty ||
                          time.isEmpty ||
                          seats.isEmpty ||
                          price.isEmpty) {
                        ScaffoldMessenger.of(
                          sheetContext,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please fill all the fields.',
                            ),
                          ),
                        );
                        return;
                      }

                      final parsedSeats = int.tryParse(seats);

                      final parsedPrice = double.tryParse(price);

                      if (parsedSeats == null || parsedSeats <= 0) {
                        ScaffoldMessenger.of(
                          sheetContext,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Enter a valid number of seats.',
                            ),
                          ),
                        );
                        return;
                      }

                      if (parsedPrice == null || parsedPrice < 0) {
                        ScaffoldMessenger.of(
                          sheetContext,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Enter a valid price.',
                            ),
                          ),
                        );
                        return;
                      }

                      final user = FirebaseAuth.instance.currentUser;

                      if (user == null) {
                        ScaffoldMessenger.of(
                          sheetContext,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please log in before posting a trip.',
                            ),
                          ),
                        );
                        return;
                      }

                      try {
                        await _firestore.collection('trips').add({
                          'destination': destination,
                          'route': route,
                          'date': date,
                          'time': time,
                          'seats': parsedSeats,
                          'price': parsedPrice,
                          'userId': user.uid,
                          'userName':
                              user.displayName ?? user.email ?? 'Student',
                          'createdAt': FieldValue.serverTimestamp(),
                        });

                        if (!sheetContext.mounted) {
                          return;
                        }

                        Navigator.pop(
                          sheetContext,
                        );

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Your trip has been posted.',
                            ),
                          ),
                        );
                      } catch (e) {
                        if (!sheetContext.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(
                          sheetContext,
                        ).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Could not post trip: $e',
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF176B68),
                      foregroundColor: const Color(0xFFE8F0EC),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          17,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Post Trip',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// TRIP CARD
// ============================================================

class _TripCard extends StatelessWidget {
  final String tripId;
  final String destination;
  final String route;
  final String date;
  final String time;
  final String price;
  final String seats;
  final String ownerId;

  const _TripCard({
    required this.tripId,
    required this.destination,
    required this.route,
    required this.date,
    required this.time,
    required this.price,
    required this.seats,
    required this.ownerId,
  });

  Future<void> _sendJoinRequest(
    BuildContext context,
  ) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please log in first.',
          ),
        ),
      );
      return;
    }

    if (currentUser.uid == ownerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You cannot join your own trip.',
          ),
        ),
      );
      return;
    }

    try {
      final requestQuery = await FirebaseFirestore.instance
          .collection('requests')
          .where(
            'type',
            isEqualTo: 'travel_join',
          )
          .where(
            'itemId',
            isEqualTo: tripId,
          )
          .where(
            'fromUserId',
            isEqualTo: currentUser.uid,
          )
          .limit(1)
          .get();

      if (requestQuery.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'You have already requested to join this trip.',
            ),
          ),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('requests').add({
        'type': 'travel_join',
        'itemId': tripId,
        'fromUserId': currentUser.uid,
        'fromUserName':
            currentUser.displayName ?? currentUser.email ?? 'Student',
        'toUserId': ownerId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('notifications').add({
        'type': 'travel_join_request',
        'userId': ownerId,
        'fromUserId': currentUser.uid,
        'itemId': tripId,
        'title': 'New travel request',
        'message':
            '${currentUser.displayName ?? 'A student'} wants to join your trip to $destination.',
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Join request sent successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not send request: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF176B68).withOpacity(.16),
                  borderRadius: BorderRadius.circular(
                    15,
                  ),
                  border: Border.all(
                    color: const Color(0xFF6F9D91).withOpacity(.18),
                  ),
                ),
                child: const Icon(
                  Icons.directions_car_rounded,
                  color: Color(0xFF80AAA0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  destination,
                  style: const TextStyle(
                    color: Color(0xFFE3ECE7),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            route,
            style: const TextStyle(
              color: Color(0xFFA2B1AA),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '$date • $time',
            style: const TextStyle(
              color: Color(0xFF71847B),
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _InfoPill(
                icon: Icons.people_outline,
                text: seats,
              ),
              const SizedBox(width: 8),
              _InfoPill(
                icon: Icons.currency_rupee,
                text: price,
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                _sendJoinRequest(
                  context,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF17302C),
                foregroundColor: const Color(0xFFB6C8C0),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    15,
                  ),
                ),
              ),
              child: const Text(
                'Contact & Join',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// INFO PILL
// ============================================================

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF17302C).withOpacity(.75),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF7B958A).withOpacity(.10),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 15,
            color: const Color(0xFF829E92),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFA2B2AA),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SEARCH FIELD
// ============================================================

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;

  const _SearchField({
    required this.controller,
    required this.icon,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        color: Color(0xFFE0E9E4),
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF78948A),
        ),
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF80938B),
        ),
        filled: true,
        fillColor: const Color(0xFF17302C).withOpacity(.65),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            16,
          ),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            16,
          ),
          borderSide: const BorderSide(
            color: Color(0xFF4F8E83),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// POST INPUT FIELD
// ============================================================

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final TextInputType keyboardType;

  const _InputField({
    required this.controller,
    required this.icon,
    required this.hint,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Color(0xFFE0E9E4),
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF78948A),
        ),
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF687B73),
        ),
        filled: true,
        fillColor: const Color(0xFF17302C).withOpacity(.65),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            16,
          ),
          borderSide: BorderSide(
            color: const Color(0xFF8AA69B).withOpacity(.10),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            16,
          ),
          borderSide: BorderSide(
            color: const Color(0xFF8AA69B).withOpacity(.10),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            16,
          ),
          borderSide: const BorderSide(
            color: Color(0xFF4F8E83),
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
