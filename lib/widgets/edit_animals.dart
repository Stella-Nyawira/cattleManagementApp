import 'dart:io';
import 'package:cattle_managementapp/controllers/animalRecords_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditAnimalPage extends StatefulWidget {
  final String animalId;

  const EditAnimalPage({super.key, required this.animalId});

  @override
  State<EditAnimalPage> createState() => _EditAnimalPageState();
}

class _EditAnimalPageState extends State<EditAnimalPage> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController colorMarkingsController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController photoUrlController = TextEditingController();

  String? selectedGender;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAnimalDetails();
  }

  Future<void> fetchAnimalDetails() async {
    final doc = await FirebaseFirestore.instance.collection('animals').doc(widget.animalId).get();
    if (doc.exists) {
      final data = doc.data()!;
      nameController.text = data['name'] ?? '';
      breedController.text = data['breed'] ?? '';
      dobController.text = data['dateOfBirth'] ?? '';
      selectedGender = data['gender'] ?? '';
      colorMarkingsController.text = data['colorMarkings'] ?? '';
      weightController.text = data['weight']?.toString() ?? '';
      photoUrlController.text = data['photoUrl'] ?? '';
    }
    setState(() => isLoading = false);
  }

  Future<void> updateAnimalDetails() async {
    if (formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('animals').doc(widget.animalId).update({
        'name': nameController.text.trim(),
        'breed': breedController.text.trim(),
        'dateOfBirth': dobController.text.isNotEmpty ? dobController.text.trim() : null,
        'gender': selectedGender ?? '',
        'colorMarkings': colorMarkingsController.text.trim(),
        'weight': double.tryParse(weightController.text.trim()) ?? 0,
        'photoUrl': photoUrlController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Animal details updated successfully!'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      // await Future.delayed(const Duration(milliseconds: 500));
      Get.find<AnimalRecordsController>().fetchAllAnimals();
      Get.back(result: true);
    }
  }

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(dobController.text) ?? DateTime(2020),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dobController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        photoUrlController.text = pickedFile.path;
      });
    }
  }

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Animal Details')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: formKey,
                  child: ListView(
                    children: [
                      if (photoUrlController.text.isNotEmpty)
                        Row(
                          children: [
                            GestureDetector(
                              onTap: pickImage,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey),
                                  image: DecorationImage(
                                    image:
                                        photoUrlController.text.startsWith('http')
                                            ? NetworkImage(photoUrlController.text)
                                            : FileImage(File(photoUrlController.text)) as ImageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            IconButton(icon: const Icon(Icons.edit), onPressed: pickImage),
                          ],
                        ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: nameController,
                        decoration: inputDecoration('Animal Name'),
                        validator: (value) => value!.isEmpty ? 'Enter a name' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(controller: breedController, decoration: inputDecoration('Breed')),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: pickDate,
                        child: AbsorbPointer(
                          child: TextFormField(controller: dobController, decoration: inputDecoration('Date of Birth')),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedGender,
                        decoration: inputDecoration('Gender'),
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
                          DropdownMenuItem(value: 'Female', child: Text('Female')),
                        ],
                        onChanged: (value) {
                          setState(() => selectedGender = value);
                        },
                        validator: (value) => value == null || value.isEmpty ? 'Select gender' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(controller: colorMarkingsController, decoration: inputDecoration('Color Markings')),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: weightController,
                        decoration: inputDecoration('Weight (kg)'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(onPressed: updateAnimalDetails, child: const Text('Save Changes')),
                    ],
                  ),
                ),
              ),
    );
  }
}
