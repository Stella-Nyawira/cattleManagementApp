import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchAnimals extends StatelessWidget {
  const SearchAnimals({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Animals')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(labelText: 'Search by Name or Breed', border: OutlineInputBorder()),
              onChanged: (value) {
                // Call the search function from the controller
                // animalRecordsController.searchAnimals(value);
              },
            ),
          ),
          Expanded(
            child: Obx(() {
              // Replace with your actual list of animals
              final animals = []; // animalRecordsController.searchResults.value;

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
