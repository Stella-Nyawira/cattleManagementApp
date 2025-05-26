import 'package:cloud_firestore/cloud_firestore.dart';

class MilkProductionRecord {
  final String id;
  final DateTime date;
  final double morning;
  final double afternoon;
  final double evening;
  final double total;
  final String? notes;

  MilkProductionRecord({
    required this.id,
    required this.date,
    required this.morning,
    required this.afternoon,
    required this.evening,
    required this.total,
    this.notes,
  });

  factory MilkProductionRecord.fromMap(Map<String, dynamic> map, String id) {
    return MilkProductionRecord(
      id: id,
      date: (map['date'] as Timestamp).toDate(),
      morning: (map['morning'] ?? 0).toDouble(),
      afternoon: (map['afternoon'] ?? 0).toDouble(),
      evening: (map['evening'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'morning': morning,
      'afternoon': afternoon,
      'evening': evening,
      'total': total,
      'notes': notes,
    };
  }

  MilkProductionRecord copyWith({
    String? id,
    DateTime? date,
    double? morning,
    double? afternoon,
    double? evening,
    double? total,
    String? notes,
  }) {
    return MilkProductionRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      morning: morning ?? this.morning,
      afternoon: afternoon ?? this.afternoon,
      evening: evening ?? this.evening,
      total: total ?? this.total,
      notes: notes ?? this.notes,
    );
  }
}
