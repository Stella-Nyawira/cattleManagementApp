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
      // Optional: Sort by date descending so latest records show first
      records.sort((a, b) => b.date.compareTo(a.date));

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

  Widget _buildMilkDetail(String label, double quantity) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text('${quantity.toStringAsFixed(1)} L', style: TextStyle(fontSize: 14)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Milk Records for ${widget.animalName}'), backgroundColor: Colors.green[700]),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : milkRecords.isEmpty
              ? Center(child: Text('No milk records found'))
              : ListView.builder(
                itemCount: milkRecords.length,
                itemBuilder: (context, index) {
                  final record = milkRecords[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date & Total
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '📅 ${record.date.toLocal().toString().split(' ')[0]}',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  'Total: ${record.total.toStringAsFixed(1)} L',
                                  style: TextStyle(fontSize: 16, color: Colors.green[700]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Session breakdown
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildMilkDetail('🌅 Morning', record.morning),
                                _buildMilkDetail('🏞️ Afternoon', record.afternoon),
                                _buildMilkDetail('🌙 Evening', record.evening),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Notes
                            if (record.notes != null && record.notes!.isNotEmpty)
                              Text('📝 Note: ${record.notes!}', style: TextStyle(color: Colors.grey[700])),
                          ],
                        ),
                      ),
                    ),
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
            ).then((_) => _loadMilkRecords()),
        child: Icon(Icons.add),
        tooltip: 'Add Milk Record',
      ),
    );
  }
}
