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
      body: Column(
        children: [
          _hostelSummary(),
          Expanded(child: _floorsList()),
        ],
      ),
    );
  }

  // ================= HOSTEL SUMMARY =================
  Widget _hostelSummary() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collectionGroup('rooms')
          .where('hostelId', isEqualTo: hostelId)
          .snapshots(),
      builder: (context, snapshot) {
        int totalRooms = 0;
        int totalBeds = 0;
        int availableBeds = 0;

        if (snapshot.hasData) {
          totalRooms = snapshot.data!.docs.length;

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final int total = data['totalBeds'] ?? 0;
            final int occupied = data['occupiedBeds'] ?? 0;

            totalBeds += total;
            availableBeds += (total - occupied);
          }
        }

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hostel Summary',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Total Rooms: $totalRooms'),
                Text('Total Beds: $totalBeds'),
                Text('Available Beds: $availableBeds'),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= FLOORS LIST =================
  Widget _floorsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('hostels')
          .doc(hostelId)
          .collection('floors')
          .orderBy('createdAt')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No floors added'));
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: ListTile(
                leading: const Icon(Icons.apartment),
                title: Text(data['name']),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
    );
  }

  // ================= ADD FLOOR =================
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
}
