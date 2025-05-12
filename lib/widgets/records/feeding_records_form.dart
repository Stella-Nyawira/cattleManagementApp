import 'package:cattle_managementapp/controllers/animalRecords_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeedingRecordsForm extends StatefulWidget {
  final String animalId;
  final String animalName;

  const FeedingRecordsForm({super.key, required this.animalId, required this.animalName});

  @override
  State<FeedingRecordsForm> createState() => _FeedingRecordsFormState();
}

class _FeedingRecordsFormState extends State<FeedingRecordsForm> {
  final AnimalRecordsController recordsController = Get.find<AnimalRecordsController>();

  final feedTypeController = TextEditingController();
  final quantityController = TextEditingController();
  final feedingTimeController = TextEditingController();
  final notesController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFeedingRecord();
  }

  Future<void> _fetchFeedingRecord() async {
    try {
      final records = await recordsController.fetchFeedingRecords(widget.animalId);
      if (records.isNotEmpty) {
        final latestRecord = records.first;
        feedTypeController.text = latestRecord['feedType'] ?? '';
        quantityController.text = latestRecord['quantity'] ?? '';
        feedingTimeController.text = latestRecord['feedingTime'] ?? '';
        notesController.text = latestRecord['notes'] ?? '';
      }
    } catch (e) {
      debugPrint('Error fetching feeding records: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveFeedingRecord() async {
    final feedingData = {
      'feedType': feedTypeController.text,
      'quantity': quantityController.text,
      'feedingTime': feedingTimeController.text,
      'notes': notesController.text,
      'createdAt': DateTime.now(),
    };

    try {
      await recordsController.saveFeedingRecord(widget.animalId, feedingData);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Feeding record saved for ${widget.animalName}')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save feeding record: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feeding Record - ${widget.animalName}')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTextField(feedTypeController, 'Feed Type'),
                    _buildTextField(quantityController, 'Quantity'),
                    _buildTextField(feedingTimeController, 'Feeding Time'),
                    _buildTextField(notesController, 'Notes', maxLines: 3),
                    const SizedBox(height: 20),
                    ElevatedButton(onPressed: _saveFeedingRecord, child: const Text('Save Feeding Record')),
                  ],
                ),
              ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextField(controller: controller, decoration: InputDecoration(labelText: label), maxLines: maxLines);
  }
}
