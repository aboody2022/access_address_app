// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// class HomeModel extends ChangeNotifier {
//   final SupabaseClient _supabaseClient = Supabase.instance.client;
//   List<Map<String, dynamic>> _orders = [];
//   List<Map<String, dynamic>> _vehicles = [];
//   bool _isOrdersLoading = true;
//   bool _isVehiclesLoading = true;
//
//   List<Map<String, dynamic>> get orders => _orders;
//   List<Map<String, dynamic>> get vehicles => _vehicles;
//   bool get isOrdersLoading => _isOrdersLoading;
//   bool get isVehiclesLoading => _isVehiclesLoading;
//
//   Future<void> fetchOrders(int userID) async {
//     _isOrdersLoading = true;
//     notifyListeners();
//
//     try {
//       final response = await _supabaseClient
//           .from('maintenance_requests')
//           .select('*, vehicles(model_id, models(name), year), request_status(*, status_name), problem_description')
//           .eq('user_id', userID)
//           .order('created_at', ascending: false)
//           .limit(3);
//
//       if (response.isNotEmpty) {
//         _orders = List<Map<String, dynamic>>.from(response);
//       } else {
//         _orders.clear(); // تأكد من مسح البيانات إذا لم يكن هناك بيانات جديدة
//       }
//     } catch (error) {
//     } finally {
//       _isOrdersLoading = false;
//       notifyListeners();
//     }
//   }
//
//   Future<void> fetchVehicles(int userID) async {
//     _isVehiclesLoading = true;
//     notifyListeners();
//
//     try {
//       final vehicleResponse = await _supabaseClient
//           .from('vehicles')
//           .select('*, manufacturers(name), models(name)')
//           .eq('user_id', userID)
//           .order('created_at', ascending: false)
//           .limit(3);
//
//       if (vehicleResponse.isNotEmpty) {
//         _vehicles = List<Map<String, dynamic>>.from(vehicleResponse);
//       } else {
//         _vehicles.clear(); // تأكد من مسح البيانات إذا لم يكن هناك بيانات جديدة
//       }
//     } catch (error) {
//     } finally {
//       _isVehiclesLoading = false;
//       notifyListeners();
//     }
//   }
// }

import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeModel extends ChangeNotifier {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // Cache للبيانات
  final Map<String, dynamic> _cache = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);

  // البيانات
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _vehicles = [];

  // حالات التحميل المحددة
  bool _isOrdersLoading = false;
  bool _isVehiclesLoading = false;
  bool _isCreatingOrder = false;
  bool _isAddingVehicle = false;
  bool _isUpdatingOrder = false;
  bool _isUpdatingVehicle = false;

  // حالة الأخطاء
  bool _hasError = false;
  String? _errorMessage;

  // Real-time subscriptions
  RealtimeChannel? _ordersChannel;
  RealtimeChannel? _vehiclesChannel;

  // Retry mechanism
  int _retryCount = 0;
  static const int _maxRetries = 3;
  Timer? _retryTimer;

  // Getters
  List<Map<String, dynamic>> get orders => List.unmodifiable(_orders);
  List<Map<String, dynamic>> get vehicles => List.unmodifiable(_vehicles);
  bool get isOrdersLoading => _isOrdersLoading;
  bool get isVehiclesLoading => _isVehiclesLoading;
  bool get isCreatingOrder => _isCreatingOrder;
  bool get isAddingVehicle => _isAddingVehicle;
  bool get isUpdatingOrder => _isUpdatingOrder;
  bool get isUpdatingVehicle => _isUpdatingVehicle;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isOrdersLoading || _isVehiclesLoading || _isCreatingOrder || _isAddingVehicle;

  /// تهيئة Real-time subscriptions
  Future<void> initializeRealtime(int userID) async {
    try {
      // إعداد real-time للطلبات
      _ordersChannel = _supabaseClient
          .channel('orders_$userID')
          .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'maintenance_requests',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: userID,
        ),
        callback: _handleOrdersRealtime,
      )
          .subscribe();

      // إعداد real-time للمركبات
      _vehiclesChannel = _supabaseClient
          .channel('vehicles_$userID')
          .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'vehicles',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: userID,
        ),
        callback: _handleVehiclesRealtime,
      )
          .subscribe();

      developer.log('Real-time subscriptions initialized', name: 'EnhancedHomeModel');
    } catch (e) {
      developer.log('Error initializing real-time: $e', name: 'EnhancedHomeModel', level: 1000);
    }
  }

  /// معالج التحديثات المباشرة للطلبات
  void _handleOrdersRealtime(PostgresChangePayload payload) {
    developer.log('Orders real-time update: ${payload.eventType}', name: 'EnhancedHomeModel');

    switch (payload.eventType) {
      case PostgresChangeEvent.insert:
        _handleOrderInsert(payload.newRecord);
        break;
      case PostgresChangeEvent.update:
        _handleOrderUpdate(payload.newRecord);
        break;
      case PostgresChangeEvent.delete:
        _handleOrderDelete(payload.oldRecord);
        break;
      case PostgresChangeEvent.all:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  /// معالج التحديثات المباشرة للمركبات
  void _handleVehiclesRealtime(PostgresChangePayload payload) {
    developer.log('Vehicles real-time update: ${payload.eventType}', name: 'EnhancedHomeModel');

    switch (payload.eventType) {
      case PostgresChangeEvent.insert:
        _handleVehicleInsert(payload.newRecord);
        break;
      case PostgresChangeEvent.update:
        _handleVehicleUpdate(payload.newRecord);
        break;
      case PostgresChangeEvent.delete:
        _handleVehicleDelete(payload.oldRecord);
        break;
      case PostgresChangeEvent.all:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  /// معالجة إدراج طلب جديد
  void _handleOrderInsert(Map<String, dynamic> newOrder) {
    // جلب البيانات الكاملة للطلب الجديد
    _fetchSingleOrder(newOrder['id']).then((fullOrder) {
      if (fullOrder != null) {
        _orders.insert(0, fullOrder);
        if (_orders.length > 10) _orders.removeLast(); // الحفاظ على 10 عناصر فقط
        _invalidateCache('orders');
        notifyListeners();
      }
    });
  }

  /// معالجة تحديث طلب
  void _handleOrderUpdate(Map<String, dynamic> updatedOrder) {
    final index = _orders.indexWhere((order) => order['id'] == updatedOrder['id']);
    if (index != -1) {
      // جلب البيانات الكاملة للطلب المحدث
      _fetchSingleOrder(updatedOrder['id']).then((fullOrder) {
        if (fullOrder != null) {
          _orders[index] = fullOrder;
          _invalidateCache('orders');
          notifyListeners();
        }
      });
    }
  }

  /// معالجة حذف طلب
  void _handleOrderDelete(Map<String, dynamic> deletedOrder) {
    _orders.removeWhere((order) => order['id'] == deletedOrder['id']);
    _invalidateCache('orders');
    notifyListeners();
  }

  /// معالجة إدراج مركبة جديدة
  void _handleVehicleInsert(Map<String, dynamic> newVehicle) {
    _fetchSingleVehicle(newVehicle['id']).then((fullVehicle) {
      if (fullVehicle != null) {
        _vehicles.insert(0, fullVehicle);
        if (_vehicles.length > 10) _vehicles.removeLast();
        _invalidateCache('vehicles');
        notifyListeners();
      }
    });
  }

  /// معالجة تحديث مركبة
  void _handleVehicleUpdate(Map<String, dynamic> updatedVehicle) {
    final index = _vehicles.indexWhere((vehicle) => vehicle['id'] == updatedVehicle['id']);
    if (index != -1) {
      _fetchSingleVehicle(updatedVehicle['id']).then((fullVehicle) {
        if (fullVehicle != null) {
          _vehicles[index] = fullVehicle;
          _invalidateCache('vehicles');
          notifyListeners();
        }
      });
    }
  }

  /// معالجة حذف مركبة
  void _handleVehicleDelete(Map<String, dynamic> deletedVehicle) {
    _vehicles.removeWhere((vehicle) => vehicle['id'] == deletedVehicle['id']);
    _invalidateCache('vehicles');
    notifyListeners();
  }

  /// جلب طلب واحد بالبيانات الكاملة
  Future<Map<String, dynamic>?> _fetchSingleOrder(int orderId) async {
    try {
      final response = await _supabaseClient
          .from('maintenance_requests')
          .select('*, vehicles(model_id, models(name), year), request_status(*, status_name), problem_description')
          .eq('id', orderId)
          .single();

      return response;
    } catch (e) {
      developer.log('Error fetching single order: $e', name: 'EnhancedHomeModel', level: 1000);
      return null;
    }
  }

  /// جلب مركبة واحدة بالبيانات الكاملة
  Future<Map<String, dynamic>?> _fetchSingleVehicle(int vehicleId) async {
    try {
      final response = await _supabaseClient
          .from('vehicles')
          .select('*, manufacturers(name), models(name)')
          .eq('id', vehicleId)
          .single();

      return response;
    } catch (e) {
      developer.log('Error fetching single vehicle: $e', name: 'EnhancedHomeModel', level: 1000);
      return null;
    }
  }

  /// جلب الطلبات مع Cache
  // Future<void> fetchOrders(int userID, {bool forceRefresh = false}) async {
  //   if (userID <= 0) {
  //     _setError('معرف المستخدم غير صالح');
  //     return;
  //   }
  //
  //   final cacheKey = 'orders_$userID';
  //
  //   // التحقق من Cache
  //   if (!forceRefresh && _isCacheValid(cacheKey)) {
  //     _orders = List<Map<String, dynamic>>.from(_cache[cacheKey]['data']);
  //     developer.log('Orders loaded from cache', name: 'EnhancedHomeModel');
  //     notifyListeners();
  //     return;
  //   }
  //
  //   _setOrdersLoading(true);
  //   _clearError();
  //
  //   try {
  //     final response = await _executeWithRetry(() async {
  //       return await _supabaseClient
  //           .from('maintenance_requests')
  //           .select('*, vehicles(model_id, models(name), year), request_status(*, status_name), problem_description')
  //           .eq('user_id', userID)
  //           .order('created_at', ascending: false)
  //           .limit(5);
  //     });
  //
  //     _orders = List<Map<String, dynamic>>.from(response);
  //
  //     // حفظ في Cache
  //     _cache[cacheKey] = {
  //       'data': _orders,
  //       'timestamp': DateTime.now(),
  //     };
  //
  //     developer.log('Orders fetched successfully: ${_orders.length} items', name: 'EnhancedHomeModel');
  //     _retryCount = 0; // إعادة تعيين عداد المحاولات
  //
  //   } catch (e) {
  //     developer.log('Error fetching orders: $e', name: 'EnhancedHomeModel', level: 1000);
  //     _setError('حدث خطأ أثناء جلب الطلبات');
  //   } finally {
  //     _setOrdersLoading(false);
  //   }
  // }

  Future<void> fetchOrders(int userID, {bool forceRefresh = false, bool silent = false}) async {
    if (userID <= 0) {
      _setError('معرف المستخدم غير صالح');
      return;
    }

    final cacheKey = 'orders_$userID';

    // التحقق من وجود بيانات في الكاش وصلاحيتها
    if (!forceRefresh && _isCacheValid(cacheKey)) {
      _orders = List<Map<String, dynamic>>.from(_cache[cacheKey]['data']);
      developer.log('Orders loaded from cache', name: 'EnhancedHomeModel');
      notifyListeners(); // تحديث الواجهة حتى لو silent لأن البيانات تغيرت
      return;
    }

    if (!silent) _setOrdersLoading(true);
    _clearError();

    try {
      final response = await _executeWithRetry(() async {
        return await _supabaseClient
            .from('maintenance_requests')
            .select('*, vehicles(model_id, models(name), year), request_status(*, status_name), problem_description')
            .eq('user_id', userID)
            .order('created_at', ascending: false)
            .limit(5);
      });

      _orders = List<Map<String, dynamic>>.from(response);

      // تحديث الكاش
      _cache[cacheKey] = {
        'data': _orders,
        'timestamp': DateTime.now(),
      };

      developer.log('Orders fetched successfully (${_orders.length} items)${silent ? ' [Silent Update]' : ''}', name: 'EnhancedHomeModel');
      _retryCount = 0;

      notifyListeners(); // تحديث الواجهة بعد جلب البيانات

    } catch (e) {
      developer.log('Error fetching orders: $e', name: 'EnhancedHomeModel', level: 1000);
      _setError('حدث خطأ أثناء جلب الطلبات');
    } finally {
      if (!silent) _setOrdersLoading(false);
    }
  }

  /// جلب المركبات مع Cache
  // Future<void> fetchVehicles(int userID, {bool forceRefresh = false}) async {
  //   if (userID <= 0) {
  //     _setError('معرف المستخدم غير صالح');
  //     return;
  //   }
  //
  //   final cacheKey = 'vehicles_$userID';
  //
  //   // التحقق من Cache
  //   if (!forceRefresh && _isCacheValid(cacheKey)) {
  //     _vehicles = List<Map<String, dynamic>>.from(_cache[cacheKey]['data']);
  //     developer.log('Vehicles loaded from cache', name: 'EnhancedHomeModel');
  //     notifyListeners();
  //     return;
  //   }
  //
  //   _setVehiclesLoading(true);
  //   _clearError();
  //
  //   try {
  //     final response = await _executeWithRetry(() async {
  //       return await _supabaseClient
  //           .from('vehicles')
  //           .select('*, manufacturers(name), models(name)')
  //           .eq('user_id', userID)
  //           .order('created_at', ascending: false)
  //           .limit(5);
  //     });
  //
  //     _vehicles = List<Map<String, dynamic>>.from(response);
  //
  //     // حفظ في Cache
  //     _cache[cacheKey] = {
  //       'data': _vehicles,
  //       'timestamp': DateTime.now(),
  //     };
  //
  //     developer.log('Vehicles fetched successfully: ${_vehicles.length} items', name: 'EnhancedHomeModel');
  //     _retryCount = 0;
  //
  //   } catch (e) {
  //     developer.log('Error fetching vehicles: $e', name: 'EnhancedHomeModel', level: 1000);
  //     _setError('حدث خطأ أثناء جلب المركبات');
  //   } finally {
  //     _setVehiclesLoading(false);
  //   }
  // }

  Future<void> fetchVehicles(int userID, {bool forceRefresh = false, bool silent = false}) async {
    if (userID <= 0) {
      _setError('معرف المستخدم غير صالح');
      return;
    }

    final cacheKey = 'vehicles_$userID';

    // التحقق من وجود بيانات في الكاش وصلاحيتها
    if (!forceRefresh && _isCacheValid(cacheKey)) {
      _vehicles = List<Map<String, dynamic>>.from(_cache[cacheKey]['data']);
      developer.log('Vehicles loaded from cache', name: 'EnhancedHomeModel');
      notifyListeners(); // تحديث الواجهة حتى لو silent لأن البيانات تغيرت
      return;
    }

    if (!silent) _setVehiclesLoading(true);
    _clearError();

    try {
      final response = await _executeWithRetry(() async {
        return await _supabaseClient
            .from('vehicles')
            .select('*, manufacturers(name), models(name)')
            .eq('user_id', userID)
            .order('created_at', ascending: false)
            .limit(5);
      });

      _vehicles = List<Map<String, dynamic>>.from(response);

      // تحديث الكاش
      _cache[cacheKey] = {
        'data': _vehicles,
        'timestamp': DateTime.now(),
      };

      developer.log('Vehicles fetched successfully (${_vehicles.length} items)${silent ? ' [Silent Update]' : ''}', name: 'EnhancedHomeModel');
      _retryCount = 0;

      notifyListeners(); // تحديث الواجهة بعد جلب البيانات

    } catch (e) {
      developer.log('Error fetching vehicles: $e', name: 'EnhancedHomeModel', level: 1000);
      _setError('حدث خطأ أثناء جلب المركبات');
    } finally {
      if (!silent) _setVehiclesLoading(false);
    }
  }
  /// إنشاء طلب صيانة جديد مع Optimistic Update
  Future<Map<String, dynamic>?> createMaintenanceRequest(Map<String, dynamic> requestData) async {
    _setCreatingOrder(true);
    _clearError();

    // Optimistic Update - إضافة الطلب محلياً أولاً
    final tempOrder = {
      'id': DateTime.now().millisecondsSinceEpoch, // ID مؤقت
      'created_at': DateTime.now().toIso8601String(),
      'problem_description': requestData['problem_description'],
      'vehicles': requestData['vehicle_data'],
      'request_status': {'status_name': 'قيد المراجعة'},
      '_isOptimistic': true, // علامة للتحديث المؤقت
    };

    _orders.insert(0, tempOrder);
    notifyListeners();

    try {
      final response = await _executeWithRetry(() async {
        return await _supabaseClient
            .from('maintenance_requests')
            .insert(requestData)
            .select('*, vehicles(model_id, models(name), year), request_status(*, status_name), problem_description');
      });

      if (response.isNotEmpty) {
        final newRequest = response.first as Map<String, dynamic>;

        // استبدال التحديث المؤقت بالبيانات الحقيقية
        final tempIndex = _orders.indexWhere((order) => order['_isOptimistic'] == true);
        if (tempIndex != -1) {
          _orders[tempIndex] = newRequest;
        }

        _invalidateCache('orders');
        notifyListeners();

        developer.log('Maintenance request created successfully', name: 'EnhancedHomeModel');
        return newRequest;
      }
    } catch (e) {
      // إزالة التحديث المؤقت في حالة الفشل
      _orders.removeWhere((order) => order['_isOptimistic'] == true);
      notifyListeners();

      developer.log('Error creating maintenance request: $e', name: 'EnhancedHomeModel', level: 1000);
      _setError('حدث خطأ أثناء إنشاء الطلب');
      rethrow;
    } finally {
      _setCreatingOrder(false);
    }

    return null;
  }

  /// إضافة مركبة جديدة مع Optimistic Update
  Future<Map<String, dynamic>?> addVehicle(Map<String, dynamic> vehicleData) async {
    _setAddingVehicle(true);
    _clearError();

    // Optimistic Update
    final tempVehicle = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'created_at': DateTime.now().toIso8601String(),
      'plate_number': vehicleData['plate_number'],
      'year': vehicleData['year'],
      'manufacturers': {'name': vehicleData['manufacturer_name']},
      'models': {'name': vehicleData['model_name']},
      '_isOptimistic': true,
    };

    _vehicles.insert(0, tempVehicle);
    notifyListeners();

    try {
      final response = await _executeWithRetry(() async {
        return await _supabaseClient
            .from('vehicles')
            .insert(vehicleData)
            .select('*, manufacturers(name), models(name)');
      });

      if (response.isNotEmpty) {
        final newVehicle = response.first as Map<String, dynamic>;

        // استبدال التحديث المؤقت
        final tempIndex = _vehicles.indexWhere((vehicle) => vehicle['_isOptimistic'] == true);
        if (tempIndex != -1) {
          _vehicles[tempIndex] = newVehicle;
        }

        _invalidateCache('vehicles');
        notifyListeners();

        developer.log('Vehicle added successfully', name: 'EnhancedHomeModel');
        return newVehicle;
      }
    } catch (e) {
      // إزالة التحديث المؤقت
      _vehicles.removeWhere((vehicle) => vehicle['_isOptimistic'] == true);
      notifyListeners();

      developer.log('Error adding vehicle: $e', name: 'EnhancedHomeModel', level: 1000);
      _setError('حدث خطأ أثناء إضافة المركبة');
      rethrow;
    } finally {
      _setAddingVehicle(false);
    }

    return null;
  }

  /// تحديث حالة طلب الصيانة مع Optimistic Update
  Future<void> updateMaintenanceRequestStatus(int requestId, int statusId, String statusName) async {
    _setUpdatingOrder(true);
    _clearError();

    // Optimistic Update
    final orderIndex = _orders.indexWhere((order) => order['id'] == requestId);
    Map<String, dynamic>? originalOrder;

    if (orderIndex != -1) {
      originalOrder = Map<String, dynamic>.from(_orders[orderIndex]);
      _orders[orderIndex]['request_status']['status_name'] = statusName;
      _orders[orderIndex]['_isOptimisticUpdate'] = true;
      notifyListeners();
    }

    try {
      final response = await _executeWithRetry(() async {
        return await _supabaseClient
            .from('maintenance_requests')
            .update({'status_id': statusId, 'updated_at': DateTime.now().toIso8601String()})
            .eq('id', requestId)
            .select('*, vehicles(model_id, models(name), year), request_status(*, status_name), problem_description');
      });

      if (response.isNotEmpty && orderIndex != -1) {
        _orders[orderIndex] = response.first as Map<String, dynamic>;
        _invalidateCache('orders');
        notifyListeners();

        developer.log('Order status updated successfully', name: 'EnhancedHomeModel');
      }
    } catch (e) {
      // استرجاع الحالة الأصلية
      if (originalOrder != null && orderIndex != -1) {
        _orders[orderIndex] = originalOrder;
        notifyListeners();
      }

      developer.log('Error updating order status: $e', name: 'EnhancedHomeModel', level: 1000);
      _setError('حدث خطأ أثناء تحديث حالة الطلب');
      rethrow;
    } finally {
      _setUpdatingOrder(false);
    }
  }

  /// تنفيذ العملية مع آلية إعادة المحاولة
  Future<T> _executeWithRetry<T>(Future<T> Function() operation) async {
    while (_retryCount < _maxRetries) {
      try {
        return await operation();
      } catch (e) {
        _retryCount++;
        if (_retryCount >= _maxRetries) {
          rethrow;
        }

        // انتظار متزايد قبل إعادة المحاولة
        final delay = Duration(seconds: _retryCount * 2);
        developer.log('Retrying operation in ${delay.inSeconds} seconds (attempt $_retryCount)',
            name: 'EnhancedHomeModel');
        await Future.delayed(delay);
      }
    }
    throw Exception('Max retries exceeded');
  }

  /// التحقق من صحة Cache
  bool _isCacheValid(String key) {
    if (!_cache.containsKey(key)) return false;

    final cacheData = _cache[key];
    final timestamp = cacheData['timestamp'] as DateTime;
    return DateTime.now().difference(timestamp) < _cacheExpiry;
  }

  /// إبطال Cache
  void _invalidateCache(String key) {
    _cache.remove(key);
  }

  /// مسح Cache بالكامل
  void clearCache() {
    _cache.clear();
    developer.log('Cache cleared', name: 'EnhancedHomeModel');
  }

  /// تحديث البيانات (Pull-to-Refresh)
  Future<void> refreshData(int userID) async {
    clearCache();
    await Future.wait([
      fetchOrders(userID, forceRefresh: true),
      fetchVehicles(userID, forceRefresh: true),
    ]);
  }

  // دوال مساعدة لإدارة الحالة
  void _setOrdersLoading(bool loading) {
    if (_isOrdersLoading != loading) {
      _isOrdersLoading = loading;
      notifyListeners();
    }
  }

  void _setVehiclesLoading(bool loading) {
    if (_isVehiclesLoading != loading) {
      _isVehiclesLoading = loading;
      notifyListeners();
    }
  }

  void _setCreatingOrder(bool creating) {
    if (_isCreatingOrder != creating) {
      _isCreatingOrder = creating;
      notifyListeners();
    }
  }

  void _setAddingVehicle(bool adding) {
    if (_isAddingVehicle != adding) {
      _isAddingVehicle = adding;
      notifyListeners();
    }
  }

  void _setUpdatingOrder(bool updating) {
    if (_isUpdatingOrder != updating) {
      _isUpdatingOrder = updating;
      notifyListeners();
    }
  }

  void _setUpdatingVehicle(bool updating) {
    if (_isUpdatingVehicle != updating) {
      _isUpdatingVehicle = updating;
      notifyListeners();
    }
  }

  void _setError(String message) {
    _hasError = true;
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    if (_hasError) {
      _hasError = false;
      _errorMessage = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // إلغاء Real-time subscriptions
    _ordersChannel?.unsubscribe();
    _vehiclesChannel?.unsubscribe();

    // إلغاء Timer
    _retryTimer?.cancel();

    // مسح Cache
    _cache.clear();

    super.dispose();
  }

  // دوال إضافية للحصول على البيانات
  Map<String, dynamic>? getOrderById(int orderId) {
    try {
      return _orders.firstWhere((order) => order['id'] == orderId);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic>? getVehicleById(int vehicleId) {
    try {
      return _vehicles.firstWhere((vehicle) => vehicle['id'] == vehicleId);
    } catch (e) {
      return null;
    }
  }

  List<Map<String, dynamic>> getOrdersByStatus(String statusName) {
    return _orders.where((order) {
      final status = order['request_status'];
      if (status != null && status is Map<String, dynamic>) {
        return status['status_name'] == statusName;
      }
      return false;
    }).toList();
  }

  Map<String, int> getOrdersStatistics() {
    final stats = <String, int>{};
    for (final order in _orders) {
      final status = order['request_status'];
      if (status != null && status is Map<String, dynamic>) {
        final statusName = status['status_name'] as String? ?? 'غير محدد';
        stats[statusName] = (stats[statusName] ?? 0) + 1;
      }
    }
    return stats;
  }

  Map<String, dynamic>? get latestOrder => _orders.isNotEmpty ? _orders.first : null;
  Map<String, dynamic>? get latestVehicle => _vehicles.isNotEmpty ? _vehicles.first : null;
}

