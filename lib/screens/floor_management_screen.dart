import 'package:flutter/material.dart';
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context),
            const SizedBox(height: 28),
            _summaryRow(),
            const SizedBox(height: 36),
            const Text(
              'All Floors',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            _floorCard(context),
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
            ),
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
            const SizedBox(height: 2),
            // ✅ DYNAMIC HOSTEL NAME (UI SAME)
            Text(hostelName, style: const TextStyle(color: Colors.grey)),
          ],
        ),
        const Spacer(),
        InkWell(
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
        ),
      ],
    );
  }

  // ───────────────── SUMMARY CARDS ─────────────────
  Widget _summaryRow() {
    return Row(
      children: const [
        _SummaryCard(
          title: 'Total Floors',
          value: '5',
          color: Color(0xFF26C6DA),
          icon: Icons.layers,
        ),
        SizedBox(width: 16),
        _SummaryCard(
          title: 'Total Rooms',
          value: '50',
          color: Color(0xFFB388FF),
          icon: Icons.bed,
        ),
        SizedBox(width: 16),
        _SummaryCard(
          title: 'Occupied Rooms',
          value: '45',
          color: Color(0xFF7C4DFF),
          icon: Icons.hotel,
        ),
        SizedBox(width: 16),
        _SummaryCard(
          title: 'Occupancy Rate',
          value: '90%',
          color: Color(0xFFFFA726),
          icon: Icons.people,
        ),
      ],
    );
  }

  // ───────────────── FLOOR CARD ─────────────────
  Widget _floorCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFE0F7FA), Color(0xFFF1FEFF)],
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20),
        ],
      ),
      child: Column(
        children: [
          _floorHeader(),
          const SizedBox(height: 24),
          _statsRow(),
          const SizedBox(height: 20),
          _progress('Room Occupancy', 0.9),
          const SizedBox(height: 12),
          _progress('Bed Occupancy', 0.93),
          const SizedBox(height: 18),
          _roomTypeChips(),
          const SizedBox(height: 22),
          _actionBar(context),
        ],
      ),
    );
  }

  Widget _floorHeader() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF009688),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            '1',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ground Floor',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text('Floor 1', style: TextStyle(color: Colors.grey)),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Color(0xFF26A69A),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('Active', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _statsRow() {
    return Row(
      children: const [
        _MiniStat('Total Rooms', '10'),
        _MiniStat('Occupied', '9', color: Color(0xFF5C6BC0)),
        _MiniStat('Total Beds', '30'),
        _MiniStat('Occupied Beds', '28', color: Color(0xFFFF7043)),
      ],
    );
  }

  Widget _progress(String label, double value) {
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
        _Chip('Single: 2', Color(0xFFB39DDB)),
        _Chip('Double: 4', Color(0xFF4DD0E1)),
        _Chip('Triple: 3', Color(0xFFCE93D8)),
        _Chip('4-Sharing: 1', Color(0xFFFFCC80)),
      ],
    );
  }

  Widget _actionBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RoomManagementScreen(hostelId: hostelId),
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
        const SizedBox(width: 14),
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
}

/* ───────────────── COMPONENTS ───────────────── */

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

class _MiniStat extends StatelessWidget {
  final String label, value;
  final Color? color;

  const _MiniStat(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
