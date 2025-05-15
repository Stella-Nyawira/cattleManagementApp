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
      appBar: AppBar(title: const Text('Calving Records')),
      body: Obx(() {
        final records = controller.calvingRecords;
        if (records.isEmpty) {
          return const Center(child: Text('No records found.'));
        }
        return ListView.builder(
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            return ListTile(
              title: Text('Calving Date: ${record.birthDate}'),
              subtitle: Text('Calf Gender: ${record.calfGender}\nName: ${record.calfName}'),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Delete Record'),
                          content: const Text('Are you sure you want to delete this calving record?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
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
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => CalvingRecordForm(animalId: animalId));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
