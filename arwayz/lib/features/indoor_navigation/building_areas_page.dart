import 'package:flutter/material.dart';
import 'department_config.dart';

class BuildingAreasPage extends StatelessWidget {
  final String buildingId;
  final DepartmentConfig? departmentConfig;

  const BuildingAreasPage({
    super.key,
    required this.buildingId,
    this.departmentConfig,
  });

  static const Color primaryDark = Color(0xFF1A2D33);
  static const Color scaffoldBg = Color(0xFFF8F9F9);

  @override
  Widget build(BuildContext context) {
    final config =
        departmentConfig ??
        (buildingId == 'CIVIL_BUILDING'
            ? civilDepartmentConfig
            : isDepartmentConfig);

    final hasDivisions = config.divisions.isNotEmpty;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header with Curved Clip & Back Button
          SliverToBoxAdapter(
            child: Stack(
              children: [
                ClipPath(
                  clipper: _HeaderClipper(),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 48),
                    color: config.themeColor,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            config.icon,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          config.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hasDivisions
                              ? 'Department Divisions & Laboratories'
                              : 'Building $buildingId Areas',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFBEC4C4),
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Modern Back Button
                Positioned(
                  top: 45,
                  left: 16,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Division Cards List / Area List
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (hasDivisions) ...[
                  Text(
                    config.id == 'CIVIL_BUILDING'
                        ? 'ROOMS & LABORATORIES'
                        : 'FACULTY DIVISIONS & SECTIONS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF7B929C),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...config.divisions.map(
                    (division) => _buildCuteDivisionCard(context, division),
                  ),
                ] else ...[
                  const Text(
                    'FACILITY AREAS & SECTIONS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF7B929C),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGenericAreaCard(
                    'Central Reception & Lobby',
                    Icons.meeting_room_rounded,
                    'Ground Floor - Main Lobby',
                  ),
                  _buildGenericAreaCard(
                    'New Computer Center',
                    Icons.computer_rounded,
                    'Third Floor - Right Wing',
                  ),
                  _buildGenericAreaCard(
                    "Dean's Office Suite",
                    Icons.admin_panel_settings_rounded,
                    'First Floor - Center Wing',
                  ),
                  _buildGenericAreaCard(
                    'IS Seminar Room',
                    Icons.co_present_rounded,
                    'Second Floor - Left Wing',
                  ),
                ],
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  /// Visually cute, modern card layout with pastel background and micro-badges
  Widget _buildCuteDivisionCard(BuildContext context, CivilDivision division) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: division.cardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: division.primaryColor.withValues(alpha: 0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: division.primaryColor.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showDivisionDetailBottomSheet(context, division),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: division.primaryColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: division.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(division.icon, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    // Title & Shortcode Badge
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: division.primaryColor.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  division.shortCode,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: division.primaryColor,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  division.floorLevel,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: division.primaryColor.withValues(
                                      alpha: 0.7,
                                    ),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            division.title,
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold,
                              color: division.primaryColor,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  division.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: division.primaryColor.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${division.keyFacilities.length} Facilities',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: division.primaryColor,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: division.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: division.primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenericAreaCard(String name, IconData icon, String location) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: primaryDark.withValues(alpha: 0.1),
          child: Icon(icon, color: primaryDark),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(location, style: const TextStyle(fontSize: 12.5)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      ),
    );
  }

  /// Visually cute modal bottom sheet for division details
  void _showDivisionDetailBottomSheet(
    BuildContext context,
    CivilDivision division,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pull Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: division.primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(division.icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: division.primaryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            division.shortCode,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: division.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          division.title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: division.primaryColor,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Text(
                division.description,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  color: primaryDark,
                ),
              ),

              const SizedBox(height: 18),
              const Divider(height: 1, color: Color(0xFFECEFF1)),
              const SizedBox(height: 14),

              // Key Facilities
              Text(
                'KEY LABORATORIES & FACILITIES',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: division.primaryColor,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              ...division.keyFacilities.map(
                (facility) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: division.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          facility,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Location Badge
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: division.cardBgColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: division.primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: division.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Location: ${division.floorLevel}',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: division.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check_rounded, size: 20),
                  label: const Text(
                    'Close Details',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: division.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 15,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
