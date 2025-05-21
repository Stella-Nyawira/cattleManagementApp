import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/transactions_controller.dart';

class ProfitsOverviewPage extends StatelessWidget {
  ProfitsOverviewPage({super.key});

  final TransactionsController txController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profits Overview')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final monthlyDataMap = txController.getMonthlySummary();

          final sortedKeys = monthlyDataMap.keys.toList()..sort();

          final monthlyData =
              sortedKeys.map((key) {
                final date = DateFormat('yyyy-MM').parse(key);
                final monthName = DateFormat('MMMM').format(date);
                final data = monthlyDataMap[key]!;
                final income = data['income'] as num? ?? 0;
                final expense = data['expense'] as num? ?? 0;
                final profit = income - expense;
                return {"month": monthName, "income": income, "expense": expense, "profit": profit};
              }).toList();

          final totalIncome = monthlyData.fold(0.0, (sum, item) => sum + (item['income'] as num? ?? 0));
          final totalExpense = monthlyData.fold(0.0, (sum, item) => sum + (item['expense'] as num? ?? 0));
          final totalProfit = totalIncome - totalExpense;

          return Column(
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _summaryCard('Total Income', totalIncome, Colors.green),
                  _summaryCard('Total Expenses', totalExpense, Colors.red),
                  _summaryCard('Net Profit', totalProfit, Colors.blue),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: monthlyData.length,
                  itemBuilder: (_, index) {
                    final data = monthlyData[index];
                    final income = data['income'] as num? ?? 0;
                    final profit = data['profit'] as num? ?? 0;
                    return ListTile(
                      title: Text(data['month'].toString()),
                      subtitle: Text('Income: ${income.toStringAsFixed(0)} | Profit: ${profit.toStringAsFixed(0)}'),
                      trailing: Icon(Icons.trending_up, color: profit >= 0 ? Colors.green : Colors.red),
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _summaryCard(String label, double amount, Color color) {
    return Card(
      elevation: 3,
      color: color.withOpacity(0.1),
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(amount.toStringAsFixed(0), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
