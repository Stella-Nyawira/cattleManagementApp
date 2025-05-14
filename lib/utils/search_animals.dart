import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cattle_managementapp/controllers/animalRecords_controller.dart';
import 'package:cattle_managementapp/pages/recordTypes_page.dart';

class SearchAnimals extends StatelessWidget {
  SearchAnimals({super.key});

  final animalRecordsController = Get.put(AnimalRecordsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(labelText: 'Search by Name or Breed', border: OutlineInputBorder()),
              onChanged: (value) {
                animalRecordsController.searchAnimals(value);
              },
            ),
          ),
          Expanded(
            child: Obx(() {
              final animals = animalRecordsController.searchResults;

              if (animalRecordsController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (animals.isEmpty) {
                return const Center(child: Text('No animals found'));
              }

              return ListView.builder(
                itemCount: animals.length,
                itemBuilder: (context, index) {
                  final animal = animals[index];

                  return ListTile(
                    title: Text(animal['name'] ?? 'Unknown'),
                    subtitle: Text(animal['breed'] ?? 'Unknown'),
                    onTap: () {
                      Get.to(() => RecordTypesPage(animalId: animal.id, animalName: animal['name'] ?? 'Animal'));
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
