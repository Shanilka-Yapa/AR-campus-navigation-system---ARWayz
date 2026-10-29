import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../destinations/navigation_selector_page.dart';
import '../indoor_navigation/building_3d_page.dart';
import '../qr_scanner/qr_scanner_page.dart';
import '../events/events_page.dart';
import '../explore/explore_page.dart';
import '../about/about_page.dart';
import '../indoor_navigation/indoor_navigation_page.dart';
import '../../core/models/qr_payload.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _DashboardHomeContentView(),
    ExplorePage(),
    AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F9),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A2D33).withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF0F62FE),
          unselectedItemColor: const Color(0xFF7B929C),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              activeIcon: Icon(Icons.home_rounded, size: 26),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore_rounded, size: 26),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info_outline_rounded),
              activeIcon: Icon(Icons.info_rounded, size: 26),
              label: 'About',
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHomeContentView extends StatelessWidget {
  const _DashboardHomeContentView();

  Future<void> _openCamera(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerPage()),
    );

    if (!context.mounted || result is! QrPayload) {
      return;
    }

    if (result.buildingId != IndoorNavigationPage.buildingId ||
        result.floor != IndoorNavigationPage.floor) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scan an IS Department ground-floor ARWayz QR code.'),
        ),
      );
      return;
    }

    context.push('/indoor', extra: result);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Curved Dark Blue Header Container with Back Button & Centered Content
          ClipPath(
            clipper: _HeaderClipper(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 46),
              color: const Color(0xFF1A2D33),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Truly Centered Header Title & Logo Content across full width
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),
                        // Logo Icon Container
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.school_outlined,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Centered App Title & Subtitle
                        const Text(
                          'ARWayz',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Your Smart Campus Guide',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFBEC4C4),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Modern Back Button to Welcome Page (Floating Left)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          context.go('/welcome');
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
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
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),

                // Centered Main Heading
                const SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Where would you like to go?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2D33),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Navigation Grid Actions (Indoor & Outdoor)
                Row(
                  children: [
                    // Indoor Navigation Card
                    Expanded(
                      child: _buildNavigationGridCard(
                        context,
                        title: 'Indoor\nNavigation',
                        icon: Icons.domain_rounded,
                        bgColor: const Color(0xFFEBF3FA),
                        iconColor: const Color(0xFF2A72D0),
                        textColor: const Color(0xFF1A2D33),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Building3DPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Outdoor Navigation Card
                    Expanded(
                      child: _buildNavigationGridCard(
                        context,
                        title: 'Outdoor\nNavigation',
                        icon: Icons.park_rounded,
                        bgColor: const Color(0xFFEBF7F2),
                        iconColor: const Color(0xFF1B8A6B),
                        textColor: const Color(0xFF1A2D33),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NavigationSelectorPage(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Full-width Scan QR Location Card
                _buildActionBannerCard(
                  context,
                  title: 'Scan QR Location',
                  icon: Icons.qr_code_scanner_rounded,
                  bgColor: const Color(0xFFF2EFFD),
                  iconColor: const Color(0xFF6B4EE0),
                  textColor: const Color(0xFF1A2D33),
                  onTap: () => _openCamera(context),
                ),

                const SizedBox(height: 32),

                // Centered Upcoming Campus Events Section Title
                const SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Upcoming Campus Events',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2D33),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Updated Events Preview Card with Modern Calendar Icon & "Explore Events" Action
                _buildEventsExploreSection(context),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationGridCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: textColor.withValues(alpha: 0.4),
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBannerCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: textColor.withValues(alpha: 0.4),
              size: 26,
            ),
          ],
        ),
      ),
    );
  }

  /// Clean preview section replacing static event cards with a modern calendar icon & "Explore Events" button
  Widget _buildEventsExploreSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF3FA),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF2A72D0).withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2A72D0).withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: Color(0xFF2A72D0),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Faculty & Campus Events',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A2D33),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Exhibitions, symposiums & student activities',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF7B929C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EventsPage(),
                  ),
                );
              },
              icon: const Icon(Icons.event_available_rounded, size: 20),
              label: const Text(
                'Explore Events',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A2D33),
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Clipper for Curved Header
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
