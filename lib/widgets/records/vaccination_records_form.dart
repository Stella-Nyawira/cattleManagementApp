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
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Vaccine Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Divider(height: 24),
                        TextFormField(
                          controller: vaccineNameController,
                          decoration: const InputDecoration(labelText: 'Vaccine Name', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: dateAdministeredController,
                          decoration: const InputDecoration(
                            labelText: 'Date Administered',
                            prefixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                          onTap: () => pickDate(dateAdministeredController),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: nextDueDateController,
                          decoration: const InputDecoration(
                            labelText: 'Next Due Date',
                            prefixIcon: Icon(Icons.event_available),
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                          onTap: () => pickDate(nextDueDateController),
                        ),
                        const SizedBox(height: 24),
                        const Text('Veterinarian Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Divider(height: 24),
                        TextFormField(
                          controller: vetNameController,
                          decoration: const InputDecoration(
                            labelText: 'Veterinarian Name',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: notesController,
                          decoration: const InputDecoration(
                            labelText: 'Notes',
                            alignLabelWithHint: true,
                            prefixIcon: Icon(Icons.note_alt),
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.save),
                            label: const Text('Save Vaccination Record'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            onPressed: saveVaccinationRecord,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
