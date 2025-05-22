import 'package:cattle_managementapp/widgets/records/milkProduction_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cattle_managementapp/controllers/animalRecords_controller.dart';
import 'package:cattle_managementapp/model/milkProduction_record_model.dart';

class MilkRecordsPage extends StatefulWidget {
  final String animalId;
  final String animalName;

  const MilkRecordsPage({super.key, required this.animalId, required this.animalName});

  @override
  State<MilkRecordsPage> createState() => _MilkRecordsPageState();
}

class _MilkRecordsPageState extends State<MilkRecordsPage> {
  final AnimalRecordsController recordsController = Get.find<AnimalRecordsController>();
  List<MilkProductionRecord> milkRecords = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMilkRecords();
  }

  Future<void> _loadMilkRecords() async {
    setState(() {
      isLoading = true;
    });
    try {
      final records = await recordsController.fetchMilkProductionRecords(widget.animalId);
      setState(() {
        milkRecords = records;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load records: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /* void _navigateToAddMilkRecord() async {
    await Navigator.pushNamed(
      context,
      '/addMilkRecord',
      arguments: {'animalId': widget.animalId, 'animalName': widget.animalName},
    );

    _loadMilkRecords();
  }
 */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Milk Records for ${widget.animalName}')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : milkRecords.isEmpty
              ? Center(child: Text('No milk records found'))
              : ListView.builder(
                itemCount: milkRecords.length,
                itemBuilder: (context, index) {
                  final record = milkRecords[index];
                  return ListTile(
                    title: Text('${record.quantity} liters'),
                    subtitle: Text('${record.date.toLocal().toString().split(' ')[0]} - ${record.notes ?? ''}'),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (builder) => MilkProductionForm(animalId: widget.animalId, animalName: widget.animalName),
              ),
            ),
        child: Icon(Icons.add),
        tooltip: 'Add Milk Record',
      ),
    );
  }
}
