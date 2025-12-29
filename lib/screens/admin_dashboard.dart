import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _TopHeader(),
            SizedBox(height: 36),
            _StatsRow(),
            SizedBox(height: 36),
            _QuickActionsRow(),
            SizedBox(height: 36),
            _MainGrid(),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
/// TOP HEADER
////////////////////////////////////////////////////////////////////////////////

class _TopHeader extends StatelessWidget {
  const _TopHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C3BFF), Color(0xFF8E6CFF)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.apartment, color: Colors.white),
        ),
        const SizedBox(width: 14),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SmartStay',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text('Admin Dashboard', style: TextStyle(color: Colors.grey)),
          ],
        ),
        const SizedBox(width: 32),
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: _softShadow,
            ),
            child: const TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.search),
                hintText: 'Search residents, rooms, payments…',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        const Icon(Icons.calendar_month_outlined),
        const SizedBox(width: 16),
        const CircleAvatar(
          backgroundColor: Color(0xFFEEE9FF),
          child: Icon(Icons.person, color: Color(0xFF6C3BFF)),
        ),
      ],
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
/// STATS ROW
////////////////////////////////////////////////////////////////////////////////

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final w = (c.maxWidth - 48) / 4;
        return Row(
          children: [
            _stat(w, 'Total Residents', '124', Icons.people, '+12 this month'),
            _stat(
              w,
              'Available Beds',
              '18',
              Icons.bed,
              '88% Occupied',
              showBar: true,
            ),
            _stat(
              w,
              'Pending Fees',
              '₹45,000',
              Icons.currency_rupee,
              '8 residents',
            ),
            _stat(
              w,
              'Open Complaints',
              '5',
              Icons.notifications_active,
              '2 new today',
            ),
          ],
        );
      },
    );
  }

  Widget _stat(
    double w,
    String title,
    String value,
    IconData icon,
    String sub, {
    bool showBar = false,
  }) {
    return HoverLift(
      child: Container(
        width: w,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: _card(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Icon(icon, color: const Color(0xFF6C3BFF)),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            if (showBar)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: 0.88,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF6C3BFF)),
                ),
              )
            else
              Text(
                sub,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6C3BFF)),
              ),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
/// QUICK ACTIONS (NAVIGATION FIXED)
////////////////////////////////////////////////////////////////////////////////

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Action(
          'Manage Hostels',
          Icons.business,
          const [Color(0xFF6C3BFF), Color(0xFF8E6CFF)],
          onTap: () {
            Navigator.pushNamed(context, '/hostel-management');
          },
        ),
        _Action('Add Resident', Icons.person_add, const [
          Color(0xFF7B5CFF),
          Color(0xFFB86BFF),
        ]),
        _Action('Allocate Room', Icons.meeting_room, const [
          Color(0xFF00B3A4),
          Color(0xFF00D2C6),
        ]),
        _Action('Send Notice', Icons.notifications, const [
          Color(0xFFFF5E8E),
          Color(0xFFFF8FB3),
        ]),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  final String t;
  final IconData i;
  final List<Color> g;
  final VoidCallback? onTap;

  const _Action(this.t, this.i, this.g, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: HoverLift(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 56,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: g),
              borderRadius: BorderRadius.circular(16),
              boxShadow: _softShadow,
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(i, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    t,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
/// MAIN GRID
////////////////////////////////////////////////////////////////////////////////

class _MainGrid extends StatelessWidget {
  const _MainGrid();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Expanded(flex: 6, child: _RecentResidents()),
        SizedBox(width: 24),
        Expanded(flex: 4, child: UpcomingDues()),
      ],
    );
  }
}

class _RecentResidents extends StatelessWidget {
  const _RecentResidents();

  @override
  Widget build(BuildContext context) {
    return HoverLift(
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: _card(),
        child: const Text('Recent Residents'),
      ),
    );
  }
}

class UpcomingDues extends StatelessWidget {
  const UpcomingDues({super.key});

  @override
  Widget build(BuildContext context) {
    return HoverLift(
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: _card(),
        child: const Text('Upcoming Fee Dues'),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
/// HOVER
////////////////////////////////////////////////////////////////////////////////

class HoverLift extends StatefulWidget {
  final Widget child;
  final double lift;

  const HoverLift({super.key, required this.child, this.lift = 8});

  @override
  State<HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<HoverLift> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _hovered ? -widget.lift : 0, 0),
        child: widget.child,
      ),
    );
  }
}

BoxDecoration _card() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(18),
  boxShadow: _softShadow,
);

const _softShadow = [
  BoxShadow(color: Color(0x11000000), blurRadius: 20, offset: Offset(0, 8)),
];
