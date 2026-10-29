import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../event_theme.dart';
import 'admin_auth_service.dart';

// Palette for the sign-in screen, matching the admin login design used
// elsewhere in the app.
const Color _colorDark = Color(0xFF1a2d33);
const Color _colorDeepTeal = Color(0xFF235559);
const Color _colorMutedTeal = Color(0xFF3f727a);
const Color _colorSteelBlue = Color(0xFF7b929c);
const Color _colorLightGray = Color(0xFFbec4c4);

/// Wraps the admin portal so its contents are only reachable by an
/// allowlisted Firebase admin.
///
/// This is what makes the portal's writes actually work: the Firestore rules
/// require `request.auth.uid` to exist in `admins`, which the hardcoded
/// password login cannot provide.
class AdminGate extends StatefulWidget {
  final Widget child;

  const AdminGate({super.key, required this.child});

  @override
  State<AdminGate> createState() => _AdminGateState();
}

class _AdminGateState extends State<AdminGate> {
  final AdminAuthService _service = AdminAuthService();
  late final Stream<User?> _authStream = _service.authStateChanges();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: kEventScaffoldBg,
            body: Center(
              child: CircularProgressIndicator(color: kEventDeepTeal),
            ),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return _AdminLoginScreen(service: _service);
        }

        // Signed in, but the account still has to be on the allowlist. A
        // student session would otherwise fall through into the portal.
        return FutureBuilder<bool>(
          future: _service.isAdmin(user.uid),
          builder: (context, adminSnapshot) {
            if (adminSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: kEventScaffoldBg,
                body: Center(
                  child: CircularProgressIndicator(color: kEventDeepTeal),
                ),
              );
            }

            if (adminSnapshot.data != true) {
              // A student may be signed in on this device. Say nothing about
              // it - signing in below replaces that session automatically.
              return _AdminLoginScreen(service: _service);
            }

            return widget.child;
          },
        );
      },
    );
  }
}

class _AdminLoginScreen extends StatefulWidget {
  final AdminAuthService service;

  const _AdminLoginScreen({required this.service});

  @override
  State<_AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<_AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() => _error = 'Enter your email and password.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await widget.service.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // The gate's auth stream rebuilds into the portal on success.
    } on AdminAuthException catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = error.message;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Something went wrong: $error';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_colorDark, _colorDeepTeal],
          ),
        ),
        child: Stack(
          children: [
            // Abstract background circles for a modern look
            Positioned(
              top: -50,
              right: -50,
              child: CircleAvatar(
                radius: 100,
                backgroundColor: _colorMutedTeal.withValues(alpha: 0.2),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: CircleAvatar(
                radius: 80,
                backgroundColor: _colorSteelBlue.withValues(alpha: 0.1),
              ),
            ),

            // Top Modern Back Button
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 10),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.maybePop(context),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
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
            ),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    // Top Logo/Icon Area
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _colorSteelBlue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        size: 70,
                        color: _colorLightGray,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "ADMIN ACCESS",
                      style: TextStyle(
                        color: _colorLightGray,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Secure Terminal Login",
                      style: TextStyle(color: _colorSteelBlue, fontSize: 14),
                    ),
                    const SizedBox(height: 40),

                    // Login Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          if (_error != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.red.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                _error!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          _buildTextField(
                            controller: _emailController,
                            label: "Email",
                            icon: Icons.person_outline,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _passwordController,
                            label: "Password",
                            icon: Icons.lock_outline,
                            isPassword: true,
                          ),
                          const SizedBox(height: 30),

                          // Modern Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _busy ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _colorMutedTeal,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    _colorMutedTeal.withValues(alpha: 0.5),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: _busy
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      "Login",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "© 2024 ARWayz Secure Systems",
                      style: TextStyle(
                        color: _colorSteelBlue.withValues(alpha: 0.5),
                        fontSize: 12,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      enabled: !_busy,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _colorSteelBlue),
        prefixIcon: Icon(icon, color: _colorMutedTeal),
        filled: true,
        fillColor: _colorDark.withValues(alpha: 0.3),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: _colorMutedTeal),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
    );
  }
}
