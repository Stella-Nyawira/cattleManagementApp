import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AnimalDetailsController extends GetxController {
  final String animalId;

  AnimalDetailsController(this.animalId);

  var breedingRecords = <DocumentSnapshot>[].obs;
  var treatmentRecords = <DocumentSnapshot>[].obs;
  var milkingRecords = <DocumentSnapshot>[].obs;

  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllDetails();
  }

  Future<void> fetchAllDetails() async {
    isLoading.value = true;
    await Future.wait([fetchBreedingRecords(), fetchTreatmentRecords(), fetchMilkingRecords()]);
    isLoading.value = false;
  }

  Future<void> fetchBreedingRecords() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('animals')
            .doc(animalId)
            .collection('breeding')
            .orderBy('serviceDate', descending: true)
            .get();
    breedingRecords.value = snapshot.docs;
  }

  Future<void> fetchTreatmentRecords() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('animals')
            .doc(animalId)
            .collection('treatments')
            .orderBy('date', descending: true)
            .get();
    treatmentRecords.value = snapshot.docs;
  }

  Future<void> fetchMilkingRecords() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('animals')
            .doc(animalId)
            .collection('milking')
            .orderBy('date', descending: true)
            .get();
    milkingRecords.value = snapshot.docs;
  }
}
