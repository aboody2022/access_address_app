// import 'package:dio/dio.dart';
// import 'package:access_address_app/features/vehicle/data/models/vehicle_model.dart';
//
// abstract class VehicleRemoteDataSource {
//   Future<List<VehicleModel>> getVehicles();
//   Future<VehicleModel> getVehicleById(String id);
//   Future<void> addVehicle(VehicleModel vehicle);
//   Future<void> updateVehicle(VehicleModel vehicle);
//   Future<void> deleteVehicle(String id);
// }
//
// class VehicleRemoteDataSourceImpl implements VehicleRemoteDataSource {
//   final Dio client;
//
//   VehicleRemoteDataSourceImpl({required this.client});
//
//   @override
//   Future<List<VehicleModel>> getVehicles() async {
//     try {
//       final response = await client.get('YOUR_API_URL/vehicles');
//       return (response.data as List)
//           .map((json) => VehicleModel.fromJson(json))
//           .toList();
//     } catch (e) {
//       throw Exception('Failed to get vehicles');
//     }
//   }
//
//   @override
//   Future<VehicleModel> getVehicleById(String id) async {
//     try {
//       final response = await client.get('YOUR_API_URL/vehicles/$id');
//       return VehicleModel.fromJson(response.data);
//     } catch (e) {
//       throw Exception('Failed to get vehicle');
//     }
//   }
//
//   @override
//   Future<void> addVehicle(VehicleModel vehicle) async {
//     try {
//       await client.post(
//         'YOUR_API_URL/vehicles',
//         data: vehicle.toJson(),
//       );
//     } catch (e) {
//       throw Exception('Failed to add vehicle');
//     }
//   }
//
//   @override
//   Future<void> updateVehicle(VehicleModel vehicle) async {
//     try {
//       await client.put(
//         'YOUR_API_URL/vehicles/${vehicle.id}',
//         data: vehicle.toJson(),
//       );
//     } catch (e) {
//       throw Exception('Failed to update vehicle');
//     }
//   }
//
//   @override
//   Future<void> deleteVehicle(String id) async {
//     try {
//       await client.delete('YOUR_API_URL/vehicles/$id');
//     } catch (e) {
//       throw Exception('Failed to delete vehicle');
//     }
//   }
// }