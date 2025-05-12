import 'dart:developer';

import 'package:cattle_managementapp/controllers/animalRecords_controller.dart';
import 'package:cattle_managementapp/model/milkProduction_record_model.dart';
import 'package:cattle_managementapp/widgets/records/milkProduction_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MilkProductionPage extends StatefulWidget {
  final String animalId;
  final String animalName;

  const MilkProductionPage({super.key, required this.animalId, required this.animalName});

  @override
  _MilkProductionPageState createState() => _MilkProductionPageState();
}

class _MilkProductionPageState extends State<MilkProductionPage> {
  final AnimalRecordsController recordsController = Get.find<AnimalRecordsController>();

  bool isLoading = true;
  List<MilkProductionRecord> milkRecords = [];

  @override
  void initState() {
    super.initState();
    _fetchMilkRecords();
  }

  Future<void> _fetchMilkRecords() async {
    try {
      final records = await recordsController.fetchMilkProductionRecords(widget.animalId);
      setState(() {
        milkRecords = records;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      log('Error fetching milk records: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.animalName}'s Milk Production")),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : milkRecords.isEmpty
              ? Center(child: Text('No milk production records found'))
              : ListView.builder(
                itemCount: milkRecords.length,
                itemBuilder: (context, index) {
                  final record = milkRecords[index];
                  return ListTile(
                    title: Text('${record.quantity} liters'),
                    subtitle: Text('Date: ${record.date.toLocal()}'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to more details if needed
                    },
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(MilkProductionForm(animalId: widget.animalId, animalName: widget.animalName));
        },
        child: Icon(Icons.add),
        tooltip: 'Add Milk Record',
      ),
    );
  }
}
