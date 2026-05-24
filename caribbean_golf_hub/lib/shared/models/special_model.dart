import 'package:cloud_firestore/cloud_firestore.dart';

class GolfSpecial {
  final String id;
  final String courseId;
  final String courseName;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime validFrom;
  final DateTime validTo;
  final double price;
  final double? originalPrice;
  final String currency;
  final List<String> tags;
  final bool isActive;
  final DateTime publishedAt;

  const GolfSpecial({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.validFrom,
    required this.validTo,
    required this.price,
    this.originalPrice,
    this.currency = 'TTD',
    this.tags = const [],
    required this.isActive,
    required this.publishedAt,
  });

  bool get isExpired => DateTime.now().isAfter(validTo);
  bool get isLive => isActive && !isExpired && DateTime.now().isAfter(validFrom);

  double? get savingsPercent {
    if (originalPrice == null || originalPrice! <= price) return null;
    return ((originalPrice! - price) / originalPrice! * 100);
  }

  Duration get timeRemaining => validTo.difference(DateTime.now());

  factory GolfSpecial.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return GolfSpecial(
      id: doc.id,
      courseId: data['courseId'] as String? ?? '',
      courseName: data['courseName'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      validFrom: (data['validFrom'] as Timestamp).toDate(),
      validTo: (data['validTo'] as Timestamp).toDate(),
      price: (data['price'] as num?)?.toDouble() ?? 0,
      originalPrice: (data['originalPrice'] as num?)?.toDouble(),
      currency: data['currency'] as String? ?? 'TTD',
      tags: List<String>.from(data['tags'] as List? ?? []),
      isActive: data['isActive'] as bool? ?? true,
      publishedAt: (data['publishedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'courseId': courseId,
        'courseName': courseName,
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'validFrom': Timestamp.fromDate(validFrom),
        'validTo': Timestamp.fromDate(validTo),
        'price': price,
        'originalPrice': originalPrice,
        'currency': currency,
        'tags': tags,
        'isActive': isActive,
        'publishedAt': FieldValue.serverTimestamp(),
        'notificationSent': false,
      };
}
