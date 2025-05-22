/* import 'package:cattle_managementapp/pages/Transactions_page.dart';
import 'package:cattle_managementapp/pages/homepage.dart';
import 'package:cattle_managementapp/widgets/notification_page.dart';

import 'package:cattle_managementapp/widgets/view_animals.dart';

import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int currentPage = 0;
  List<Widget> pages = [Homepage(), ViewAnimalsPage(), NotificationsPage(), TransactionsPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(icon: Icon(Icons.home), label: "Summary"),
          NavigationDestination(icon: Icon(Icons.pets), label: "Animals"),

          //NavigationDestination(icon: Icon(Icons.notifications), label: "Notifications"),
          NavigationDestination(icon: Icon(Icons.description), label: "Transactions"),
        ],
        selectedIndex: currentPage,
        onDestinationSelected: (value) {
          setState(() {
            currentPage = value;
          });
        },
      ),
      body: pages[currentPage],
    );
  }
}
 */
import 'package:cattle_managementapp/controllers/notification_controller.dart';
import 'package:cattle_managementapp/pages/Transactions_page.dart';
import 'package:cattle_managementapp/pages/homepage.dart';
import 'package:cattle_managementapp/widgets/notification_page.dart';
import 'package:cattle_managementapp/widgets/view_animals.dart';

import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:get/get.dart';
// Use an alias to avoid ambiguity

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int get unreadNotifications => Get.find<NotificationsController>().notificationsList.length;

  int currentPage = 0;
  //int unreadNotifications = 5; // Example unread count

  List<Widget> pages = [Homepage(), ViewAnimalsPage(), NotificationsPage(), TransactionsPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(icon: Icon(Icons.home), label: "Summary"),
          NavigationDestination(icon: Icon(Icons.pets), label: "Animals"),

          Obx(
            () => NavigationDestination(
              icon: badges.Badge(
                showBadge: unreadNotifications > 0,
                badgeContent: Text(unreadNotifications.toString(), style: TextStyle(color: Colors.white, fontSize: 10)),
                badgeStyle: badges.BadgeStyle(badgeColor: Colors.red),
                child: Icon(Icons.notifications),
              ),
              label: "Notifications",
            ),
          ),

          NavigationDestination(icon: Icon(Icons.description), label: "Transactions"),
        ],
        selectedIndex: currentPage,
        onDestinationSelected: (value) {
          setState(() {
            currentPage = value;
          });
        },
      ),
      body: pages[currentPage],
    );
  }
}
