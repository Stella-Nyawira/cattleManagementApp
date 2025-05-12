import 'dart:developer';

import 'package:cattle_managementapp/model/milkProduction_record_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:cattle_managementapp/model/healthRecord_model.dart';

class AnimalRecordsController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> saveBreedingRecord({required String animalId, required Map<String, dynamic> breedingData}) async {
    await firestore.collection('animals').doc(animalId).collection('breedingRecords').add({
      ...breedingData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> fetchBreedingRecords(String animalId) async {
    final snapshot =
        await firestore
            .collection('animals')
            .doc(animalId)
            .collection('breedingRecords')
            .orderBy('createdAt', descending: true)
            .get();

    return snapshot.docs.map((doc) {
      return {'id': doc.id, ...doc.data()};
    }).toList();
  }

  Future<void> saveVaccinationRecord(String animalId, Map<String, dynamic> data) async {
    await firestore.collection('animals').doc(animalId).collection('vaccinationRecords').add(data);
  }

  Future<List<Map<String, dynamic>>> fetchVaccinationRecords(String animalId) async {
    final snapshot =
        await firestore
            .collection('animals')
            .doc(animalId)
            .collection('vaccinationRecords')
            .orderBy('dateAdministered', descending: true)
            .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> saveFeedingRecord(String animalId, Map<String, dynamic> feedingData) async {
    try {
      await firestore.collection('animals').doc(animalId).collection('feedingRecords').add(feedingData);
    } catch (e) {
      log('Error saving feeding record: $e');
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> fetchFeedingRecords(String animalId) async {
    try {
      final snapshot =
          await firestore
              .collection('animals')
              .doc(animalId)
              .collection('feedingRecords')
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      log('Error fetching feeding records: $e');
      return [];
    }
  }

  Future<void> saveMilkRecord(String animalId, Map<String, dynamic> milkData) async {
    await firestore.collection('animals').doc(animalId).collection('milkProductionRecords').add({
      ...milkData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<MilkProductionRecord>> fetchMilkProductionRecords(String animalId) async {
    final snapshot =
        await firestore
            .collection('animals')
            .doc(animalId)
            .collection('milkProductionRecords')
            .orderBy('date', descending: true)
            .get();

    return snapshot.docs.map((doc) => MilkProductionRecord.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> saveHealthRecord(String animalId, Map<String, dynamic> data) async {
    await firestore.collection('animals').doc(animalId).collection('healthRecords').add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<HealthRecord>> fetchHealthRecords(String animalId) async {
    final snapshot =
        await firestore
            .collection('animals')
            .doc(animalId)
            .collection('healthRecords')
            .orderBy('createdAt', descending: true)
            .get();

    return snapshot.docs.map((doc) => HealthRecord.fromMap(doc.data(), doc.id)).toList();
  }

  /// - fetchMilkProductionRecords()
}
