import 'package:cloud_firestore/cloud_firestore.dart';

class HealthRecord {
  final String id;
  final String condition;
  final String symptoms;
  final DateTime diagnosisDate;
  final String treatment;
  final String treatedBy;
  final String recoveryStatus;
  final String? notes;

  HealthRecord({
    required this.id,
    required this.condition,
    required this.symptoms,
    required this.diagnosisDate,
    required this.treatment,
    required this.treatedBy,
    required this.recoveryStatus,
    this.notes,
  });

  factory HealthRecord.fromMap(Map<String, dynamic> map, String id) {
    return HealthRecord(
      id: id,
      condition: map['condition'] ?? '',
      symptoms: map['symptoms'] ?? '',
      diagnosisDate: (map['diagnosisDate'] as Timestamp).toDate(),
      treatment: map['treatment'] ?? '',
      treatedBy: map['treatedBy'] ?? '',
      recoveryStatus: map['recoveryStatus'] ?? 'Recovering',
      notes: map['notes'],
    );
  }
}
