class UpcomingEvent {
  final String id;
  final String animalId;
  final String animalName;
  final String eventType;
  final DateTime eventDate;
  final String notes;

  UpcomingEvent({
    required this.id,
    required this.animalId,
    required this.animalName,
    required this.eventType,
    required this.eventDate,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'animalId': animalId,
      'animalName': animalName,
      'eventType': eventType,
      'eventDate': eventDate.toIso8601String(),
      'notes': notes,
    };
  }

  factory UpcomingEvent.fromMap(Map<String, dynamic> map) {
    return UpcomingEvent(
      id: map['id'],
      animalId: map['animalId'],
      animalName: map['animalName'],
      eventType: map['eventType'],
      eventDate: DateTime.parse(map['eventDate']),
      notes: map['notes'] ?? '',
    );
  }
}
