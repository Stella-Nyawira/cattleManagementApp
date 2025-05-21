import 'package:cattle_managementapp/controllers/animalRecords_controller.dart';
import 'package:cattle_managementapp/widgets/records/health_records_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HealthRecordsPage extends StatefulWidget {
  final String animalId;
  final String animalName;

  const HealthRecordsPage({super.key, required this.animalId, required this.animalName});

  @override
  State<HealthRecordsPage> createState() => _HealthRecordsPageState();
}

class _HealthRecordsPageState extends State<HealthRecordsPage> {
  final AnimalRecordsController controller = Get.put(AnimalRecordsController());

  @override
  void initState() {
    super.initState();
    controller.fetchHealthRecords(widget.animalId);
  }

  Future<void> _openAddRecordForm() async {
    await Get.to(() => HealthRecordsForm(animalId: widget.animalId, animalName: widget.animalName));
  }

  void _showDeleteDialog(String recordId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Record'),
            content: Text('Are you sure you want to delete this health record?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close dialog
                  await controller.deleteHealthRecord(animalId: widget.animalId, recordId: recordId);
                  controller.fetchHealthRecords(widget.animalId); // Refresh list
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Health Records for ${widget.animalName}')),
      body: Obx(() {
        if (controller.healthRecords.isEmpty) {
          return Center(child: Text('No health records found'));
        }
        return ListView.builder(
          itemCount: controller.healthRecords.length,
          itemBuilder: (context, index) {
            final record = controller.healthRecords[index];
            return Card(
              child: ListTile(
                title: Text(record['condition'] ?? 'Unknown condition'),
                subtitle: Text(record['notes'] ?? ''),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteDialog(record['id']); // Ensure 'id' exists in the record
                  },
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(onPressed: _openAddRecordForm, child: Icon(Icons.add)),
    );
  }
}
