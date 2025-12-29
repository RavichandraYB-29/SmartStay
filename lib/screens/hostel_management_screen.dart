import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'add_hostel_dialog.dart';
import 'floor_management_screen.dart';

class HostelManagementScreen extends StatelessWidget {
  const HostelManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('User not logged in')));
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Header(),
            const SizedBox(height: 28),
            _MetricsRow(ownerId: user.uid),
            const SizedBox(height: 36),
            const _SectionTitle(),
            const SizedBox(height: 20),

            /// HOSTEL LIST
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('hostels')
                  .where('ownerId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text(
                        'No hostels added yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    childAspectRatio: 1.35,
                  ),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, i) {
                    final doc = snapshot.data!.docs[i];
                    final data = doc.data() as Map<String, dynamic>;

                    return _HostelCard(
                      hostelId: doc.id,
                      name: data['name'] ?? '',
                      address: data['address'] ?? '',
                      floors: data['floors'] ?? 0,
                      totalRooms: data['totalRooms'] ?? 0,
                      occupiedRooms: data['occupiedRooms'] ?? 0,
                      totalBeds: data['totalBeds'] ?? 0,
                      occupiedBeds: data['occupiedBeds'] ?? 0,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
/// HEADER
////////////////////////////////////////////////////////////////////////////////

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: AppDecorations.iconBox,
            child: const Icon(Icons.arrow_back),
          ),
        ),
        const SizedBox(width: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.apartment, color: Colors.white),
        ),
        const SizedBox(width: 14),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hostel Management',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2),
            Text(
              'Manage your hostels, floors & rooms',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        const Spacer(),
        InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const AddHostelDialog(),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              children: [
                Icon(Icons.add, color: Colors.white, size: 18),
                SizedBox(width: 6),
                Text(
                  'Add Hostel',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
/// METRICS ROW
////////////////////////////////////////////////////////////////////////////////

class _MetricsRow extends StatelessWidget {
  final String ownerId;
  const _MetricsRow({required this.ownerId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('hostels')
          .where('ownerId', isEqualTo: ownerId)
          .snapshots(),
      builder: (context, snapshot) {
        final hostels = snapshot.data?.docs ?? [];

        int floors = 0, rooms = 0, beds = 0;
        for (var d in hostels) {
          final m = d.data() as Map<String, dynamic>;
          floors += (m['floors'] ?? 0) as int;
          rooms += (m['totalRooms'] ?? 0) as int;
          beds += (m['totalBeds'] ?? 0) as int;
        }

        return Row(
          children: [
            _MetricCard('Total Hostels', hostels.length.toString()),
            _MetricCard('Total Floors', floors.toString()),
            _MetricCard('Total Rooms', rooms.toString()),
            _MetricCard('Total Beds', beds.toString()),
          ],
        );
      },
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
/// HOSTEL CARD (FIGMA EXACT)
////////////////////////////////////////////////////////////////////////////////

class _HostelCard extends StatelessWidget {
  final String hostelId;
  final String name;
  final String address;
  final int floors;
  final int totalRooms;
  final int occupiedRooms;
  final int totalBeds;
  final int occupiedBeds;

  const _HostelCard({
    required this.hostelId,
    required this.name,
    required this.address,
    required this.floors,
    required this.totalRooms,
    required this.occupiedRooms,
    required this.totalBeds,
    required this.occupiedBeds,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.hostelCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 8,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C3BFF), Color(0xFFE10098)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _StatusBadge(),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        address,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _miniStat('Floors', floors.toString()),
                    _miniStat('Total Rooms', totalRooms.toString()),
                    _miniStat('Occupied Rooms', '$occupiedRooms/$totalRooms'),
                    _miniStat('Occupied Beds', '$occupiedBeds/$totalBeds'),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FloorManagementScreen(
                                hostelId: hostelId,
                                hostelName: name,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.visibility),
                        label: const Text('Manage Floors & Rooms'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _iconAction(
                      icon: Icons.edit,
                      color: const Color(0xFF6C3BFF),
                      onTap: () {
                        // TODO: Edit Hostel Dialog
                      },
                    ),
                    const SizedBox(width: 8),
                    _iconAction(
                      icon: Icons.delete,
                      color: Colors.red,
                      onTap: () async {
                        await FirebaseFirestore.instance
                            .collection('hostels')
                            .doc(hostelId)
                            .delete();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String t, String v) {
    return Container(
      padding: const EdgeInsets.all(14),
      width: 150,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F6FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          Text(
            v,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _iconAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
/// SMALL UI
////////////////////////////////////////////////////////////////////////////////

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  const _MetricCard(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: AppDecorations.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F7F3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Active',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF00B894),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'All Hostels',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
/// DESIGN SYSTEM
////////////////////////////////////////////////////////////////////////////////

class AppColors {
  static const bg = Color(0xFFF6F7FB);
}

class AppGradients {
  static const primary = LinearGradient(
    colors: [Color(0xFF6C3BFF), Color(0xFF9B4DFF), Color(0xFFE10098)],
  );
}

class AppDecorations {
  static final card = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
  );

  static final hostelCard = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(22),
  );

  static final iconBox = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
  );
}
