import 'package:cattle_managementapp/controllers/animalRecords_controller.dart';
import 'package:cattle_managementapp/widgets/calves/calving_records_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CalvingRecordsPage extends StatelessWidget {
  final String animalId;
  final controller = Get.find<AnimalRecordsController>();

  CalvingRecordsPage({Key? key, required this.animalId}) : super(key: key) {
    controller.fetchCalvingRecords(animalId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calving Records'), centerTitle: true, elevation: 2),
      body: Obx(() {
        final records = controller.calvingRecords;
        if (records.isEmpty) {
          return const Center(child: Text('No calving records yet.', style: TextStyle(fontSize: 16)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          record.calfName ?? 'Unnamed Calf',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Delete Record'),
                                    content: const Text('Are you sure you want to delete this calving record?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                            );

                            if (confirmed == true) {
                              await controller.deleteCalvingRecord(animalId: animalId, recordId: record.id ?? '');
                              Get.snackbar(
                                'Deleted',
                                'The calving record was deleted successfully.',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.cake, size: 18),
                        const SizedBox(width: 6),
                        Text('Birth Date: ${record.birthDate ?? "N/A"}', style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.pets, size: 18),
                        const SizedBox(width: 6),
                        Text('Gender: ${record.calfGender ?? "N/A"}', style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.to(() => CalvingRecordForm(animalId: animalId));
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Record"),
      ),
    );
  }
}
