import 'package:cloud_firestore/cloud_firestore.dart';

/// Where a student sits in the registration workflow.
///
/// A student signs up, lands in [pending], and can only comment or like once
/// an admin moves them to [approved]. This is enforced by the Firestore
/// rules, not just by the app.
enum StudentStatus { pending, approved, blocked }

StudentStatus _parseStatus(String? raw) {
  switch (raw) {
    case 'approved':
      return StudentStatus.approved;
    case 'blocked':
      return StudentStatus.blocked;
    default:
      return StudentStatus.pending;
  }
}

String statusToFirestore(StudentStatus status) => status.name;

/// A registered student, stored at `students/{uid}` where the id is the
/// Firebase Auth uid.
class StudentProfile {
  final String uid;
  final String name;
  final String indexNumber;
  final String email;
  final StudentStatus status;
  final DateTime? createdAt;

  const StudentProfile({
    required this.uid,
    required this.name,
    required this.indexNumber,
    required this.email,
    required this.status,
    this.createdAt,
  });

  factory StudentProfile.fromFirestore(
    String documentId,
    Map<String, dynamic> data,
  ) {
    return StudentProfile(
      uid: documentId,
      name: data['name'] as String? ?? 'Student',
      indexNumber: data['indexNumber'] as String? ?? '',
      email: data['email'] as String? ?? '',
      status: _parseStatus(data['status'] as String?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Only approved students may comment or like.
  bool get isApproved => status == StudentStatus.approved;
  bool get isPending => status == StudentStatus.pending;
  bool get isBlocked => status == StudentStatus.blocked;
}
