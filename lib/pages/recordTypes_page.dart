import 'package:cattle_managementapp/widgets/records/breeding_records_form.dart';
import 'package:cattle_managementapp/widgets/records/vaccination_records_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecordTypesPage extends StatelessWidget {
  final String animalId;
  final String animalName;

  const RecordTypesPage({super.key, required this.animalId, required this.animalName});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> recordTypes = [
      {
        'title': 'Breeding Records',
        'icon': Icons.favorite,
        'pageBuilder': () => BreedingRecordForm(animalId: animalId, animalName: animalName),
      },
      {
        'title': 'Health Records',
        'icon': Icons.local_hospital,
        //'pageBuilder': () => PlaceholderPage(animalId: animalId),
      },
      {
        'title': 'Vaccination Records',
        'icon': Icons.vaccines,
        'pageBuilder': () => VaccinationRecordsForm(animalId: animalId, animalName: animalName),
      },
      {
        'title': 'Feeding Records',
        'icon': Icons.fastfood,
        // 'pageBuilder': () => PlaceholderPage(animalId: animalId),
      },
      {
        'title': 'Milk Production',
        'icon': Icons.local_drink,
        // 'pageBuilder': () => PlaceholderPage(animalId: animalId),
      },
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
            onTap: () => Get.to(record['pageBuilder']()),
          );
        },
      ),
    );
  }
}
