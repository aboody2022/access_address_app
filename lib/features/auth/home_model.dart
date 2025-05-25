import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeModel extends ChangeNotifier {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _vehicles = [];
  bool _isOrdersLoading = true;
  bool _isVehiclesLoading = true;

  List<Map<String, dynamic>> get orders => _orders;
  List<Map<String, dynamic>> get vehicles => _vehicles;
  bool get isOrdersLoading => _isOrdersLoading;
  bool get isVehiclesLoading => _isVehiclesLoading;

  Future<void> fetchOrders(int userID) async {
    _isOrdersLoading = true;
    notifyListeners();

    try {
      final response = await _supabaseClient
          .from('maintenance_requests')
          .select('*, vehicles(model_id, models(name), year), request_status(*, status_name), problem_description')
          .eq('user_id', userID)
          .order('created_at', ascending: false)
          .limit(3);

      if (response.isNotEmpty) {
        _orders = List<Map<String, dynamic>>.from(response);
      } else {
        _orders.clear(); // تأكد من مسح البيانات إذا لم يكن هناك بيانات جديدة
      }
    } catch (error) {
    } finally {
      _isOrdersLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchVehicles(int userID) async {
    _isVehiclesLoading = true;
    notifyListeners();

    try {
      final vehicleResponse = await _supabaseClient
          .from('vehicles')
          .select('*, manufacturers(name), models(name)')
          .eq('user_id', userID)
          .order('created_at', ascending: false)
          .limit(3);

      if (vehicleResponse.isNotEmpty) {
        _vehicles = List<Map<String, dynamic>>.from(vehicleResponse);
      } else {
        _vehicles.clear(); // تأكد من مسح البيانات إذا لم يكن هناك بيانات جديدة
      }
    } catch (error) {
    } finally {
      _isVehiclesLoading = false;
      notifyListeners();
    }
  }
}