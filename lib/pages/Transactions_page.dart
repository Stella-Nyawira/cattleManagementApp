import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/transactions_controller.dart'; // Adjust path accordingly

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final TransactionsController txController = Get.put(TransactionsController());

  DateTime selectedMonth = DateTime.now();

  Future<void> _addTransaction(bool isIncome) async {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(isIncome ? 'Add Income' : 'Add Expense'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(DateFormat.yMMMd().format(selectedDate)),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  final title = titleController.text.trim();
                  final amount = double.tryParse(amountController.text.trim()) ?? 0;
                  if (title.isNotEmpty && amount > 0) {
                    await txController.saveTransaction({
                      'title': title,
                      'amount': amount,
                      'isIncome': isIncome,
                      'date': Timestamp.fromDate(selectedDate),
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  List<Map<String, dynamic>> get filteredTransactions {
    return txController.transactions.where((tx) {
      final date = (tx['date'] as Timestamp).toDate();
      return date.month == selectedMonth.month && date.year == selectedMonth.year;
    }).toList();
  }

  double get totalIncome =>
      filteredTransactions.where((tx) => tx['isIncome']).fold(0.0, (sum, tx) => sum + (tx['amount'] ?? 0.0));

  double get totalExpenses =>
      filteredTransactions.where((tx) => !tx['isIncome']).fold(0.0, (sum, tx) => sum + (tx['amount'] ?? 0.0));

  double get totalProfit => totalIncome - totalExpenses;

  void _changeMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Select Month',
    );
    if (picked != null) {
      setState(() => selectedMonth = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transactions"),
        actions: [IconButton(icon: const Icon(Icons.calendar_month), onPressed: _changeMonth, tooltip: 'Change Month')],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(
          () => ListView(
            children: [
              Text(
                "Month: ${DateFormat.yMMMM().format(selectedMonth)}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildSummary("Income", totalIncome, Colors.green),
              _buildSummary("Expenses", totalExpenses, Colors.red),
              _buildSummary("Profit", totalProfit, Colors.blue),
              const Divider(height: 30),
              const Text("Transactions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ...filteredTransactions.map((tx) {
                final date = (tx['date'] as Timestamp).toDate();
                return ListTile(
                  leading: Icon(
                    tx['isIncome'] ? Icons.arrow_downward : Icons.arrow_upward,
                    color: tx['isIncome'] ? Colors.green : Colors.red,
                  ),
                  title: Text(tx['title']),
                  subtitle: Text(DateFormat.yMMMd().format(date)),
                  trailing: Text(NumberFormat('#,##0').format(tx['amount'])),
                );
              }),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.add, size: 25),
            onSelected: (value) => _addTransaction(value == 'income'),
            itemBuilder:
                (context) => const [
                  PopupMenuItem(value: 'income', child: Text('Add Income')),
                  PopupMenuItem(value: 'expense', child: Text('Add Expense')),
                ],
          ),
          const SizedBox(height: 4),
          const Text("Add Transaction", style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSummary(String label, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          Text(NumberFormat('#,##0').format(amount), style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
