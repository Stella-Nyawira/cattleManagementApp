import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewAnimalsPage extends StatefulWidget {
  const ViewAnimalsPage({super.key});

  @override
  _ViewAnimalsPageState createState() => _ViewAnimalsPageState();
}

class _ViewAnimalsPageState extends State<ViewAnimalsPage> {
  late Future<List<DocumentSnapshot>> animalsFuture;

  @override
  void initState() {
    super.initState();
    animalsFuture = fetchAnimals();
  }

  Future<List<DocumentSnapshot>> fetchAnimals() async {
    var querySnapshot = await FirebaseFirestore.instance.collection('animals').get();
    return querySnapshot.docs;
  }

  Future<void> deleteAnimal(String animalId) async {
    await FirebaseFirestore.instance.collection('animals').doc(animalId).delete();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Animal deleted successfully")));
    setState(() {
      animalsFuture = fetchAnimals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("All Animals")),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: animalsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Something went wrong. Please try again later."));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No animals found. Add some animals."));
          }

          var animals = snapshot.data!;

          return ListView.builder(
            itemCount: animals.length,
            itemBuilder: (context, index) {
              var animal = animals[index];
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ListTile(
                  title: Text(
                    animal['name'] ?? 'Unnamed Animal',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2),
                      Text('Breed: ${animal['breed'] ?? 'Unknown'}'),
                      Text('Gender: ${animal['gender'] ?? 'Unknown'}'),
                      Text('Weight: ${animal['weight']?.toString() ?? 'Unknown'} kg'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteAnimal(animal.id),
                  ),
                  onTap: () {},
                ),
              );
            },
          );
        },
      ),
    );
  }
}
