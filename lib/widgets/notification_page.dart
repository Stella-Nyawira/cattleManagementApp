import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notification_controller.dart';
import 'package:intl/intl.dart';

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
        //backgroundColor: Colors.greenAccent,
        elevation: 4,
        actions: [
          Obx(() {
            return controller.notificationsList.isNotEmpty
                ? IconButton(
                  tooltip: "Mark all as read",
                  icon: Icon(Icons.check),
                  onPressed: () async {
                    controller.markAllAsRead();
                    Get.snackbar(
                      "Notifications",
                      "All notifications marked as read.",
                      backgroundColor: Colors.green.shade100,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                )
                : SizedBox.shrink();
          }),
        ],
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
        return RefreshIndicator(
          onRefresh: () async {
            controller.notificationsAlert();
          },
          child: ListView.separated(
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
                  dense: true, // makes the ListTile more compact vertically
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  leading: CircleAvatar(
                    radius: 20, // smaller avatar radius
                    backgroundColor: notification.isRead ? Colors.grey.shade300 : Colors.orange.shade100,
                    child: Icon(
                      notification.isRead ? Icons.check : Icons.notifications,
                      color: notification.isRead ? Colors.grey : Colors.orange,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    notification.message,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: notification.isRead ? Colors.grey : Colors.black,
                      decoration: notification.isRead ? TextDecoration.lineThrough : null,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // shrink to fit content vertically
                    children: [
                      Text(
                        formatDateTime(notification.scheduledTime),
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                      if (!notification.isRead)
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size(50, 20),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            alignment: Alignment.centerLeft,
                          ),
                          onPressed: () => controller.markAsRead(notification.id),
                          child: Text("Mark as Read", style: TextStyle(fontSize: 12)),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
      backgroundColor: Colors.grey[100],
    );
  }
}
