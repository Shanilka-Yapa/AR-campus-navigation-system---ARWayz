import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'route_preview_page.dart';
import 'outdoor_navigation_page.dart';

class NavigationSelectorPage extends StatelessWidget {
  const NavigationSelectorPage({super.key});

  // Color Palette Definitions
  static const Color primaryDark = Color(0xFF1A2D33);
  static const Color deepTeal = Color(0xFF235559);
  static const Color mutedTeal = Color(0xFF3F727A);
  static const Color steelBlue = Color(0xFF7B929C);
  static const Color lightGray = Color(0xFFBEC4C4);
  static const Color scaffoldBg = Color(0xFFF8F9F9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: const Text(
          'Choose Navigation Method',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryDark,
        elevation: 4,
        shadowColor: primaryDark.withOpacity(0.5),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('buildings').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: deepTeal),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              _buildSectionHeader('Available Methods'),
              const SizedBox(height: 16),
              // --- AR NAVIGATION CARD ---
              _buildMethodCard(
                context,
                title: 'AR Compass Arrow',
                icon: Icons.explore_rounded,
                subtitle: 'Realtime camera-based guidance',
                description:
                    'Green arrow + turn-by-turn directions + 3D AR marker at destination.',
                accentColor: mutedTeal,
                destinations: liveCampusPlaces,
                onSelect: (destName, lat, lon, type) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoutePreviewPage(
                        destLat: lat,
                        destLng: lon,
                        placeName: destName,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // --- GOOGLE MAPS CARD ---
              _buildMethodCard(
                context,
                title: 'Google Maps',
                icon: Icons.map_rounded,
                subtitle: 'Traditional map-based navigation',
                description:
                    'Full map view with markers, directions, and turn-by-turn guidance.',
                accentColor: steelBlue,
                destinations: liveCampusPlaces,
                onSelect: (destName, lat, lon, type) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OutdoorNavigationPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildInfoCard(),
            ],
          );
        },
      ),
    );
  }

  // --- UI HELPER COMPONENTS ---

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: steelBlue,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        fontSize: 13,
      ),
    );
  }

  Widget _buildMethodCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String subtitle,
    required String description,
    required Color accentColor,
    required List<(String, double, double, String)> destinations,
    required Function(String, double, double, String) onSelect,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryDark.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: accentColor.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(icon, color: accentColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryDark,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(fontSize: 13, color: steelBlue),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: primaryDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: lightGray, height: 1),
                  const SizedBox(height: 16),
                  const Text(
                    'SELECT DESTINATION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: steelBlue,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (destinations.isEmpty)
                    const Text("No buildings found in database.",
                        style: TextStyle(fontSize: 12, color: Colors.redAccent))
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: destinations.map((dest) {
                        return ElevatedButton(
                          onPressed: () => onSelect(dest.$1, dest.$2, dest.$3, dest.$4),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: deepTeal,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            dest.$1,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: primaryDark,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tips_and_updates_outlined, color: lightGray),
              SizedBox(width: 8),
              Text(
                'Navigation Tips',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.check_circle_outline, 
              'AR Compass: Keep device level and works without GPS.'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.check_circle_outline, 
              'Google Maps: Full turn-by-turn. Requires active internet.'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: steelBlue),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: lightGray, height: 1.4),
          ),
        ),
      ],
    );
  }
}