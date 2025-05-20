import 'package:cattle_managementapp/controllers/animalRecords_controller.dart';
import 'package:cattle_managementapp/widgets/records/vaccination_records_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VaccinationRecordsPage extends StatefulWidget {
  final String animalId;
  final String animalName;

  const VaccinationRecordsPage({super.key, required this.animalId, required this.animalName});

  @override
  State<VaccinationRecordsPage> createState() => _VaccinationRecordsPageState();
}

class _VaccinationRecordsPageState extends State<VaccinationRecordsPage> {
  final AnimalRecordsController controller = Get.find<AnimalRecordsController>();

  @override
  void initState() {
    super.initState();
    controller.loadVaccinationRecords(widget.animalId); // 🔁 Loads correct records for this animal
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.animalName}'s Vaccination Records")),
      body: Obx(() {
        final records = controller.vaccinationRecords;

        if (records.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medical_services_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 20),
                  Text("No vaccination records found", style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            return _buildVaccinationCard(record);
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => VaccinationRecordsForm(animalId: widget.animalId, animalName: widget.animalName));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildVaccinationCard(Map<String, dynamic> record) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.vaccines, color: Colors.green),
        title: Text(record['vaccineName'] ?? 'Unknown Vaccine', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Vet: ${record['vetName'] ?? 'N/A'}"),
              Text("Date: ${record['dateAdministered'] ?? 'N/A'}"),
              Text("Next Due: ${record['nextDueDate'] ?? 'Not set'}"),
            ],
          ),
        ),
        isThreeLine: true,
      ),
    );
  }
}
