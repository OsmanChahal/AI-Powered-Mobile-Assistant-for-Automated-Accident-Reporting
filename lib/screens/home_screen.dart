import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/report_state.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'profile_screen.dart';
import 'report_details_screen.dart';

class HomeScreen extends StatefulWidget {
  final ReportState state;

  const HomeScreen({super.key, required this.state});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Helper method to format the Firebase Timestamp into a readable string
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'Dashboard' : 'Profile'),
        actions: [
          if (_currentIndex == 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.blue50,
                child: const Text('JS',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.blue600)),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.border),
        ),
      ),
      body: _currentIndex == 0 ? _buildDashboard() : const ProfileScreen(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDashboard() {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PrimaryButton(
            label: '+ Report new accident',
            onTap: () {
              widget.state.startNewReport();
              Navigator.pushNamed(context, '/plate-instructions');
            },
          ),
          const SizedBox(height: 24),
          const SectionLabel(text: 'Recent assessments'),

          // 🔑 StreamBuilder to fetch real-time data from Firestore
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Reports')
                .where('reported_by', isEqualTo: currentUserId)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.blue600),
                  ),
                );
              }

              if (snapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text('Error loading reports.',
                        style: TextStyle(color: Colors.redAccent)),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return _buildEmptyState();
              }

              return Column(
                children: docs.map((doc) => _buildRecentItem(doc)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.directions_car_outlined,
                size: 48, color: AppColors.textTertiary),
            SizedBox(height: 12),
            Text('No assessments yet',
                style: TextStyle(fontSize: 13, color: AppColors.textTertiary)),
          ],
        ),
      ),
    );
  }

  // 🔑 Updated to parse data directly from a Firestore Document
  Widget _buildRecentItem(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Safely extract timestamp
    final timestamp = data['timestamp'] as Timestamp?;
    final dateStr =
        timestamp != null ? _formatDate(timestamp.toDate()) : 'Recently';

    // Safely extract car details from your Array of Maps structure
    final carsInvolved = data['cars_involved'] as List<dynamic>? ?? [];

    String plate = 'Unknown Plate';
    String damageStr = 'Damage assessed';
    String severity = 'Low';

    if (carsInvolved.isNotEmpty) {
      final firstCar = carsInvolved.first as Map<String, dynamic>;
      plate = firstCar['license_plate'] ?? 'Unknown Plate';

      final parts = firstCar['detected_parts'] as List<dynamic>? ?? [];
      if (parts.isNotEmpty) {
        damageStr = parts.join(', ');
        // Simple logic to set a severity badge based on the number of parts damaged
        if (parts.length >= 3) {
          severity = 'High';
        } else if (parts.length == 2) {
          severity = 'Medium';
        }
      }
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReportDetailsScreen(data: data),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.blue50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.directions_car,
                  size: 22, color: AppColors.blue600),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plate,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                          fontFamily: 'Courier')),
                  const SizedBox(height: 2),
                  Text('$dateStr · $damageStr',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textTertiary)),
                ],
              ),
            ),
            SeverityPill(label: severity),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right,
                size: 18, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        color: Colors.white,
      ),
      child: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppColors.blue600,
        unselectedItemColor: AppColors.textTertiary,
        selectedLabelStyle:
            const TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
