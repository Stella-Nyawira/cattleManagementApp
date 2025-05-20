import 'package:cattle_managementapp/controllers/animalRecords_controller.dart';
import 'package:cattle_managementapp/model/events_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpcomingEventsPage extends StatelessWidget {
  final AnimalRecordsController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    controller.fetchUpcomingEvents();

    return Scaffold(
      appBar: AppBar(title: const Text("Upcoming Events")),
      body: Obx(() {
        if (controller.upcomingEvents.isEmpty) {
          return const Center(child: Text("No upcoming events recorded."));
        }
        return ListView.builder(
          itemCount: controller.upcomingEvents.length,
          itemBuilder: (context, index) {
            final event = controller.upcomingEvents[index];
            return ListTile(
              leading: const Icon(Icons.event),
              title: Text(event.eventType),
              subtitle: Text("${event.animalName} - ${event.eventDate.toLocal().toString().split(' ')[0]}"),
              trailing: Text(event.notes),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddEventDialog(context),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    final TextEditingController customTypeController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String? selectedAnimalId;
    String? selectedAnimalName;
    String? selectedEventType;

    // Predefined event options
    final List<String> eventOptions = [
      'Dry-off / End of Lactation',
      'Housing Event',
      'Weight Measurement',
      'Growth Milestone',
      'Buying New Animal',
      'Selling Animal',
      'Other',
    ];

    showDialog(
      context: context,
      builder: (_) {
        final controller = Get.find<AnimalRecordsController>();
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add Upcoming Event"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Event type dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Event Type'),
                      items: eventOptions.map((e) => DropdownMenuItem<String>(value: e, child: Text(e))).toList(),
                      value: selectedEventType,
                      onChanged: (value) {
                        setState(() {
                          selectedEventType = value;
                          // Clear custom input if event type is not 'Other'
                          if (value != 'Other') {
                            customTypeController.clear();
                          }
                        });
                      },
                    ),

                    // Show custom event text field only if 'Other' is selected
                    if (selectedEventType == 'Other')
                      TextField(
                        controller: customTypeController,
                        decoration: const InputDecoration(labelText: 'Custom Event Type'),
                      ),

                    const SizedBox(height: 10),

                    // Animal dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Select Animal'),
                      items:
                          controller.allAnimals.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final name = data['name'] ?? 'Unnamed';
                            return DropdownMenuItem<String>(value: doc.id, child: Text(name));
                          }).toList(),
                      value: selectedAnimalId,
                      onChanged: (value) {
                        setState(() {
                          selectedAnimalId = value;
                          // Get the animal name for the selected id
                          final animalDoc = controller.allAnimals.firstWhere((doc) => doc.id == value);
                          final data = animalDoc.data() as Map<String, dynamic>;
                          selectedAnimalName = data['name'] ?? 'Unnamed';
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    // Date picker field
                    Row(
                      children: [
                        const Text('Event Date: '),
                        TextButton(
                          child: Text(
                            "${selectedDate.toLocal()}".split(' ')[0],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                selectedDate = pickedDate;
                              });
                            }
                          },
                        ),
                      ],
                    ),

                    // Notes input
                    TextField(controller: notesController, decoration: const InputDecoration(labelText: 'Notes')),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    final eventTypeToSave =
                        (selectedEventType == 'Other' && customTypeController.text.isNotEmpty)
                            ? customTypeController.text
                            : selectedEventType ?? '';

                    if (eventTypeToSave.isEmpty || selectedAnimalId == null) {
                      Get.snackbar('Error', 'Please select event type and animal.');
                      return;
                    }

                    final event = UpcomingEvent(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      animalId: selectedAnimalId!,
                      animalName: selectedAnimalName ?? '',
                      eventType: eventTypeToSave,
                      eventDate: selectedDate,
                      notes: notesController.text,
                    );

                    await controller.addUpcomingEvent(event);
                    Navigator.pop(context);
                  },
                  child: const Text("Save Event"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
