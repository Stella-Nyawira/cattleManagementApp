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
          padding: const EdgeInsets.all(12),
          itemCount: controller.upcomingEvents.length,
          itemBuilder: (context, index) {
            final event = controller.upcomingEvents[index];
            final bool isUpcoming = event.eventDate.isAfter(DateTime.now());

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                leading: CircleAvatar(radius: 16, child: const Icon(Icons.event, size: 16, color: Colors.white)),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(event.eventType, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                    Text(
                      isUpcoming ? 'Upcoming' : 'Past',
                      style: TextStyle(
                        fontSize: 11,
                        color: isUpcoming ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.pets, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(event.animalName, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          "${event.eventDate.toLocal()}".split(' ')[0],
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    if (event.notes != null && event.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.notes, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.notes!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  onPressed: () => controller.deleteUpcomingEvent(event.id),
                ),
              ),
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
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Event Type'),
                      items: eventOptions.map((e) => DropdownMenuItem<String>(value: e, child: Text(e))).toList(),
                      value: selectedEventType,
                      onChanged: (value) {
                        setState(() {
                          selectedEventType = value;
                          if (value != 'Other') customTypeController.clear();
                        });
                      },
                    ),
                    if (selectedEventType == 'Other')
                      TextField(
                        controller: customTypeController,
                        decoration: const InputDecoration(labelText: 'Custom Event Type'),
                      ),
                    const SizedBox(height: 10),
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
                          final animalDoc = controller.allAnimals.firstWhere((doc) => doc.id == value);
                          final data = animalDoc.data() as Map<String, dynamic>;
                          selectedAnimalName = data['name'] ?? 'Unnamed';
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Event Date:'),
                        const SizedBox(width: 10),
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
