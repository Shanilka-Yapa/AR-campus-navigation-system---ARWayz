import 'package:flutter/material.dart';
import '../admin/admin_login_page.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const Color primaryDark = Color(0xFF1A2D33);
  static const Color deepTeal = Color(0xFF235559);
  static const Color mutedTeal = Color(0xFF3F727A);
  static const Color steelBlue = Color(0xFF7B929C);
  static const Color goldAccent = Color(0xFFB7791F);
  static const Color scaffoldBg = Color(0xFFF8F9F9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      body: CustomScrollView(
        slivers: [
          // Centered Header
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline_rounded, color: Colors.white, size: 28),
                      SizedBox(width: 10),
                      Text(
                        'About ARWayz',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Campus AR Navigation & Project Info',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFBEC4C4),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Body Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // About App Card
                _buildCard(
                  title: 'About The App',
                  icon: Icons.alt_route_rounded,
                  accentColor: mutedTeal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ARWayz is an intelligent AR Campus Navigation System developed specifically for the Faculty of Engineering, University of Ruhuna.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: primaryDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Vision & Motivation:',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: deepTeal,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Navigating a large university campus with multiple department buildings and floors can be challenging for freshers, visitors, and guests. ARWayz combines real-time AR compass directions, 3D interactive indoor floorplans, and location QR scanning to make campus exploration effortless.',
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.5,
                          color: primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Supervisors & Mentors Section
                _buildCard(
                  title: 'Supervisors & Mentors',
                  icon: Icons.school_rounded,
                  accentColor: goldAccent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSupervisorTile(
                        name: 'Dr. Prabath Weerasinghe',
                        roleTag: 'Client',
                        description:
                            'Senior Lecturer, Faculty of Engineering, University of Ruhuna | B.Sc., M.Sc., Eng., Ph.D.',
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1, color: Color(0xFFECEFF1)),
                      const SizedBox(height: 14),
                      _buildSupervisorTile(
                        name: 'Mr. Thiwanka Silva',
                        roleTag: 'Mentor',
                        description:
                            'Visiting Lecturer, Faculty of Engineering, University of Ruhuna | Software Engineer, Enactor Ltd',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Undergraduate Project Members Section
                _buildCard(
                  title: 'Undergraduate Project Members',
                  icon: Icons.groups_rounded,
                  accentColor: deepTeal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Department of Computer Engineering',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: steelBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1, color: Color(0xFFECEFF1)),
                      const SizedBox(height: 12),
                      _buildProjectMemberTile('EG/2022/5332', 'Bipuli Yovinma W.K.'),
                      const SizedBox(height: 10),
                      _buildProjectMemberTile('EG/2022/5435', 'Shanilka T. Yapa'),
                      const SizedBox(height: 10),
                      _buildProjectMemberTile('EG/2022/4933', 'Ambalangodage H.U.'),
                      const SizedBox(height: 10),
                      _buildProjectMemberTile('EG/2022/5136', 'Kavindi S.H.V'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Admin Access Section
                _buildAdminAccessCard(context),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color accentColor,
    required Widget child,
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFECEFF1)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildSupervisorTile({
    required String name,
    required String roleTag,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: primaryDark,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: goldAccent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: goldAccent.withOpacity(0.3)),
              ),
              child: Text(
                roleTag,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: goldAccent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: const TextStyle(
            fontSize: 13,
            color: steelBlue,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildProjectMemberTile(String regNo, String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFECEFF1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            regNo,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: deepTeal,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            name,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminAccessCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: primaryDark,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.admin_panel_settings_rounded, color: goldAccent, size: 24),
              SizedBox(width: 10),
              Text(
                'Administrator Access',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Manage campus destinations, AR markers, indoor nodes, and campus events.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.75),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminLoginPage(),
                  ),
                );
              },
              icon: const Icon(Icons.lock_open_rounded, size: 18),
              label: const Text('Admin Portal Login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: goldAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
