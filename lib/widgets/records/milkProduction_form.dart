import 'package:cattle_managementapp/controllers/animalRecords_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MilkProductionForm extends StatefulWidget {
  final String animalId;
  final String animalName;

  const MilkProductionForm({super.key, required this.animalId, required this.animalName});

  @override
  _MilkProductionFormState createState() => _MilkProductionFormState();
}

class _MilkProductionFormState extends State<MilkProductionForm> {
  final AnimalRecordsController recordsController = Get.find<AnimalRecordsController>();

  final TextEditingController morningController = TextEditingController();
  final TextEditingController afternoonController = TextEditingController();
  final TextEditingController eveningController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  DateTime? selectedDate;

  bool isLoading = false;

  String get formattedDate {
    if (selectedDate == null) return 'Select Date';
    return DateFormat('EEE, MMM d, yyyy').format(selectedDate!);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _saveMilkRecord() async {
    // Parse quantities, default to 0 if empty
    final morning = double.tryParse(morningController.text) ?? 0;
    final afternoon = double.tryParse(afternoonController.text) ?? 0;
    final evening = double.tryParse(eveningController.text) ?? 0;

    if (selectedDate == null) {
      Get.snackbar(
        'Error',
        'Please select a date for the milk record.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (morning <= 0 && afternoon <= 0 && evening <= 0) {
      Get.snackbar(
        'Error',
        'Please enter at least one milk quantity greater than zero.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final milkData = {
      'morning': morning,
      'afternoon': afternoon,
      'evening': evening,
      'date': selectedDate,
      'notes': notesController.text.trim(),
    };

    setState(() {
      isLoading = true;
    });

    try {
      await recordsController.saveMilkRecord(widget.animalId, milkData);
      Get.snackbar(
        'Success',
        'Milk record saved for ${widget.animalName}.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Navigator.pop(context);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save milk record: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildInputField({required String label, required TextEditingController controller, String? hintText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }

  @override
  void dispose() {
    morningController.dispose();
    afternoonController.dispose();
    eveningController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Milk Record for ${widget.animalName}'), backgroundColor: Colors.greenAccent),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Picker Card
            Text('Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _pickDate,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formattedDate, style: TextStyle(fontSize: 16)),
                      Icon(Icons.calendar_today, color: Colors.greenAccent),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Milk Amount Inputs
            Text(
              'Milk Amounts (liters)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green[800]),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    buildInputField(
                      label: 'Morning',
                      controller: morningController,
                      hintText: 'Enter morning milk quantity',
                    ),
                    buildInputField(
                      label: 'Afternoon',
                      controller: afternoonController,
                      hintText: 'Enter afternoon milk quantity',
                    ),
                    buildInputField(
                      label: 'Evening',
                      controller: eveningController,
                      hintText: 'Enter evening milk quantity',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Notes
            Text('Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextFormField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Additional notes (optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveMilkRecord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child:
                    isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                        : const Text('Save Milk Record', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
