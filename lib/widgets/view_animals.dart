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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    animalsFuture = fetchAnimals();
  }

  Future<List<DocumentSnapshot>> fetchAnimals() async {
    var querySnapshot = await FirebaseFirestore.instance.collection('animals').get();
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

  Widget _buildImageWidget(String urlOrPath) {
    if (urlOrPath.startsWith('http')) {
      return Image.network(
        urlOrPath,
        width: 80,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _fallbackImage();
        },
      );
    } else {
      return Image.file(
        File(urlOrPath),
        width: 80,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _fallbackImage();
        },
      );
    }
  }

  Widget _fallbackImage() {
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

      body: FutureBuilder<List<DocumentSnapshot>>(
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

          var animals = snapshot.data!;

          return ListView.builder(
            itemCount: animals.length,
            itemBuilder: (context, index) {
              var animal = animals[index];
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
                      photoUrl != null && photoUrl.toString().isNotEmpty
                          ? ClipRRect(borderRadius: BorderRadius.circular(8), child: _buildImageWidget(photoUrl))
                          : Container(
                            width: 80,
                            height: 100,
                            color: Colors.grey[300],
                            child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey[600]),
                          ),
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
    );
  }
}
