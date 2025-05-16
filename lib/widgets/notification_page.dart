import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notification_controller.dart';

import 'package:intl/intl.dart'; // For date formatting
// Adjust import as needed

class NotificationsPage extends StatelessWidget {
  final NotificationsController controller = Get.find<NotificationsController>();

  String formatDateTime(DateTime dateTime) {
    return DateFormat('EEE, MMM d, yyyy – h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade600, Colors.deepOrange.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
      ),
      body: Obx(() {
        final notifications = controller.notificationsList;
        if (notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off, size: 60, color: Colors.grey),
                SizedBox(height: 10),
                Text("No notifications yet", style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          separatorBuilder: (context, index) => SizedBox(height: 12),
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: Offset(0, 4))],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.shade100,
                  child: Icon(Icons.notifications, color: Colors.orange),
                ),
                title: Text(notification.message, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  formatDateTime(notification.scheduledTime),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            );
          },
        );
      }),
      backgroundColor: Colors.grey[100],
    );
  }
}
