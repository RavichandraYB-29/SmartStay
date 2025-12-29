import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'add_floor_dialog.dart';
import 'room_management_screen.dart';

class FloorManagementScreen extends StatelessWidget {
  final String hostelId;
  final String hostelName;

  const FloorManagementScreen({
    super.key,
    required this.hostelId,
    required this.hostelName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('hostels')
            .doc(hostelId)
            .snapshots(),
        builder: (context, hostelSnapshot) {
          if (!hostelSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final hostelData =
              hostelSnapshot.data!.data() as Map<String, dynamic>;
          final int totalFloors = hostelData['floors'] ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context),
                const SizedBox(height: 28),
                _summaryRow(totalFloors),
                const SizedBox(height: 36),
                const Text(
                  'All Floors',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('hostels')
                      .doc(hostelId)
                      .collection('floors')
                      .snapshots(),
                  builder: (context, floorSnapshot) {
                    if (!floorSnapshot.hasData) return const SizedBox();

                    return Column(
                      children: List.generate(totalFloors, (index) {
                        final docs = floorSnapshot.data!.docs
                            .where((d) => d['floorIndex'] == index)
                            .toList();

                        final data = docs.isNotEmpty
                            ? docs.first.data() as Map<String, dynamic>
                            : null;

                        final floorId = docs.isNotEmpty ? docs.first.id : null;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 28),
                          child: _floorCard(context, index, data, floorId),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ───────────────── HEADER ─────────────────
  Widget _header(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: _box(),
            child: const Icon(Icons.arrow_back),
          ),
        ),
        const SizedBox(width: 14),
        const Icon(Icons.layers, size: 26, color: Color(0xFF009688)),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Floor Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(hostelName, style: const TextStyle(color: Colors.grey)),
          ],
        ),
        const Spacer(),
        _addFloorBtn(context),
      ],
    );
  }

  Widget _addFloorBtn(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AddFloorDialog(hostelId: hostelId),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF009688),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Row(
          children: [
            Icon(Icons.add, color: Colors.white, size: 18),
            SizedBox(width: 6),
            Text(
              'Add Floor',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────── SUMMARY ─────────────────
  Widget _summaryRow(int totalFloors) {
    return Row(
      children: [
        _SummaryCard(
          title: 'Total Floors',
          value: '$totalFloors',
          color: const Color(0xFF26C6DA),
          icon: Icons.layers,
        ),
        const SizedBox(width: 16),
        const _SummaryCard(
          title: 'Total Rooms',
          value: '—',
          color: Color(0xFFB388FF),
          icon: Icons.bed,
        ),
        const SizedBox(width: 16),
        const _SummaryCard(
          title: 'Occupied Rooms',
          value: '—',
          color: Color(0xFF7C4DFF),
          icon: Icons.hotel,
        ),
        const SizedBox(width: 16),
        const _SummaryCard(
          title: 'Occupancy Rate',
          value: '—',
          color: Color(0xFFFFA726),
          icon: Icons.people,
        ),
      ],
    );
  }

  // ───────────────── FLOOR CARD ─────────────────
  Widget _floorCard(
    BuildContext context,
    int index,
    Map<String, dynamic>? data,
    String? floorId,
  ) {
    final tr = data?['totalRooms'] ?? 0;
    final or = data?['occupiedRooms'] ?? 0;
    final tb = data?['totalBeds'] ?? 0;
    final ob = data?['occupiedBeds'] ?? 0;

    final roomRate = tr == 0 ? 0.0 : or / tr;
    final bedRate = tb == 0 ? 0.0 : ob / tb;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFFE0F7FA), Color(0xFFF1FEFF)],
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 18),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _floorHeader(index),
          const SizedBox(height: 22),
          _statsCards(tr, or, tb, ob),
          const SizedBox(height: 18),
          _progressBar('Room Occupancy', roomRate),
          const SizedBox(height: 12),
          _progressBar('Bed Occupancy', bedRate),
          const SizedBox(height: 18),
          _roomTypeChips(),
          const SizedBox(height: 22),
          _actionRow(context, floorId),
        ],
      ),
    );
  }

  Widget _floorHeader(int index) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF009688),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _floorTitle(index),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              'Floor ${index + 1}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statsCards(int tr, int or, int tb, int ob) {
    return Row(
      children: [
        _statCard('Total Rooms', '$tr'),
        _statCard('Occupied', '$or', color: const Color(0xFF5C6BC0)),
        _statCard('Total Beds', '$tb'),
        _statCard('Occupied Beds', '$ob', color: const Color(0xFFFF7043)),
      ],
    );
  }

  Widget _statCard(String label, String value, {Color? color}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.65),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressBar(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label),
            const Spacer(),
            Text('${(value * 100).toInt()}%'),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: value,
          minHeight: 6,
          backgroundColor: Colors.grey.shade300,
          color: const Color(0xFF009688),
        ),
      ],
    );
  }

  Widget _roomTypeChips() {
    return Wrap(
      spacing: 10,
      children: const [
        _Chip('Single: 0', Color(0xFFB39DDB)),
        _Chip('Double: 0', Color(0xFF4DD0E1)),
        _Chip('Triple: 0', Color(0xFFCE93D8)),
        _Chip('4-Sharing: 0', Color(0xFFFFCC80)),
      ],
    );
  }

  Widget _actionRow(BuildContext context, String? floorId) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: floorId == null
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RoomManagementScreen(
                          hostelId: hostelId,
                          floorId: floorId,
                        ),
                      ),
                    );
                  },
            icon: const Icon(Icons.visibility),
            label: const Text('View Rooms'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF009688),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _iconBtn(Icons.edit, Colors.blue),
        const SizedBox(width: 8),
        _iconBtn(Icons.delete, Colors.red),
      ],
    );
  }

  Widget _iconBtn(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color),
    );
  }

  String _floorTitle(int index) {
    const names = [
      'Ground Floor',
      'First Floor',
      'Second Floor',
      'Third Floor',
      'Fourth Floor',
      'Fifth Floor',
    ];
    return index < names.length ? names[index] : 'Floor ${index + 1}';
  }

  BoxDecoration _box() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 6)),
    ],
  );
}

/* ───────── UI COMPONENTS ───────── */

class _SummaryCard extends StatelessWidget {
  final String title, value;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16),
          ],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(icon, size: 30, color: color),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;

  const _Chip(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text),
    );
  }
}
