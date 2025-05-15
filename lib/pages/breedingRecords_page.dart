import 'package:cattle_managementapp/controllers/animalRecords_controller.dart';
import 'package:cattle_managementapp/widgets/records/breeding_records_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BreedingRecordsPage extends StatelessWidget {
  final String animalId;
  final String animalName;
  final AnimalRecordsController controller = Get.put(AnimalRecordsController());

  BreedingRecordsPage({super.key, required this.animalId, required this.animalName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Breeding Records')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: controller.fetchBreedingRecords(animalId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading breeding records'));
          }

          final records = snapshot.data ?? [];

          if (records.isEmpty) {
            return const Center(child: Text('No breeding records found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(record['breedingMethod'] ?? 'Unknown Method'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (record['bullName'] != null) Text('Bull: ${record['bullName']} (${record['bullBreed']})'),
                      if (record['inseminationDate'] != null) Text('Date: ${record['inseminationDate']}'),
                      if (record['pregnancyStatus'] != null) Text('Status: ${record['pregnancyStatus']}'),
                      if (record['notes'] != null) Text('Notes: ${record['notes']}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => BreedingRecordForm(animalId: animalId, animalName: 'Animal Name'));
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Breeding Record',
      ),
    );
  }
}
