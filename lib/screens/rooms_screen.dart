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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(floorName)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRoomDialog(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('hostels')
            .doc(hostelId)
            .collection('floors')
            .doc(floorId)
            .collection('rooms')
            .orderBy('createdAt')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.meeting_room_outlined,
                    size: 64,
                    color: Color(0xFFA5A1FF),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Rooms Added',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E2E3A),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap + to add rooms to this floor',
                    style: TextStyle(color: Color(0xFF6B6B7A)),
                  ),
                ],
              ),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final int occupied = data['occupiedBeds'];
              final int total = data['totalBeds'];

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
                    Icons.meeting_room,
                    color: Color(0xFF6C63FF),
                  ),
                  title: Text(
                    'Room ${data['roomNumber']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${data['sharing']}-Sharing • $occupied / $total occupied',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditRoomDialog(context, doc.id, data);
                      } else if (value == 'delete') {
                        _deleteRoom(context, doc.id, occupied);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  // ---------------- ADD ROOM ----------------
  void _showAddRoomDialog(BuildContext context) {
    final roomController = TextEditingController();
    int sharing = 1;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Room'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: roomController,
                  decoration: const InputDecoration(labelText: 'Room Number'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: sharing,
                  decoration: const InputDecoration(labelText: 'Sharing Type'),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('1 Sharing')),
                    DropdownMenuItem(value: 2, child: Text('2 Sharing')),
                    DropdownMenuItem(value: 3, child: Text('3 Sharing')),
                    DropdownMenuItem(value: 4, child: Text('4 Sharing')),
                  ],
                  onChanged: (value) => setState(() => sharing = value!),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            child: const Text('Add'),
            onPressed: () async {
              if (roomController.text.trim().isEmpty) return;

              await FirebaseFirestore.instance
                  .collection('hostels')
                  .doc(hostelId)
                  .collection('floors')
                  .doc(floorId)
                  .collection('rooms')
                  .add({
                    'roomNumber': roomController.text.trim(),
                    'sharing': sharing,
                    'totalBeds': sharing,
                    'occupiedBeds': 0,
                    'createdAt': Timestamp.now(),
                  });

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // ---------------- EDIT ROOM ----------------
  void _showEditRoomDialog(
    BuildContext context,
    String roomId,
    Map<String, dynamic> data,
  ) {
    final roomController = TextEditingController(text: data['roomNumber']);
    int sharing = data['sharing'];
    final bool isOccupied = data['occupiedBeds'] > 0;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Room'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: roomController,
                  decoration: const InputDecoration(labelText: 'Room Number'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: sharing,
                  decoration: const InputDecoration(labelText: 'Sharing Type'),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('1 Sharing')),
                    DropdownMenuItem(value: 2, child: Text('2 Sharing')),
                    DropdownMenuItem(value: 3, child: Text('3 Sharing')),
                    DropdownMenuItem(value: 4, child: Text('4 Sharing')),
                  ],
                  onChanged: isOccupied
                      ? null
                      : (value) => setState(() => sharing = value!),
                ),
                if (isOccupied)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Sharing cannot be changed while occupied',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            child: const Text('Save'),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('hostels')
                  .doc(hostelId)
                  .collection('floors')
                  .doc(floorId)
                  .collection('rooms')
                  .doc(roomId)
                  .update({
                    'roomNumber': roomController.text.trim(),
                    if (!isOccupied) ...{
                      'sharing': sharing,
                      'totalBeds': sharing,
                    },
                  });

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // ---------------- DELETE ROOM ----------------
  Future<void> _deleteRoom(
    BuildContext context,
    String roomId,
    int occupiedBeds,
  ) async {
    if (occupiedBeds > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete room with occupied beds')),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('hostels')
        .doc(hostelId)
        .collection('floors')
        .doc(floorId)
        .collection('rooms')
        .doc(roomId)
        .delete();
  }
}
