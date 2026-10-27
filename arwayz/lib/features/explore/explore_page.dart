import 'package:flutter/material.dart';
import '../indoor_navigation/building_3d_page.dart';

class LocationItem {
  final String name;
  final String building;
  final IconData icon;

  const LocationItem({
    required this.name,
    required this.building,
    this.icon = Icons.location_on_rounded,
  });

  String get formattedResult => '$name - $building';
}

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  static const Color primaryDark = Color(0xFF1A2D33);
  static const Color deepTeal = Color(0xFF235559);
  static const Color mutedTeal = Color(0xFF3F727A);
  static const Color steelBlue = Color(0xFF7B929C);
  static const Color goldAccent = Color(0xFFB7791F);
  static const Color scaffoldBg = Color(0xFFF8F9F9);

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Data structure for faculty campus locations across buildings
  static const List<LocationItem> _allLocations = [
    // IS (Admin Building)
    LocationItem(name: "Dean's Office Suite", building: "IS Building", icon: Icons.admin_panel_settings_rounded),
    LocationItem(name: "Central Reception & Lobby", building: "IS Building", icon: Icons.meeting_room_rounded),
    LocationItem(name: "Faculty Board Room", building: "IS Building", icon: Icons.groups_rounded),
    LocationItem(name: "Meeting Room", building: "IS Building", icon: Icons.event_seat_rounded),
    LocationItem(name: "Electrical & Electronic Center (EEC)", building: "IS Building", icon: Icons.memory_rounded),
    LocationItem(name: "Computer Lab 1", building: "IS Building", icon: Icons.computer_rounded),
    LocationItem(name: "Computer Lab 2", building: "IS Building", icon: Icons.laptop_chromebook_rounded),
    LocationItem(name: "IS Department Head Office", building: "IS Building", icon: Icons.work_rounded),
    LocationItem(name: "IS Seminar Hall", building: "IS Building", icon: Icons.co_present_rounded),

    // Electrical & Information Engineering Building
    LocationItem(name: "EIE Main Office", building: "Electrical Dept Building", icon: Icons.business_center_rounded),
    LocationItem(name: "High Voltage Laboratory", building: "Electrical Dept Building", icon: Icons.electric_bolt_rounded),
    LocationItem(name: "Telecommunication Lab", building: "Electrical Dept Building", icon: Icons.cell_tower_rounded),
    LocationItem(name: "Electronics Lab", building: "Electrical Dept Building", icon: Icons.developer_board_rounded),
    LocationItem(name: "Robotics & Automation Lab", building: "Electrical Dept Building", icon: Icons.precision_manufacturing_rounded),
    LocationItem(name: "EIE Seminar Room", building: "Electrical Dept Building", icon: Icons.co_present_rounded),

    // Mechanical & Manufacturing Engineering Building
    LocationItem(name: "MME Head Office", building: "Mechanical Dept Building", icon: Icons.business_rounded),
    LocationItem(name: "CAD/CAM Laboratory", building: "Mechanical Dept Building", icon: Icons.desktop_windows_rounded),
    LocationItem(name: "Thermodynamics Lab", building: "Mechanical Dept Building", icon: Icons.whatshot_rounded),
    LocationItem(name: "Manufacturing Workshop", building: "Mechanical Dept Building", icon: Icons.build_rounded),
    LocationItem(name: "Fluid Mechanics Lab", building: "Mechanical Dept Building", icon: Icons.water_drop_rounded),
    LocationItem(name: "Thermodynamics Hall", building: "Mechanical Dept Building", icon: Icons.apartment_rounded),

    // Civil & Environmental Engineering Building
    LocationItem(name: "CEE Head Office", building: "Civil Dept Building", icon: Icons.corporate_fare_rounded),
    LocationItem(name: "Structural & Concrete Testing Lab", building: "Civil Dept Building", icon: Icons.foundation_rounded),
    LocationItem(name: "Geotechnical Engineering Lab", building: "Civil Dept Building", icon: Icons.terrain_rounded),
    LocationItem(name: "Hydraulics Laboratory", building: "Civil Dept Building", icon: Icons.water_rounded),
    LocationItem(name: "Environmental Engineering Lab", building: "Civil Dept Building", icon: Icons.eco_rounded),
    LocationItem(name: "Surveying Instrument Store", building: "Civil Dept Building", icon: Icons.design_services_rounded),
  ];

  List<LocationItem> get _filteredLocations {
    if (_searchQuery.trim().isEmpty) {
      return [];
    }
    final query = _searchQuery.toLowerCase();
    return _allLocations.where((item) {
      return item.name.toLowerCase().contains(query) ||
          item.building.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredLocations;
    final isSearching = _searchQuery.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Centered Header Sliver
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
              decoration: const BoxDecoration(
                color: primaryDark,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.explore_rounded, color: Colors.white, size: 28),
                      SizedBox(width: 10),
                      Text(
                        'Explore Faculty',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Search campus locations & discover departments',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFBEC4C4),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Prominent Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      style: const TextStyle(color: primaryDark, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Search locations, rooms or offices...',
                        hintStyle: const TextStyle(color: steelBlue, fontSize: 14),
                        prefixIcon: const Icon(Icons.search_rounded, color: deepTeal),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, color: steelBlue),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Body Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (isSearching) ...[
                  // SEARCH RESULTS VIEW
                  _buildSectionTitle('Search Results (${filtered.length})'),
                  const SizedBox(height: 12),
                  if (filtered.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.search_off_rounded, size: 48, color: steelBlue),
                          const SizedBox(height: 12),
                          Text(
                            'No locations matching "$_searchQuery"',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: primaryDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Try searching for "Dean\'s Office", "Lab", "Reception" or department name.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: steelBlue),
                          ),
                        ],
                      ),
                    )
                  else
                    ...filtered.map((item) => _buildSearchResultTile(context, item)),
                  const SizedBox(height: 24),
                ] else ...[
                  // STANDARD EXPLORE CONTENT
                  _buildSectionTitle('Academic Departments'),
                  const SizedBox(height: 14),

                  _buildDepartmentCard(
                    title: 'Interdisciplinary Studies (IS)',
                    subtitle: 'Computer Science, Mathematics & Software Systems',
                    icon: Icons.computer_rounded,
                    color: const Color(0xFF3F51B5),
                    highlights: [
                      'Computer Engineering & Software Systems',
                      'Augmented Reality & AI Research Labs',
                      'Interactive 3D Floor Maps Available'
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildDepartmentCard(
                    title: 'Electrical & Information Eng.',
                    subtitle: 'Electronics, Telecommunication & Smart Systems',
                    icon: Icons.electrical_services_rounded,
                    color: const Color(0xFF00897B),
                    highlights: [
                      'Power & Energy Engineering Labs',
                      'Telecommunications & Embedded Systems',
                      'Robotics & Automation Center'
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildDepartmentCard(
                    title: 'Mechanical & Manufacturing Eng.',
                    subtitle: 'Thermodynamics, Mechatronics & Production',
                    icon: Icons.precision_manufacturing_rounded,
                    color: const Color(0xFFD84315),
                    highlights: [
                      'CAD/CAM & Manufacturing Workshop',
                      'Automotive & Thermodynamics Lab',
                      'Mechatronics Innovation Center'
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildDepartmentCard(
                    title: 'Civil & Environmental Eng.',
                    subtitle: 'Structural, Hydraulic & Transportation Systems',
                    icon: Icons.architecture_rounded,
                    color: const Color(0xFF00838F),
                    highlights: [
                      'Structural & Concrete Testing Lab',
                      'Hydraulics & Fluid Mechanics Center',
                      'Environmental & Surveying Units'
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Degree Programs'),
                  const SizedBox(height: 14),
                  _buildCourseHighlightCard(),
                  const SizedBox(height: 24),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
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

  /// Displays search result in explicit format: [Location Name] - [Department/Building Name]
  Widget _buildSearchResultTile(BuildContext context, LocationItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryDark.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: deepTeal.withOpacity(0.1),
          child: Icon(item.icon, color: deepTeal, size: 22),
        ),
        title: Text(
          item.formattedResult, // Displays [Location Name] - [Department/Building Name]
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: primaryDark,
          ),
        ),
        subtitle: const Text(
          'Tap to open building location map',
          style: TextStyle(fontSize: 12, color: steelBlue),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: deepTeal),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Building3DPage(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDepartmentCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<String> highlights,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryDark.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: steelBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFECEFF1)),
            const SizedBox(height: 12),
            ...highlights.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: deepTeal.withOpacity(0.8)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 13,
                          color: primaryDark.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseHighlightCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.workspace_premium_rounded, color: goldAccent, size: 24),
              SizedBox(width: 10),
              Text(
                'B.Sc. Engineering (Honours)',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '4-Year Full Time Degree Program accredited by the Institution of Engineers Sri Lanka (IESL) under the Washington Accord.',
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.white.withOpacity(0.85),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
