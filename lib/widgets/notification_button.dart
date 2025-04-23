import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:realtime_client/realtime_client.dart';
import 'dart:async';
import 'notification_badge.dart';
import '../screens/notifications_modal.dart';


class NotificationButton extends StatefulWidget {
  final bool isDarkMode;
  final int userId;

  const NotificationButton({
    Key? key,
    required this.isDarkMode,
    required this.userId,
  }) : super(key: key);

  @override
  State<NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<NotificationButton> {
  int unreadCount = 0;
  RealtimeChannel? _channel;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _fetchUnreadCount();
  }

  void _initializeNotifications() {
    _channel = Supabase.instance.client.realtime
        .channel('public:notifications')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'notifications',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: widget.userId,
      ),
      callback: (payload) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 500), () {
          _fetchUnreadCount();
        });
      },
    );

    _channel?.subscribe();
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final response = await Supabase.instance.client
          .from('notifications')
          .select()
          .eq('user_id', widget.userId)
          .eq('is_read', false)
          .eq('is_for_admin', false);

      if (mounted && response.isNotEmpty) {
        setState(() {
          unreadCount = (response as List).length;
        });
      }
    } catch (e) {
      debugPrint('Error fetching notification count: $e');
    }
  }

  Future<void> _showNotifications() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => NotificationsModal(
        userId: widget.userId,
        isDarkMode: widget.isDarkMode,
      ),
    );
    _fetchUnreadCount();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showNotifications,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(10),
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          NotificationBadge(count: unreadCount),
        ],
      ),
    );
  }
}