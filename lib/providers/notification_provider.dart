import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// class NotificationProvider with ChangeNotifier {
//   final int _userId;
//   int _unreadCount = 0;
//   RealtimeChannel? _notificationChannel;
//
//   NotificationProvider(this._userId) {
//     _initializeNotifications();
//   }
//
//   int get unreadCount => _unreadCount;
//   int get userId => _userId;
//
//   void _initializeNotifications() {
//     // إنشاء اتصال Realtime
//     _notificationChannel = Supabase.instance.client
//         .channel('public:notifications')
//         .onPostgresChanges(
//       event: PostgresChangeEvent.insert,
//       schema: 'public',
//       table: 'notifications',
//       filter: PostgresChangeFilter(
//         type: PostgresChangeFilterType.eq,
//         column: 'user_id',
//         value: _userId,
//       ),
//       callback: (payload) {
//         updateUnreadCount();
//       },
//     );
//
//     // الاشتراك في القناة
//     _notificationChannel?.subscribe();
//
//     // تحديث العدد الأولي
//     updateUnreadCount();
//   }
//
//   Future<void> updateUnreadCount() async {
//     try {
//       final response = await Supabase.instance.client
//           .from('notifications')
//           .count()
//           .eq('user_id', _userId)
//           .eq('is_read', false);
//
//       _unreadCount = response ?? 0;
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Error updating notification count: $e');
//     }
//   }
//
//   @override
//   void dispose() {
//     _notificationChannel?.unsubscribe();
//     super.dispose();
//   }
// }

class NotificationProvider with ChangeNotifier {
  final int _userId;
  int _unreadCount = 0;
  bool _isInitialized = false;
  RealtimeChannel? _notificationChannel;

  // حالة التحميل
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // الوصول للبيانات
  int get unreadCount => _unreadCount;
  int get userId => _userId;
  bool get isInitialized => _isInitialized;

  NotificationProvider(this._userId) {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    if (_isInitialized) return;

    try {
      // إلغاء الاشتراك السابق إذا وجد
      await _notificationChannel?.unsubscribe();

      // إنشاء اتصال Realtime جديد
      _notificationChannel = Supabase.instance.client
          .channel('notifications_$_userId')
          .onPostgresChanges(
        event: PostgresChangeEvent.all, // الاستماع لجميع التغييرات
        schema: 'public',
        table: 'notifications',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: _userId,
        ),
        callback: (payload) {
          // تحديث العدد عند أي تغيير
          updateUnreadCount();
        },
      );

      // الاشتراك في القناة
      await _notificationChannel?.subscribe();

      // تحديث العدد الأولي
      await updateUnreadCount();

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
      _handleError('فشل في تهيئة الإشعارات');
    }
  }

  Future<void> updateUnreadCount() async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      notifyListeners();

      final response = await Supabase.instance.client
          .from('notifications')
          .count() // تحديد العمود للعد
          .eq('user_id', _userId)
          .eq('is_read', false);

      _unreadCount = response;
    } catch (e) {
      debugPrint('Error updating notification count: $e');
      _handleError('فشل في تحديث عدد الإشعارات');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // تحديث حالة قراءة الإشعار
  Future<void> markAsRead(int notificationId) async {
    try {
      await Supabase.instance.client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId)
          .eq('user_id', _userId);

      await updateUnreadCount();
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      _handleError('فشل في تحديث حالة الإشعار');
    }
  }

  // تحديث جميع الإشعارات كمقروءة
  Future<void> markAllAsRead() async {
    try {
      await Supabase.instance.client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', _userId)
          .eq('is_read', false);

      await updateUnreadCount();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      _handleError('فشل في تحديث جميع الإشعارات');
    }
  }

  // إعادة تحميل الإشعارات
  Future<void> refresh() async {
    _isInitialized = false;
    await _initializeNotifications();
  }

  void _handleError(String message) {
    // يمكنك تنفيذ معالجة الأخطاء هنا
    // مثل عرض رسالة للمستخدم أو تسجيل الخطأ
  }

  @override
  void dispose() {
    _notificationChannel?.unsubscribe();
    _isInitialized = false;
    super.dispose();
  }
}