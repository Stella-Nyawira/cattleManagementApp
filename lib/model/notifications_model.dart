class NotificationModel {
  final String id;
  final String message;
  final DateTime scheduledTime;

  NotificationModel({required this.id, required this.message, required this.scheduledTime});

  Map<String, dynamic> toMap() {
    return {'id': id, 'message': message, 'scheduledTime': scheduledTime.toIso8601String()};
  }
}
