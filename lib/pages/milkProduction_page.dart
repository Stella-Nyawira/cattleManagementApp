import 'package:cattle_managementapp/controllers/animalRecords_controller.dart';
import 'package:cattle_managementapp/model/milkProduction_record_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MilkProductionPage extends StatefulWidget {
  final String animalId;
  final String? animalName;

  const MilkProductionPage({required this.animalId, super.key, this.animalName});

  @override
  State<MilkProductionPage> createState() => _MilkProductionPageState();
}

class _MilkProductionPageState extends State<MilkProductionPage> {
  final AnimalRecordsController controller = Get.find();
  late Future<List<MilkProductionRecord>> milkRecordsFuture;

  @override
  void initState() {
    super.initState();
    milkRecordsFuture = controller.fetchMilkProductionRecords(widget.animalId);
  }

  void _showAddMilkDialog() {
    final date = DateTime.now();
    final morningController = TextEditingController();
    final eveningController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Add Milk Record'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: morningController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Morning Amount (L)'),
                ),
                TextField(
                  controller: eveningController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Evening Amount (L)'),
                ),
                TextField(controller: notesController, decoration: const InputDecoration(labelText: 'Notes')),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final milkData = {
                    'date': date,
                    'amountMorning': double.tryParse(morningController.text) ?? 0.0,
                    'amountEvening': double.tryParse(eveningController.text) ?? 0.0,
                    'notes': notesController.text,
                  };

                  await controller.saveMilkRecord(widget.animalId, milkData);
                  setState(() {
                    milkRecordsFuture = controller.fetchMilkProductionRecords(widget.animalId);
                  });

                  Navigator.of(context).pop();
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Milk Production')),
      floatingActionButton: FloatingActionButton(onPressed: _showAddMilkDialog, child: const Icon(Icons.add)),
      body: FutureBuilder<List<MilkProductionRecord>>(
        future: milkRecordsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final records = snapshot.data!;
          if (records.isEmpty) return const Center(child: Text('No milk records found'));

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return ListTile(
                title: Text('${record.date.toLocal()}'.split(' ')[0]),
                subtitle: Text('Morning: ${record.amountMorning}L, Evening: ${record.amountEvening}L'),
                trailing: Text(record.notes),
              );
            },
          );
        },
      ),
    );
  }
}
