import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/campus_background.dart';
import '../widgets/glass_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view notifications.'),
        ),
      );
    }

    return Scaffold(
      body: CampusBackground(
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _firestore
                .collection('notifications')
                .where(
                  'userId',
                  isEqualTo: user.uid,
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
                return _ErrorState(
                  message: 'Could not load notifications.',
                );
              }

              final notifications = snapshot.data?.docs.toList() ?? [];

              // Sort locally so we don't need a Firestore
              // composite index.
              notifications.sort((a, b) {
                final aTime = a.data()['createdAt'];
                final bTime = b.data()['createdAt'];

                if (aTime is Timestamp && bTime is Timestamp) {
                  return bTime.compareTo(aTime);
                }

                return 0;
              });

              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  22,
                  15,
                  22,
                  35,
                ),
                children: [
                  _Header(
                    title: 'Notifications',
                    subtitle: 'What is awaiting you.',
                    onBack: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 20),
                  if (notifications.isNotEmpty)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          _markAllAsRead(
                            notifications,
                          );
                        },
                        child: const Text(
                          'Mark all as read',
                          style: TextStyle(
                            color: Color(0xFF8EE8D8),
                          ),
                        ),
                      ),
                    ),
                  if (notifications.isEmpty) const _EmptyNotifications(),
                  ...notifications.map(
                    (doc) {
                      return _NotificationCard(
                        document: doc,
                        onTap: () {
                          _markAsRead(doc.id);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'Your requests',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 13),
                  _YourRequests(
                    firestore: _firestore,
                    userId: user.uid,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MARK ONE AS READ
  // ============================================================

  Future<void> _markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'read': true,
      });
    } catch (_) {}
  }

  // ============================================================
  // MARK ALL AS READ
  // ============================================================

  Future<void> _markAllAsRead(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> notifications,
  ) async {
    try {
      final batch = _firestore.batch();

      for (final notification in notifications) {
        final data = notification.data();

        if (data['read'] != true) {
          batch.update(
            notification.reference,
            {
              'read': true,
            },
          );
        }
      }

      await batch.commit();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'All notifications marked as read.',
          ),
          backgroundColor: Color(0xFF3AAE9E),
        ),
      );
    } catch (_) {}
  }
}

// ============================================================
// NOTIFICATION CARD
// ============================================================

class _NotificationCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> document;

  final VoidCallback onTap;

  const _NotificationCard({
    required this.document,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final data = document.data();

    final type = data['type']?.toString() ?? '';

    final title = _notificationTitle(type);

    final message = data['message']?.toString() ?? _defaultMessage(data, type);

    final isRead = data['read'] == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          padding: const EdgeInsets.all(17),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NotificationIcon(
                type: type,
                isRead: isRead,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isRead ? Colors.white70 : Colors.white,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF57C7B6),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white54,
                        height: 1.35,
                      ),
                    ),
                    if (data['itemTitle'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 7),
                        child: Text(
                          data['itemTitle'].toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF8EE8D8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _notificationTitle(String type) {
    switch (type) {
      case 'travel_request':
        return 'Travel request';

      case 'item_purchase':
        return 'Interested buyer';

      case 'book_purchase':
        return 'Book request';

      default:
        return 'New notification';
    }
  }

  String _defaultMessage(
    Map<String, dynamic> data,
    String type,
  ) {
    final from = data['fromUserName']?.toString() ?? 'Someone';

    final item = data['itemTitle']?.toString() ?? 'your listing';

    switch (type) {
      case 'travel_request':
        return '$from wants to join your trip.';

      case 'item_purchase':
        return '$from is interested in your $item.';

      case 'book_purchase':
        return '$from wants to buy your $item.';

      default:
        return 'You have a new request.';
    }
  }
}

// ============================================================
// NOTIFICATION ICON
// ============================================================

class _NotificationIcon extends StatelessWidget {
  final String type;
  final bool isRead;

  const _NotificationIcon({
    required this.type,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (type) {
      case 'travel_request':
        icon = Icons.directions_car_rounded;
        color = const Color(0xFF9D8AFF);
        break;

      case 'item_purchase':
        icon = Icons.sell_outlined;
        color = const Color(0xFFFF8FC5);
        break;

      case 'book_purchase':
        icon = Icons.menu_book_rounded;
        color = const Color(0xFF9D8AFF);
        break;

      default:
        icon = Icons.notifications_none_rounded;
        color = const Color(0xFF57C7B6);
    }

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(
          isRead ? .06 : .12,
        ),
      ),
      child: Icon(
        icon,
        color: color,
        size: 27,
      ),
    );
  }
}

// ============================================================
// YOUR REQUESTS
// ============================================================

class _YourRequests extends StatelessWidget {
  final FirebaseFirestore firestore;
  final String userId;

  const _YourRequests({
    required this.firestore,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: firestore
          .collection('requests')
          .where(
            'fromUserId',
            isEqualTo: userId,
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF57C7B6),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Text(
            'Unable to load your requests.',
            style: TextStyle(
              color: Color(0x73FFFFFF),
            ),
          );
        }

        final requests = snapshot.data?.docs.toList() ?? [];

        requests.sort((a, b) {
          final aTime = a.data()['createdAt'];
          final bTime = b.data()['createdAt'];

          if (aTime is Timestamp && bTime is Timestamp) {
            return bTime.compareTo(aTime);
          }

          return 0;
        });

        if (requests.isEmpty) {
          return const GlassCard(
            child: Text(
              'You have not sent any requests yet.',
              style: TextStyle(
                color: Color(0x73FFFFFF),
              ),
            ),
          );
        }

        return Column(
          children: requests.map((doc) {
            return _RequestCard(
              data: doc.data(),
            );
          }).toList(),
        );
      },
    );
  }
}

// ============================================================
// REQUEST CARD
// ============================================================

class _RequestCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _RequestCard({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final type = data['type']?.toString() ?? '';

    final status = data['status']?.toString() ?? 'pending';

    final itemTitle = data['itemTitle']?.toString();

    String title;
    IconData icon;

    if (type == 'book_purchase') {
      title = 'Book purchase request';
      icon = Icons.menu_book_rounded;
    } else if (type == 'item_purchase') {
      title = 'Purchase request';
      icon = Icons.shopping_bag_outlined;
    } else if (type == 'travel_request') {
      title = 'Travel request';
      icon = Icons.directions_car_rounded;
    } else {
      title = 'Request';
      icon = Icons.swap_horiz_rounded;
    }

    final statusColor = _statusColor(status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: GlassCard(
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: statusColor.withOpacity(.10),
              ),
              child: Icon(
                icon,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (itemTitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      itemTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    _statusText(status),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusText(String status) {
    switch (status) {
      case 'accepted':
        return 'Request accepted';

      case 'rejected':
        return 'Request declined';

      case 'completed':
        return 'Completed';

      case 'cancelled':
        return 'Cancelled';

      default:
        return 'Waiting for a response';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return const Color(0xFF57C7B6);

      case 'rejected':
        return Colors.redAccent;

      case 'completed':
        return const Color(0xFF8EE8D8);

      default:
        return const Color(0xFFBBA5FF);
    }
  }
}

// ============================================================
// EMPTY NOTIFICATIONS
// ============================================================

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 35,
      ),
      child: Column(
        children: [
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF57C7B6).withOpacity(.08),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 38,
              color: Color(0xFF57C7B6),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'No new notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Requests and activity will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0x66FFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ERROR
// ============================================================

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 45,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white60,
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
  final VoidCallback onBack;

  const _Header({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: onBack,
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
