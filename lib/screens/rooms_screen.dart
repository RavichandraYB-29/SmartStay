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
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No rooms added'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              final int total = data['totalBeds'] ?? 0;
              final int occupied = data['occupiedBeds'] ?? 0;
              final bool isFull = occupied >= total;

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.meeting_room,
                    color: isFull ? Colors.red : Colors.green,
                  ),
                  title: Text('Room ${data['roomNumber']}'),
                  subtitle: Text(
                    '${data['sharing']}-Sharing • $occupied / $total occupied',
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  // ================= ADD ROOM =================
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
                const SizedBox(height: 12),
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
                    'hostelId': hostelId, // ✅ FIX (VERY IMPORTANT)
                    'createdAt': Timestamp.now(),
                  });

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
