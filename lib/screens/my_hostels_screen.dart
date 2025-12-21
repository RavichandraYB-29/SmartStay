import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'hostel_floors_screen.dart';

class MyHostelsScreen extends StatelessWidget {
  const MyHostelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('User not logged in')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Hostels')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create-hostel');
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('hostels')
            .where('ownerId', isEqualTo: user.uid)
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
                    Icons.home_work_outlined,
                    size: 64,
                    color: Color(0xFFA5A1FF),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Hostels Yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E2E3A),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap + to add your first PG or Hostel',
                    style: TextStyle(color: Color(0xFF6B6B7A)),
                  ),
                ],
              ),
            );
          }

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
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    data['address'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditHostelDialog(context, doc.id, data);
                      } else if (value == 'delete') {
                        _deleteHostel(context, doc.id);
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
                        builder: (_) => HostelFloorsScreen(
                          hostelId: doc.id,
                          hostelName: data['name'],
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

  // ---------------- EDIT HOSTEL ----------------
  void _showEditHostelDialog(
    BuildContext context,
    String hostelId,
    Map<String, dynamic> data,
  ) {
    final nameController = TextEditingController(text: data['name']);
    final addressController = TextEditingController(text: data['address']);
    final rulesController = TextEditingController(text: data['rules']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Hostel'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Hostel Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: rulesController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Rules'),
              ),
            ],
          ),
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
                  .update({
                    'name': nameController.text.trim(),
                    'address': addressController.text.trim(),
                    'rules': rulesController.text.trim(),
                  });

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // ---------------- DELETE HOSTEL ----------------
  Future<void> _deleteHostel(BuildContext context, String hostelId) async {
    final floorsSnapshot = await FirebaseFirestore.instance
        .collection('hostels')
        .doc(hostelId)
        .collection('floors')
        .limit(1)
        .get();

    if (floorsSnapshot.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete hostel with existing floors'),
        ),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('hostels')
        .doc(hostelId)
        .delete();
  }
}
