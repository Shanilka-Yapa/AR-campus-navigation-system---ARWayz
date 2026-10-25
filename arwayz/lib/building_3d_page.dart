import 'package:flutter/material.dart';
import 'building_3d_view.dart';
import 'indoor_wayfinder_page.dart';

class Building3DPage extends StatefulWidget {
  const Building3DPage({super.key});

  @override
  State<Building3DPage> createState() => _Building3DPageState();
}

class _Building3DPageState extends State<Building3DPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Buildings'),
        backgroundColor: const Color(0xFF1A2D33),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Choose a department building',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A2D33),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a building to open its interactive 3D view.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 24),
          _BuildingOption(
            name: 'IS Department',
            subtitle: 'IS Building',
            icon: Icons.computer,
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
            icon: Icons.electrical_services,
          ),
          _BuildingOption(
            name: 'Mechanical Department',
            subtitle: 'Mechanical Department Building',
            icon: Icons.precision_manufacturing,
          ),
          _BuildingOption(
            name: 'Civil Engineering Department',
            subtitle: 'Civil Engineering Building',
            icon: Icons.architecture,
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
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          available ? subtitle : '$subtitle • 3D view coming soon',
        ),
        trailing: Icon(
          available ? Icons.arrow_forward_ios : Icons.lock_outline,
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
        title: const Text('IS Building 3D View'),
        backgroundColor: const Color(0xFF1A2D33),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _openWayfinder(context),
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Open ',
          ),
        ],
      ),
      body: const Building3DView(),
    );
  }
}