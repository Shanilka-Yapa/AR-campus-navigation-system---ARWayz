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

// Civil Engineering Department Divisions & Configurations
const List<CivilDivision> civilEngineeringDivisions = [
  CivilDivision(
    id: 'bse',
    title: 'Building and Structural Engineering Division',
    shortCode: 'BSE',
    description:
        'Focuses on advanced structural dynamics, concrete mechanics, earthquake resilience, high-rise steel structure design, and modern material testing.',
    icon: Icons.architecture_rounded,
    primaryColor: Color(0xFF2C3E50), // Slate Blue
    accentColor: Color(0xFF34495E),
    cardBgColor: Color(0xFFEBF2F7), // Soft Slate Pastel
    keyFacilities: [
      'Heavy Structural Testing Laboratory',
      'Concrete & Construction Materials Unit',
      'Structural Modeling & CAD Studio',
      'Vibration & Dynamics Analysis Lab',
    ],
    researchAreas: [
      'Seismic Retrofitting & Vibration Control',
      'Sustainable Concrete & Green Composites',
      'Finite Element Analysis of High-Rises',
    ],
    floorLevel: 'Ground & First Floor - North Wing',
    floor: 0,
    wing: 'North Wing',
    markerOffset: Offset(0.32, 0.38),
  ),
  CivilDivision(
    id: 'gte',
    title: 'Geotechnical Engineering Division',
    shortCode: 'GTE',
    description:
        'Specializes in soil mechanics, deep foundation engineering, slope stability, landslide mitigation, rock mechanics, and geo-environmental testing.',
    icon: Icons.layers_rounded,
    primaryColor: Color(0xFFD35400), // Warm Terracotta
    accentColor: Color(0xFFE67E22),
    cardBgColor: Color(0xFFFDF2E9), // Soft Terracotta Pastel
    keyFacilities: [
      'Soil Mechanics & Triaxial Testing Lab',
      'Geotechnical Field Instrumentation Store',
      'Rock Mechanics & Geology Unit',
      'In-situ Testing & Exploration Equipment',
    ],
    researchAreas: [
      'Southern Expressway Slope Stability Analysis',
      'Soil Improvement & Geosynthetics',
      'Groundwater Mechanics & Contamination',
    ],
    floorLevel: 'Ground Floor - East Wing',
    floor: 0,
    wing: 'East Wing',
    markerOffset: Offset(0.68, 0.62),
  ),
  CivilDivision(
    id: 'idm',
    title: 'Infrastructure Development and Management Division',
    shortCode: 'IDM',
    description:
        'Covers smart transportation systems, highway pavement engineering, urban infrastructure planning, project management, and network optimization.',
    icon: Icons.apartment_rounded,
    primaryColor: Color(0xFF16A085), // Emerald / Modern Mint
    accentColor: Color(0xFF2ECC71),
    cardBgColor: Color(0xFFE8F8F5), // Soft Mint Pastel
    keyFacilities: [
      'Transportation Systems & Pavement Lab',
      'GIS & Highway Planning Computing Studio',
      'Traffic Simulation & Network Hub',
      'Construction Management Workshop',
    ],
    researchAreas: [
      'Smart City Traffic Signal Optimization',
      'Asphalt Polymer Modification',
      'Building Information Modeling (BIM)',
    ],
    floorLevel: 'Second Floor - Main Facade & Roof Garden',
    floor: 2,
    wing: 'Main Facade',
    markerOffset: Offset(0.50, 0.28),
  ),
  CivilDivision(
    id: 'wee',
    title: 'Water and Environmental Engineering Division',
    shortCode: 'WEE',
    description:
        'Dedicated to open channel hydraulics, hydrology, coastal engineering, water resources management, water quality testing, and eco-systems protection.',
    icon: Icons.water_drop_rounded,
    primaryColor: Color(0xFF0097A7), // Soft Cyan / Ocean Blue
    accentColor: Color(0xFF00BCD4),
    cardBgColor: Color(0xFFE0F7FA), // Soft Ocean Cyan Pastel
    keyFacilities: [
      'Hydraulics & Wave Flume Laboratory',
      'Environmental Water Quality Testing Lab',
      'Hydrology & GIS Data Center',
      'Fluid Mechanics Demonstration Flumes',
    ],
    researchAreas: [
      'Coastal Erosion Control along Southern Coast',
      'Urban Drainage & Flood Mitigation',
      'Desalination & Advanced Wastewater Treatment',
    ],
    floorLevel: 'First & Second Floor - South Eco Patio',
    floor: 1,
    wing: 'South Eco Patio',
    markerOffset: Offset(0.22, 0.68),
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
