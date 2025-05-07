class Animal {
  final String name;
  final String breed;
  final String gender;
  final DateTime? dateOfBirth;
  final String? colorMarkings;
  final double? weight;

  final bool isPregnant;
  final DateTime? expectedCalvingDate;
  final DateTime? lastServiceDate;
  final String? sireTag;
  final String? damTag;

  final bool isMilking;
  final String? imagePath;

  Animal({
    required this.name,
    required this.breed,
    required this.gender,
    this.dateOfBirth,
    this.colorMarkings,
    this.weight,
    this.isPregnant = false,
    this.expectedCalvingDate,
    this.lastServiceDate,
    this.sireTag,
    this.damTag,
    this.isMilking = false,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'breed': breed,
    'gender': gender,
    'dateOfBirth': dateOfBirth?.toIso8601String(),
    'colorMarkings': colorMarkings,
    'weight': weight,
    'isPregnant': isPregnant,
    'expectedCalvingDate': expectedCalvingDate?.toIso8601String(),
    'lastServiceDate': lastServiceDate?.toIso8601String(),
    'sireTag': sireTag,
    'damTag': damTag,
    'isMilking': isMilking,
    'imagePath': imagePath,
  };

  factory Animal.fromJson(Map<String, dynamic> json) => Animal(
    name: json['name'],
    breed: json['breed'],
    gender: json['gender'],
    dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
    colorMarkings: json['colorMarkings'],
    weight: (json['weight'] as num?)?.toDouble(),
    isPregnant: json['isPregnant'] ?? false,
    expectedCalvingDate: json['expectedCalvingDate'] != null ? DateTime.parse(json['expectedCalvingDate']) : null,
    lastServiceDate: json['lastServiceDate'] != null ? DateTime.parse(json['lastServiceDate']) : null,
    sireTag: json['sireTag'],
    damTag: json['damTag'],
    isMilking: json['isMilking'] ?? false,
    imagePath: json['imagePath'],
  );
}
