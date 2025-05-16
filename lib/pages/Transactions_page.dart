import 'package:flutter/material.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  List<Map<String, dynamic>> incomeList = [];
  List<Map<String, dynamic>> expenseList = [];

  void _addTransaction(bool isIncome) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(isIncome ? 'Add Income' : 'Add Expense'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Title')),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  final title = nameController.text.trim();
                  final amount = double.tryParse(amountController.text.trim()) ?? 0;
                  if (title.isNotEmpty && amount > 0) {
                    setState(() {
                      final item = {'title': title, 'amount': amount};
                      if (isIncome) {
                        incomeList.add(item);
                      } else {
                        expenseList.add(item);
                      }
                    });
                  }
                  Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  double get totalIncome => incomeList.fold(0.0, (sum, item) => sum + item['amount']);
  double get totalExpenses => expenseList.fold(0.0, (sum, item) => sum + item['amount']);
  double get totalProfit => totalIncome - totalExpenses;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transactions")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text("Current Month", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            const Text("Income", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            ...incomeList.map((item) => _buildRow(item['title'], item['amount'])),
            _buildRow("Total", totalIncome, isBold: true),

            const SizedBox(height: 20),
            const Text("Expenses", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            ...expenseList.map((item) => _buildRow(item['title'], item['amount'])),
            _buildRow("Total", totalExpenses, isBold: true),

            const SizedBox(height: 20),
            const Text("Profits", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            _buildRow("Total Profit", totalProfit, isBold: true),
          ],
        ),
      ),
      floatingActionButton: PopupMenuButton<String>(
        icon: const Icon(Icons.add),
        onSelected: (value) {
          _addTransaction(value == 'income');
        },
        itemBuilder:
            (context) => [
              const PopupMenuItem(value: 'income', child: Text('Add Income')),
              const PopupMenuItem(value: 'expense', child: Text('Add Expense')),
            ],
      ),
    );
  }

  Widget _buildRow(String title, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(amount.toStringAsFixed(0), style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
