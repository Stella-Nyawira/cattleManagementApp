import 'package:cattle_managementapp/widgets/records/vaccination_records_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cattle_managementapp/controllers/animalRecords_controller.dart';

class AllAnimalVaccinesPage extends StatefulWidget {
  const AllAnimalVaccinesPage({Key? key}) : super(key: key);

  @override
  _AllAnimalVaccinesPageState createState() => _AllAnimalVaccinesPageState();
}

class _AllAnimalVaccinesPageState extends State<AllAnimalVaccinesPage> {
  final AnimalRecordsController recordsController = Get.find();

  // Track which animals are expanded (to fetch records lazily if needed)
  final Set<String> expandedAnimals = {};

  @override
  void initState() {
    super.initState();
    // Fetch all animals initially
    recordsController.fetchAllAnimals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Animals Vaccination Overview')),
      body: Obx(() {
        final animals = recordsController.allAnimals;

        if (animals.isEmpty) {
          return const Center(child: Text('No animals found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: animals.length,
          itemBuilder: (context, index) {
            final animal = animals[index];
            final animalId = animal.id;
            final animalName = animal['name'] as String;

            final isExpanded = expandedAnimals.contains(animalId);

            // Fetch vaccinations for this animal when expanded
            if (isExpanded && !recordsController.vaccinationRecordsMap.containsKey(animalId)) {
              recordsController.fetchVaccinationRecords(animalId);
            }

            final vaccinations = recordsController.vaccinationRecordsMap[animalId] ?? [];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ExpansionTile(
                key: PageStorageKey(animalId),
                title: Text(animalName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: Text('ID: $animalId'),
                initiallyExpanded: isExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    if (expanded) {
                      expandedAnimals.add(animalId);
                    } else {
                      expandedAnimals.remove(animalId);
                    }
                  });
                },
                children:
                    vaccinations.isEmpty
                        ? [
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No vaccination records for this animal.'),
                          ),
                        ]
                        : vaccinations.map<Widget>((record) {
                          return ListTile(
                            title: Text(record['vaccineName'] ?? 'Unknown Vaccine'),
                            subtitle: Text(
                              'Administered: ${record['dateAdministered'] ?? '-'}\nNext Due: ${record['nextDueDate'] ?? '-'}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => VaccinationRecordsForm(
                                          animalId: animalId,
                                          animalName: animalName,
                                          existingRecord: record,
                                        ),
                                  ),
                                ).then((_) {
                                  // Refresh this animal's vaccination records after editing
                                  recordsController.fetchVaccinationRecords(animalId);
                                });
                              },
                            ),
                          );
                        }).toList(),
              ),
            );
          },
        );
      }),
    );
  }
}
