import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cattle_managementapp/controllers/animalRecords_controller.dart';
import 'package:cattle_managementapp/pages/recordTypes_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
            final data = animal.data() as Map<String, dynamic>;
            final name = (data['name'] ?? '').toString().toLowerCase();
            final breed = (data['breed'] ?? '').toString().toLowerCase();
            final searchQuery = query.toLowerCase();
            return name.contains(searchQuery) || breed.contains(searchQuery);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Animals")),
      body: Column(
        children: [
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
                const SizedBox(width: 8),
                Expanded(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isSearchActive ? 1.0 : 0.5,
                    child: IgnorePointer(
                      ignoring: !isSearchActive,
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
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                        ),
                        onChanged: filterAnimals,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                    final data = animal.data() as Map<String, dynamic>;
                    String? photoUrl = data['photoUrl'];

                    Widget imageWidget;
                    if (photoUrl != null && photoUrl.isNotEmpty) {
                      if (photoUrl.startsWith('http')) {
                        imageWidget = CachedNetworkImage(
                          imageUrl: photoUrl,
                          width: 80,
                          height: 100,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => const SizedBox(
                                width: 80,
                                height: 100,
                                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              ),
                          errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 40),
                        );
                      } else {
                        imageWidget = Image.file(
                          File(photoUrl),
                          width: 80,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40),
                        );
                      }
                    } else {
                      imageWidget = Container(
                        width: 80,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                      );
                    }

                    return InkWell(
                      /* onTap: () {
                        Get.to(() => RecordTypesPage(animalId: animal.id, animalName: data['name']));
                      }, */
                      onTap: () async {
                        bool? result = await Get.to(
                          () => RecordTypesPage(animalId: animal.id, animalName: data['name']),
                        );
                        if (result == true) {
                          Get.find<AnimalRecordsController>().fetchAllAnimals(); // ✅ Refresh animal list again
                        }
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
                            ClipRRect(borderRadius: BorderRadius.circular(8), child: imageWidget),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['name'] ?? 'Unnamed Animal',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Breed: ${data['breed'] ?? 'Unknown'}'),
                                  Text('Gender: ${data['gender'] ?? 'Unknown'}'),
                                  Text('Weight: ${data['weight']?.toString() ?? 'Unknown'} kg'),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => confirmDelete(animal.id, data['name'] ?? 'this animal'),
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
