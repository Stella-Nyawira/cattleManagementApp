import 'package:cattle_managementapp/pages/Transactions_page.dart';
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
          NavigationDestination(icon: Icon(Icons.notifications), label: "Notifications"),
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
