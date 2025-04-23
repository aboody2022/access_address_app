// vehicle_model.dart
class VehicleModel {
  final int vehicleId;
  final int userId;
  final String make;
  final String model;
  final int year;
  final String plateNumber;
  final String? color;
  final int? mileage;
  final DateTime? insuranceExpiryDate;
  final bool isActive;

  VehicleModel({
    required this.vehicleId,
    required this.userId,
    required this.make,
    required this.model,
    required this.year,
    required this.plateNumber,
    this.color,
    this.mileage,
    this.insuranceExpiryDate,
    required this.isActive,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      vehicleId: json['vehicle_id'],
      userId: json['user_id'],
      make: json['make'],
      model: json['model'],
      year: json['year'],
      plateNumber: json['plate_number'],
      color: json['color'],
      mileage: json['mileage'],
      insuranceExpiryDate: json['insurance_expiry_date'] != null
          ? DateTime.parse(json['insurance_expiry_date'])
          : null,
      isActive: json['is_active'] == 1,
    );
  }
}