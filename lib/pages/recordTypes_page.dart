import 'package:cattle_managementapp/pages/milkProduction_page.dart';
import 'package:cattle_managementapp/widgets/records/breeding_records_form.dart';
import 'package:cattle_managementapp/widgets/records/feeding_records_form.dart';
import 'package:cattle_managementapp/widgets/records/vaccination_records_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cattle_managementapp/widgets/records/health_records_form.dart';

class RecordTypesPage extends StatelessWidget {
  final String animalId;
  final String animalName;

  const RecordTypesPage({super.key, required this.animalId, required this.animalName});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> recordTypes = [
      {
        'title': 'Edit animal Details',

        'icon': Icons.edit,
        //'pageBuilder': () => EditAnimalPage(animalId: animalId, animalName: animalName),
      },
      {
        'title': 'Breeding Records',

        'pageBuilder': () => BreedingRecordForm(animalId: animalId, animalName: animalName),
      },
      {'title': 'Health Records', 'pa4geBuilder': () => HealthRecordsForm(animalId: animalId, animalName: animalName)},
      {
        'title': 'Vaccination Records',

        'pageBuilder': () => VaccinationRecordsForm(animalId: animalId, animalName: animalName),
      },
      {'title': 'Feeding Records', 'pageBuilder': () => FeedingRecordsForm(animalId: animalId, animalName: animalName)},
      {'title': 'Milk Production', 'pageBuilder': () => MilkProductionPage(animalId: animalId, animalName: animalName)},
    ];

    return Scaffold(
      appBar: AppBar(title: Text("$animalName's Records")),
      body: ListView.builder(
        itemCount: recordTypes.length,
        itemBuilder: (context, index) {
          final record = recordTypes[index];
          return ListTile(
            leading: Icon(record['icon']),
            title: Text(record['title']),
            trailing: Icon(Icons.chevron_right),
            onTap: () => Get.to(record['pageBuilder']),
          );
        },
      ),
    );
  }
}
