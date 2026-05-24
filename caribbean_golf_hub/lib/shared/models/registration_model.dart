import 'package:cloud_firestore/cloud_firestore.dart';

enum RegistrationStatus { pending, confirmed, waitlisted }

extension RegistrationStatusExt on RegistrationStatus {
  String get label {
    switch (this) {
      case RegistrationStatus.pending:
        return 'Pending';
      case RegistrationStatus.confirmed:
        return 'Confirmed';
      case RegistrationStatus.waitlisted:
        return 'Waitlisted';
    }
  }

  static RegistrationStatus fromString(String? s) {
    switch (s) {
      case 'confirmed':
        return RegistrationStatus.confirmed;
      case 'waitlisted':
        return RegistrationStatus.waitlisted;
      default:
        return RegistrationStatus.pending;
    }
  }
}

class TournamentRegistration {
  final String id;
  final String tournamentId;
  final String tournamentName;
  final String fullName;
  final String email;
  final String phone;
  final String homeClub;
  final double handicapIndex;
  final RegistrationStatus status;
  final DateTime submittedAt;
  final String? notes;

  const TournamentRegistration({
    required this.id,
    required this.tournamentId,
    required this.tournamentName,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.homeClub,
    required this.handicapIndex,
    this.status = RegistrationStatus.pending,
    required this.submittedAt,
    this.notes,
  });

  factory TournamentRegistration.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return TournamentRegistration(
      id: doc.id,
      tournamentId: data['tournamentId'] as String? ?? '',
      tournamentName: data['tournamentName'] as String? ?? '',
      fullName: data['fullName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      homeClub: data['homeClub'] as String? ?? '',
      handicapIndex: (data['handicapIndex'] as num?)?.toDouble() ?? 0,
      status: RegistrationStatusExt.fromString(data['status'] as String?),
      submittedAt: (data['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: data['notes'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'tournamentId': tournamentId,
        'tournamentName': tournamentName,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'homeClub': homeClub,
        'handicapIndex': handicapIndex,
        'status': status.label.toLowerCase(),
        'submittedAt': FieldValue.serverTimestamp(),
        'notes': notes,
      };

  /// CSV header row for export
  static List<String> get csvHeaders => [
        'Full Name',
        'Email',
        'Phone',
        'Home Club',
        'Handicap Index',
        'Status',
        'Submitted At',
      ];

  /// CSV data row
  List<String> toCsvRow() => [
        fullName,
        email,
        phone,
        homeClub,
        handicapIndex.toStringAsFixed(1),
        status.label,
        submittedAt.toIso8601String(),
      ];
}
