// vehicle_repository.dart
import '../../../../core/api/api_endpoints.dart';
import '../../data/models/vehicle_model.dart';

class VehicleRepository {
  final ApiService _apiService;

  VehicleRepository(this._apiService);

  Future<List<VehicleModel>> getUserVehicles() async {
    try {
      final response = await _apiService.get(ApiEndpoints.vehicles);

      if (response['status']) {
        return (response['data'] as List)
            .map((vehicle) => VehicleModel.fromJson(vehicle))
            .toList();
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      throw Exception('فشل في جلب المركبات: $e');
    }
  }

  Future<VehicleModel> addVehicle(Map<String, dynamic> vehicleData) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.addVehicle,
        vehicleData,
      );

      if (response['status']) {
        return VehicleModel.fromJson(response['data']);
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      throw Exception('فشل في إضافة المركبة: $e');
    }
  }
}