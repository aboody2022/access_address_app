// vehicle_card.dart
import 'package:flutter/material.dart';
import '../../data/models/vehicle_model.dart';

class VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;

  const VehicleCard({Key? key, required this.vehicle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${vehicle.make} ${vehicle.model} ${vehicle.year}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.directions_car,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('رقم اللوحة: ${vehicle.plateNumber}'),
            if (vehicle.color != null)
              Text('اللون: ${vehicle.color}'),
            if (vehicle.mileage != null)
              Text('عداد المسافات: ${vehicle.mileage} كم'),
            if (vehicle.insuranceExpiryDate != null)
              Text(
                'تاريخ انتهاء التأمين: ${_formatDate(vehicle.insuranceExpiryDate!)}',
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }
}