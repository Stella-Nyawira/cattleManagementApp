import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cattle_managementapp/model/milkProduction_record_model.dart';
import 'package:cattle_managementapp/controllers/animalRecords_controller.dart';

class MilkProductionForm extends StatefulWidget {
  final String animalId;
  final String animalName;
  final MilkProductionRecord? existingRecord;

  const MilkProductionForm({super.key, required this.animalId, required this.animalName, this.existingRecord});

  @override
  State<MilkProductionForm> createState() => _MilkProductionFormState();
}

class _MilkProductionFormState extends State<MilkProductionForm> {
  final _formKey = GlobalKey<FormState>();
  final AnimalRecordsController recordsController = Get.find<AnimalRecordsController>();

  late TextEditingController morningController;
  late TextEditingController afternoonController;
  late TextEditingController eveningController;
  late TextEditingController notesController;

  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    // If editing an existing record, prefill the values
    if (widget.existingRecord != null) {
      selectedDate = widget.existingRecord!.date;
      morningController = TextEditingController(text: widget.existingRecord!.morning.toString());
      afternoonController = TextEditingController(text: widget.existingRecord!.afternoon.toString());
      eveningController = TextEditingController(text: widget.existingRecord!.evening.toString());
      notesController = TextEditingController(text: widget.existingRecord!.notes ?? '');
    } else {
      morningController = TextEditingController();
      afternoonController = TextEditingController();
      eveningController = TextEditingController();
      notesController = TextEditingController();
    }
  }

  @override
  void dispose() {
    morningController.dispose();
    afternoonController.dispose();
    eveningController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final morning = double.tryParse(morningController.text) ?? 0;
      final afternoon = double.tryParse(afternoonController.text) ?? 0;
      final evening = double.tryParse(eveningController.text) ?? 0;
      final total = morning + afternoon + evening;

      final record = MilkProductionRecord(
        id: widget.existingRecord?.id ?? '', // leave empty for new, reuse for edit
        date: selectedDate,
        morning: morning,
        afternoon: afternoon,
        evening: evening,
        total: total,
        notes: notesController.text.trim(),
      );

      try {
        if (widget.existingRecord != null) {
          await recordsController.updateMilkProductionRecord(widget.animalId, record);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Record updated')));
        } else {
          await recordsController.addMilkProductionRecord(widget.animalId, record);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Record added')));
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingRecord != null ? 'Edit Milk Record' : 'Add Milk Record'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Animal: ${widget.animalName}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                title: Text('Date: ${selectedDate.toLocal().toString().split(' ')[0]}'),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: morningController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Morning (L)', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Enter morning quantity' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: afternoonController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Afternoon (L)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: eveningController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Evening (L)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: notesController,
                maxLines: 3,
                decoration: InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                child: Text(widget.existingRecord != null ? 'Update Record' : 'Add Record'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
