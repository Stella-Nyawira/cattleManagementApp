import 'dart:developer';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class AddAnimalPage extends StatefulWidget {
  const AddAnimalPage({super.key});

  @override
  AddAnimalPageState createState() => AddAnimalPageState();
}

class AddAnimalPageState extends State<AddAnimalPage> {
  final nameController = TextEditingController();
  final genderController = TextEditingController();
  final breedController = TextEditingController();
  final dobController = TextEditingController();
  final colorController = TextEditingController();
  final weightController = TextEditingController();

  final expectedBreedingCalvingController = TextEditingController();
  final breedingInseminationDateController = TextEditingController();

  bool isPregnant = false;
  bool isMilking = false;

  File? selectedImage;
  final picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> uploadImage(File image, String tag) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$tag.jpg';
      final ref = FirebaseStorage.instance.ref().child('animal_images/$fileName');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      log("Image upload error: $e");
      return null;
    }
  }

  Future<void> pickDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = picked.toLocal().toString().split(' ')[0];
    }
  }

  Future<void> saveAnimalToFirebase() async {
    String tag = nameController.text.trim(); // Used as doc ID
    if (tag.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tag/Name cannot be empty")));
      return;
    }

    try {
      String? imageUrl = selectedImage != null ? await uploadImage(selectedImage!, tag) : null;

      if (imageUrl == null) {
        log("Image uploaded successfully:$imageUrl");
      }
      final animalData = {
        'name': tag,
        'breed': breedController.text.trim(),
        'gender': genderController.text.trim(),
        'dateOfBirth': dobController.text.isNotEmpty ? DateTime.parse(dobController.text).toIso8601String() : null,
        'colorMarkings': colorController.text.trim(),
        'weight': double.tryParse(weightController.text.trim()),
        'isPregnant': isPregnant,
        'expectedCalvingDate':
            expectedBreedingCalvingController.text.isNotEmpty
                ? DateTime.parse(expectedBreedingCalvingController.text).toIso8601String()
                : null,
        'lastServiceDate':
            breedingInseminationDateController.text.isNotEmpty
                ? DateTime.parse(breedingInseminationDateController.text).toIso8601String()
                : null,
        'sireTag': '',
        'damTag': '',
        'isMilking': isMilking,
        'photoUrl': imageUrl,
      };

      await FirebaseFirestore.instance.collection('animals').doc(tag).set(animalData);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Animal saved successfully")));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving animal: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Animal")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Basic Information", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Name/Tag")),
            TextField(controller: genderController, decoration: InputDecoration(labelText: "Gender")),
            TextField(controller: breedController, decoration: InputDecoration(labelText: "Breed")),
            TextField(
              controller: dobController,
              decoration: InputDecoration(labelText: "Date of Birth"),
              readOnly: true,
              onTap: () => pickDate(dobController),
            ),
            TextField(controller: colorController, decoration: InputDecoration(labelText: "Color/Markings")),
            TextField(controller: weightController, decoration: InputDecoration(labelText: "Weight")),

            ExpansionTile(
              title: Text("Breeding Information", style: TextStyle(fontWeight: FontWeight.bold)),
              children: [
                SwitchListTile(
                  title: Text("Is Pregnant?"),
                  value: isPregnant,
                  onChanged: (val) => setState(() => isPregnant = val),
                ),
                if (isPregnant)
                  TextField(
                    controller: expectedBreedingCalvingController,
                    decoration: InputDecoration(labelText: "Expected Calving Date"),
                    readOnly: true,
                    onTap: () => pickDate(expectedBreedingCalvingController),
                  ),
                TextField(
                  controller: breedingInseminationDateController,
                  decoration: InputDecoration(labelText: "Date of Last Service/Insemination"),
                  readOnly: true,
                  onTap: () => pickDate(breedingInseminationDateController),
                ),
              ],
            ),

            ExpansionTile(
              title: Text("Milk Production", style: TextStyle(fontWeight: FontWeight.bold)),
              children: [
                SwitchListTile(
                  title: Text("Is a milking cow?"),
                  value: isMilking,
                  onChanged: (val) => setState(() => isMilking = val),
                ),
              ],
            ),

            Text("Photo Upload", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.lightBlue)),
            SizedBox(height: 8),
            InkWell(
              onTap: pickImage,
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  image:
                      selectedImage != null
                          ? DecorationImage(image: FileImage(selectedImage!), fit: BoxFit.cover)
                          : null,
                ),

                child: selectedImage == null ? Icon(Icons.add_a_photo, size: 40, color: Colors.grey[800]) : null,
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(onPressed: saveAnimalToFirebase, child: Text("Save")),
          ],
        ),
      ),
    );
  }
}
