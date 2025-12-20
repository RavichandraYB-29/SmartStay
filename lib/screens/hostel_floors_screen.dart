import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'rooms_screen.dart'; // ✅ ADD THIS

class HostelFloorsScreen extends StatelessWidget {
  final String hostelId;
  final String hostelName;

  const HostelFloorsScreen({
    super.key,
    required this.hostelId,
    required this.hostelName,
  });

  // ➕ ADD / ✏️ EDIT FLOOR
  void _showFloorDialog(
    BuildContext context, {
    String? floorId,
    String? oldName,
  }) {
    final controller = TextEditingController(text: oldName ?? "");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(floorId == null ? "Add Floor" : "Edit Floor"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Floor name (e.g. Ground Floor)",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;

              final floorsRef = FirebaseFirestore.instance
                  .collection('hostels')
                  .doc(hostelId)
                  .collection('floors');

              if (floorId == null) {
                await floorsRef.add({
                  'floorName': name,
                  'createdAt': Timestamp.now(),
                });
              } else {
                await floorsRef.doc(floorId).update({'floorName': name});
              }

              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ❌ DELETE FLOOR
  void _confirmDelete(BuildContext context, String floorId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Floor"),
        content: const Text(
          "Are you sure you want to delete this floor?\n"
          "Rooms under this floor will also be deleted.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('hostels')
                  .doc(hostelId)
                  .collection('floors')
                  .doc(floorId)
                  .delete();

              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final floorsRef = FirebaseFirestore.instance
        .collection('hostels')
        .doc(hostelId)
        .collection('floors')
        .orderBy('createdAt');

    return Scaffold(
      appBar: AppBar(title: Text("Floors – $hostelName")),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFloorDialog(context),
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: floorsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          final floors = snapshot.data!.docs;

          if (floors.isEmpty) {
            return const Center(
              child: Text(
                "No floors added yet",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: floors.length,
            itemBuilder: (context, index) {
              final doc = floors[index];
              final floorName = doc['floorName'];

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.layers),
                  title: Text(floorName),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showFloorDialog(
                          context,
                          floorId: doc.id,
                          oldName: floorName,
                        );
                      } else if (value == 'delete') {
                        _confirmDelete(context, doc.id);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text("Edit")),
                      PopupMenuItem(value: 'delete', child: Text("Delete")),
                    ],
                  ),

                  // ✅ NAVIGATE TO ROOMS
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RoomsScreen(
                          hostelId: hostelId,
                          floorId: doc.id,
                          floorName: floorName,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
