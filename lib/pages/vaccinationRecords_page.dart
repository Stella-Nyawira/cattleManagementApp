import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/animalRecords_controller.dart';

class VaccinationRecordsPage extends StatelessWidget {
  final AnimalRecordsController controller = Get.find<AnimalRecordsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Vaccination Records")),
      body: Obx(() {
        if (controller.vaccinationRecords.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medical_services_outlined, size: 60, color: Colors.grey),
                SizedBox(height: 10),
                Text("No vaccination records found", style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          );
        }

        // Group records by animal name
        final grouped = <String, List<Map<String, dynamic>>>{};
        for (var record in controller.vaccinationRecords) {
          final name = record['animalName'] ?? 'Unknown Animal';
          grouped[name] = [...(grouped[name] ?? []), record];
        }

        return ListView(
          children:
              grouped.entries.map((entry) {
                final animalName = entry.key;
                final records = entry.value;

                return ExpansionTile(
                  title: Text(animalName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  leading: const Icon(Icons.pets, color: Colors.brown),
                  children:
                      records.map((record) {
                        return ListTile(
                          leading: const Icon(Icons.vaccines, color: Colors.green),
                          title: Text(record['vaccineName'] ?? 'Unknown Vaccine'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Vet: ${record['vetName'] ?? 'N/A'}"),
                              Text("Date: ${record['dateAdministered'] ?? 'N/A'}"),
                              Text("Next Due: ${record['nextDueDate'] ?? 'Not set'}"),
                            ],
                          ),
                          isThreeLine: true,
                        );
                      }).toList(),
                );
              }).toList(),
        );
      }),
    );
  }
}
