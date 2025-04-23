// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:access_address/features/vehicle/presentation/bloc/vehicle_bloc.dart';
// import 'package:access_address/injection.dart';
// import '../widgets/vehicle_card.dart';
//
// class VehicleListingPage extends StatelessWidget {
//   const VehicleListingPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => sl<VehicleBloc>()..add(GetVehiclesEvent()),
//       child: Scaffold(
//         backgroundColor: Colors.grey[100],
//         appBar: AppBar(
//           title: Row(
//             children: [
//               Image.asset(
//                 'assets/images/logo.png',
//                 height: 40,
//               ),
//               const SizedBox(width: 8),
//               const Text(
//                 'مركباتي',
//                 style: TextStyle(
//                   color: Color(0xFF0D47A1),
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           backgroundColor: Colors.white,
//           elevation: 0,
//         ),
//         body: BlocBuilder<VehicleBloc, VehicleState>(
//           builder: (context, state) {
//             if (state is VehicleLoading) {
//               return const Center(child: CircularProgressIndicator());
//             } else if (state is VehicleError) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       state.message,
//                       style: const TextStyle(color: Colors.red),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: () {
//                         context.read<VehicleBloc>().add(GetVehiclesEvent());
//                       },
//                       child: const Text('إعادة المحاولة'),
//                     ),
//                   ],
//                 ),
//               );
//             } else if (state is VehicleLoaded) {
//               return RefreshIndicator(
//                 onRefresh: () async {
//                   context.read<VehicleBloc>().add(GetVehiclesEvent());
//                 },
//                 child: ListView.separated(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: state.vehicles.length,
//                   separatorBuilder: (context, index) => const SizedBox(height: 16),
//                   itemBuilder: (context, index) {
//                     final vehicle = state.vehicles[index];
//                     return VehicleCard(
//                       name: vehicle.name,
//                       year: vehicle.year,
//                       type: vehicle.type,
//                       imageUrl: vehicle.imageUrl,
//                     );
//                   },
//                 ),
//               );
//             }
//             return const SizedBox();
//           },
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: () {
//             // TODO: Navigate to add vehicle page
//           },
//           backgroundColor: const Color(0xFF2196F3),
//           child: const Icon(Icons.add),
//         ),
//       ),
//     );
//   }
// }