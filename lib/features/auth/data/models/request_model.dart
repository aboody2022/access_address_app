// request_model.dart
class MaintenanceRequestModel {
  final int requestId;
  final int userId;
  final int vehicleId;
  final String requestType;
  final String serviceProvider;
  final String problemDescription;
  final double? locationLatitude;
  final double? locationLongitude;
  final String? locationAddress;
  final int statusId;
  final String? additionalNotes;
  final DateTime createdAt;
  final String? adminNotes;
  final String? cancellationReason;
  final DateTime? completionDate;
  final int? assignedTo;

  MaintenanceRequestModel({
    required this.requestId,
    required this.userId,
    required this.vehicleId,
    required this.requestType,
    required this.serviceProvider,
    required this.problemDescription,
    this.locationLatitude,
    this.locationLongitude,
    this.locationAddress,
    required this.statusId,
    this.additionalNotes,
    required this.createdAt,
    this.adminNotes,
    this.cancellationReason,
    this.completionDate,
    this.assignedTo,
  });

  factory MaintenanceRequestModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceRequestModel(
      requestId: json['request_id'],
      userId: json['user_id'],
      vehicleId: json['vehicle_id'],
      requestType: json['request_type'],
      serviceProvider: json['service_provider'],
      problemDescription: json['problem_description'],
      locationLatitude: json['location_latitude'],
      locationLongitude: json['location_longitude'],
      locationAddress: json['location_address'],
      statusId: json['status_id'],
      additionalNotes: json['additional_notes'],
      createdAt: DateTime.parse(json['created_at']),
      adminNotes: json['admin_notes'],
      cancellationReason: json['cancellation_reason'],
      completionDate: json['completion_date'] != null
          ? DateTime.parse(json['completion_date'])
          : null,
      assignedTo: json['assigned_to'],
    );
  }
}

// notification_model.dart
class NotificationModel {
  final int notificationId;
  final int userId;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final String? notificationType;
  final int? relatedRequestId;

  NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.notificationType,
    this.relatedRequestId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notification_id'],
      userId: json['user_id'],
      title: json['title'],
      message: json['message'],
      isRead: json['is_read'] == 1,
      createdAt: DateTime.parse(json['created_at']),
      notificationType: json['notification_type'],
      relatedRequestId: json['related_request_id'],
    );
  }
}