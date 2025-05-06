import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddAnimalPage extends StatefulWidget {
  const AddAnimalPage({super.key});

  @override
  AddAnimalPageState createState() => AddAnimalPageState();
}

class AddAnimalPageState extends State<AddAnimalPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final breedController = TextEditingController();
  final genderController = TextEditingController();
  final weightController = TextEditingController();

  bool isPregnant = false;
  bool isMilking = false;
  DateTime? lastServiceDate;
  String? sireTag;
  String? damTag;
  String? imagePath;

  // Save Animal Data to Firestore
  Future<void> saveAnimal() async {
    final animalData = {
      'name': nameController.text,
      'breed': breedController.text,
      'gender': genderController.text,
      'weight': double.tryParse(weightController.text),
      'isPregnant': isPregnant,
      'isMilking': isMilking,
      'lastServiceDate': lastServiceDate?.toIso8601String(),
      'sireTag': sireTag,
      'damTag': damTag,
      'imagePath': imagePath,
    };

    try {
      await FirebaseFirestore.instance.collection('animals').add(animalData);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Animal added successfully!")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving animal data")));
    }
  }

  // Pick an image from gallery
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Animal')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              // Name
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Animal Name"),
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),
              // Breed
              TextFormField(controller: breedController, decoration: InputDecoration(labelText: "Breed")),
              // Gender
              TextFormField(controller: genderController, decoration: InputDecoration(labelText: "Gender")),
              // Weight
              TextFormField(
                controller: weightController,
                decoration: InputDecoration(labelText: "Weight (kg)"),
                keyboardType: TextInputType.number,
              ),
              // Is Pregnant
              CheckboxListTile(
                title: Text("Is Pregnant"),
                value: isPregnant,
                onChanged: (bool? value) {
                  setState(() {
                    isPregnant = value!;
                  });
                },
              ),
              // Sire Tag
              TextFormField(decoration: InputDecoration(labelText: "Sire Tag"), onChanged: (value) => sireTag = value),
              // Dam Tag
              TextFormField(decoration: InputDecoration(labelText: "Dam Tag"), onChanged: (value) => damTag = value),
              // Is Milking
              CheckboxListTile(
                title: Text("Is Milking"),
                value: isMilking,
                onChanged: (bool? value) {
                  setState(() {
                    isMilking = value!;
                  });
                },
              ),
              // Image Picker
              imagePath != null ? Image.file(File(imagePath!)) : Text("No photo selected"),
              IconButton(icon: Icon(Icons.camera_alt), onPressed: pickImage),
              // Save Button
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    saveAnimal();
                  }
                },
                child: Text('Save Animal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
