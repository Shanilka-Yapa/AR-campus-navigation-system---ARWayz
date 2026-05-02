import 'package:flutter/material.dart';
import 'ar_compass_navigation_page.dart';
import 'outdoor_navigation_page.dart';

/// Navigation method selector - Choose between AR Compass or Google Maps

class NavigationSelectorPage extends StatelessWidget {
  const NavigationSelectorPage({super.key});

  // All campus locations with real coordinates
  static const List<(String, double, double, String)> campusPlaces = [
    ('Administration Building', 6.079416859527051, 80.19201064963008, 'admin'),
    ('CEE', 6.078164889030307, 80.1914069593956, 'building'),
    ('MME', 6.07859285299213, 80.19170316455609, 'building'),
    ('EIE', 6.078235704870035, 80.19216766168712, 'building'),
    ('Main Cafeteria', 6.078713286039461, 80.19253361063727, 'cafeteria'),
    ('Faculty Library', 6.079367213340776, 80.19153075282063, 'library'),
    ('Faculty Auditorium', 6.0791364229092055, 80.19126639090263, 'auditorium'),
    ('Faculty Playground', 6.081236252406866, 80.19091511916912, 'playground'),
    ('FoE Quarters', 6.080658084327748, 80.19018714697019, 'hostel'),
    ('Hostel B', 6.078065483420608, 80.19276081564473, 'hostel'),
    ('Hostel A', 6.077860310832621, 80.19304316527848, 'hostel'),
    ('Boys Hostel D', 6.081582404604873, 80.18952163605634, 'hostel'),
    ('Gymnasium', 6.0808828638193315, 80.19118258134027, 'gym'),
    ('Bo Maluwa', 6.079505589725185, 80.19106937366881, 'building'),
    ('Hela Bojun Cafeteria', 6.078723433792474, 80.19283111418744, 'cafeteria'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Navigation Method'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),
          _buildMethodCard(
            context,
            title: '🧭 AR Compass Arrow',
            subtitle: 'Realtime pointing arrow in camera',
            description:
                'Green arrow + turn-by-turn directions + 3D AR marker at destination.',
            color: Colors.green,
            destinations: campusPlaces,
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
          _buildMethodCard(
            context,
            title: '🗺️ Google Maps',
            subtitle: 'Traditional map-based navigation',
            description:
                'Full map view with markers, directions, and turn-by-turn guidance.',
            color: Colors.blue,
            destinations: const [],
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
      ),
    );
  }

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
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: destinations.isEmpty
            ? () => onSelect('University', 6.0789, 80.1922, 'building')
            : null,
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
              if (destinations.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Quick navigate to:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: destinations.map((dest) {
                    return ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
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
              ] else ...[
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onSelect('University', 6.0789, 80.1922, 'building');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Open Maps'),
                ),
              ],
            ],
          ),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
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
            const SizedBox(height: 12),
            const Text(
              '🧭 AR Compass Arrow:\n'
              '• Works with or without GPS\n'
              '• Keep device level\n'
              '• Arrow points to destination\n'
              '• Shows real-time distance',
              style: TextStyle(fontSize: 12, height: 1.6),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              '🗺️ Google Maps:\n'
              '• Full map interface\n'
              '• Requires internet\n'
              '• Shows multiple routes\n'
              '• Complete turn-by-turn',
              style: TextStyle(fontSize: 12, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
