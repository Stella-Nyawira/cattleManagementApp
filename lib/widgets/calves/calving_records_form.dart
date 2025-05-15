import 'package:cattle_managementapp/controllers/animalRecords_controller.dart';
import 'package:cattle_managementapp/model/calving_records_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CalvingRecordForm extends StatefulWidget {
  final String animalId;

  const CalvingRecordForm({Key? key, required this.animalId}) : super(key: key);

  @override
  State<CalvingRecordForm> createState() => _CalvingRecordFormState();
}

class _CalvingRecordFormState extends State<CalvingRecordForm> {
  final controller = Get.find<AnimalRecordsController>();

  final _formKey = GlobalKey<FormState>();

  final _birthDateController = TextEditingController();
  final _calfNameController = TextEditingController();
  final _complicationsController = TextEditingController();
  final _vetNameController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedGender;
  String? _selectedOutcome;

  Future<void> _pickDate(TextEditingController controller) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      controller.text = date.toIso8601String().split('T').first;
    }
  }

  void _saveRecord() {
    if (_formKey.currentState!.validate()) {
      final record = CalvingRecord(
        animalId: widget.animalId,
        birthDate: _birthDateController.text,
        calfGender: _selectedGender ?? '',
        calfName: _calfNameController.text,
        calvingOutcome: _selectedOutcome ?? '',
        complications: _complicationsController.text,
        vetName: _vetNameController.text,
        notes: _notesController.text,
      );
      controller.saveCalvingRecord(record);
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    // If editing existing record, initialize _selectedGender and _selectedOutcome here
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Calving Record')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Calving Info Section
              Text('Calving Information', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _birthDateController,
                readOnly: true,
                onTap: () => _pickDate(_birthDateController),
                decoration: InputDecoration(
                  labelText: 'Calving Date',
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Calf Gender',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _calfNameController,
                decoration: InputDecoration(
                  labelText: 'Calf Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),

              const SizedBox(height: 24),
              // Outcome & Vet Info Section
              Text('Outcome & Vet Details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedOutcome,
                items: const [
                  DropdownMenuItem(value: 'Healthy', child: Text('Healthy')),
                  DropdownMenuItem(value: 'Still Birth', child: Text('Still Birth')),
                  DropdownMenuItem(value: 'Premature', child: Text('Premature')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedOutcome = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Calving Outcome',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _complicationsController,
                decoration: InputDecoration(
                  labelText: 'Complications',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _vetNameController,
                decoration: InputDecoration(
                  labelText: 'Vet Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),

              const SizedBox(height: 24),
              // Notes Section
              Text('Additional Notes', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saveRecord,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Save', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
