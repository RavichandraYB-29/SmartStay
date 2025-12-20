import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomsScreen extends StatelessWidget {
  final String hostelId;
  final String floorId;
  final String floorName;

  const RoomsScreen({
    super.key,
    required this.hostelId,
    required this.floorId,
    required this.floorName,
  });

  void _showRoomDialog(
    BuildContext context, {
    String? roomId,
    String? oldName,
    int? oldCapacity,
  }) {
    final nameController = TextEditingController(text: oldName ?? "");
    final capacityController = TextEditingController(
      text: oldCapacity?.toString() ?? "",
    );

    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(roomId == null ? "Add Room" : "Edit Room"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Room Name / Number",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: capacityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Bed Capacity",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final name = nameController.text.trim();
                          final capacity = int.tryParse(
                            capacityController.text.trim(),
                          );

                          if (name.isEmpty ||
                              capacity == null ||
                              capacity <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Enter valid room details"),
                              ),
                            );
                            return;
                          }

                          setState(() => isSaving = true);

                          final ref = FirebaseFirestore.instance
                              .collection('hostels')
                              .doc(hostelId)
                              .collection('floors')
                              .doc(floorId)
                              .collection('rooms');

                          if (roomId == null) {
                            await ref.add({
                              'roomName': name,
                              'capacity': capacity,
                              'createdAt': Timestamp.now(),
                            });
                          } else {
                            await ref.doc(roomId).update({
                              'roomName': name,
                              'capacity': capacity,
                            });
                          }

                          // ✅ CLOSE DIALOG AFTER SAVE
                          Navigator.of(dialogContext).pop();
                        },
                  child: isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteRoom(BuildContext context, String roomId) async {
    await FirebaseFirestore.instance
        .collection('hostels')
        .doc(hostelId)
        .collection('floors')
        .doc(floorId)
        .collection('rooms')
        .doc(roomId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    final roomsRef = FirebaseFirestore.instance
        .collection('hostels')
        .doc(hostelId)
        .collection('floors')
        .doc(floorId)
        .collection('rooms')
        .orderBy('createdAt');

    return Scaffold(
      appBar: AppBar(title: Text("Rooms – $floorName")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRoomDialog(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: roomsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final rooms = snapshot.data!.docs;

          if (rooms.isEmpty) {
            return const Center(child: Text("No rooms added yet"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final doc = rooms[index];

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(doc['roomName']),
                  subtitle: Text("Capacity: ${doc['capacity']} beds"),
                  trailing: PopupMenuButton(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showRoomDialog(
                          context,
                          roomId: doc.id,
                          oldName: doc['roomName'],
                          oldCapacity: doc['capacity'],
                        );
                      } else if (value == 'delete') {
                        _deleteRoom(context, doc.id);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text("Edit")),
                      PopupMenuItem(value: 'delete', child: Text("Delete")),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
