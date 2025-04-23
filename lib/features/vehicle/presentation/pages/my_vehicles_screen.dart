// my_vehicles_screen.dart
import 'package:flutter/material.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../data/models/vehicle_model.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../widgets/vehicle_card.dart';

class MyVehiclesScreen extends StatefulWidget {
  @override
  _MyVehiclesScreenState createState() => _MyVehiclesScreenState();
}

class _MyVehiclesScreenState extends State<MyVehiclesScreen> {
  final _vehicleRepository = VehicleRepository(ApiService());
  bool _isLoading = true;
  List<VehicleModel> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    try {
      final vehicles = await _vehicleRepository.getUserVehicles();
      setState(() {
        _vehicles = vehicles;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مركباتي'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/add-vehicle'),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _vehicles.isEmpty
          ? Center(child: Text('لا توجد مركبات مضافة'))
          : ListView.builder(
        itemCount: _vehicles.length,
        itemBuilder: (context, index) {
          return VehicleCard(vehicle: _vehicles[index]);
        },
      ),
    );
  }
}