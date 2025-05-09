import 'dart:developer';

import 'package:cattle_managementapp/controllers/animalRecords_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VaccinationRecordsForm extends StatefulWidget {
  final String animalId;
  final String animalName;

  const VaccinationRecordsForm({super.key, required this.animalId, required this.animalName});

  @override
  _VaccinationRecordsFormState createState() => _VaccinationRecordsFormState();
}

class _VaccinationRecordsFormState extends State<VaccinationRecordsForm> {
  final AnimalRecordsController recordsController = Get.put(AnimalRecordsController());

  final vaccineNameController = TextEditingController();
  final dateAdministeredController = TextEditingController();
  final nextDueDateController = TextEditingController();
  final vetNameController = TextEditingController();
  final notesController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVaccinationRecord();
  }

  Future<void> fetchVaccinationRecord() async {
    try {
      final records = await recordsController.fetchVaccinationRecords(widget.animalId);
      if (records.isNotEmpty) {
        final existing = records.first;
        vaccineNameController.text = existing['vaccineName'] ?? '';
        dateAdministeredController.text = existing['dateAdministered'] ?? '';
        nextDueDateController.text = existing['nextDueDate'] ?? '';
        vetNameController.text = existing['vetName'] ?? '';
        notesController.text = existing['notes'] ?? '';
      }
    } catch (e) {
      log('Error fetching vaccination records: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = picked.toLocal().toString().split(' ')[0];
    }
  }

  Future<void> saveVaccinationRecord() async {
    final data = {
      'vaccineName': vaccineNameController.text,
      'dateAdministered': dateAdministeredController.text,
      'nextDueDate': nextDueDateController.text,
      'vetName': vetNameController.text,
      'notes': notesController.text,
    };

    try {
      await recordsController.saveVaccinationRecord(widget.animalId, data);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Vaccination record saved for ${widget.animalName}')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save record: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vaccination Record - ${widget.animalName}')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: vaccineNameController,
                      decoration: InputDecoration(labelText: 'Vaccine Name'),
                    ),
                    TextFormField(
                      controller: dateAdministeredController,
                      decoration: InputDecoration(labelText: 'Date Administered'),
                      readOnly: true,
                      onTap: () => pickDate(dateAdministeredController),
                    ),
                    TextFormField(
                      controller: nextDueDateController,
                      decoration: InputDecoration(labelText: 'Next Due Date'),
                      readOnly: true,
                      onTap: () => pickDate(nextDueDateController),
                    ),
                    TextFormField(
                      controller: vetNameController,
                      decoration: InputDecoration(labelText: 'Veterinarian Name'),
                    ),
                    TextFormField(
                      controller: notesController,
                      decoration: InputDecoration(labelText: 'Notes'),
                      maxLines: 3,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(onPressed: saveVaccinationRecord, child: Text('Save Vaccination Record')),
                  ],
                ),
              ),
    );
  }
}
