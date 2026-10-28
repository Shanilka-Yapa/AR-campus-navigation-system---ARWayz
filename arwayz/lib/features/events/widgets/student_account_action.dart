import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../event_theme.dart';
import '../models/student_profile.dart';
import '../pages/student_auth_page.dart';
import '../services/student_auth_service.dart';

/// App bar action showing who is signed in.
///
/// Signed out, it opens the sign-in screen. Signed in, it opens a sheet with
/// the student's details, their approval status, and the sign-out button.
class StudentAccountAction extends StatelessWidget {
  const StudentAccountAction({super.key});

  @override
  Widget build(BuildContext context) {
    final service = StudentAuthService();

    return StreamBuilder<User?>(
      stream: service.authStateChanges(),
      builder: (context, authSnapshot) {
        final user = authSnapshot.data;

        if (user == null) {
          return IconButton(
            tooltip: 'Student sign in',
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StudentAuthPage()),
            ),
          );
        }

        return StreamBuilder<StudentProfile?>(
          stream: service.watchProfile(user.uid),
          builder: (context, profileSnapshot) {
            final profile = profileSnapshot.data;
            return IconButton(
              tooltip: 'Your account',
              icon: Icon(
                profile != null && profile.isApproved
                    ? Icons.account_circle
                    : Icons.account_circle_outlined,
              ),
              onPressed: () => _showAccountSheet(
                context,
                service: service,
                user: user,
                profile: profile,
              ),
            );
          },
        );
      },
    );
  }

  void _showAccountSheet(
    BuildContext context, {
    required StudentAuthService service,
    required User user,
    required StudentProfile? profile,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_circle, color: kEventDeepTeal),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        profile?.name ?? 'Student',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: kEventPrimaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (profile != null && profile.indexNumber.isNotEmpty)
                  _InfoLine(
                    icon: Icons.badge_outlined,
                    text: profile.indexNumber,
                  ),
                _InfoLine(
                  icon: Icons.mail_outline,
                  text: profile?.email ?? user.email ?? '',
                ),
                const SizedBox(height: 12),
                _StatusLine(profile: profile),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      // Close the sheet first so it is not left orphaned when
                      // the auth stream rebuilds this action.
                      Navigator.pop(sheetContext);
                      await service.signOut();
                    },
                    icon: const Icon(Icons.logout, color: kEventPrimaryDark),
                    label: const Text(
                      'Sign out',
                      style: TextStyle(
                        color: kEventPrimaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: const BorderSide(color: kEventLightGray),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: kEventSteelBlue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13.5, color: kEventMutedTeal),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  final StudentProfile? profile;

  const _StatusLine({required this.profile});

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color background;
    late final Color foreground;
    late final IconData icon;

    if (profile == null) {
      label = 'No student profile found for this account.';
      background = kEventLightGray;
      foreground = kEventPrimaryDark;
      icon = Icons.help_outline;
    } else if (profile!.isApproved) {
      label = 'Approved - you can comment and like.';
      background = const Color(0xFFEEF4F4);
      foreground = kEventDeepTeal;
      icon = Icons.verified_outlined;
    } else if (profile!.isBlocked) {
      label = 'Blocked by an admin.';
      background = Colors.red.shade50;
      foreground = Colors.red.shade900;
      icon = Icons.block;
    } else {
      label = 'Waiting for admin approval.';
      background = const Color(0xFFEEF4F4);
      foreground = kEventDeepTeal;
      icon = Icons.hourglass_empty;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: foreground),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
