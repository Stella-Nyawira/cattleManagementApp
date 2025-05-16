import 'package:cattle_managementapp/auth/sign_in_page.dart';
import 'package:cattle_managementapp/controllers/animalRecords_controller.dart';
import 'package:cattle_managementapp/controllers/auth_controller.dart';
import 'package:cattle_managementapp/pages/vaccinationRecords_page.dart';
import 'package:cattle_managementapp/utils/dashBoard_cards.dart';
import 'package:cattle_managementapp/widgets/add_animals.dart';
import 'package:cattle_managementapp/widgets/view_animals.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final AnimalRecordsController animalRecordsController = Get.put(AnimalRecordsController());

    return Scaffold(
      appBar: AppBar(
        title: Text("Cattle Manager", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
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
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => buildSummaryItems("Livestock", "${animalRecordsController.totalAnimals.value} Cows")),
                      buildSummaryItems("Next Vaccine", "3 days"),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildSummaryItems("This month profit", "Ksh 15,230"),
                      buildSummaryItems("Today's Milk", "13.6L"),
                    ],
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
                  DashboardCard(title: "Milk Records", icon: Icons.local_drink),
                  DashboardCard(title: "Profits", icon: Icons.attach_money),
                  DashboardCard(
                    title: "Vaccines",
                    icon: Icons.health_and_safety,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VaccinationRecordsPage())),
                  ),
                  DashboardCard(title: "Upcoming events", icon: Icons.upcoming),
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
        SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
