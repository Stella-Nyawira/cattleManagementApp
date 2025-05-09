import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AnimalRecordsController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Save a breeding record
  Future<void> saveBreedingRecord({required String animalId, required Map<String, dynamic> breedingData}) async {
    await firestore.collection('animals').doc(animalId).collection('breedingRecords').add({
      ...breedingData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Fetch all breeding records for a specific animal
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

  /// You can later add similar methods for:
  /// - fetchHealthRecords()

  /// - fetchFeedingRecords()
  /// - fetchMilkProductionRecords()
}
