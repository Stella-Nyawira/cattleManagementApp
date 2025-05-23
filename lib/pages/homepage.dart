import 'package:cattle_managementapp/auth/sign_in_page.dart';
import 'package:cattle_managementapp/controllers/animalRecords_controller.dart';
import 'package:cattle_managementapp/controllers/auth_controller.dart';
import 'package:cattle_managementapp/controllers/transactions_controller.dart';
import 'package:cattle_managementapp/pages/milk_overview_page.dart';
import 'package:cattle_managementapp/pages/profits_overview_page.dart';
import 'package:cattle_managementapp/utils/dashBoard_cards.dart';
import 'package:cattle_managementapp/widgets/add_animals.dart';
import 'package:cattle_managementapp/widgets/allAnimalsInfo/all_animal_vaccines_page.dart';
import 'package:cattle_managementapp/widgets/events/upcoming_event_page.dart';
import 'package:cattle_managementapp/widgets/view_animals.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final AnimalRecordsController animalRecordsController = Get.put(AnimalRecordsController());
    final TransactionsController transactionsController = Get.put(TransactionsController());

    return Scaffold(
      appBar: AppBar(
        title: Text("Cattle Manager", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        // backgroundColor: Colors.green[700],
        actions: [
          Obx(() {
            if (authController.user.value != null) {
              return GestureDetector(
                onTap: () async {
                  await authController.signOut();
                  Get.offAll(() => SignInPage());
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(authController.user.value?.photoURL ?? ''),
                  child: authController.user.value?.photoURL == null ? Icon(Icons.account_circle, size: 30) : null,
                ),
              );
            } else {
              return Container();
            }
          }),
          SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => buildSummaryItems("Livestock", "${animalRecordsController.totalAnimals.value} Cows")),
                  Obx(
                    () => buildSummaryItems(
                      "This month profit",
                      "\$${transactionsController.currentMonthProfit.toStringAsFixed(0)}",
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  DashboardCard(
                    title: "View Animals",
                    icon: Icons.pets,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ViewAnimalsPage()));
                    },
                  ),
                  DashboardCard(
                    title: "Milk Records",
                    icon: Icons.local_drink,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MilkOverviewPage())),
                  ),
                  DashboardCard(
                    title: "Profits",
                    icon: Icons.attach_money,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfitsOverviewPage())),
                  ),
                  DashboardCard(
                    title: "Vaccines",
                    icon: Icons.health_and_safety,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AllAnimalVaccinesPage())),
                  ),
                  DashboardCard(
                    title: "Upcoming events",
                    icon: Icons.upcoming,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UpcomingEventsPage())),
                  ),
                  DashboardCard(
                    title: "Add Animals",
                    icon: Icons.add,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => AddAnimalPage()));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSummaryItems(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
