import 'package:cattle_managementapp/pages/healthRecords_page.dart';
import 'package:cattle_managementapp/pages/milkProduction_page.dart';
import 'package:cattle_managementapp/pages/vaccinationRecords_page.dart';
import 'package:cattle_managementapp/widgets/calves/calving_records_page.dart';
import 'package:cattle_managementapp/widgets/edit_animals.dart';

import 'package:cattle_managementapp/widgets/records/breeding_records_form.dart';
import 'package:cattle_managementapp/widgets/records/vaccination_records_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class RecordTypesPage extends StatelessWidget {
  final String animalId;
  final String animalName;

  const RecordTypesPage({super.key, required this.animalId, required this.animalName});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> recordTypes = [
      {'title': 'Edit Animal Details', 'icon': Icons.edit, 'pageBuilder': () => EditAnimalPage(animalId: animalId)},
      {
        'title': 'Breeding Records',
        'icon': MdiIcons.cow,
        'pageBuilder': () => BreedingRecordForm(animalId: animalId, animalName: animalName),
      },
      {'title': 'Calving Records', 'icon': MdiIcons.cow, 'pageBuilder': () => CalvingRecordsPage(animalId: animalId)},
      {
        'title': 'Milk Production',
        'icon': Icons.local_drink,
        'pageBuilder': () => MilkProductionPage(animalId: animalId, animalName: animalName),
      },
      {
        'title': 'Health Records',
        'icon': Icons.health_and_safety,
        'pageBuilder': () => HealthRecordsPage(animalId: animalId, animalName: animalName),
      },
      {
        'title': 'Vaccination Records',
        'icon': Icons.local_hospital,
        'pageBuilder': () => VaccinationRecordsPage(animalId: animalId, animalName: animalName),
      },
      /* {
        'title': 'Feeding Records',
        'icon': MdiIcons.grass,
        'pageBuilder': () => FeedingRecordsForm(animalId: animalId, animalName: animalName),
      }, */
    ];

    return Scaffold(
      appBar: AppBar(title: Text("$animalName's Records")),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(color: Colors.grey[100]),
        child: ListView.builder(
          itemCount: recordTypes.length,
          itemBuilder: (context, index) {
            final record = recordTypes[index];
            return Card(
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: Icon(record['icon'], color: Colors.lightGreen),
                title: Text(record['title'], style: TextStyle(fontSize: 18)),
                trailing: Icon(Icons.chevron_right, color: Colors.grey[600]),
                onTap: () => Get.to(record['pageBuilder']),
              ),
            );
          },
        ),
      ),
    );
  }
}
