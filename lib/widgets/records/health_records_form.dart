import 'dart:developer';

import 'package:cattle_managementapp/controllers/animalRecords_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class HealthRecordsForm extends StatefulWidget {
  final String animalId;
  final String animalName;

  const HealthRecordsForm({super.key, required this.animalId, required this.animalName});

  @override
  State<HealthRecordsForm> createState() => _HealthRecordsFormState();
}

class _HealthRecordsFormState extends State<HealthRecordsForm> {
  final controller = Get.find<AnimalRecordsController>();

  final conditionController = TextEditingController();
  final symptomsController = TextEditingController();
  final treatmentController = TextEditingController();
  final treatedByController = TextEditingController();
  final notesController = TextEditingController();

  String recoveryStatus = 'Recovering';
  DateTime? diagnosisDate;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLatestRecord();
  }

  Future<void> _loadLatestRecord() async {
    try {
      final records = await controller.fetchHealthRecords(widget.animalId);
      if (records.isNotEmpty) {
        final latest = records.first;
        conditionController.text = latest.condition;
        symptomsController.text = latest.symptoms;
        treatmentController.text = latest.treatment;
        treatedByController.text = latest.treatedBy;
        notesController.text = latest.notes ?? '';
        recoveryStatus = latest.recoveryStatus;
        diagnosisDate = latest.diagnosisDate;
      }
    } catch (e) {
      log("Error loading latest health record: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveHealthRecord() async {
    if (diagnosisDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a diagnosis date')));
      return;
    }

    final data = {
      'condition': conditionController.text,
      'symptoms': symptomsController.text,
      'diagnosisDate': diagnosisDate,
      'treatment': treatmentController.text,
      'treatedBy': treatedByController.text,
      'recoveryStatus': recoveryStatus,
      'notes': notesController.text,
    };

    try {
      await controller.saveHealthRecord(widget.animalId, data);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Health record saved for ${widget.animalName}")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving record: $e")));
    }
  }

  Future<void> _pickDiagnosisDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: diagnosisDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        diagnosisDate = picked;
      });
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        // Change to UnderlineInputBorder for a simpler look
        border: UnderlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Health Record - ${widget.animalName}")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildTextField(conditionController, 'Condition'),
                          const SizedBox(height: 12),
                          _buildTextField(symptomsController, 'Symptoms', maxLines: 2),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: _pickDiagnosisDate,
                            child: AbsorbPointer(
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'Diagnosis Date',
                                  hintText: 'Pick a date',
                                  border: UnderlineInputBorder(),
                                  suffixIcon: const Icon(Icons.calendar_today),
                                ),
                                controller: TextEditingController(
                                  text: diagnosisDate == null ? '' : DateFormat.yMMMd().format(diagnosisDate!),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(treatmentController, 'Treatment Given', maxLines: 2),
                          const SizedBox(height: 12),
                          _buildTextField(treatedByController, 'Treated By'),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: recoveryStatus,
                            items:
                                [
                                  'Recovering',
                                  'Recovered',
                                  'Ongoing',
                                ].map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
                            onChanged: (val) => setState(() => recoveryStatus = val!),
                            decoration: const InputDecoration(
                              labelText: 'Recovery Status',
                              border: UnderlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(notesController, 'Additional Notes', maxLines: 3),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _saveHealthRecord,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Health Record'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
