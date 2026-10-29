import 'package:flutter/material.dart';
import 'building_3d_view.dart';
import 'indoor_wayfinder_page.dart';

class Building3DPage extends StatefulWidget {
  const Building3DPage({super.key});

  @override
  State<Building3DPage> createState() => _Building3DPageState();
}

class _Building3DPageState extends State<Building3DPage> {
  static const Color primaryDark = Color(0xFF1A2D33);
  static const Color goldAccent = Color(0xFFB7791F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F9),
      appBar: AppBar(
        title: const Text(
          'Explore Buildings',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        backgroundColor: primaryDark,
        centerTitle: true,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            onPressed: () => Navigator.maybePop(context),
            tooltip: 'Back',
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Choose a department building',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primaryDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Select a building to open its interactive 3D floorplan view.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13.5),
          ),
          const SizedBox(height: 24),
          _BuildingOption(
            name: 'IS Department',
            subtitle: 'IS Building',
            icon: Icons.computer_rounded,
            available: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const _IsBuilding3DPage(),
                ),
              );
            },
          ),
          _BuildingOption(
            name: 'Electrical Department',
            subtitle: 'Electrical Department Building',
            icon: Icons.electrical_services_rounded,
          ),
          _BuildingOption(
            name: 'Mechanical Department',
            subtitle: 'Mechanical Department Building',
            icon: Icons.precision_manufacturing_rounded,
          ),
          _BuildingOption(
            name: 'Civil Engineering Department',
            subtitle: 'Civil Engineering Building',
            icon: Icons.architecture_rounded,
          ),
        ],
      ),
    );
  }
}

class _BuildingOption extends StatelessWidget {
  final String name;
  final String subtitle;
  final IconData icon;
  final bool available;
  final VoidCallback? onTap;

  const _BuildingOption({
    required this.name,
    required this.subtitle,
    required this.icon,
    this.available = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: available
              ? const Color(0xFFB7791F)
              : Colors.blueGrey.shade100,
          child: Icon(
            icon,
            color: available ? Colors.white : Colors.blueGrey.shade600,
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          available ? subtitle : '$subtitle • 3D view coming soon',
          style: const TextStyle(fontSize: 12.5),
        ),
        trailing: Icon(
          available ? Icons.arrow_forward_ios_rounded : Icons.lock_outline_rounded,
          size: 18,
          color: available ? const Color(0xFFB7791F) : Colors.grey,
        ),
        onTap: available
            ? onTap
            : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('This department 3D view is coming soon.'),
                  ),
                );
              },
      ),
    );
  }
}

class _IsBuilding3DPage extends StatelessWidget {
  const _IsBuilding3DPage();

  void _openWayfinder(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const IndoorWayfinderPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'IS Building 3D View',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF1A2D33),
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            onPressed: () => Navigator.maybePop(context),
            tooltip: 'Back',
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _openWayfinder(context),
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: 'If you are inside the IS Building, select your destination and scan the nearest floor QR to get support',
          ),
        ],
      ),
      body: const Building3DView(),
    );
  }
}
