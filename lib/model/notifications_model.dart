class NotificationModel {
  final String id;
  final String message;
  final DateTime scheduledTime;
  bool isRead; // Add this

  NotificationModel({required this.id, required this.message, required this.scheduledTime, this.isRead = false});
}
