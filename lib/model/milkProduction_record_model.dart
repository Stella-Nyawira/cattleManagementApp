import 'package:cloud_firestore/cloud_firestore.dart';

class MilkProductionRecord {
  final String id;
  final DateTime date;
  final double morning;
  final double afternoon;
  final double evening;
  final String? notes;

  MilkProductionRecord({
    required this.id,
    required this.date,
    required this.morning,
    required this.afternoon,
    required this.evening,
    this.notes,
  });

  factory MilkProductionRecord.fromMap(Map<String, dynamic> map, String documentId) {
    return MilkProductionRecord(
      id: documentId,
      date: (map['date'] as Timestamp).toDate(),
      morning: (map['morning'] != null) ? (map['morning'] as num).toDouble() : 0.0,
      afternoon: (map['afternoon'] != null) ? (map['afternoon'] as num).toDouble() : 0.0,
      evening: (map['evening'] != null) ? (map['evening'] as num).toDouble() : 0.0,
      notes: map['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'morning': morning,
      'afternoon': afternoon,
      'evening': evening,
      'note': notes,
    };
  }

  double get total => morning + afternoon + evening;
}
