import 'package:flutter/material.dart';
import 'building_3d_view.dart';
import 'building_areas_page.dart';
import 'department_config.dart';
import 'indoor_wayfinder_page.dart';

class Building3DPage extends StatefulWidget {
  final DepartmentConfig? initialDepartment;

  const Building3DPage({super.key, this.initialDepartment});

  @override
  State<Building3DPage> createState() => _Building3DPageState();
}

class _Building3DPageState extends State<Building3DPage> {
  static const Color primaryDark = Color(0xFF1A2D33);
  static const Color goldAccent = Color(0xFFB7791F);

  @override
  Widget build(BuildContext context) {
    if (widget.initialDepartment != null) {
      return DepartmentBuilding3DPage(config: widget.initialDepartment!);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F9),
      appBar: AppBar(
        title: const Text(
          'Explore Buildings',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
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
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 18),
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
            name: 'Civil Department',
            subtitle: 'Civil & Environmental Building',
            icon: Icons.architecture_rounded,
            available: true,
            themeColor: const Color(0xFF2C3E50),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DepartmentBuilding3DPage(
                    config: civilDepartmentConfig,
                  ),
                ),
              );
            },
          ),
          _BuildingOption(
            name: 'IS Department',
            subtitle: 'IS Building',
            icon: Icons.computer_rounded,
            available: true,
            themeColor: goldAccent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DepartmentBuilding3DPage(
                    config: isDepartmentConfig,
                  ),
                ),
              );
            },
          ),
          const _BuildingOption(
            name: 'Electrical Department',
            subtitle: 'Electrical Department Building',
            icon: Icons.electrical_services_rounded,
          ),
          const _BuildingOption(
            name: 'Mechanical Department',
            subtitle: 'Mechanical Department Building',
            icon: Icons.precision_manufacturing_rounded,
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
  final Color themeColor;
  final VoidCallback? onTap;

  const _BuildingOption({
    required this.name,
    required this.subtitle,
    required this.icon,
    this.available = false,
    this.themeColor = const Color(0xFFB7791F),
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
          backgroundColor: available ? themeColor : Colors.blueGrey.shade100,
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
          available
              ? Icons.arrow_forward_ios_rounded
              : Icons.lock_outline_rounded,
          size: 18,
          color: available ? themeColor : Colors.grey,
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

/// Generic, modular 3D building viewer with dynamic header title & high contrast wrapped action buttons
class DepartmentBuilding3DPage extends StatefulWidget {
  final DepartmentConfig config;

  const DepartmentBuilding3DPage({super.key, required this.config});

  @override
  State<DepartmentBuilding3DPage> createState() =>
      _DepartmentBuilding3DPageState();
}

class _DepartmentBuilding3DPageState extends State<DepartmentBuilding3DPage> {
  CivilDivision? _selectedDivision;

  void _openWayfinder(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IndoorWayfinderPage(
          departmentConfig: widget.config,
        ),
      ),
    );
  }

  void _openDepartmentAreas(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BuildingAreasPage(
          buildingId: widget.config.id,
          departmentConfig: widget.config,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final divisions = config.divisions;

    return Scaffold(
      appBar: AppBar(
        // Dynamic title based on selected department (e.g., "Civil Building 3D View" or "IS Building 3D View")
        title: Text(
          '${config.name} 3D View',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 17,
          ),
        ),
        backgroundColor: config.themeColor,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.25)),
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
        actions: [
          // High-contrast wrapped Details Icon button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.25)),
            ),
            child: IconButton(
              onPressed: () => _openDepartmentAreas(context),
              icon: const Icon(
                Icons.list_alt_rounded,
                color: Colors.white,
                size: 20,
              ),
              tooltip: 'View Areas',
            ),
          ),
          // High-contrast wrapped QR Code Icon button
          Container(
            margin: const EdgeInsets.only(left: 4, right: 12, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.25)),
            ),
            child: IconButton(
              onPressed: () => _openWayfinder(context),
              icon: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
                size: 20,
              ),
              tooltip: 'Scan indoor QR',
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 3D Canvas
          const Building3DView(),

          // Interactive Tap Raycast Division Overlay Markers
          if (divisions.isNotEmpty)
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;

                return Stack(
                  children: divisions.map((division) {
                    final isSelected = _selectedDivision?.id == division.id;
                    final posX = width * division.markerOffset.dx;
                    final posY = height * division.markerOffset.dy;

                    return Positioned(
                      left: posX - 24,
                      top: posY - 24,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDivision = division;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? division.primaryColor
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: division.primaryColor,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: division.primaryColor.withOpacity(0.35),
                                blurRadius: isSelected ? 12 : 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                division.icon,
                                size: 16,
                                color: isSelected
                                    ? Colors.white
                                    : division.primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                division.shortCode,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : division.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

          // Selected Division Bottom Mini Preview Card
          if (_selectedDivision != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _selectedDivision!.cardBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _selectedDivision!.primaryColor.withOpacity(0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _selectedDivision!.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _selectedDivision!.icon,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _selectedDivision!.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _selectedDivision!.primaryColor,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () {
                            setState(() {
                              _selectedDivision = null;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _selectedDivision!.floorLevel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _selectedDivision!.primaryColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
