import 'package:cloud_firestore/cloud_firestore.dart';

class MilkProductionRecord {
  final String id;
  final DateTime date;
  final double quantity; // <-- Make sure this exists!
  final String? notes;

  MilkProductionRecord({required this.id, required this.date, required this.quantity, this.notes});

  factory MilkProductionRecord.fromMap(Map<String, dynamic> map, String documentId) {
    return MilkProductionRecord(
      id: documentId,
      date: (map['date'] as Timestamp).toDate(),
      quantity: (map['quantity'] as num).toDouble(), // <-- parsing here too
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {'date': Timestamp.fromDate(date), 'quantity': quantity, 'notes': notes};
  }
}
