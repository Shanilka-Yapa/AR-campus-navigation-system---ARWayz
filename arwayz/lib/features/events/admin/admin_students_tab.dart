import 'package:flutter/material.dart';

import '../event_theme.dart';
import '../models/student_profile.dart';
import 'admin_data_service.dart';

/// Registration review and moderation.
///
/// A student can sign in as soon as they register but stays `pending` and
/// cannot comment or like until approved here.
class AdminStudentsTab extends StatefulWidget {
  const AdminStudentsTab({super.key});

  @override
  State<AdminStudentsTab> createState() => _AdminStudentsTabState();
}

class _AdminStudentsTabState extends State<AdminStudentsTab> {
  final AdminDataService _service = AdminDataService();
  late final Stream<List<StudentProfile>> _stream = _service.watchStudents();

  StudentStatus _filter = StudentStatus.pending;
  String _busyUid = '';

  Future<void> _run(String uid, Future<void> Function() action) async {
    setState(() => _busyUid = uid);
    try {
      await action();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not update: $error'),
            backgroundColor: kEventPrimaryDark,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busyUid = '');
    }
  }

  Future<void> _confirmReject(StudentProfile student) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject registration?'),
        content: Text(
          '${student.name} (${student.indexNumber}) will be removed and '
          'locked out.\n\nTheir sign-in account still exists in Firebase '
          'Authentication and must be deleted there separately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _run(student.uid, () => _service.deleteStudent(student.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kEventScaffoldBg,
      appBar: AppBar(
        backgroundColor: kEventPrimaryDark,
        foregroundColor: Colors.white,
        title: const Text('Manage Students'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return StreamBuilder<List<StudentProfile>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: kEventDeepTeal),
          );
        }
        if (snapshot.hasError) {
          return _ErrorState(error: '${snapshot.error}');
        }

        final all = snapshot.data ?? const <StudentProfile>[];
        final counts = <StudentStatus, int>{
          for (final status in StudentStatus.values)
            status: all.where((s) => s.status == status).length,
        };
        final visible = all.where((s) => s.status == _filter).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Requests',
                    count: counts[StudentStatus.pending] ?? 0,
                    selected: _filter == StudentStatus.pending,
                    onTap: () =>
                        setState(() => _filter = StudentStatus.pending),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Approved',
                    count: counts[StudentStatus.approved] ?? 0,
                    selected: _filter == StudentStatus.approved,
                    onTap: () =>
                        setState(() => _filter = StudentStatus.approved),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Blocked',
                    count: counts[StudentStatus.blocked] ?? 0,
                    selected: _filter == StudentStatus.blocked,
                    onTap: () =>
                        setState(() => _filter = StudentStatus.blocked),
                  ),
                ],
              ),
            ),
            Expanded(
              child: visible.isEmpty
                  ? _EmptyState(
                      message: _filter == StudentStatus.pending
                          ? 'No registration requests waiting.'
                          : 'No ${_filter.name} students.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: visible.length,
                      itemBuilder: (context, index) {
                        final student = visible[index];
                        return _StudentCard(
                          student: student,
                          busy: _busyUid == student.uid,
                          onApprove: () => _run(
                            student.uid,
                            () => _service.setStudentStatus(
                              student.uid,
                              StudentStatus.approved,
                            ),
                          ),
                          onBlock: () => _run(
                            student.uid,
                            () => _service.setStudentStatus(
                              student.uid,
                              StudentStatus.blocked,
                            ),
                          ),
                          onReject: () => _confirmReject(student),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _StudentCard extends StatelessWidget {
  final StudentProfile student;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onBlock;
  final VoidCallback onReject;

  const _StudentCard({
    required this.student,
    required this.busy,
    required this.onApprove,
    required this.onBlock,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              student.name,
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
                color: kEventPrimaryDark,
              ),
            ),
            const SizedBox(height: 6),
            _Line(icon: Icons.badge_outlined, text: student.indexNumber),
            _Line(icon: Icons.mail_outline, text: student.email),
            const SizedBox(height: 10),
            Row(
              children: [
                if (student.isPending) ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: busy ? null : onApprove,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kEventDeepTeal,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Approve'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: busy ? null : onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                ],
                if (student.isApproved)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: busy ? null : onBlock,
                      icon: const Icon(Icons.block, size: 18),
                      label: const Text('Block'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                      ),
                    ),
                  ),
                if (student.isBlocked)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: busy ? null : onApprove,
                      icon: const Icon(Icons.lock_open, size: 18),
                      label: const Text('Unblock'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kEventDeepTeal,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Line({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 15, color: kEventSteelBlue),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: kEventMutedTeal),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? kEventPrimaryDark : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? kEventPrimaryDark : kEventLightGray,
            ),
          ),
          child: Text(
            count > 0 ? '$label ($count)' : label,
            style: TextStyle(
              color: selected ? Colors.white : kEventMutedTeal,
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: kEventSteelBlue),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Could not load students.\n\n$error',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: kEventSteelBlue),
        ),
      ),
    );
  }
}
