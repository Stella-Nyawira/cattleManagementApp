import 'package:cloud_firestore/cloud_firestore.dart';

class MilkProductionRecord {
  String id;
  DateTime date;
  double amountMorning;
  double amountEvening;
  String notes;

  MilkProductionRecord({
    required this.id,
    required this.date,
    required this.amountMorning,
    required this.amountEvening,
    this.notes = '',
  });

  factory MilkProductionRecord.fromMap(Map<String, dynamic> data, String id) {
    return MilkProductionRecord(
      id: id,
      date: (data['date'] as Timestamp).toDate(),
      amountMorning: (data['amountMorning'] ?? 0).toDouble(),
      amountEvening: (data['amountEvening'] ?? 0).toDouble(),
      notes: data['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'date': date, 'amountMorning': amountMorning, 'amountEvening': amountEvening, 'notes': notes};
  }
}
