import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../outdoor_navigation/route_preview_page.dart';
import '../outdoor_navigation/outdoor_navigation_page.dart';

class NavigationSelectorPage extends StatelessWidget {
  const NavigationSelectorPage({super.key});

  // Color Palette Definitions
  static const Color primaryDark = Color(0xFF1A2D33);
  static const Color deepTeal = Color(0xFF235559);
  static const Color mutedTeal = Color(0xFF3F727A);
  static const Color steelBlue = Color(0xFF7B929C);
  static const Color lightGray = Color(0xFFBEC4C4);
  static const Color goldAccent = Color(0xFFB7791F);
  static const Color scaffoldBg = Color(0xFFF8F9F9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: const Text(
          'Select Your Campus Navigation Mode',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: primaryDark,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
            onPressed: () => Navigator.maybePop(context),
            tooltip: 'Back',
          ),
        ),
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
                'Error loading destinations: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final List<(String, double, double, String)> liveCampusPlaces =
              (snapshot.hasData && snapshot.data != null)
              ? snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return (
                    (data['name'] ?? 'Unknown Building') as String,
                    (data['latitude'] ?? 6.0794) as double,
                    (data['longitude'] ?? 80.192) as double,
                    (data['type'] ?? 'building') as String,
                  );
                }).toList()
              : [];

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Subtitle Banner Box
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
                  decoration: const BoxDecoration(
                    color: primaryDark,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Choose between AR camera compass guidance, GPS maps',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Main Navigation Modes Content
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSectionHeader('Outdoor Navigation Options'),
                    const SizedBox(height: 16),

                    // --- MODE 1: AR COMPASS ARROW CARD ---
                    _buildModernMethodCard(
                      context,
                      title: 'AR Compass Arrow',
                      tagLine: 'AR CAMERA GUIDANCE',
                      icon: Icons.compass_calibration_rounded,
                      gradientColors: [
                        const Color(0xFF235559),
                        const Color(0xFF3F727A),
                      ],
                      accentColor: goldAccent,
                      description:
                          'Realtime green direction arrow overlaid on your camera feed with 3D AR location markers.',
                      destinations: liveCampusPlaces,
                      onSelectDestination: (name, lat, lon, type) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RoutePreviewPage(
                              destLat: lat,
                              destLng: lon,
                              placeName: name,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // --- MODE 2: GOOGLE MAPS OUTDOOR CARD ---
                    _buildModernMethodCard(
                      context,
                      title: 'Google Maps Outdoor',
                      tagLine: 'GPS & MAP ROUTING',
                      icon: Icons.map_rounded,
                      gradientColors: [
                        const Color(0xFF1A2D33),
                        const Color(0xFF2C444E),
                      ],
                      accentColor: const Color(0xFF2A72D0),
                      description:
                          'Full interactive satellite map with markers, distance calculations, and turn-by-turn walking paths.',
                      destinations: liveCampusPlaces,
                      onSelectDestination: (name, lat, lon, type) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OutdoorNavigationPage(
                              destLat: lat,
                              destLon: lon,
                              destinationName: name,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Navigation Guidance Tips
                    _buildTipsCard(),

                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: steelBlue,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        fontSize: 12.5,
      ),
    );
  }

  /// Modern Interactive Grid Card
  Widget _buildModernMethodCard(
    BuildContext context, {
    required String title,
    required String tagLine,
    required IconData icon,
    required List<Color> gradientColors,
    required Color accentColor,
    required String description,
    required List<(String, double, double, String)> destinations,
    required Function(String, double, double, String) onSelectDestination,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: primaryDark.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tagLine,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Description & Destination Selection Grid
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.5,
                      color: primaryDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFECEFF1)),
                  const SizedBox(height: 14),
                  const Text(
                    'SELECT DESTINATION TO START',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: steelBlue,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (destinations.isEmpty)
                    const Text(
                      'No campus buildings loaded.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orangeAccent,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: destinations.map((dest) {
                        return ElevatedButton.icon(
                          onPressed: () => onSelectDestination(
                            dest.$1,
                            dest.$2,
                            dest.$3,
                            dest.$4,
                          ),
                          icon: const Icon(Icons.near_me_rounded, size: 14),
                          label: Text(
                            dest.$1,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: deepTeal,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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

  Widget _buildTipsCard() {
    return Container(
      decoration: BoxDecoration(
        color: primaryDark,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.tips_and_updates_outlined,
                color: goldAccent,
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'Navigation Guidance Tips',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            Icons.check_circle_outline,
            'AR Compass: Hold phone vertically. Works outdoors without requiring continuous GPS signal.',
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            Icons.check_circle_outline,
            'Google Maps: Outdoor turn-by-turn routing using live device GPS location.',
          ),
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
            style: const TextStyle(
              fontSize: 12.5,
              color: lightGray,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
