// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:access_address_app/features/vehicle/domain/entities/vehicle.dart';
// import 'package:access_address_app/features/vehicle/domain/usecases/get_vehicles_usecase.dart';
//
// // Events
// abstract class VehicleEvent extends Equatable {
//   @override
//   List<Object?> get props => [];
// }
//
// class GetVehiclesEvent extends VehicleEvent {}
//
// // States
// abstract class VehicleState extends Equatable {
//   @override
//   List<Object?> get props => [];
// }
//
// class VehicleInitial extends VehicleState {}
//
// class VehicleLoading extends VehicleState {}
//
// class VehicleLoaded extends VehicleState {
//   final List<Vehicle> vehicles;
//
//   VehicleLoaded({required this.vehicles});
//
//   @override
//   List<Object?> get props => [vehicles];
// }
//
// class VehicleError extends VehicleState {
//   final String message;
//
//   VehicleError({required this.message});
//
//   @override
//   List<Object?> get props => [message];
// }
//
// // Bloc
// class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
//   final GetVehiclesUseCase getVehiclesUseCase;
//
//   VehicleBloc({required this.getVehiclesUseCase}) : super(VehicleInitial()) {
//     on<GetVehiclesEvent>((event, emit) async {
//       emit(VehicleLoading());
//       final result = await getVehiclesUseCase();
//       result.fold(
//         (failure) => emit(VehicleError(message: failure.message)),
//         (vehicles) => emit(VehicleLoaded(vehicles: vehicles)),
//       );
//     });
//   }
// }