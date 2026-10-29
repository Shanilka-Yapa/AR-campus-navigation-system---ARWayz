import 'package:flutter/material.dart';

class CivilDivision {
  final String id;
  final String title;
  final String shortCode;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final Color accentColor;
  final Color cardBgColor;
  final List<String> keyFacilities;
  final List<String> researchAreas;
  final String floorLevel;
  final int floor;
  final String wing;
  final Offset markerOffset; // 3D overlay relative positioning offset

  const CivilDivision({
    required this.id,
    required this.title,
    required this.shortCode,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.accentColor,
    required this.cardBgColor,
    required this.keyFacilities,
    required this.researchAreas,
    required this.floorLevel,
    required this.floor,
    required this.wing,
    required this.markerOffset,
  });
}

class DepartmentConfig {
  final String id;
  final String name;
  final String subtitle;
  final String modelPath;
  final IconData icon;
  final Color themeColor;
  final List<CivilDivision> divisions;

  const DepartmentConfig({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.modelPath,
    required this.icon,
    required this.themeColor,
    this.divisions = const [],
  });
}

// Civil Building rooms and laboratories
const List<CivilDivision> civilEngineeringDivisions = [
  CivilDivision(
    id: 'lobby',
    title: 'Lobby',
    shortCode: 'LOBBY',
    description: 'The central lobby and main access point on the ground floor.',
    icon: Icons.meeting_room_rounded,
    primaryColor: Color(0xFF2C3E50), // Slate Blue
    accentColor: Color(0xFF34495E),
    cardBgColor: Color(0xFFEBF2F7), // Soft Slate Pastel
    keyFacilities: ['Main entrance and reception'],
    researchAreas: [],
    floorLevel: 'Ground Floor - Middle',
    floor: 0,
    wing: 'Middle',
    markerOffset: Offset(0.50, 0.50),
  ),
  CivilDivision(
    id: 'board_meeting_room',
    title: 'Board Meeting Room',
    shortCode: 'BMR',
    description: 'Board meeting room on the right side of the ground floor.',
    icon: Icons.groups_rounded,
    primaryColor: Color(0xFFD35400), // Warm Terracotta
    accentColor: Color(0xFFE67E22),
    cardBgColor: Color(0xFFFDF2E9), // Soft Terracotta Pastel
    keyFacilities: ['Board meeting facilities'],
    researchAreas: [],
    floorLevel: 'Ground Floor - Right',
    floor: 0,
    wing: 'Right',
    markerOffset: Offset(0.75, 0.30),
  ),
  CivilDivision(
    id: 'head_room',
    title: 'Head Room',
    shortCode: 'HEAD',
    description: 'Head room on the right side of the ground floor.',
    icon: Icons.person_rounded,
    primaryColor: Color(0xFF16A085), // Emerald / Modern Mint
    accentColor: Color(0xFF2ECC71),
    cardBgColor: Color(0xFFE8F8F5), // Soft Mint Pastel
    keyFacilities: ['Head of department office'],
    researchAreas: [],
    floorLevel: 'Ground Floor - Right',
    floor: 0,
    wing: 'Right',
    markerOffset: Offset(0.82, 0.50),
  ),
  CivilDivision(
    id: 'to_room',
    title: 'TO Room',
    shortCode: 'TO',
    description: 'TO room on the right side of the ground floor.',
    icon: Icons.meeting_room_rounded,
    primaryColor: Color(0xFF0097A7), // Soft Cyan / Ocean Blue
    accentColor: Color(0xFF00BCD4),
    cardBgColor: Color(0xFFE0F7FA), // Soft Ocean Cyan Pastel
    keyFacilities: ['TO office facilities'],
    researchAreas: [],
    floorLevel: 'Ground Floor - Right',
    floor: 0,
    wing: 'Right',
    markerOffset: Offset(0.88, 0.70),
  ),
  CivilDivision(
    id: 'survey_instrument_room',
    title: 'Survey Instrument Room',
    shortCode: 'SIR',
    description: 'Survey instrument room on the left side of the ground floor.',
    icon: Icons.gps_fixed_rounded,
    primaryColor: Color(0xFF6C3483),
    accentColor: Color(0xFF8E44AD),
    cardBgColor: Color(0xFFF5EEF8),
    keyFacilities: ['Surveying instruments and equipment'],
    researchAreas: [],
    floorLevel: 'Ground Floor - Left',
    floor: 0,
    wing: 'Left',
    markerOffset: Offset(0.18, 0.62),
  ),
  CivilDivision(
    id: 'geotechnical_lab',
    title: 'Geotechnical Lab',
    shortCode: 'GEO',
    description: 'Geotechnical laboratory on the left side of the first floor.',
    icon: Icons.layers_rounded,
    primaryColor: Color(0xFF795548),
    accentColor: Color(0xFF8D6E63),
    cardBgColor: Color(0xFFEFEBE9),
    keyFacilities: ['Soil and foundation testing'],
    researchAreas: [],
    floorLevel: 'First Floor - Left',
    floor: 1,
    wing: 'Left',
    markerOffset: Offset(0.22, 0.30),
  ),
  CivilDivision(
    id: 'concrete_work_lab',
    title: 'Concrete Work Lab',
    shortCode: 'CWL',
    description:
        'Concrete work laboratory on the right side of the first floor.',
    icon: Icons.construction_rounded,
    primaryColor: Color(0xFF455A64),
    accentColor: Color(0xFF607D8B),
    cardBgColor: Color(0xFFECEFF1),
    keyFacilities: ['Concrete and construction materials testing'],
    researchAreas: [],
    floorLevel: 'First Floor - Right',
    floor: 1,
    wing: 'Right',
    markerOffset: Offset(0.78, 0.30),
  ),
  CivilDivision(
    id: 'structural_analysis_lab',
    title: 'Structural Analysis Lab',
    shortCode: 'SAL',
    description:
        'Structural analysis laboratory on the right side of the second floor.',
    icon: Icons.account_tree_rounded,
    primaryColor: Color(0xFF283593),
    accentColor: Color(0xFF3949AB),
    cardBgColor: Color(0xFFE8EAF6),
    keyFacilities: ['Structural analysis and modelling'],
    researchAreas: [],
    floorLevel: 'Second Floor - Right',
    floor: 2,
    wing: 'Right',
    markerOffset: Offset(0.78, 0.35),
  ),
  CivilDivision(
    id: 'transportation_lab',
    title: 'Transportation Lab',
    shortCode: 'TRL',
    description:
        'Transportation laboratory on the left side of the second floor.',
    icon: Icons.directions_car_rounded,
    primaryColor: Color(0xFF00695C),
    accentColor: Color(0xFF00897B),
    cardBgColor: Color(0xFFE0F2F1),
    keyFacilities: ['Transportation and pavement studies'],
    researchAreas: [],
    floorLevel: 'Second Floor - Left',
    floor: 2,
    wing: 'Left',
    markerOffset: Offset(0.22, 0.35),
  ),
  CivilDivision(
    id: 'water_lab',
    title: 'Water Lab',
    shortCode: 'WAT',
    description: 'Water laboratory on the right side of the third floor.',
    icon: Icons.water_drop_rounded,
    primaryColor: Color(0xFF0277BD),
    accentColor: Color(0xFF039BE5),
    cardBgColor: Color(0xFFE1F5FE),
    keyFacilities: ['Water quality and hydraulics testing'],
    researchAreas: [],
    floorLevel: 'Third Floor - Right',
    floor: 3,
    wing: 'Right',
    markerOffset: Offset(0.78, 0.35),
  ),
  CivilDivision(
    id: 'waste_water_lab',
    title: 'Waste Water Lab',
    shortCode: 'WWL',
    description: 'Waste water laboratory on the left side of the third floor.',
    icon: Icons.recycling_rounded,
    primaryColor: Color(0xFF2E7D32),
    accentColor: Color(0xFF43A047),
    cardBgColor: Color(0xFFE8F5E9),
    keyFacilities: ['Waste water treatment and analysis'],
    researchAreas: [],
    floorLevel: 'Third Floor - Left',
    floor: 3,
    wing: 'Left',
    markerOffset: Offset(0.22, 0.35),
  ),
];

const DepartmentConfig civilDepartmentConfig = DepartmentConfig(
  id: 'CIVIL_BUILDING',
  name: 'Civil Building',
  subtitle: 'Civil & Environmental Engineering Complex',
  modelPath: 'assets/models/civil_building.glb',
  icon: Icons.architecture_rounded,
  themeColor: Color(0xFF2C3E50),
  divisions: civilEngineeringDivisions,
);

const DepartmentConfig isDepartmentConfig = DepartmentConfig(
  id: 'IS_BUILDING',
  name: 'IS Building',
  subtitle: 'Interdisciplinary Studies Building',
  modelPath: 'assets/models/is_building.glb',
  icon: Icons.computer_rounded,
  themeColor: Color(0xFFB7791F),
  divisions: [],
);
