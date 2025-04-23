import 'package:equatable/equatable.dart';

class Vehicle extends Equatable {
  final String id;
  final String name;
  final String model;
  final String year;
  final String imageUrl;
  final String type;

  const Vehicle({
    required this.id,
    required this.name,
    required this.model,
    required this.year,
    required this.imageUrl,
    required this.type,
  });

  @override
  List<Object?> get props => [id, name, model, year, imageUrl, type];
}