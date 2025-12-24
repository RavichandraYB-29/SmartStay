import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'assign_room_screen.dart'; // ✅ ADD THIS

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            /// MY HOSTELS CARD
            _DashboardCard(
              icon: Icons.apartment_rounded,
              title: 'My Hostels',
              subtitle: 'Create and manage PG / Hostels',
              onTap: () {
                Navigator.pushNamed(context, '/my-hostels');
              },
            ),

            const SizedBox(height: 20),

            /// ASSIGN ROOM CARD (MODULE 2)
            _DashboardCard(
              icon: Icons.meeting_room_outlined,
              title: 'Assign Room',
              subtitle: 'Allocate residents to rooms',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AssignRoomScreen()),
                );
              },
            ),

            const SizedBox(height: 20),

            /// PROFILE CARD
            _DashboardCard(
              icon: Icons.person_outline,
              title: 'Profile',
              subtitle: 'View and edit your profile',
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),

            const SizedBox(height: 20),

            /// FUTURE MODULE PLACEHOLDER
            _ComingSoonCard(),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------
/// DASHBOARD CARD WIDGET
/// ---------------------------
class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------------------
/// COMING SOON CARD
/// ---------------------------
class _ComingSoonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.grey.shade400),
            const SizedBox(width: 16),
            Text(
              'More modules coming soon',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
