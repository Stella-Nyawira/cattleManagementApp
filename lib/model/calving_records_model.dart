class CalvingRecord {
  String? id;
  String animalId;
  String birthDate;
  String calfGender;
  String calfName;
  String calvingOutcome;
  String complications;
  String vetName;
  String notes;

  CalvingRecord({
    this.id,
    required this.animalId,
    required this.birthDate,
    required this.calfGender,
    required this.calfName,
    required this.calvingOutcome,
    required this.complications,
    required this.vetName,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'animalId': animalId,
      'calvingDate': birthDate,
      'calfGender': calfGender,
      'calfName': calfName,
      'calvingOutcome': calvingOutcome,
      'complications': complications,
      'vetName': vetName,
      'notes': notes,
    };
  }

  factory CalvingRecord.fromMap(String id, Map<String, dynamic> map) {
    return CalvingRecord(
      id: id,
      animalId: map['animalId'] ?? '',
      birthDate: map['calvingDate'] ?? '',
      calfGender: map['calfGender'] ?? '',
      calfName: map['calfName'] ?? '',
      calvingOutcome: map['calvingOutcome'] ?? '',
      complications: map['complications'] ?? '',
      vetName: map['vetName'] ?? '',
      notes: map['notes'] ?? '',
    );
  }
}
