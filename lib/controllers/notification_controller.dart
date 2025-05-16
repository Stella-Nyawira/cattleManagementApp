import 'dart:developer';

import 'package:cattle_managementapp/model/notifications_model.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final notificationsList = <NotificationModel>[].obs;

  @override
  void onInit() {
    checkUpcomingEvents();
    super.onInit();
  }

  void checkUpcomingEvents() {
    DateTime now = DateTime.now();
    DateTime alertThreshold = now.add(Duration(days: 2)); // Look ahead two days

    firestore.collection('animals').get().then((snapshot) {
      for (var animal in snapshot.docs) {
        _checkBreedingRecords(animal.id, animal['name'], alertThreshold);
        _checkVaccinationRecords(animal.id, animal['name'], alertThreshold); // Pass DateTime directly
      }
    });
  }

  void _checkBreedingRecords(String animalId, String animalName, DateTime threshold) {
    firestore.collection('animals').doc(animalId).collection('breedingRecords').get().then((snapshot) {
      for (var doc in snapshot.docs) {
        if (doc['nextExpectedHeatDate'] != null && doc['nextExpectedHeatDate'] != "") {
          DateTime eventTime = DateTime.parse(doc['nextExpectedHeatDate']); // Convert from stored String

          if (eventTime.isBefore(threshold) && eventTime.isAfter(DateTime.now())) {
            _addNotification(doc.id, "Heat expected soon for $animalName ", eventTime);
          }
        }
      }
    });
  }

  void _checkVaccinationRecords(String animalId, String animalName, DateTime threshold) {
    firestore.collection('animals').doc(animalId).collection('vaccinationRecords').get().then((snapshot) {
      for (var doc in snapshot.docs) {
        if (doc['nextDueDate'] != null && doc['nextDueDate'] != "") {
          DateTime eventTime = DateTime.parse(doc['nextDueDate']); // Convert stored String to DateTime

          log("Vaccination check for $animalName on $eventTime"); // Debugging log

          if (eventTime.isBefore(threshold) && eventTime.isAfter(DateTime.now())) {
            _addNotification(doc.id, "Vaccination due soon for $animalName (${doc['vaccineName']})", eventTime);
          }
        }
      }
    });
  }

  void _addNotification(String id, String message, DateTime scheduledTime) {
    final notification = NotificationModel(id: id, message: message, scheduledTime: scheduledTime);
    notificationsList.add(notification);
  }
}
