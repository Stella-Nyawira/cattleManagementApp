import 'dart:developer';
import 'dart:io';
import 'package:cattle_managementapp/controllers/animalRecords_controller.dart';
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

  String? selectedBreed;
  bool isOtherBreed = false;
  final otherBreedController = TextEditingController();

  File? selectedImage;
  final picker = ImagePicker();

  bool isSaving = false; // to control loader and disable button

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
    if (isSaving) return; // prevent multiple calls

    String tag = nameController.text.trim();
    if (tag.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tag/Name cannot be empty")));
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      String? imageUrl = selectedImage != null ? await uploadImage(selectedImage!, tag) : null;

      final animalData = {
        'name': tag,
        'breed': breedController.text.trim(),
        'gender': genderController.text.trim(),
        'dateOfBirth': dobController.text.isNotEmpty ? dobController.text : null,
        'colorMarkings': colorController.text.trim(),
        'weight': double.tryParse(weightController.text.trim()),
        'photoUrl': imageUrl,
      };

      await FirebaseFirestore.instance.collection('animals').add(animalData);
      Get.snackbar("Success", "Animal saved successfully");
      final animalRecordsController = Get.find<AnimalRecordsController>();
      await animalRecordsController.fetchAllAnimals(); // Refresh the list of animals
      Get.offAll(() => const Homepage());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving animal: $e")));
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    genderController.dispose();
    breedController.dispose();
    dobController.dispose();
    colorController.dispose();
    weightController.dispose();
    otherBreedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Animal")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Basic Information", style: TextStyle(fontWeight: FontWeight.bold)),

            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name/Tag")),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: genderController.text.isNotEmpty ? genderController.text : null,
              decoration: const InputDecoration(labelText: "Gender"),
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
            const SizedBox(height: 10),

            // Breed dropdown + text input combo
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: isOtherBreed ? 'Other' : selectedBreed,
                  decoration: const InputDecoration(labelText: "Breed"),
                  items:
                      ['Zebu', 'Freshian', 'Jersey', 'Guernsey', 'Ayrshire', 'Brown Swiss', 'Holstein', 'Other'].map((
                        breed,
                      ) {
                        return DropdownMenuItem<String>(value: breed, child: Text(breed));
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      if (value == 'Other') {
                        isOtherBreed = true;
                        selectedBreed = null;
                        breedController.text = '';
                      } else {
                        isOtherBreed = false;
                        selectedBreed = value;
                        breedController.text = value ?? '';
                      }
                    });
                  },
                ),
                if (isOtherBreed) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: otherBreedController,
                    decoration: const InputDecoration(labelText: "Enter Breed", hintText: "Type breed here"),
                    onChanged: (val) {
                      breedController.text = val;
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),

            TextField(
              controller: dobController,
              decoration: const InputDecoration(labelText: "Date of Birth"),
              readOnly: true,
              onTap: () => pickDate(dobController),
            ),
            const SizedBox(height: 10),

            TextField(controller: colorController, decoration: const InputDecoration(labelText: "Color/Markings")),
            const SizedBox(height: 10),

            TextField(controller: weightController, decoration: const InputDecoration(labelText: "Weight")),

            const SizedBox(height: 16),
            const Text("Photo Upload", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.lightBlue)),
            const SizedBox(height: 8),

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
            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: isSaving ? null : saveAnimalToFirebase,
              child:
                  isSaving
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                      : const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
