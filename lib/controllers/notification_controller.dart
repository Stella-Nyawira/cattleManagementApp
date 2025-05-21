import 'dart:developer';

import 'package:cattle_managementapp/model/notifications_model.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final notificationsList = <NotificationModel>[].obs;

  @override
  void onInit() {
    notificationsAlert();
    super.onInit();
  }

  void notificationsAlert() {
    DateTime now = DateTime.now();
    DateTime alertThreshold = now.add(Duration(days: 2)); // Look ahead two days

    firestore.collection('animals').get().then((snapshot) {
      for (var animal in snapshot.docs) {
        _checkBreedingRecords(animal.id, animal['name'], alertThreshold);
        _checkVaccinationRecords(animal.id, animal['name'], alertThreshold); // Pass DateTime directly
        // Pass DateTime directly
      }
      _checkUpcomingEvents(alertThreshold);
    });
  }

  void _checkBreedingRecords(String animalId, String animalName, DateTime threshold) {
    firestore.collection('animals').doc(animalId).collection('breedingRecords').get().then((snapshot) {
      for (var doc in snapshot.docs) {
        log('BreedingRecord doc data: ${doc.data()}');
        if (doc['nextExpectedHeatDate'] != null && doc['nextExpectedHeatDate'] != "") {
          DateTime eventTime = DateTime.parse(doc['nextExpectedHeatDate']);
          log('Parsed heat date: $eventTime'); // Convert from stored String

          if (eventTime.isBefore(threshold) && eventTime.isAfter(DateTime.now())) {
            _addNotification(doc.id, "Heat expected soon for $animalName ", eventTime);
            log('Notification added for heat date');
          }
        }
      }
    });
  }

  void _checkVaccinationRecords(String animalId, String animalName, DateTime threshold) {
    firestore.collection('animals').doc(animalId).collection('vaccinationRecords').get().then((snapshot) {
      log('VaccinationRecords for $animalName: ${snapshot.docs.length} found');
      for (var doc in snapshot.docs) {
        log('VaccinationRecord doc data: ${doc.data()}');
        if (doc['nextDueDate'] != null && doc['nextDueDate'] != "") {
          DateTime eventTime = DateTime.parse(doc['nextDueDate']); // Convert stored String to DateTime

          log("Parsed vaccination date for $animalName: $eventTime"); // Debugging log

          if (eventTime.isBefore(threshold) && eventTime.isAfter(DateTime.now())) {
            _addNotification(doc.id, "Vaccination due soon for $animalName (${doc['vaccineName']})", eventTime);
            log('Notification added for vaccination');
          }
        }
      }
    });
  }

  void _checkUpcomingEvents(DateTime threshold) {
    firestore.collection('upcomingEvents').get().then((snapshot) {
      for (var doc in snapshot.docs) {
        log('UpcomingEvent doc data: ${doc.data()}');

        String eventDateStr = doc['eventDate'];
        if (eventDateStr.isNotEmpty) {
          DateTime eventDate = DateTime.parse(eventDateStr);

          if (eventDate.isBefore(threshold) && eventDate.isAfter(DateTime.now())) {
            final message = "Upcoming event for ${doc['animalName']}: ${doc['eventType']}";
            _addNotification(doc.id, message, eventDate);
            log('Notification added for upcoming event: $message');
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
