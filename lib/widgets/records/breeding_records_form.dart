import 'dart:developer';

import 'package:cattle_managementapp/controllers/animalRecords_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BreedingRecordForm extends StatefulWidget {
  final String animalId;
  final String animalName;

  const BreedingRecordForm({super.key, required this.animalId, required this.animalName});

  @override
  State<BreedingRecordForm> createState() => _BreedingRecordFormState();
}

class _BreedingRecordFormState extends State<BreedingRecordForm> {
  final AnimalRecordsController recordsController = Get.put(AnimalRecordsController());

  final heatDateController = TextEditingController();
  final inseminationDateController = TextEditingController();
  final expectedHeatDateController = TextEditingController();
  final expectedCalvingDateController = TextEditingController();
  final vetNameController = TextEditingController();
  final breedingMethodController = TextEditingController();
  final bullIdController = TextEditingController();
  final notesController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Fetch existing records when the page is loaded
    fetchBreedingRecord();
  }

  // Fetch existing breeding record for this animal (if available)
  Future<void> fetchBreedingRecord() async {
    try {
      // Fetch the most recent breeding record
      var records = await recordsController.fetchBreedingRecords(widget.animalId);

      if (records.isNotEmpty) {
        // Fill in the fields with existing data
        var existingRecord = records.first; // Assuming the first record is the most recent
        heatDateController.text = existingRecord['heatDate'] ?? '';
        inseminationDateController.text = existingRecord['inseminationDate'] ?? '';
        expectedHeatDateController.text = existingRecord['expectedHeatDate'] ?? '';
        expectedCalvingDateController.text = existingRecord['expectedCalvingDate'] ?? '';
        vetNameController.text = existingRecord['vetName'] ?? '';
        breedingMethodController.text = existingRecord['breedingMethod'] ?? '';
        bullIdController.text = existingRecord['bullId'] ?? '';
        notesController.text = existingRecord['notes'] ?? '';
      }
    } catch (e) {
      log('Error fetching breeding record: $e');
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

  Future<void> saveBreedingRecord() async {
    final breedingData = {
      'heatDate': heatDateController.text,
      'inseminationDate': inseminationDateController.text,
      'expectedHeatDate': expectedHeatDateController.text,
      'expectedCalvingDate': expectedCalvingDateController.text,
      'vetName': vetNameController.text,
      'breedingMethod': breedingMethodController.text,
      'bullId': bullIdController.text,
      'notes': notesController.text,
    };

    try {
      await recordsController.saveBreedingRecord(animalId: widget.animalId, breedingData: breedingData);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Breeding record saved for ${widget.animalName}')));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save breeding record: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Breeding Record - ${widget.animalName}')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: heatDateController,
                      decoration: InputDecoration(labelText: 'Heat Date'),
                      readOnly: true,
                      onTap: () => pickDate(heatDateController),
                    ),
                    TextField(
                      controller: inseminationDateController,
                      decoration: InputDecoration(labelText: 'Insemination Date'),
                      readOnly: true,
                      onTap: () => pickDate(inseminationDateController),
                    ),
                    TextField(
                      controller: expectedHeatDateController,
                      decoration: InputDecoration(labelText: 'Expected Heat Date'),
                      readOnly: true,
                      onTap: () => pickDate(expectedHeatDateController),
                    ),
                    TextField(
                      controller: expectedCalvingDateController,
                      decoration: InputDecoration(labelText: 'Expected Calving Date'),
                      readOnly: true,
                      onTap: () => pickDate(expectedCalvingDateController),
                    ),
                    TextField(
                      controller: breedingMethodController,
                      decoration: InputDecoration(labelText: 'Method of Breeding'),
                    ),
                    TextField(controller: bullIdController, decoration: InputDecoration(labelText: 'Bull ID')),
                    TextField(
                      controller: vetNameController,
                      decoration: InputDecoration(labelText: 'Veterinary Doctor Name'),
                    ),
                    TextField(
                      controller: notesController,
                      decoration: InputDecoration(labelText: 'Notes'),
                      maxLines: 3,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(onPressed: saveBreedingRecord, child: Text('Save Breeding Record')),
                  ],
                ),
              ),
    );
  }
}
