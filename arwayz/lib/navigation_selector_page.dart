import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ar_compass_navigation_page.dart';
import 'outdoor_navigation_page.dart';

class NavigationSelectorPage extends StatelessWidget {
  const NavigationSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Navigation Method'),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('buildings').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Convert Firebase data to our list format using your specific fields
          final List<(String, double, double, String)> liveCampusPlaces = 
              snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            
            return (
              (data['name'] ?? 'Unknown') as String,
              (data['latitude'] ?? 6.0794) as double,
              (data['longitude'] ?? 80.192) as double,
              (data['type'] ?? 'building') as String,
            );
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 16),
              // --- AR NAVIGATION CARD ---
              _buildMethodCard(
                context,
                title: '🧭 AR Compass Arrow',
                subtitle: 'Realtime pointing arrow in camera',
                description: 'Green arrow + turn-by-turn directions + 3D AR marker at destination.',
                color: Colors.green,
                destinations: liveCampusPlaces,
                onSelect: (destName, lat, lon, type) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ARCompassNavigationPage(
                        destLat: lat,
                        destLon: lon,
                        destName: destName,
                        locationType: type,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // --- GOOGLE MAPS CARD ---
              _buildMethodCard(
                context,
                title: '🗺️ Google Maps',
                subtitle: 'Traditional map-based navigation',
                description: 'Full map view with markers, directions, and turn-by-turn guidance.',
                color: Colors.blue,
                destinations: liveCampusPlaces, // Now shows your buildings here too!
                onSelect: (destName, lat, lon, type) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OutdoorNavigationPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildInfoCard(),
            ],
          );
        },
      ),
    );
  }

  // --- HELPER FUNCTIONS ---

  Widget _buildMethodCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    required List<(String, double, double, String)> destinations,
    required Function(String, double, double, String) onSelect,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Select a destination:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            if (destinations.isEmpty)
              const Text("No buildings found in database.", style: TextStyle(fontSize: 12, color: Colors.red))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: destinations.map((dest) {
                  return ElevatedButton(
                    onPressed: () {
                      // This uses the specific lat/lon for the button you click!
                      onSelect(dest.$1, dest.$2, dest.$3, dest.$4);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color.withOpacity(0.8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      dest.$1,
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade200),
      ),
      child: const Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Navigation Tips',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              '🧭 AR Compass Arrow:\n'
              '• Works with or without GPS\n'
              '• Keep device level\n'
              '• Arrow points to destination',
              style: TextStyle(fontSize: 12, height: 1.6),
            ),
            SizedBox(height: 12),
            Divider(),
            SizedBox(height: 12),
            Text(
              '🗺️ Google Maps:\n'
              '• Full map interface\n'
              '• Requires internet\n'
              '• Complete turn-by-turn',
              style: TextStyle(fontSize: 12, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}