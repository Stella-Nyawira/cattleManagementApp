import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class TransactionsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<Map<String, dynamic>> transactions = <Map<String, dynamic>>[].obs;

  Future<void> saveTransaction(Map<String, dynamic> data) async {
    await _firestore.collection('transactions').add({...data, 'createdAt': FieldValue.serverTimestamp()});
    fetchTransactions(); // Refresh
  }

  Future<void> fetchTransactions() async {
    final snapshot = await _firestore.collection('transactions').orderBy('date', descending: true).get();

    transactions.value =
        snapshot.docs.map((doc) {
          return {'id': doc.id, ...doc.data()};
        }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
  }

  /// Returns profit for the current month (income - expense)
  double get currentMonthProfit {
    final now = DateTime.now();
    final key = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    final monthlyData = getMonthlySummary();

    final income = monthlyData[key]?['income'] ?? 0.0;
    final expense = monthlyData[key]?['expense'] ?? 0.0;

    return income - expense;
  }
  // In transactions_controller.dart

  Map<String, Map<String, double>> getMonthlySummary() {
    Map<String, Map<String, double>> monthlyData = {};

    for (var tx in transactions) {
      final date = (tx['date'] as Timestamp).toDate();
      final key = "${date.year}-${date.month.toString().padLeft(2, '0')}";
      final isIncome = tx['isIncome'];
      final amount = tx['amount'] ?? 0.0;

      monthlyData[key] ??= {"income": 0.0, "expense": 0.0};
      if (isIncome) {
        monthlyData[key]!['income'] = (monthlyData[key]!['income'] ?? 0) + amount;
      } else {
        monthlyData[key]!['expense'] = (monthlyData[key]!['expense'] ?? 0) + amount;
      }
    }

    return monthlyData;
  }
}
