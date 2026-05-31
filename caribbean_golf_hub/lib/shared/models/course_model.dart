import 'package:cloud_firestore/cloud_firestore.dart';

class RateTier {
  final double? weekday;
  final double? weekend;
  final double? twilight;

  const RateTier({this.weekday, this.weekend, this.twilight});

  factory RateTier.fromMap(Map<String, dynamic> map) => RateTier(
        weekday: (map['weekday'] as num?)?.toDouble(),
        weekend: (map['weekend'] as num?)?.toDouble(),
        twilight: (map['twilight'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'weekday': weekday,
        'weekend': weekend,
        'twilight': twilight,
      };
}

class CourseRates {
  final RateTier local;
  final RateTier tourist;
  final String currencyLocal;
  final String currencyTourist;
  final String? notes;

  const CourseRates({
    required this.local,
    required this.tourist,
    this.currencyLocal = 'TTD',
    this.currencyTourist = 'USD',
    this.notes,
  });

  factory CourseRates.fromMap(Map<String, dynamic> map) => CourseRates(
        local: RateTier.fromMap(
            (map['local'] as Map<String, dynamic>?) ?? {}),
        tourist: RateTier.fromMap(
            (map['tourist'] as Map<String, dynamic>?) ?? {}),
        currencyLocal: map['currency_local'] as String? ?? 'TTD',
        currencyTourist: map['currency_tourist'] as String? ?? 'USD',
        notes: map['notes'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'local': local.toMap(),
        'tourist': tourist.toMap(),
        'currency_local': currencyLocal,
        'currency_tourist': currencyTourist,
        'notes': notes,
      };
}

class GolfCourse {
  final String id;
  final String name;
  final String location;
  final String? mapLink;
  final double? latitude;
  final double? longitude;
  final String contactNumber;
  final String whatsappNumber;
  final List<String> amenities;
  final String? imageUrl;
  final String description;
  final CourseRates rates;
  final bool isActive;
  final DateTime? updatedAt;

  const GolfCourse({
    required this.id,
    required this.name,
    required this.location,
    this.mapLink,
    this.latitude,
    this.longitude,
    required this.contactNumber,
    required this.whatsappNumber,
    required this.amenities,
    this.imageUrl,
    required this.description,
    required this.rates,
    this.isActive = true,
    this.updatedAt,
  });

  factory GolfCourse.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return GolfCourse(
      id: doc.id,
      name: data['name'] as String? ?? '',
      location: data['location'] as String? ?? '',
      mapLink: data['mapLink'] as String?,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      contactNumber: data['contactNumber'] as String? ?? '',
      whatsappNumber: data['whatsappNumber'] as String? ?? '',
      amenities: List<String>.from(data['amenities'] as List? ?? []),
      imageUrl: data['imageUrl'] as String?,
      description: data['description'] as String? ?? '',
      rates: CourseRates.fromMap(
          (data['rates'] as Map<String, dynamic>?) ?? {}),
      isActive: data['isActive'] as bool? ?? true,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'location': location,
        'mapLink': mapLink,
        'latitude': latitude,
        'longitude': longitude,
        'contactNumber': contactNumber,
        'whatsappNumber': whatsappNumber,
        'amenities': amenities,
        'imageUrl': imageUrl,
        'description': description,
        'rates': rates.toMap(),
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  factory GolfCourse.fromJson(Map<String, dynamic> map) => GolfCourse(
        id: map['id'] as String? ?? '',
        name: map['name'] as String? ?? '',
        location: map['location'] as String? ?? '',
        mapLink: map['mapLink'] as String?,
        latitude: (map['latitude'] as num?)?.toDouble(),
        longitude: (map['longitude'] as num?)?.toDouble(),
        contactNumber: map['contactNumber'] as String? ?? '',
        whatsappNumber: map['whatsappNumber'] as String? ?? '',
        amenities: List<String>.from(map['amenities'] as List? ?? []),
        imageUrl: map['imageUrl'] as String?,
        description: map['description'] as String? ?? '',
        rates: CourseRates.fromMap((map['rates'] as Map<String, dynamic>?) ?? {}),
        isActive: map['isActive'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'location': location,
        if (mapLink != null) 'mapLink': mapLink,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'contactNumber': contactNumber,
        'whatsappNumber': whatsappNumber,
        'amenities': amenities,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'description': description,
        'rates': rates.toMap(),
        'isActive': isActive,
      };
}
