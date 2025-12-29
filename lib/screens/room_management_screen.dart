import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_room_dialog.dart';

class RoomManagementScreen extends StatelessWidget {
  final String hostelId;
  final String floorId;

  const RoomManagementScreen({
    super.key,
    required this.hostelId,
    required this.floorId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('hostels')
            .doc(hostelId)
            .collection('floors')
            .doc(floorId)
            .collection('rooms')
            .snapshots(),
        builder: (context, snapshot) {
          final rooms = snapshot.data?.docs ?? [];

          int totalRooms = rooms.length;
          int totalBeds = 0;
          int occupiedBeds = 0;

          for (var r in rooms) {
            final d = r.data() as Map<String, dynamic>;
            totalBeds += (d['totalBeds'] ?? 0) as int;
            occupiedBeds += (d['occupiedBeds'] ?? 0) as int;
          }

          final vacantBeds = totalBeds - occupiedBeds;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context),
                const SizedBox(height: 28),
                _summaryRow(
                  totalRooms: totalRooms,
                  occupied: occupiedBeds,
                  vacant: vacantBeds,
                  residents: occupiedBeds,
                ),
                const SizedBox(height: 36),
                _sectionTitle(),
                const SizedBox(height: 20),
                _roomGrid(rooms),
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
            decoration: _cardDecoration(),
            child: const Icon(Icons.arrow_back),
          ),
        ),
        const SizedBox(width: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFB145FF), Color(0xFFEC4899)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.bed, color: Colors.white),
        ),
        const SizedBox(width: 14),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Room Management',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2),
            Text('SmartStay PG', style: TextStyle(color: Colors.grey)),
          ],
        ),
        const Spacer(),
        InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) =>
                  AddRoomDialog(hostelId: hostelId, floorId: floorId),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFB145FF), Color(0xFFEC4899)],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              children: [
                Icon(Icons.add, color: Colors.white, size: 18),
                SizedBox(width: 6),
                Text(
                  'Add Room',
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

  // ───────────────── SUMMARY ─────────────────
  Widget _summaryRow({
    required int totalRooms,
    required int occupied,
    required int vacant,
    required int residents,
  }) {
    return Row(
      children: [
        _SummaryCard(
          title: 'Total Rooms',
          value: totalRooms.toString(),
          icon: Icons.meeting_room,
          color: const Color(0xFFB145FF),
        ),
        const SizedBox(width: 16),
        _SummaryCard(
          title: 'Occupied',
          value: occupied.toString(),
          icon: Icons.people,
          color: const Color(0xFF14B8A6),
        ),
        const SizedBox(width: 16),
        _SummaryCard(
          title: 'Vacant',
          value: vacant.toString(),
          icon: Icons.event_available,
          color: const Color(0xFFF59E0B),
        ),
        const SizedBox(width: 16),
        _SummaryCard(
          title: 'Total Residents',
          value: residents.toString(),
          icon: Icons.group,
          color: const Color(0xFF6366F1),
        ),
      ],
    );
  }

  // ───────────────── ROOM GRID ─────────────────
  Widget _roomGrid(List<QueryDocumentSnapshot> rooms) {
    if (rooms.isEmpty) {
      return const Text(
        'No rooms added yet',
        style: TextStyle(color: Colors.grey),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 24,
      mainAxisSpacing: 24,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      children: rooms.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        final totalBeds = data['totalBeds'] ?? 0;
        final occupiedBeds = data['occupiedBeds'] ?? 0;

        final bool full = occupiedBeds == totalBeds && totalBeds != 0;

        return _RoomCard(
          roomNo: data['roomNo'],
          sharing: '${data['sharingType']} Sharing',
          totalBeds: totalBeds,
          occupiedBeds: occupiedBeds,
          rent: data['rentPerBed'],
          status: full ? 'Fully Occupied' : 'Available',
          statusColor: full ? Colors.green : Colors.orange,
        );
      }).toList(),
    );
  }

  // ───────────────── ROOM CARD ─────────────────
  Widget _RoomCard({
    required String roomNo,
    required String sharing,
    required int totalBeds,
    required int occupiedBeds,
    required int rent,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB145FF), Color(0xFFEC4899)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  roomNo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Room $roomNo',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _infoChip(
                title: 'Sharing Type',
                value: '$totalBeds Beds',
                bg: const Color(0xFFF3E8FF),
                color: const Color(0xFF7C3AED),
              ),
              const SizedBox(width: 12),
              _infoChip(
                title: 'Occupancy',
                value: '$occupiedBeds/$totalBeds',
                bg: const Color(0xFFE0F7FA),
                color: const Color(0xFF009688),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '₹$rent per bed',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip({
    required String title,
    required String value,
    required Color bg,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _SummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        decoration: _cardDecoration(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ],
    );
  }

  Widget _sectionTitle() {
    return Row(
      children: const [
        SizedBox(
          height: 18,
          child: VerticalDivider(
            thickness: 3,
            width: 20,
            color: Color(0xFFB145FF),
          ),
        ),
        Text(
          'All Rooms',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
