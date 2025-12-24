import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AssignRoomScreen extends StatefulWidget {
  const AssignRoomScreen({super.key});

  @override
  State<AssignRoomScreen> createState() => _AssignRoomScreenState();
}

class _AssignRoomScreenState extends State<AssignRoomScreen> {
  String? residentId;
  String? hostelId;
  String? floorId;
  String? roomId;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String adminId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assign Room')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // ================= RESIDENT =================
            StreamBuilder<QuerySnapshot>(
              stream: _db
                  .collection('users')
                  .where('role', isEqualTo: 'resident')
                  .where('stayStatus', isEqualTo: 'pending') // ✅ FIXED
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                return DropdownButtonFormField<String>(
                  value: residentId,
                  decoration: const InputDecoration(
                    labelText: 'Select Resident',
                    border: OutlineInputBorder(),
                  ),
                  items: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text(data['name'] ?? data['email']),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => residentId = value),
                );
              },
            ),

            const SizedBox(height: 16),

            // ================= HOSTEL =================
            StreamBuilder<QuerySnapshot>(
              stream: _db
                  .collection('hostels')
                  .where('ownerId', isEqualTo: adminId) // ✅ SECURITY FIX
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                return DropdownButtonFormField<String>(
                  value: hostelId,
                  decoration: const InputDecoration(
                    labelText: 'Select Hostel',
                    border: OutlineInputBorder(),
                  ),
                  items: snapshot.data!.docs.map((doc) {
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text(doc['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      hostelId = value;
                      floorId = null;
                      roomId = null;
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            // ================= FLOOR =================
            if (hostelId != null)
              StreamBuilder<QuerySnapshot>(
                stream: _db
                    .collection('hostels')
                    .doc(hostelId)
                    .collection('floors')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  return DropdownButtonFormField<String>(
                    value: floorId,
                    decoration: const InputDecoration(
                      labelText: 'Select Floor',
                      border: OutlineInputBorder(),
                    ),
                    items: snapshot.data!.docs.map((doc) {
                      return DropdownMenuItem(
                        value: doc.id,
                        child: Text(doc['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        floorId = value;
                        roomId = null;
                      });
                    },
                  );
                },
              ),

            const SizedBox(height: 16),

            // ================= ROOM =================
            if (floorId != null)
              StreamBuilder<QuerySnapshot>(
                stream: _db
                    .collection('hostels')
                    .doc(hostelId)
                    .collection('floors')
                    .doc(floorId)
                    .collection('rooms')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  return DropdownButtonFormField<String>(
                    value: roomId,
                    decoration: const InputDecoration(
                      labelText: 'Select Room',
                      border: OutlineInputBorder(),
                    ),
                    items: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final int total = data['totalBeds'] ?? 0;
                      final int occupied = data['occupiedBeds'] ?? 0;
                      final bool isFull = occupied >= total;

                      return DropdownMenuItem(
                        value: doc.id,
                        enabled: !isFull,
                        child: Text(
                          'Room ${data['roomNumber']} '
                          '(${total - occupied} beds available)',
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => roomId = value),
                  );
                },
              ),

            const SizedBox(height: 30),

            // ================= ASSIGN =================
            ElevatedButton(
              onPressed: _assignRoom,
              child: const Text('Assign Room'),
            ),
          ],
        ),
      ),
    );
  }

  // ================= ASSIGN LOGIC (TRANSACTION SAFE) =================
  Future<void> _assignRoom() async {
    if (residentId == null ||
        hostelId == null ||
        floorId == null ||
        roomId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select all fields')));
      return;
    }

    final roomRef = _db
        .collection('hostels')
        .doc(hostelId)
        .collection('floors')
        .doc(floorId)
        .collection('rooms')
        .doc(roomId);

    await _db.runTransaction((transaction) async {
      final roomSnap = await transaction.get(roomRef);

      final int total = roomSnap['totalBeds'];
      final int occupied = roomSnap['occupiedBeds'];

      if (occupied >= total) {
        throw Exception('Room is full');
      }

      // Update room
      transaction.update(roomRef, {'occupiedBeds': occupied + 1});

      // Update resident
      transaction.update(_db.collection('users').doc(residentId), {
        'assignedHostelId': hostelId,
        'assignedFloorId': floorId,
        'assignedRoomId': roomId,
        'stayStatus': 'active',
        'checkInDate': Timestamp.now(),
      });
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Room assigned successfully')));

    Navigator.pop(context);
  }
}
