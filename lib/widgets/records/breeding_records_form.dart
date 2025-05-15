import 'dart:developer';
import 'package:cattle_managementapp/controllers/animalRecords_controller.dart';
import 'package:cattle_managementapp/widgets/edit/edit_breeding_records.dart';
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
  final AnimalRecordsController animalRecordsController = Get.find();
  final animalNameController = TextEditingController();
  final animalBreedController = TextEditingController();
  final bullNameController = TextEditingController();
  final bullBreedController = TextEditingController();
  final inseminationDateController = TextEditingController();
  final vetNameController = TextEditingController();
  final notesController = TextEditingController();

  final firstHeatDateController = TextEditingController();
  final firstServingDateController = TextEditingController();
  final secondServingDateController = TextEditingController();
  final thirdServingDateController = TextEditingController();
  final fifthServingDateController = TextEditingController();
  final nextExpectedHeatDateController = TextEditingController();
  final estimatedCalvingDateController = TextEditingController();

  String? breedingMethod;
  String? breedingSubType;
  String? pregnancyStatus;

  final List<String> breedingMethods = ['Natural', 'AI'];
  final Map<String, List<String>> breedingSubTypes = {
    'Natural': ['Inbreeding', 'Crossbreeding', 'Other'],
    'AI': ['Straw', 'Embryo transfer(ET)'],
  };
  final List<String> pregnancyStatusOptions = ['Pregnant', 'Not Pregnant', 'Awaiting Scan'];

  bool showForm = false;
  List<Map<String, dynamic>> breedingRecords = [];
  bool isLoadingRecords = true;

  @override
  void initState() {
    super.initState();
    loadAnimalDetails();
    fetchBreedingRecords();
  }

  Future<void> loadAnimalDetails() async {
    try {
      final animalDoc = await animalRecordsController.firestore.collection('animals').doc(widget.animalId).get();
      if (animalDoc.exists) {
        final animalData = animalDoc.data();
        animalNameController.text = animalData?['name'] ?? '';
        animalBreedController.text = animalData?['breed'] ?? '';
      }
    } catch (e) {
      log('Error loading animal details: $e');
    }
  }

  Future<void> fetchBreedingRecords() async {
    try {
      final records = await animalRecordsController.fetchBreedingRecords(widget.animalId);
      setState(() {
        breedingRecords = records;
        isLoadingRecords = false;
      });
    } catch (e) {
      log('Error fetching records: $e');
      setState(() => isLoadingRecords = false);
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
      controller.text = picked.toIso8601String().split('T').first;
      _updateAutoCalculatedDates();
    }
  }

  void _updateAutoCalculatedDates() {
    DateTime? baseDate;

    // Prefer serving date, fallback to first heat date
    if (firstServingDateController.text.isNotEmpty) {
      baseDate = DateTime.tryParse(firstServingDateController.text);
    } else if (firstHeatDateController.text.isNotEmpty) {
      baseDate = DateTime.tryParse(firstHeatDateController.text);
    }

    if (baseDate != null) {
      nextExpectedHeatDateController.text = baseDate.add(const Duration(days: 21)).toIso8601String().split('T').first;

      if (pregnancyStatus == 'Pregnant') {
        estimatedCalvingDateController.text =
            baseDate.add(const Duration(days: 283)).toIso8601String().split('T').first;
      } else {
        estimatedCalvingDateController.text = '';
      }
    } else {
      nextExpectedHeatDateController.text = '';
      estimatedCalvingDateController.text = '';
    }
  }

  void saveRecord() async {
    final breedingData = {
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
      await animalRecordsController.saveBreedingRecord(animalId: widget.animalId, breedingData: breedingData);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Breeding record saved')));
      setState(() => showForm = false);
      fetchBreedingRecords();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error saving breeding record')));
      log('Error saving breeding record: $e');
    }
  }

  void onPregnancyStatusChanged(String? newStatus) {
    setState(() {
      pregnancyStatus = newStatus;
      _updateAutoCalculatedDates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Breeding Record')),
      body: showForm ? buildBreedingForm() : buildRecordsList(),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(showForm ? Icons.list : Icons.add),
        label: Text(showForm ? 'View Records' : 'Add Record'),
        onPressed: () => setState(() => showForm = !showForm),
      ),
    );
  }

  Widget buildRecordsList() {
    if (isLoadingRecords) return const Center(child: CircularProgressIndicator());
    if (breedingRecords.isEmpty) return const Center(child: Text('No breeding records found.'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: breedingRecords.length,
      itemBuilder: (context, index) {
        final record = breedingRecords[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text('${record['breedingMethod']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date: ${record['inseminationDate'] ?? 'Unknown'}'),
                Text('Breeding: ${record['breedingSubType'] ?? 'N/A'}'),
                Text(
                  record['breedingMethod'] == 'Natural'
                      ? 'Bull: ${record['bullName'] ?? '-'}'
                      : 'Inseminated by: ${record['vetName'] ?? '-'}',
                ),
                Text('Status: ${record['pregnancyStatus'] ?? 'N/A'}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Delete Record'),
                        content: const Text('Are you sure you want to delete this record?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              animalRecordsController.deleteBreedingRecord(
                                animalId: widget.animalId,
                                recordId: record['id'],
                              );
                              fetchBreedingRecords();
                            },
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                        ],
                      ),
                );
              },
            ),
            isThreeLine: true,
            onTap: () async {
              final updated = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditBreedingRecordPage(animalId: widget.animalId, breedingRecord: record),
                ),
              );
              if (updated == true) {
                // Refresh after edit if needed
                fetchBreedingRecords();
              }
            },
          ),
        );
      },
    );
  }

  Widget buildBreedingForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle('Animal Information'),
          formCard([
            buildTextField(animalNameController, 'Animal Name'),
            buildTextField(animalBreedController, 'Animal Breed'),
          ]),
          const SizedBox(height: 20),
          sectionTitle('Serving Information'),
          formCard([
            buildDateField(firstHeatDateController, 'First Heat Date'),
            buildDateField(firstServingDateController, 'First Serving Date'),
            if (pregnancyStatus == 'Not Pregnant') ...[
              buildDateField(secondServingDateController, 'Second Serving Date'),
              buildDateField(thirdServingDateController, 'Third Serving Date'),
              buildDateField(fifthServingDateController, 'forth Serving Date'),
            ],
            buildDateField(nextExpectedHeatDateController, 'Next Expected Heat Date'),
          ]),
          const SizedBox(height: 20),
          sectionTitle('Breeding Method'),
          formCard([
            buildDropdown('Method of Breeding', breedingMethods, breedingMethod, (value) {
              setState(() {
                breedingMethod = value;
                breedingSubType = null;
              });
            }),
            if (breedingMethod != null)
              buildDropdown(
                breedingMethod == 'Natural' ? 'Natural Breeding Type' : 'AI Type',
                breedingSubTypes[breedingMethod!]!,
                breedingSubType,
                (value) => setState(() => breedingSubType = value),
              ),
          ]),
          const SizedBox(height: 20),
          sectionTitle('Bull / Insemination Information'),
          formCard([
            if (breedingMethod == 'Natural') ...[
              buildTextField(bullNameController, 'Bull ID / Name'),
              buildTextField(bullBreedController, 'Bull Breed'),
            ],
            if (breedingMethod == 'AI') ...[
              buildDateField(inseminationDateController, 'Insemination Date'),
              buildTextField(vetNameController, 'Veterinarian Name'),
            ],
          ]),
          const SizedBox(height: 20),
          sectionTitle(' Pregnancy'),
          formCard([
            buildDropdown('Pregnancy Status', pregnancyStatusOptions, pregnancyStatus, onPregnancyStatusChanged),
            buildDateField(estimatedCalvingDateController, 'Estimated Calving Date'),
          ]),
          const SizedBox(height: 20),
          sectionTitle('Additional Notes'),
          formCard([buildTextField(notesController, 'Additional Notes', maxLines: 3)]),
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton.icon(
              onPressed: saveRecord,
              icon: const Icon(Icons.save),
              label: const Text('Save Breeding Record'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget formCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: children.map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: e)).toList(),
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    );
  }

  Widget buildDropdown(String label, List<String> options, String? value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      value: value,
      items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
      onChanged: onChanged,
    );
  }

  Widget buildDateField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      onTap: () => pickDate(controller),
    );
  }
}
