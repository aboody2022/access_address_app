// import 'package:dartz/dartz.dart';
// import 'package:access_address_app/core/error/failures.dart';
// import 'package:access_address_app/features/vehicle/data/datasources/vehicle_remote_data_source.dart';
// import 'package:access_address_app/features/vehicle/domain/entities/vehicle.dart';
// import 'package:access_address_app/features/vehicle/domain/repositories/vehicle_repository.dart';
//
// import '../models/vehicle_model.dart';
//
// class VehicleRepositoryImpl implements VehicleRepository {
//   final VehicleRemoteDataSource remoteDataSource;
//
//   VehicleRepositoryImpl({required this.remoteDataSource});
//
//   @override
//   Future<Either<Failure, List<Vehicle>>> getVehicles() async {
//     try {
//       final vehicles = await remoteDataSource.getVehicles();
//       return Right(vehicles);
//     } catch (e) {
//       return const Left(ServerFailure('Failed to get vehicles'));
//     }
//   }
//
//   @override
//   Future<Either<Failure, Vehicle>> getVehicleById(String id) async {
//     try {
//       final vehicle = await remoteDataSource.getVehicleById(id);
//       return Right(vehicle);
//     } catch (e) {
//       return const Left(ServerFailure('Failed to get vehicle'));
//     }
//   }
//
//   @override
//   Future<Either<Failure, void>> addVehicle(Vehicle vehicle) async {
//     try {
//       await remoteDataSource.addVehicle(vehicle as VehicleModel);
//       return const Right(null);
//     } catch (e) {
//       return const Left(ServerFailure('Failed to add vehicle'));
//     }
//   }
//
//   @override
//   Future<Either<Failure, void>> updateVehicle(Vehicle vehicle) async {
//     try {
//       await remoteDataSource.updateVehicle(vehicle as VehicleModel);
//       return const Right(null);
//     } catch (e) {
//       return const Left(ServerFailure('Failed to update vehicle'));
//     }
//   }
//
//   @override
//   Future<Either<Failure, void>> deleteVehicle(String id) async {
//     try {
//       await remoteDataSource.deleteVehicle(id);
//       return const Right(null);
//     } catch (e) {
//       return const Left(ServerFailure('Failed to delete vehicle'));
//     }
//   }
// }