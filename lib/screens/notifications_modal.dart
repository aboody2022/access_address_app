import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:realtime_client/realtime_client.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:async';

class NotificationsModal extends StatefulWidget {
  final int userId;
  final bool isDarkMode;

  const NotificationsModal({
    Key? key,
    required this.userId,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<NotificationsModal> createState() => _NotificationsModalState();
}

class _NotificationsModalState extends State<NotificationsModal> {
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;
  RealtimeChannel? _channel;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _fetchNotifications();
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
          _fetchNotifications();
        });
      },
    );

    _channel?.subscribe();
  }

  Future<void> _fetchNotifications() async {
    try {
      final response = await Supabase.instance.client
          .from('notifications')
          .select()
          .eq('user_id', widget.userId)
          .eq('is_for_admin', false)
          .order('created_at', ascending: false);

      if (mounted && response.isNotEmpty) {
        setState(() {
          notifications = List<Map<String, dynamic>>.from(response);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _markAsRead(int notificationId) async {
    try {
      await Supabase.instance.client
          .from('notifications')
          .update({'is_read': true})
          .eq('notification_id', notificationId);

      if (mounted) {
        setState(() {
          notifications = notifications.map((notification) {
            if (notification['notification_id'] == notificationId) {
              return {...notification, 'is_read': true};
            }
            return notification;
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: widget.isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الإشعارات',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Cairo',
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: widget.isDarkMode ? Colors.white : Colors.black,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : notifications.isEmpty
                ? Center(
              child: Text(
                'لا توجد إشعارات',
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                  fontFamily: 'Cairo',
                ),
              ),
            )
                : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return InkWell(
                  onTap: () => _markAsRead(notification['notification_id']),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: !notification['is_read']
                          ? (widget.isDarkMode
                          ? Colors.blue.withValues(alpha:0.1)
                          : Colors.blue.withValues(alpha:0.05))
                          : null,
                      border: Border(
                        bottom: BorderSide(
                          color: widget.isDarkMode
                              ? Colors.grey[800]!
                              : Colors.grey[200]!,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification['title'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: widget.isDarkMode
                                ? Colors.white
                                : Colors.black,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification['message'] ?? '',
                          style: TextStyle(
                            color: widget.isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeago.format(
                            DateTime.parse(notification['created_at']),
                            locale: 'ar',
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.isDarkMode
                                ? Colors.grey[500]
                                : Colors.grey[600],
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}