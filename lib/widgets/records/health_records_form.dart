import 'package:cattle_managementapp/controllers/animalRecords_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  bool isLoading = false;

  Future<void> _saveHealthRecord() async {
    if (diagnosisDate == null || conditionController.text.trim().isEmpty || symptomsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill required fields and pick a date')));
      return;
    }

    final data = {
      'condition': conditionController.text,
      'symptoms': symptomsController.text,
      'diagnosisDate': Timestamp.fromDate(diagnosisDate!),
      'treatment': treatmentController.text,
      'treatedBy': treatedByController.text,
      'recoveryStatus': recoveryStatus,
      'notes': notesController.text,
    };

    try {
      setState(() => isLoading = true);
      await controller.addHealthRecord(widget.animalId, data);
      Get.back();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save record: $e')));
    } finally {
      setState(() => isLoading = false);
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextField(controller: controller, maxLines: maxLines, decoration: _inputDecoration(label));
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Health Details'),
                    const SizedBox(height: 16),
                    _buildTextField(conditionController, 'Condition'),
                    const SizedBox(height: 12),
                    _buildTextField(symptomsController, 'Symptoms', maxLines: 2),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickDiagnosisDate,
                      child: AbsorbPointer(
                        child: TextField(
                          controller: TextEditingController(
                            text: diagnosisDate == null ? '' : DateFormat.yMMMd().format(diagnosisDate!),
                          ),
                          decoration: _inputDecoration(
                            'Diagnosis Date',
                          ).copyWith(suffixIcon: const Icon(Icons.calendar_today), hintText: 'Pick a date'),
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
                      decoration: _inputDecoration('Recovery Status'),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(notesController, 'Additional Notes', maxLines: 3),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _saveHealthRecord,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Health Record'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
