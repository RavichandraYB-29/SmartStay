import 'package:flutter/material.dart';
import 'add_room_dialog.dart';

class RoomManagementScreen extends StatelessWidget {
  /// ✅ REQUIRED FOR NAVIGATION & FIRESTORE
  final String hostelId;

  const RoomManagementScreen({
    super.key,
    required this.hostelId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context),
            const SizedBox(height: 28),
            _summaryRow(),
            const SizedBox(height: 36),
            _sectionTitle(),
            const SizedBox(height: 20),
            _roomGrid(),
          ],
        ),
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
            Text(
              'SmartStay PG → Koramangala → Ground Floor',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        const Spacer(),

        /// ➕ ADD ROOM
        InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => AddRoomDialog(hostelId: hostelId),
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

  // ───────────────── SUMMARY ROW ─────────────────
  Widget _summaryRow() {
    return Row(
      children:  [
        _SummaryCard(
          title: 'Total Rooms',
          value: '6',
          icon: Icons.meeting_room,
          color: Color(0xFFB145FF),
        ),
        SizedBox(width: 16),
        _SummaryCard(
          title: 'Occupied',
          value: '5',
          icon: Icons.people,
          color: Color(0xFF14B8A6),
        ),
        SizedBox(width: 16),
        _SummaryCard(
          title: 'Vacant',
          value: '1',
          icon: Icons.event_available,
          color: Color(0xFFF59E0B),
        ),
        SizedBox(width: 16),
        _SummaryCard(
          title: 'Total Residents',
          value: '12',
          icon: Icons.group,
          color: Color(0xFF6366F1),
        ),
      ],
    );
  }

  // ───────────────── SECTION TITLE ─────────────────
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

  // ───────────────── ROOM GRID ─────────────────
  Widget _roomGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.25,
      children:  [
        _RoomCard(
          roomNo: '101',
          title: 'Room 101',
          sharing: 'Single Sharing',
          status: 'Fully Occupied',
          statusColor: Colors.green,
          beds: '1 Bed',
          occupancy: '1/1',
          rent: '₹8,000 per bed',
          residents: ['Rahul Sharma'],
        ),
        _RoomCard(
          roomNo: '102',
          title: 'Room 102',
          sharing: 'Double Sharing',
          status: 'Fully Occupied',
          statusColor: Colors.green,
          beds: '2 Beds',
          occupancy: '2/2',
          rent: '₹6,000 per bed',
          residents: ['Priya Patel', 'Sneha Reddy'],
        ),
      ],
    );
  }

  // ───────────────── ROOM CARD ─────────────────
  Widget _RoomCard({
    required String roomNo,
    required String title,
    required String sharing,
    required String status,
    required Color statusColor,
    required String beds,
    required String occupancy,
    required String rent,
    required List<String> residents,
  }) {
    return Container(
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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            sharing,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            '$beds • $occupancy',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            rent,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ───────────────── SUMMARY CARD ─────────────────
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
}
