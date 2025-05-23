import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cattle_managementapp/controllers/animalRecords_controller.dart';

class MilkOverviewPage extends StatefulWidget {
  @override
  _MilkOverviewPageState createState() => _MilkOverviewPageState();
}

class _MilkOverviewPageState extends State<MilkOverviewPage> {
  final AnimalRecordsController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.updateMilkOverview();
  }

  Future<void> _refreshData() async {
    await controller.updateMilkOverview();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Milk Overview')),
      body: Obx(() {
        // Show loading indicator while fetching
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        final entries = controller.individualMilkProduction.entries.toList();

        if (entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.pets, size: 64, color: Colors.grey),
                SizedBox(height: 12),
                Text('No milk production records found.', style: TextStyle(fontSize: 18, color: Colors.grey[700])),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              _buildTotalMilkCard(),
              SizedBox(height: 24),
              Text('Milk Production Per Animal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              SizedBox(height: 12),
              ...entries.map((entry) => _buildAnimalMilkCard(entry.key, entry.value)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTotalMilkCard() {
    return Card(
      color: Colors.lightBlue[50],
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Text(
          'Total Milk Produced: ${controller.totalMilkProduced.value.toStringAsFixed(2)} liters',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue[900]),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildAnimalMilkCard(String animalName, double liters) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Icon(Icons.pets, color: Colors.brown),
        title: Text(animalName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        trailing: Text('${liters.toStringAsFixed(2)} L', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
