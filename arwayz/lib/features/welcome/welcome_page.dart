import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  // Project Color Palette
  static const Color primaryDark = Color(0xFF1A2D33);
  static const Color deepTeal = Color(0xFF235559);
  static const Color mutedTeal = Color(0xFF3F727A);
  static const Color steelBlue = Color(0xFF7B929C);
  static const Color goldAccent = Color(0xFFB7791F);
  static const Color scaffoldBg = Color(0xFFF8F9F9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: scaffoldBg,
      body: Stack(
        children: [
          // Background Hero Image (Faculty Gate) with Gradient Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.58,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/gate.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        primaryDark.withValues(alpha: 0.2),
                        primaryDark.withValues(alpha: 0.55),
                        const Color.fromARGB(255, 56, 56, 56),
                      ],
                      stops: const [0.0, 0.65, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.school, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'University of Ruhuna',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content Container (Decreased height, compact white box)
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.42),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 20.0,
                    ),
                    decoration: const BoxDecoration(
                      color: scaffoldBg,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ARWayz Branded Logo Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/arwayz_icon.png',
                              width: 42,
                              height: 42,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 4),
                            Image.asset(
                              'assets/images/arwayz_wordmark.png',
                              width: 122,
                              height: 34,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Title (Centered)
                        const Text(
                          'Faculty of Engineering',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryDark,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'University of Ruhuna',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: deepTeal,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Expanded Description with rich faculty details
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Text(
                              'Welcome to the premier engineering institution in Southern Sri Lanka, located in Hapugala, Galle. Home to five major academic departments—Interdisciplinary Studies, Electrical & Information Engineering, Mechanical & Manufacturing Engineering, Civil & Environmental Engineering—and advanced research facilities.ARWayz is a smart campus navigation system that combines GPS-based outdoor navigation, AR compass guidance, and QR code-based indoor wayfinding. It helps students and visitors locate university buildings, explore interactive 3D floor plans, and navigate campus facilities with ease.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.5,
                                color: primaryDark.withValues(alpha: 0.78),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Get Started Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              context.go('/dashboard');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryDark,
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shadowColor: primaryDark.withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Get Started',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
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
        ],
      ),
    );
  }
}
