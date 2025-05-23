import 'dart:developer';
import 'package:cattle_managementapp/model/calving_records_model.dart';
import 'package:cattle_managementapp/model/events_model.dart';
import 'package:cattle_managementapp/model/milkProduction_record_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AnimalRecordsController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  var allAnimals = <DocumentSnapshot>[].obs;
  var searchResults = <DocumentSnapshot>[].obs;
  var isLoading = false.obs;
  var searchTerm = ''.obs;
  var totalAnimals = 0.obs;

  var calvingRecords = <CalvingRecord>[].obs;
  var vaccinationRecords = <Map<String, dynamic>>[].obs;
  var vaccinationRecordsMap = <String, List<Map<String, dynamic>>>{}.obs;
  var healthRecords = <Map<String, dynamic>>[].obs;

  RxMap<String, double> individualMilkProduction = <String, double>{}.obs;
  RxDouble totalMilkProduced = 0.0.obs;
  RxList<UpcomingEvent> upcomingEvents = <UpcomingEvent>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllAnimals();
    fetchAllVaccinationRecords();
    fetchAllMilkRecords();
  }

  Future<void> fetchAllAnimals() async {
    /* try {
      isLoading.value = true;
      final snapshot = await firestore.collection('animals').get();
      allAnimals.value = snapshot.docs;
      searchResults.value = snapshot.docs;
      totalAnimals.value = snapshot.docs.length;
      // Check for notifications after fetching animals
    } catch (e) {
      log('Error fetching animals: $e');
    } finally {
      isLoading.value = false;
    } */
    firestore.collection('animals').snapshots().listen((snapshot) {
      allAnimals.value = snapshot.docs;
      searchResults.value = snapshot.docs;
      totalAnimals.value = snapshot.docs.length;
    });
  }

  void searchAnimals(String query) {
    searchTerm.value = query;

    if (query.isEmpty) {
      searchResults.value = allAnimals;
    } else {
      searchResults.value =
          allAnimals.where((animal) {
            final name = (animal['name'] ?? '').toString().toLowerCase();
            final breed = (animal['breed'] ?? '').toString().toLowerCase();
            return name.contains(query.toLowerCase()) || breed.contains(query.toLowerCase());
          }).toList();
    }
  }

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

  Future<void> updateBreedingRecord({
    required String animalId,
    required String recordId,
    required Map<String, dynamic> updatedData,
  }) async {
    try {
      await firestore.collection('animals').doc(animalId).collection('breedingRecords').doc(recordId).update({
        ...updatedData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log('Failed to update breeding record: $e');
      throw Exception('Failed to update breeding record');
    }
  }

  Future<void> saveCalvingRecord(CalvingRecord record) async {
    final doc = await firestore.collection('animals').doc(record.animalId).collection('calving').add(record.toMap());
    record.id = doc.id;

    // 🔄 Fetch parent animal
    final parentSnapshot = await FirebaseFirestore.instance.collection('animals').doc(record.animalId).get();

    if (parentSnapshot.exists) {
      final parentData = parentSnapshot.data()!;
      final parentBreed = parentData['breed'] ?? 'Unknown';

      // 🐮 Create new calf animal
      final calfData = {
        'name': record.calfName,
        'gender': record.calfGender,
        'birthDate': record.birthDate,
        'breed': parentBreed,
        'motherId': record.animalId,
        'isCalf': true,
        'createdAt': FieldValue.serverTimestamp(),
      };
      log('Calf data being saved: $calfData');

      await FirebaseFirestore.instance.collection('animals').add(calfData);
      await fetchAllAnimals();
    }
  }

  Future<void> fetchCalvingRecords(String animalId) async {
    final snapshot = await firestore.collection('animals').doc(animalId).collection('calving').get();

    calvingRecords.value = snapshot.docs.map((doc) => CalvingRecord.fromMap(doc.id, doc.data())).toList();
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

  Future<void> loadVaccinationRecords(String animalId) async {
    final records = await fetchVaccinationRecords(animalId);
    vaccinationRecords.value = records;
  }

  /* Future<void> saveFeedingRecord(String animalId, Map<String, dynamic> feedingData) async {
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
 */
  Future<void> saveMilkRecord(String animalId, Map<String, dynamic> milkData) async {
    await firestore.collection('animals').doc(animalId).collection('milkProductionRecords').add({
      ...milkData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<MilkProductionRecord>> fetchAllMilkRecords() async {
    final snapshot = await firestore.collectionGroup('milkProductionRecords').get();
    return snapshot.docs.map((doc) => MilkProductionRecord.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> updateMilkOverview() async {
    try {
      totalMilkProduced.value = 0;
      individualMilkProduction.clear();

      final animalsSnapshot = await FirebaseFirestore.instance.collection('animals').get();

      for (var animalDoc in animalsSnapshot.docs) {
        double animalTotal = 0;

        final milkRecordsSnapshot =
            await FirebaseFirestore.instance
                .collection('animals')
                .doc(animalDoc.id)
                .collection('milkProductionRecords')
                .get();

        for (var milkDoc in milkRecordsSnapshot.docs) {
          var data = milkDoc.data();

          double morning = (data['morning'] ?? 0).toDouble();
          double afternoon = (data['afternoon'] ?? 0).toDouble();
          double evening = (data['evening'] ?? 0).toDouble();

          animalTotal += morning + afternoon + evening;
          totalMilkProduced.value += morning + afternoon + evening;
        }

        individualMilkProduction[animalDoc['name']] = animalTotal;
      }

      log('Milk overview updated successfully');
    } catch (e) {
      log(' Error fetching milk data: $e');
    }
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

  Future<void> addHealthRecord(String animalId, Map<String, dynamic> data) async {
    try {
      await firestore.collection('animals').doc(animalId).collection('healthRecords').add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await fetchHealthRecords(animalId); // Refresh after saving
    } catch (e) {
      log('Error adding health record: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchHealthRecords(String animalId) async {
    try {
      final snapshot =
          await firestore
              .collection('animals')
              .doc(animalId)
              .collection('healthRecords')
              .orderBy('createdAt', descending: true)
              .get();

      final records =
          snapshot.docs.map((doc) {
            var data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

      healthRecords.value = records;

      return records;
    } catch (e) {
      log('Error fetching health records: $e');
      healthRecords.value = [];
      return [];
    }
  }

  Future<void> deleteBreedingRecord({required String animalId, required String recordId}) async {
    try {
      await firestore.collection('animals').doc(animalId).collection('breedingRecords').doc(recordId).delete();
    } catch (e) {
      throw Exception('Failed to delete record: $e');
    }
  }

  Future<void> deleteCalvingRecord({required String animalId, required String recordId}) async {
    try {
      await firestore.collection('animals').doc(animalId).collection('calving').doc(recordId).delete();
      await fetchCalvingRecords(animalId); // Refresh the records list
    } catch (e) {
      throw Exception('Failed to delete calving record: $e');
    }
  }

  // Fetch all vaccine records across all animals
  Future<void> fetchAllVaccinationRecords() async {
    final snapshot = await firestore.collectionGroup('vaccinationRecords').get();

    final allRecords =
        snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id, // add doc ID here
            ...data,
            'animalId': doc.reference.parent.parent?.id,
          };
        }).toList();

    vaccinationRecords.value = allRecords;

    // Group by animalId
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (var record in allRecords) {
      final animalId = record['animalId'] ?? 'unknown';
      grouped.putIfAbsent(animalId, () => []).add(record);
    }
    vaccinationRecordsMap.value = grouped;
  }

  Future<void> deleteHealthRecord({required String animalId, required String recordId}) async {
    try {
      await firestore.collection('animals').doc(animalId).collection('healthRecords').doc(recordId).delete();
    } catch (e) {
      log('Error deleting health record: $e');
      throw Exception('Failed to delete health record');
    }
  }

  Future<void> fetchUpcomingEvents() async {
    final snapshot = await FirebaseFirestore.instance.collection('upcomingEvents').orderBy('eventDate').get();
    upcomingEvents.value = snapshot.docs.map((doc) => UpcomingEvent.fromMap(doc.data())).toList();
  }

  Future<void> addUpcomingEvent(UpcomingEvent event) async {
    await FirebaseFirestore.instance.collection('upcomingEvents').doc(event.id).set(event.toMap());
    await fetchUpcomingEvents(); // Refresh after adding
  }

  Future<void> deleteUpcomingEvent(String eventId) async {
    try {
      await FirebaseFirestore.instance.collection('upcomingEvents').doc(eventId).delete();
      upcomingEvents.removeWhere((event) => event.id == eventId); // Update UI instantly
    } catch (e) {
      log('Error deleting event: $e');
    }
  }
}
