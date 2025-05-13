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
  final AnimalRecordsController recordsController = Get.find<AnimalRecordsController>();

  final heatDateController = TextEditingController();
  final inseminationDateController = TextEditingController();
  final expectedHeatDateController = TextEditingController();
  final expectedCalvingDateController = TextEditingController();
  final vetNameController = TextEditingController();
  final breedingMethodController = TextEditingController();
  final bullIdController = TextEditingController();
  final notesController = TextEditingController();

  String? selectedGender;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBreedingRecord();
  }

  Future<void> _fetchBreedingRecord() async {
    try {
      var records = await recordsController.fetchBreedingRecords(widget.animalId);
      if (records.isNotEmpty) {
        var existingRecord = records.first;
        heatDateController.text = existingRecord['heatDate'] ?? '';
        inseminationDateController.text = existingRecord['inseminationDate'] ?? '';
        expectedHeatDateController.text = existingRecord['expectedHeatDate'] ?? '';
        expectedCalvingDateController.text = existingRecord['expectedCalvingDate'] ?? '';
        vetNameController.text = existingRecord['vetName'] ?? '';
        breedingMethodController.text = existingRecord['breedingMethod'] ?? '';
        bullIdController.text = existingRecord['bullId'] ?? '';
        notesController.text = existingRecord['notes'] ?? '';
        selectedGender = existingRecord['gender'] ?? null;
      }
    } catch (e) {
      debugPrint('Error fetching breeding record: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _pickDate(TextEditingController controller) async {
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

  Future<void> _saveBreedingRecord() async {
    final breedingData = {
      'heatDate': heatDateController.text,
      'inseminationDate': inseminationDateController.text,
      'expectedHeatDate': expectedHeatDateController.text,
      'expectedCalvingDate': expectedCalvingDateController.text,
      'vetName': vetNameController.text,
      'breedingMethod': breedingMethodController.text,
      'bullId': bullIdController.text,
      'notes': notesController.text,
      'gender': selectedGender,
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    buildDropdownField('Gender', ['Male', 'Female']),
                    buildDateField(heatDateController, 'Heat Date'),
                    buildDateField(inseminationDateController, 'Insemination Date'),
                    buildDateField(expectedHeatDateController, 'Expected Heat Date'),
                    buildDateField(expectedCalvingDateController, 'Expected Calving Date'),
                    buildTextField(breedingMethodController, 'Method of Breeding'),
                    buildTextField(bullIdController, 'Bull ID'),
                    buildTextField(vetNameController, 'Veterinary Doctor Name'),
                    buildTextField(notesController, 'Notes', maxLines: 3),
                    const SizedBox(height: 20),
                    ElevatedButton(onPressed: _saveBreedingRecord, child: const Text('Save Breeding Record')),
                  ],
                ),
              ),
    );
  }

  Widget buildDateField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      readOnly: true,
      onTap: () => _pickDate(controller),
    );
  }

  Widget buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextField(controller: controller, decoration: InputDecoration(labelText: label), maxLines: maxLines);
  }

  Widget buildDropdownField(String label, List<String> options) {
    return DropdownButtonFormField<String>(
      value: selectedGender,
      decoration: InputDecoration(labelText: label),
      items: options.map((gender) => DropdownMenuItem(value: gender, child: Text(gender))).toList(),
      onChanged: (value) {
        setState(() {
          selectedGender = value!;
        });
      },
    );
  }
}
