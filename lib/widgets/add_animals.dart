import 'dart:developer';
import 'dart:io';
import 'package:cattle_managementapp/pages/homepage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

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
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> saveAnimalToFirebase() async {
    String tag = nameController.text.trim();
    if (tag.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tag/Name cannot be empty")));
      return;
    }

    try {
      String? imageUrl = selectedImage != null ? await uploadImage(selectedImage!, tag) : null;

      final animalData = {
        'name': tag,
        'breed': breedController.text.trim(),
        'gender': genderController.text.trim(),
        // Save the DOB in yyyy-MM-dd format
        'dateOfBirth': dobController.text.isNotEmpty ? dobController.text : null,
        'colorMarkings': colorController.text.trim(),
        'weight': double.tryParse(weightController.text.trim()),
        'photoUrl': imageUrl,
      };

      await FirebaseFirestore.instance.collection('animals').add(animalData);
      Get.snackbar("Success", "Animal saved successfully");
      Get.offAll(() => Homepage());
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
            SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: genderController.text.isNotEmpty ? genderController.text : null,
              decoration: InputDecoration(labelText: "Gender"),
              items:
                  ['Male', 'Female'].map((gender) {
                    return DropdownMenuItem(value: gender, child: Text(gender));
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  genderController.text = value!;
                });
              },
            ),
            SizedBox(height: 10),

            TextField(controller: breedController, decoration: InputDecoration(labelText: "Breed")),
            SizedBox(height: 10),

            TextField(
              controller: dobController,
              decoration: InputDecoration(labelText: "Date of Birth"),
              readOnly: true,
              onTap: () => pickDate(dobController),
            ),
            SizedBox(height: 10),

            TextField(controller: colorController, decoration: InputDecoration(labelText: "Color/Markings")),
            SizedBox(height: 10),

            TextField(controller: weightController, decoration: InputDecoration(labelText: "Weight")),

            SizedBox(height: 16),
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
