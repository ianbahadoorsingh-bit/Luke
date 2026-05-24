import 'package:cloud_firestore/cloud_firestore.dart';

class Tournament {
  final String id;
  final String name;
  final String description;
  final String courseId;
  final String courseName;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime registrationDeadline;
  final String format;
  final int maxParticipants;
  final double entryFee;
  final String feeCurrency;
  final String? imageUrl;
  final bool registrationOpen;
  final String country;
  final List<String> tags;
  final int? registrationCount;

  const Tournament({
    required this.id,
    required this.name,
    required this.description,
    required this.courseId,
    required this.courseName,
    required this.startDate,
    required this.endDate,
    required this.registrationDeadline,
    required this.format,
    required this.maxParticipants,
    required this.entryFee,
    this.feeCurrency = 'TTD',
    this.imageUrl,
    required this.registrationOpen,
    this.country = 'TT',
    this.tags = const [],
    this.registrationCount,
  });

  bool get isFull =>
      registrationCount != null && registrationCount! >= maxParticipants;

  bool get isAcceptingRegistrations =>
      registrationOpen && !isFull && registrationDeadline.isAfter(DateTime.now());

  factory Tournament.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Tournament(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      courseId: data['courseId'] as String? ?? '',
      courseName: data['courseName'] as String? ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      registrationDeadline:
          (data['registrationDeadline'] as Timestamp).toDate(),
      format: data['format'] as String? ?? 'Strokeplay',
      maxParticipants: data['maxParticipants'] as int? ?? 100,
      entryFee: (data['entryFee'] as num?)?.toDouble() ?? 0,
      feeCurrency: data['feeCurrency'] as String? ?? 'TTD',
      imageUrl: data['imageUrl'] as String?,
      registrationOpen: data['registrationOpen'] as bool? ?? true,
      country: data['country'] as String? ?? 'TT',
      tags: List<String>.from(data['tags'] as List? ?? []),
      registrationCount: data['registrationCount'] as int?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'description': description,
        'courseId': courseId,
        'courseName': courseName,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'registrationDeadline': Timestamp.fromDate(registrationDeadline),
        'format': format,
        'maxParticipants': maxParticipants,
        'entryFee': entryFee,
        'feeCurrency': feeCurrency,
        'imageUrl': imageUrl,
        'registrationOpen': registrationOpen,
        'country': country,
        'tags': tags,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
