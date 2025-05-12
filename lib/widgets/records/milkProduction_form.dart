import 'package:cattle_managementapp/controllers/animalRecords_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MilkProductionForm extends StatefulWidget {
  final String animalId;
  final String animalName;

  const MilkProductionForm({super.key, required this.animalId, required this.animalName});

  @override
  _MilkProductionFormState createState() => _MilkProductionFormState();
}

class _MilkProductionFormState extends State<MilkProductionForm> {
  final AnimalRecordsController recordsController = Get.find<AnimalRecordsController>();

  final quantityController = TextEditingController();
  final notesController = TextEditingController();

  bool isLoading = false;

  Future<void> _saveMilkRecord() async {
    final double quantity = double.tryParse(quantityController.text) ?? 0.0;
    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a valid quantity')));
      return;
    }

    final milkData = {'quantity': quantity, 'date': DateTime.now(), 'notes': notesController.text};

    setState(() {
      isLoading = true;
    });

    try {
      await recordsController.saveMilkRecord(widget.animalId, milkData);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Milk record saved for ${widget.animalName}')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save milk record: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Milk Record for ${widget.animalName}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: quantityController,
              decoration: InputDecoration(labelText: 'Milk Quantity (liters)'),
              keyboardType: TextInputType.number,
            ),
            TextField(controller: notesController, decoration: InputDecoration(labelText: 'Notes'), maxLines: 3),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _saveMilkRecord,
              child: isLoading ? CircularProgressIndicator() : Text('Save Milk Record'),
            ),
          ],
        ),
      ),
    );
  }
}
