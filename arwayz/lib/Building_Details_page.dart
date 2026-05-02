
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'ar_compass_navigation_page.dart';

// ─── Data Model ───────────────────────────────────────────────────────────────

class BuildingInfo {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<Facility> facilities;
  final String? openingHours;
  final String? floor;
  final double destLat;
  final double destLon;
  final String locationType;
  final bool isOpenWeekends;

  const BuildingInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.facilities,
    required this.destLat,
    required this.destLon,
    this.locationType = 'building',
    this.openingHours,
    this.floor,
    this.isOpenWeekends = false,
  });
}

class Facility {
  final IconData icon;
  final String label;

  const Facility({required this.icon, required this.label});
}

// ─── Campus Buildings Data ────────────────────────────────────────────────────

final List<BuildingInfo> campusBuildings = [
  BuildingInfo(
    id: 'ADM',
    name: 'Administration Building',
    description:
    'The Administration Building is the central hub of the Faculty of Engineering, '
        'University of Ruhuna. It houses the Dean\'s Office, faculty administration, '
        'finance division, and key administrative services. All official academic and '
        'administrative matters are handled here. The building features a grand entrance '
        'flanked by palm trees and well-maintained gardens.',
    imageUrl: 'assets/images/admin_building.png',
    openingHours: '8:30 AM – 4:30 PM (Weekdays only)',
    floor: 'Ground – 3rd Floor',
    locationType: 'admin',
    destLat: 6.079485747386843,
    destLon: 80.19192167968897,
    isOpenWeekends: false,
    facilities: const [
      Facility(icon: Icons.admin_panel_settings, label: 'Dean\'s Office'),
      Facility(icon: Icons.account_balance,       label: 'Finance'),
      Facility(icon: Icons.wifi,                  label: 'Free Wi-Fi'),
      Facility(icon: Icons.accessible,            label: 'Accessible'),
      Facility(icon: Icons.local_parking,         label: 'Parking'),
      Facility(icon: Icons.security,              label: 'Security'),
      Facility(icon: Icons.phone,                 label: 'Reception'),
      Facility(icon: Icons.engineering,              label: 'EEC'),
    ],
  ),

  BuildingInfo(
    id: 'DCEE',
    name: 'Dept. of Civil & Env. Engineering',
    description:
    'The Department of Civil and Environmental Engineering (DCEE) is one of the '
        'leading departments at the Faculty of Engineering. It offers undergraduate and '
        'postgraduate programmes in civil, structural, and environmental engineering. '
        'The building contains advanced laboratories for materials testing, hydraulics, '
        'surveying, and environmental analysis, supporting cutting-edge research.',
    imageUrl: 'assets/images/dcee.png',
    openingHours: '8:30 AM – 4:30 PM (Weekdays only)',
    floor: 'Ground – 3rd Floor',
    locationType: 'building',
    destLat: 6.0781849,
    destLon: 80.1913757,
    isOpenWeekends: false,
    facilities: const [
      Facility(icon: Icons.science,        label: 'Hydraulics Lab'),
      Facility(icon: Icons.architecture,   label: 'Survey Lab'),
      Facility(icon: Icons.wifi,           label: 'Free Wi-Fi'),
      Facility(icon: Icons.meeting_room,   label: 'Meeting Room'),
      Facility(icon: Icons.print,          label: 'Printing'),
      Facility(icon: Icons.accessible,     label: 'Accessible'),
      Facility(icon: Icons.local_library,  label: 'Reading Area'),
      Facility(icon: Icons.school,       label: 'Lecture Rooms'),
    ],
  ),

  BuildingInfo(
    id: 'DMME',
    name: 'Dept. of Mechanical & Mfg. Engineering',
    description:
    'The Department of Mechanical and Manufacturing Engineering (DMME) is a '
        'premier destination for engineering innovation. The modern multi-storey building '
        'hosts state-of-the-art laboratories for thermodynamics, fluid mechanics, '
        'manufacturing processes, and robotics. Students benefit from industry-standard '
        'equipment and strong links with the engineering sector.',
    imageUrl: 'assets/images/dmme.png',
    openingHours: '8:30 AM – 4:30 PM (Weekdays only)',
    floor: 'Ground – 4th Floor',
    locationType: 'building',
    destLat: 6.0784190,
    destLon: 80.1918074,
    isOpenWeekends: false,
    facilities: const [
      Facility(icon: Icons.precision_manufacturing, label: 'Mfg. Lab'),
      Facility(icon: Icons.thermostat,              label: 'Thermo Lab'),
      Facility(icon: Icons.wifi,                    label: 'Free Wi-Fi'),
      Facility(icon: Icons.meeting_room,            label: 'Project Room'),
      Facility(icon: Icons.print,                   label: 'Printing'),
      Facility(icon: Icons.accessible,              label: 'Accessible'),
      Facility(icon: Icons.school,                label: 'Lecture Rooms'),
      Facility(icon: Icons.security,                label: 'Security'),
    ],
  ),

  BuildingInfo(
    id: 'DEIE',
    name: 'Dept. of Electrical & Info. Engineering',
    description:
    'The Department of Electrical and Information Engineering (DEIE) drives '
        'innovation in electronics, telecommunications, and information technology. '
        'The department building houses advanced labs for embedded systems, power '
        'electronics, signal processing, and networking. It is a vibrant centre for '
        'research and technology development at the Faculty of Engineering.',
    imageUrl: 'assets/images/deie.png',
    openingHours: '8:30 AM – 4:30 PM (Weekdays only)',
    floor: 'Ground – 3rd Floor',
    locationType: 'building',
    destLat: 6.0781742,
    destLon: 80.1921752,
    isOpenWeekends: false,
    facilities: const [
      Facility(icon: Icons.electrical_services, label: 'Electronics Lab'),
      Facility(icon: Icons.router,              label: 'Network Lab'),
      Facility(icon: Icons.wifi,                label: 'Free Wi-Fi'),
      Facility(icon: Icons.meeting_room,        label: 'Seminar Room'),
      Facility(icon: Icons.computer,            label: 'Computer Lab'),
      Facility(icon: Icons.print,               label: 'Printing'),
      Facility(icon: Icons.accessible,          label: 'Accessible'),
      Facility(icon: Icons.security,            label: 'Security'),
    ],
  ),

  BuildingInfo(
    id: 'LIB',
    name: 'Faculty Library',
    description:
    'The Faculty Library is a quiet and resourceful study environment for '
        'engineering students and staff. It holds a comprehensive collection of '
        'textbooks, journals, research papers, and digital resources across all '
        'engineering disciplines. The library offers individual study tables, '
        'group study areas, and computer workstations with internet access.',
    imageUrl: 'assets/images/library.png',
    openingHours: '8:30 AM – 4:30 PM (Weekdays only)',
    floor: 'Ground-2nd',
    locationType: 'library',
    destLat: 6.0794413,
    destLon: 80.1915942,
    isOpenWeekends: false,
    facilities: const [
      Facility(icon: Icons.local_library,  label: 'Book Collection'),
      Facility(icon: Icons.space_dashboard,label: 'Free space'),
      Facility(icon: Icons.wifi,           label: 'Free Wi-Fi'),
      Facility(icon: Icons.meeting_room,   label: 'Study Rooms'),
      Facility(icon: Icons.print,          label: 'Printing'),
      Facility(icon: Icons.accessible,     label: 'Accessible'),
      Facility(icon: Icons.description,    label: 'Past Papers'),
      Facility(icon: Icons.security,       label: 'Security'),
    ],
  ),

  BuildingInfo(
    id: 'GUEST',
    name: 'Guest House',
    description:
    'The Faculty Guest House provides comfortable accommodation for visiting '
        'academics, researchers, and invited guests of the Faculty of Engineering. '
        'Set in a serene, green environment surrounded by tropical trees, the guest '
        'house offers a peaceful retreat within the campus. It is also used for '
        'small workshops and visiting lecturer stays.',
    imageUrl: 'assets/images/guest.png',
    openingHours: '8:30 AM – 4:30 PM (Weekdays only)',
    floor: 'Ground – 1st Floor',
    locationType: 'hostel',
    destLat: 6.0783298,
    destLon: 80.1908615,
    isOpenWeekends: false,
    facilities: const [
      Facility(icon: Icons.hotel,          label: 'Guest Rooms'),
      Facility(icon: Icons.wifi,           label: 'Free Wi-Fi'),
      Facility(icon: Icons.local_cafe,     label: 'Kitchenette'),
      Facility(icon: Icons.accessible,     label: 'Accessible'),
      Facility(icon: Icons.local_parking,  label: 'Parking'),
      Facility(icon: Icons.security,       label: '24 h Security'),
      Facility(icon: Icons.nature,         label: 'Garden View'),
      Facility(icon: Icons.ac_unit,        label: 'Air Conditioned'),
    ],
  ),

  BuildingInfo(
    id: 'LHALL',
    name: 'Lecture Halls Complex',
    description:
    'The Lecture Halls Complex is the primary venue for undergraduate lectures '
        'and tutorials across all engineering departments. It features large, '
        'well-equipped lecture theatres with modern audio-visual systems, comfortable '
        'seating, and excellent acoustics. The complex is designed to support '
        'large-batch teaching and interactive learning sessions.',
    imageUrl: 'assets/images/lhall.png',
    openingHours: '8:30 AM – 4:30 PM (Weekdays only)',
    floor: 'Ground – 2nd Floor',
    locationType: 'building',
    destLat: 6.079001836440434,
    destLon: 80.19137467284587,
    isOpenWeekends: false,
    facilities: const [
      Facility(icon: Icons.cast_for_education, label: 'AV Systems'),
      Facility(icon: Icons.wifi,               label: 'Free Wi-Fi'),
      Facility(icon: Icons.accessible,         label: 'Accessible'),
      Facility(icon: Icons.ac_unit,            label: 'Air Conditioned'),
      Facility(icon: Icons.security,           label: 'Security'),
      Facility(icon: Icons.local_drink,        label: 'Water Fountain'),
      Facility(icon: Icons.wc,                 label: 'Restrooms'),
      Facility(icon: Icons.elevator,           label: 'Elevator'),
    ],
  ),

  BuildingInfo(
    id: 'WORKSHOP',
    name: 'DMME Workshop',
    description:
    'The DMME Workshop is a dedicated practical training facility for mechanical '
        'and manufacturing engineering students. Equipped with industrial-grade machinery '
        'including lathes, milling machines, welding stations, and CNC equipment, '
        'it provides hands-on experience essential for engineering practice. '
        'Safety training is mandatory before accessing the workshop.',
    imageUrl: 'assets/images/workshop.png',
    openingHours: '8:30 AM – 4:30 PM (Weekdays only)',
    floor: 'Ground – 1st Floor',
    locationType: 'building',
    destLat: 6.0775015,
    destLon: 80.1909446,
    isOpenWeekends: false,
    facilities: const [
      Facility(icon: Icons.build,                   label: 'CNC Machines'),
      Facility(icon: Icons.precision_manufacturing, label: 'Lathes'),
      Facility(icon: Icons.local_fire_department,   label: 'Welding'),
      Facility(icon: Icons.security,                label: 'Safety Gear'),
      Facility(icon: Icons.accessible,              label: 'Accessible'),
      Facility(icon: Icons.local_parking,           label: 'Parking'),
      Facility(icon: Icons.wifi,                    label: 'Free Wi-Fi'),
      Facility(icon: Icons.wc,                      label: 'Restrooms'),
    ],
  ),

  BuildingInfo(
    id: 'GATE',
    name: 'Main Gate',
    description:
    'The Main Gate is the primary entrance to the Faculty of Engineering, '
        'University of Ruhuna. It serves as the landmark entry point for students, '
        'staff, and visitors. The gate features a security checkpoint and a prominent '
        'sign proudly displaying the name of the institution. It is the starting '
        'point for navigating across the beautiful green campus.',
    imageUrl: 'assets/images/main_gate.png',
    openingHours: '8:30 AM – 4:30 PM (Weekdays only)',
    floor: 'Ground Level',
    locationType: 'admin',
    destLat: 6.0795878,
    destLon: 80.1924846,
    isOpenWeekends: false,
    facilities: const [
      Facility(icon: Icons.security,      label: 'Security Post'),
      Facility(icon: Icons.local_parking, label: 'Visitor Parking'),
      Facility(icon: Icons.accessible,    label: 'Accessible'),
      Facility(icon: Icons.info,          label: 'Info Board'),
      Facility(icon: Icons.camera_alt,    label: 'CCTV'),
      Facility(icon: Icons.phone,         label: 'Intercom'),
      Facility(icon: Icons.directions,    label: 'Signage'),
      Facility(icon: Icons.wc,            label: 'Restrooms'),
    ],
  ),

  BuildingInfo(
    id: 'PLAY',
    name: 'Faculty Playground',
    description:
    'The Faculty Playground is a spacious outdoor recreational area for '
        'engineering students and staff. It supports a range of sports activities '
        'including cricket, football, and athletics. The grounds are well maintained '
        'and provide a refreshing space for students to unwind between lectures. '
        'Inter-department tournaments and sports events are regularly held here.',
    imageUrl: 'assets/images/ground.jpg',
    openingHours: '8:30 AM – 4:30 PM (Weekdays only)',
    floor: 'Open Ground',
    locationType: 'playground',
    destLat: 6.081252611543052,
    destLon: 80.19055393525753,
    isOpenWeekends: false,
    facilities: const [
      Facility(icon: Icons.sports_cricket,  label: 'Cricket'),
      Facility(icon: Icons.sports_soccer,   label: 'Football'),
      Facility(icon: Icons.directions_run,  label: 'Athletics'),
      Facility(icon: Icons.accessible,      label: 'Accessible'),
      Facility(icon: Icons.local_drink,     label: 'Water Point'),
      Facility(icon: Icons.wc,              label: 'Restrooms'),
      Facility(icon: Icons.security,        label: 'Security'),
      Facility(icon: Icons.nature,          label: 'Green Space'),
    ],
  ),
];

// ─── Default sample building used in main.dart ───────────────────────────────
final sampleBuilding = campusBuildings[0];

// ─── Voice Navigation Service ─────────────────────────────────────────────────

enum NavigationDirection { straight, left, right }

class VoiceNavigationService {
  final FlutterTts _tts = FlutterTts();
  NavigationDirection? _lastDirection;

  VoiceNavigationService() {
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.45);
    _tts.setVolume(1.0);
    _tts.setPitch(1.0);
  }

  static String _label(NavigationDirection dir) {
    switch (dir) {
      case NavigationDirection.straight:
        return 'Go straight';
      case NavigationDirection.left:
        return 'Turn left';
      case NavigationDirection.right:
        return 'Turn right';
    }
  }

  Future<void> onDirectionUpdate(NavigationDirection direction) async {
    if (direction == _lastDirection) return;
    _lastDirection = direction;
    await _tts.speak(_label(direction));
  }

  Future<void> speakArrival(String buildingName) async {
    _lastDirection = null;
    await _tts.speak('You have arrived at $buildingName');
  }

  Future<void> dispose() async => _tts.stop();
}

// ─── Campus Selector Page ─────────────────────────────────────────────────────

class CampusSelectorPage extends StatefulWidget {
  const CampusSelectorPage({super.key});

  @override
  State<CampusSelectorPage> createState() => _CampusSelectorPageState();
}

class _CampusSelectorPageState extends State<CampusSelectorPage> {
  String _search = '';

  static const Color _bg      = Color(0xFF0F1117);
  static const Color _surface = Color(0xFF1A1D27);
  static const Color _accent  = Color(0xFF4ECDC4);
  static const Color _textPri = Color(0xFFF0F2F5);
  static const Color _textSec = Color(0xFF8A90A2);
  static const Color _border  = Color(0xFF2A2D3A);

  List<BuildingInfo> get _filtered => campusBuildings
      .where((b) =>
  b.name.toLowerCase().contains(_search.toLowerCase()) ||
      b.id.toLowerCase().contains(_search.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context),
            _buildSearchBar(),
            _buildSubtitle(),
            Expanded(child: _buildBuildingList()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _surface,
                shape: BoxShape.circle,
                border: Border.all(color: _border),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _textPri, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Campus Destinations',
                style: TextStyle(
                  color: _textPri,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'University of Ruhuna — Faculty of Engineering',
                style: TextStyle(color: _textSec, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: TextField(
          onChanged: (v) => setState(() => _search = v),
          style: const TextStyle(color: _textPri, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search buildings...',
            hintStyle: const TextStyle(color: _textSec, fontSize: 14),
            prefixIcon:
            const Icon(Icons.search_rounded, color: _accent, size: 20),
            border: InputBorder.none,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: _accent,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${_filtered.length} location${_filtered.length == 1 ? '' : 's'} found',
            style: const TextStyle(
                color: _textSec, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withOpacity(0.4)),
            ),
            child: Row(
              children: const [
                Icon(Icons.access_time_rounded,
                    color: Colors.green, size: 12),
                SizedBox(width: 4),
                Text(
                  '8:30 AM – 4:30 PM',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuildingList() {
    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.search_off_rounded, color: _textSec, size: 48),
            SizedBox(height: 12),
            Text('No buildings found',
                style: TextStyle(color: _textSec, fontSize: 15)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: _filtered.length,
      itemBuilder: (_, i) => _buildingCard(_filtered[i]),
    );
  }

  Widget _buildingCard(BuildingInfo b) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BuildingDetailsPage(
            building: b,
            onStartArNavigation: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ARCompassNavigationPage(
                    destLat: b.destLat,
                    destLon: b.destLon,
                    destName: b.name,
                    locationType: b.locationType,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16)),
              child: Image.asset(
                b.imageUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 90,
                  height: 90,
                  color: _accent.withOpacity(0.15),
                  child: const Icon(Icons.apartment_rounded,
                      color: _accent, size: 36),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        b.id,
                        style: const TextStyle(
                          color: _accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      b.name,
                      style: const TextStyle(
                        color: _textPri,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            color: _textSec, size: 11),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            b.openingHours ?? '8:30 AM – 4:30 PM',
                            style:
                            const TextStyle(color: _textSec, fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.view_in_ar_rounded,
                    color: _accent, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Building Details Page ────────────────────────────────────────────────────

class BuildingDetailsPage extends StatefulWidget {
  final BuildingInfo building;
  final VoidCallback onStartArNavigation;

  const BuildingDetailsPage({
    super.key,
    required this.building,
    required this.onStartArNavigation,
  });

  @override
  State<BuildingDetailsPage> createState() => _BuildingDetailsPageState();
}

class _BuildingDetailsPageState extends State<BuildingDetailsPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  static const Color _bg      = Color(0xFF0F1117);
  static const Color _surface = Color(0xFF1A1D27);
  static const Color _accent  = Color(0xFF4ECDC4);
  static const Color _textPri = Color(0xFFF0F2F5);
  static const Color _textSec = Color(0xFF8A90A2);
  static const Color _border  = Color(0xFF2A2D3A);

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _launchAr() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ARCompassNavigationPage(
          destLat: widget.building.destLat,
          destLon: widget.building.destLon,
          destName: widget.building.name,
          locationType: widget.building.locationType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildMetaChips(),
                      const SizedBox(height: 24),
                      _buildArBanner(),
                      const SizedBox(height: 28),
                      _buildDescription(),
                      const SizedBox(height: 28),
                      _buildFacilitiesSection(),
                      const SizedBox(height: 28),
                      _buildHoursCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildArButton(),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: _bg,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _bg.withOpacity(0.75),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _textPri, size: 18),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              widget.building.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: _surface,
                child: Center(
                  child: Icon(Icons.apartment_rounded,
                      color: _accent, size: 72),
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    _bg.withOpacity(0.6),
                    _bg,
                  ],
                  stops: const [0.4, 0.75, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _launchAr,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.building.name,
                  style: const TextStyle(
                    color: _textPri,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _accent.withOpacity(0.4)),
                ),
                child: const Icon(Icons.view_in_ar_rounded,
                    color: _accent, size: 18),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _launchAr,
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _accent.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_rounded,
                    color: _accent, size: 13),
                const SizedBox(width: 4),
                Text(
                  'ID: ${widget.building.id}  •  Tap to navigate',
                  style: const TextStyle(
                    color: _accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded,
                    color: _accent, size: 14),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArBanner() {
    return GestureDetector(
      onTap: _launchAr,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _accent.withOpacity(0.15),
              _accent.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _accent.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.record_voice_over_rounded,
                  color: _accent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Voice AR Navigation Ready',
                    style: TextStyle(
                      color: _textPri,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    '"Go straight"  •  "Turn left"  •  "Turn right"',
                    style: TextStyle(
                        color: _textSec, fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: _accent, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        if (widget.building.openingHours != null)
          _chip(Icons.access_time_rounded, widget.building.openingHours!),
        if (widget.building.floor != null)
          _chip(Icons.layers_rounded, widget.building.floor!),
        _chip(
          widget.building.isOpenWeekends
              ? Icons.event_available
              : Icons.event_busy,
          widget.building.isOpenWeekends ? 'Open Weekends' : 'Weekdays Only',
        ),
      ],
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: _border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _accent, size: 14),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: _textSec,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('About'),
        const SizedBox(height: 10),
        Text(
          widget.building.description,
          style: const TextStyle(
              color: _textSec, fontSize: 15, height: 1.65),
        ),
      ],
    );
  }

  Widget _buildFacilitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Facilities'),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.building.facilities.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (_, i) =>
              _facilityTile(widget.building.facilities[i]),
        ),
      ],
    );
  }

  Widget _facilityTile(Facility f) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(f.icon, color: _accent, size: 20),
          ),
          const SizedBox(height: 7),
          Text(
            f.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _textSec,
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoursCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Opening Hours'),
          const SizedBox(height: 14),
          _hoursRow('Monday – Friday', '8:30 AM – 4:30 PM', true),
          const SizedBox(height: 8),
          _hoursRow('Saturday', 'Closed', false),
          const SizedBox(height: 8),
          _hoursRow('Sunday', 'Closed', false),
          const SizedBox(height: 8),
          _hoursRow('Public Holidays', 'Closed', false),
        ],
      ),
    );
  }

  Widget _hoursRow(String day, String hours, bool isOpen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(day,
            style: const TextStyle(color: _textSec, fontSize: 13)),
        Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isOpen
                ? Colors.green.withOpacity(0.15)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            hours,
            style: TextStyle(
              color: isOpen ? Colors.green : Colors.red.shade300,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: _accent,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(text,
            style: const TextStyle(
              color: _textPri,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            )),
      ],
    );
  }

  Widget _buildArButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [_accent, Color(0xFF38B2AC)]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _accent.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.view_in_ar_rounded,
                color: Color(0xFF0F1117), size: 22),
            label: const Text(
              'Start AR Navigation',
              style: TextStyle(
                color: Color(0xFF0F1117),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            onPressed: _launchAr,
          ),
        ),
      ),
    );
  }
}