import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'rooms_screen.dart';

class HostelFloorsScreen extends StatelessWidget {
  final String hostelId;
  final String hostelName;

  const HostelFloorsScreen({
    super.key,
    required this.hostelId,
    required this.hostelName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(hostelName)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFloorDialog(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('hostels')
            .doc(hostelId)
            .collection('floors')
            .orderBy('createdAt')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // EMPTY STATE
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.layers_outlined,
                    size: 64,
                    color: Color(0xFFA5A1FF),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Floors Added',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E2E3A),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap + to add floors to this hostel',
                    style: TextStyle(color: Color(0xFF6B6B7A)),
                  ),
                ],
              ),
            );
          }

          // FLOORS LIST
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  leading: const Icon(
                    Icons.apartment,
                    color: Color(0xFF6C63FF),
                  ),
                  title: Text(
                    data['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E2E3A),
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditFloorDialog(context, doc.id, data['name']);
                      } else if (value == 'delete') {
                        _deleteFloor(context, doc.id);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RoomsScreen(
                          hostelId: hostelId,
                          floorId: doc.id,
                          floorName: data['name'],
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  // ---------------- ADD FLOOR ----------------
  void _showAddFloorDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Floor'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Floor Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            child: const Text('Add'),
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;

              await FirebaseFirestore.instance
                  .collection('hostels')
                  .doc(hostelId)
                  .collection('floors')
                  .add({
                    'name': controller.text.trim(),
                    'createdAt': Timestamp.now(),
                  });

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // ---------------- EDIT FLOOR ----------------
  void _showEditFloorDialog(
    BuildContext context,
    String floorId,
    String currentName,
  ) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Floor'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Floor Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            child: const Text('Save'),
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;

              await FirebaseFirestore.instance
                  .collection('hostels')
                  .doc(hostelId)
                  .collection('floors')
                  .doc(floorId)
                  .update({'name': controller.text.trim()});

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // ---------------- DELETE FLOOR ----------------
  Future<void> _deleteFloor(BuildContext context, String floorId) async {
    final roomsSnapshot = await FirebaseFirestore.instance
        .collection('hostels')
        .doc(hostelId)
        .collection('floors')
        .doc(floorId)
        .collection('rooms')
        .limit(1)
        .get();

    if (roomsSnapshot.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete floor with existing rooms'),
        ),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('hostels')
        .doc(hostelId)
        .collection('floors')
        .doc(floorId)
        .delete();
  }
}
