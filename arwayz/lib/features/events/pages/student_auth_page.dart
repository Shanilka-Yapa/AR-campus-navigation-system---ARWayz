import 'package:flutter/material.dart';

import '../event_theme.dart';
import '../services/student_auth_service.dart';

/// Sign-in and registration for students who want to comment or like.
///
/// Browsing events never reaches this screen; it is only opened from the
/// comment box or the like button.
class StudentAuthPage extends StatefulWidget {
  const StudentAuthPage({super.key});

  @override
  State<StudentAuthPage> createState() => _StudentAuthPageState();
}

class _StudentAuthPageState extends State<StudentAuthPage> {
  final StudentAuthService _service = StudentAuthService();

  final _nameController = TextEditingController();
  final _indexController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _registering = false;
  bool _busy = false;
  String? _error;
  String? _notice;

  @override
  void dispose() {
    _nameController.dispose();
    _indexController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validate() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) return 'Enter your email address.';
    if (!email.contains('@') || !email.contains('.')) {
      return 'Enter a valid email address.';
    }
    if (password.isEmpty) return 'Enter your password.';

    if (_registering) {
      if (_nameController.text.trim().isEmpty) return 'Enter your full name.';
      if (_indexController.text.trim().isEmpty) {
        return 'Enter your index number.';
      }
      if (password.length < 6) {
        return 'Choose a password of at least 6 characters.';
      }
    }
    return null;
  }

  Future<void> _submit() async {
    final problem = _validate();
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });

    try {
      if (_registering) {
        await _service.register(
          name: _nameController.text,
          indexNumber: _indexController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (!mounted) return;
        // Registration signs the student in, but they stay pending until an
        // admin approves, so say so rather than dropping them back silently.
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Registration submitted. An admin must approve your account '
              'before you can comment or like.',
            ),
            backgroundColor: kEventDeepTeal,
            duration: Duration(seconds: 5),
          ),
        );
      } else {
        await _service.signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (!mounted) return;
        Navigator.pop(context);
      }
    } on StudentAuthException catch (error) {
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
      backgroundColor: kEventScaffoldBg,
      appBar: AppBar(
        title: Text(_registering ? 'Create an account' : 'Student sign in'),
        backgroundColor: kEventPrimaryDark,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            _registering
                ? 'Register with your faculty details. An admin reviews every '
                    'request before the account can be used.'
                : 'Sign in to comment on and like campus events.',
            style: const TextStyle(fontSize: 14, color: kEventMutedTeal),
          ),
          const SizedBox(height: 20),

          if (_error != null) ...[
            _Banner(text: _error!, color: Colors.red.shade50, textColor: Colors.red.shade900),
            const SizedBox(height: 14),
          ],
          if (_notice != null) ...[
            _Banner(
              text: _notice!,
              color: const Color(0xFFEEF4F4),
              textColor: kEventDeepTeal,
            ),
            const SizedBox(height: 14),
          ],

          if (_registering) ...[
            _Field(
              controller: _nameController,
              label: 'Full name',
              icon: Icons.person_outline,
              enabled: !_busy,
            ),
            const SizedBox(height: 14),
            _Field(
              controller: _indexController,
              label: 'Index number',
              icon: Icons.badge_outlined,
              enabled: !_busy,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 14),
          ],

          _Field(
            controller: _emailController,
            label: 'Email',
            icon: Icons.mail_outline,
            enabled: !_busy,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          _Field(
            controller: _passwordController,
            label: 'Password',
            icon: Icons.lock_outline,
            enabled: !_busy,
            obscureText: true,
          ),
          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _busy ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: kEventPrimaryDark,
                disabledBackgroundColor: kEventLightGray,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _registering ? 'Submit registration' : 'Sign in',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),

          TextButton(
            onPressed: _busy
                ? null
                : () => setState(() {
                      _registering = !_registering;
                      _error = null;
                      _notice = null;
                    }),
            child: Text(
              _registering
                  ? 'I already have an account - sign in'
                  : 'New here? Create an account',
              style: const TextStyle(color: kEventDeepTeal),
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    required this.enabled,
    this.obscureText = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: kEventMutedTeal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kEventLightGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kEventLightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kEventDeepTeal, width: 1.5),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;

  const _Banner({
    required this.text,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 13.5, color: textColor),
      ),
    );
  }
}
