import 'package:flutter/material.dart';
import 'main.dart'; // Import your main.dart for navigation

class BuildingAreasPage extends StatelessWidget {
  final String buildingId;

  const BuildingAreasPage({super.key, required this.buildingId});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> areas = [
      {'name': 'Dining area 01', 'icon': Icons.restaurant_menu},
      {'name': 'Dining area 02', 'icon': Icons.restaurant_menu},
      {'name': 'Bookshop', 'icon': Icons.book},
      {'name': 'Study area 01', 'icon': Icons.school},
      {'name': 'Carrom room', 'icon': Icons.sports},
      {'name': 'Art room', 'icon': Icons.brush},
      {'name': 'Gym', 'icon': Icons.fitness_center},
      {'name': 'Washroom', 'icon': Icons.wc},
    ];

    return Scaffold(
      body: Column(
        children: [
          // Curved Header with Back Button
          Stack(
            children: [
              ClipPath(
                clipper: HeaderClipper(),
                child: Container(
                  height: 180,
                  color: const Color(0xFF1A2D33),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_city, color: Colors.white, size: 40),
                      const SizedBox(height: 8),
                      const Text(
                        'Main Cafeteria',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Building $buildingId',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Back Button
              Positioned(
                top: 40,
                left: 16,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Navigate back to main.dart
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),

          // Area List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: areas.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(areas[index]['icon'], color: const Color(0xFF1A2D33)),
                    title: Text(
                      areas[index]['name'],
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () {
                      debugPrint('Selected area: ${areas[index]['name']}');
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Custom clipper for curved header
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 2, size.height,
      size.width, size.height - 50,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
