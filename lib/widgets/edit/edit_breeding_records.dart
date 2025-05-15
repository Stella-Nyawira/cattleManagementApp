import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cattle_managementapp/controllers/animalRecords_controller.dart';

class EditBreedingRecordPage extends StatefulWidget {
  final String animalId;
  final Map<String, dynamic> breedingRecord;

  const EditBreedingRecordPage({super.key, required this.animalId, required this.breedingRecord});

  @override
  _EditBreedingRecordPageState createState() => _EditBreedingRecordPageState();
}

class _EditBreedingRecordPageState extends State<EditBreedingRecordPage> {
  final AnimalRecordsController animalRecordsController = Get.find();

  late TextEditingController animalNameController;
  late TextEditingController animalBreedController;
  late TextEditingController bullNameController;
  late TextEditingController bullBreedController;
  late TextEditingController inseminationDateController;
  late TextEditingController vetNameController;
  late TextEditingController notesController;
  late TextEditingController firstHeatDateController;
  late TextEditingController firstServingDateController;
  late TextEditingController secondServingDateController;
  late TextEditingController thirdServingDateController;
  late TextEditingController fifthServingDateController;
  late TextEditingController nextExpectedHeatDateController;
  late TextEditingController estimatedCalvingDateController;

  String? breedingMethod;
  String? breedingSubType;
  String? pregnancyStatus;

  final List<String> breedingMethods = ['Natural', 'AI'];
  final Map<String, List<String>> breedingSubTypes = {
    'Natural': ['Inbreeding', 'Crossbreeding', 'Other'],
    'AI': ['Straw', 'Embryo transfer(ET)'],
  };
  final List<String> pregnancyStatusOptions = ['Pregnant', 'Not Pregnant', 'Awaiting Scan'];

  @override
  void initState() {
    super.initState();

    final record = widget.breedingRecord;
    animalNameController = TextEditingController(text: record['animalName'] ?? '');
    animalBreedController = TextEditingController(text: record['animalBreed'] ?? '');
    bullNameController = TextEditingController(text: record['bullName'] ?? '');
    bullBreedController = TextEditingController(text: record['bullBreed'] ?? '');
    inseminationDateController = TextEditingController(text: record['inseminationDate'] ?? '');
    vetNameController = TextEditingController(text: record['vetName'] ?? '');
    notesController = TextEditingController(text: record['notes'] ?? '');
    firstHeatDateController = TextEditingController(text: record['firstHeatDate'] ?? '');
    firstServingDateController = TextEditingController(text: record['firstServingDate'] ?? '');
    secondServingDateController = TextEditingController(text: record['secondServingDate'] ?? '');
    thirdServingDateController = TextEditingController(text: record['thirdServingDate'] ?? '');
    fifthServingDateController = TextEditingController(text: record['forthServingDate'] ?? '');
    nextExpectedHeatDateController = TextEditingController(text: record['nextExpectedHeatDate'] ?? '');
    estimatedCalvingDateController = TextEditingController(text: record['estimatedCalvingDate'] ?? '');

    breedingMethod = record['breedingMethod'];
    breedingSubType = record['breedingSubType'];
    pregnancyStatus = record['pregnancyStatus'];
  }

  Future<void> pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.text.isNotEmpty ? DateTime.tryParse(controller.text) ?? DateTime.now() : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = picked.toIso8601String().split('T').first;
      setState(() {});
    }
  }

  void saveChanges() async {
    final updatedData = {
      'animalName': animalNameController.text,
      'animalBreed': animalBreedController.text,
      'breedingMethod': breedingMethod,
      'breedingSubType': breedingSubType,
      'bullName': bullNameController.text,
      'bullBreed': bullBreedController.text,
      'inseminationDate': inseminationDateController.text,
      'vetName': vetNameController.text,
      'pregnancyStatus': pregnancyStatus,
      'notes': notesController.text,
      'firstHeatDate': firstHeatDateController.text,
      'firstServingDate': firstServingDateController.text,
      'secondServingDate': secondServingDateController.text,
      'thirdServingDate': thirdServingDateController.text,
      'forthServingDate': fifthServingDateController.text,
      'nextExpectedHeatDate': nextExpectedHeatDateController.text,
      'estimatedCalvingDate': estimatedCalvingDateController.text,
    };

    try {
      await animalRecordsController.updateBreedingRecord(
        animalId: widget.animalId,
        recordId: widget.breedingRecord['id'],
        updatedData: updatedData,
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Record updated successfully')));
      Navigator.of(context).pop(true); // pass true to indicate update
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update record')));
    }
  }

  Widget buildDropdown(String label, List<String> options, String? value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      value: value,
      items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
      onChanged: onChanged,
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: readOnly ? const Icon(Icons.calendar_today) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Breeding Record')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Animal Information'),
            const SizedBox(height: 8),
            buildTextField(animalNameController, 'Animal Name'),
            const SizedBox(height: 8),
            buildTextField(animalBreedController, 'Animal Breed'),
            const SizedBox(height: 16),

            Text('Serving Information'),
            const SizedBox(height: 8),
            buildTextField(
              firstHeatDateController,
              'First Heat Date',
              readOnly: true,
              onTap: () => pickDate(firstHeatDateController),
            ),
            const SizedBox(height: 8),
            buildTextField(
              firstServingDateController,
              'First Serving Date',
              readOnly: true,
              onTap: () => pickDate(firstServingDateController),
            ),
            const SizedBox(height: 8),
            buildTextField(
              secondServingDateController,
              'Second Serving Date',
              readOnly: true,
              onTap: () => pickDate(secondServingDateController),
            ),
            const SizedBox(height: 8),
            buildTextField(
              thirdServingDateController,
              'Third Serving Date',
              readOnly: true,
              onTap: () => pickDate(thirdServingDateController),
            ),
            const SizedBox(height: 8),
            buildTextField(
              fifthServingDateController,
              'Forth Serving Date',
              readOnly: true,
              onTap: () => pickDate(fifthServingDateController),
            ),
            const SizedBox(height: 8),
            buildTextField(nextExpectedHeatDateController, 'Next Expected Heat Date', readOnly: true),

            const SizedBox(height: 16),
            Text('Breeding Method'),
            const SizedBox(height: 8),
            buildDropdown('Method of Breeding', breedingMethods, breedingMethod, (val) {
              setState(() {
                breedingMethod = val;
                breedingSubType = null;
              });
            }),
            const SizedBox(height: 8),
            if (breedingMethod != null)
              buildDropdown(
                breedingMethod == 'Natural' ? 'Natural Breeding Type' : 'AI Type',
                breedingSubTypes[breedingMethod!]!,
                breedingSubType,
                (val) => setState(() => breedingSubType = val),
              ),

            const SizedBox(height: 16),
            Text('Bull / Insemination Information'),
            const SizedBox(height: 8),
            if (breedingMethod == 'Natural') ...[
              buildTextField(bullNameController, 'Bull ID / Name'),
              const SizedBox(height: 8),
              buildTextField(bullBreedController, 'Bull Breed'),
            ],
            if (breedingMethod == 'AI') ...[
              buildTextField(
                inseminationDateController,
                'Insemination Date',
                readOnly: true,
                onTap: () => pickDate(inseminationDateController),
              ),
              const SizedBox(height: 8),
              buildTextField(vetNameController, 'Veterinarian Name'),
            ],

            const SizedBox(height: 16),
            Text('Pregnancy'),
            const SizedBox(height: 8),
            buildDropdown('Pregnancy Status', pregnancyStatusOptions, pregnancyStatus, (val) {
              setState(() {
                pregnancyStatus = val;
              });
            }),
            const SizedBox(height: 8),
            buildTextField(estimatedCalvingDateController, 'Estimated Calving Date', readOnly: true),

            const SizedBox(height: 16),
            Text('Additional Notes'),
            const SizedBox(height: 8),
            buildTextField(notesController, 'Additional Notes', maxLines: 3),

            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: saveChanges,
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
