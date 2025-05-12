import 'package:cloud_firestore/cloud_firestore.dart';

class MilkProductionRecord {
  final String id;
  final double quantity;
  final DateTime date;
  final String? notes;

  MilkProductionRecord({required this.id, required this.quantity, required this.date, this.notes});

  factory MilkProductionRecord.fromMap(Map<String, dynamic> data, String id) {
    return MilkProductionRecord(
      id: id,
      quantity: (data['quantity'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'quantity': quantity, 'date': date, 'notes': notes};
  }
}
