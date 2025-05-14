import 'package:cattle_managementapp/controllers/animalRecords_controller.dart';
import 'package:cattle_managementapp/pages/recordTypes_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

class ViewAnimalsPage extends StatefulWidget {
  const ViewAnimalsPage({super.key});

  @override
  _ViewAnimalsPageState createState() => _ViewAnimalsPageState();
}

class _ViewAnimalsPageState extends State<ViewAnimalsPage> {
  late Future<List<DocumentSnapshot>> animalsFuture;
  final AnimalRecordsController animalRecordsController = Get.put(AnimalRecordsController());
  final TextEditingController searchController = TextEditingController();
  bool isSearchActive = false;
  List<DocumentSnapshot> allAnimals = [];
  List<DocumentSnapshot> filteredAnimals = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    animalsFuture = fetchAnimals();
  }

  Future<List<DocumentSnapshot>> fetchAnimals() async {
    var querySnapshot = await FirebaseFirestore.instance.collection('animals').get();
    allAnimals = querySnapshot.docs;
    filteredAnimals = allAnimals;
    return querySnapshot.docs;
  }

  Future<void> deleteAnimal(String animalId) async {
    await FirebaseFirestore.instance.collection('animals').doc(animalId).delete();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Animal deleted successfully")));

    setState(() {
      animalsFuture = fetchAnimals();
    });
  }

  void confirmDelete(String animalId, String animalName) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Deletion'),
            content: Text('Are you sure you want to delete "$animalName"?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await deleteAnimal(animalId);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void filterAnimals(String query) {
    setState(() {
      filteredAnimals =
          allAnimals.where((animal) {
            final name = animal['name']?.toLowerCase() ?? '';
            final breed = animal['breed']?.toLowerCase() ?? '';
            final searchQuery = query.toLowerCase();
            return name.contains(searchQuery) || breed.contains(searchQuery);
          }).toList();
    });
  }

  Widget buildImageWidget(String urlOrPath) {
    if (urlOrPath.startsWith('http')) {
      return Image.network(
        urlOrPath,
        width: 80,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return fallbackImage();
        },
      );
    } else {
      return Image.file(
        File(urlOrPath),
        width: 80,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return fallbackImage();
        },
      );
    }
  }

  Widget fallbackImage() {
    return Container(
      width: 80,
      height: 100,
      color: Colors.grey[300],
      child: Icon(Icons.broken_image, size: 40, color: Colors.grey[600]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Animals")),
      body: Column(
        children: [
          // Search field with an icon just below the app bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(isSearchActive ? Icons.close : Icons.search, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      isSearchActive = !isSearchActive;
                      if (!isSearchActive) {
                        searchController.clear();
                        filteredAnimals = allAnimals;
                      }
                    });
                  },
                ),
                if (isSearchActive)
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by Name or Breed',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        prefixIcon: const Icon(Icons.search),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      onChanged: (value) {
                        filterAnimals(value);
                      },
                    ),
                  ),
              ],
            ),
          ),
          // Displaying the animal list
          Expanded(
            child: FutureBuilder<List<DocumentSnapshot>>(
              future: animalsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text("Something went wrong. Please try again later."));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No animals found. Add some animals."));
                }

                return ListView.builder(
                  itemCount: filteredAnimals.length,
                  itemBuilder: (context, index) {
                    var animal = filteredAnimals[index];
                    String? photoUrl = animal['photoUrl'];

                    return InkWell(
                      onTap: () {
                        Get.to(() => RecordTypesPage(animalId: animal.id, animalName: animal['name']));
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            photoUrl != null && photoUrl.isNotEmpty
                                ? ClipRRect(borderRadius: BorderRadius.circular(8), child: buildImageWidget(photoUrl))
                                : fallbackImage(),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    animal['name'] ?? 'Unnamed Animal',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Breed: ${animal['breed'] ?? 'Unknown'}'),
                                  Text('Gender: ${animal['gender'] ?? 'Unknown'}'),
                                  Text('Weight: ${animal['weight']?.toString() ?? 'Unknown'} kg'),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => confirmDelete(animal.id, animal['name'] ?? 'this animal'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
