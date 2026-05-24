import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import '../models/course_model.dart';
import '../models/tournament_model.dart';
import '../models/registration_model.dart';
import '../models/special_model.dart';
import '../models/rule_model.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final _db = FirebaseFirestore.instance;

  // ── Collections ──────────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _courses =>
      _db.collection('courses');

  CollectionReference<Map<String, dynamic>> get _tournaments =>
      _db.collection('tournaments');

  CollectionReference<Map<String, dynamic>> get _specials =>
      _db.collection('specials');

  CollectionReference<Map<String, dynamic>> get _rules =>
      _db.collection('rules');

  CollectionReference<Map<String, dynamic>> _registrations(String tournamentId) =>
      _tournaments.doc(tournamentId).collection('registrations');

  // ── Courses ───────────────────────────────────────────────────────────────

  Stream<List<GolfCourse>> watchCourses() {
    return _courses
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => GolfCourse.fromFirestore(
                doc as DocumentSnapshot<Map<String, dynamic>>))
            .toList());
  }

  Future<GolfCourse?> getCourse(String courseId) async {
    final doc = await _courses.doc(courseId).get();
    if (!doc.exists) return null;
    return GolfCourse.fromFirestore(
        doc as DocumentSnapshot<Map<String, dynamic>>);
  }

  Future<void> saveCourse(GolfCourse course) async {
    if (course.id.isEmpty) {
      await _courses.add(course.toFirestore());
    } else {
      await _courses.doc(course.id).set(course.toFirestore(), SetOptions(merge: true));
    }
  }

  // ── Tournaments ───────────────────────────────────────────────────────────

  Stream<List<Tournament>> watchUpcomingTournaments({String? country}) {
    Query<Map<String, dynamic>> query = _tournaments
        .where('startDate', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('startDate');

    if (country != null) {
      query = query.where('country', isEqualTo: country);
    }

    return query.snapshots().map((snap) => snap.docs
        .map((doc) => Tournament.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList());
  }

  Future<Tournament?> getTournament(String tournamentId) async {
    final doc = await _tournaments.doc(tournamentId).get();
    if (!doc.exists) return null;
    return Tournament.fromFirestore(
        doc as DocumentSnapshot<Map<String, dynamic>>);
  }

  // ── Registrations ─────────────────────────────────────────────────────────

  Future<String> submitRegistration(TournamentRegistration reg) async {
    final ref = await _registrations(reg.tournamentId).add(reg.toFirestore());
    // Atomically increment the registration count on the tournament
    await _tournaments.doc(reg.tournamentId).update({
      'registrationCount': FieldValue.increment(1),
    });
    return ref.id;
  }

  Stream<List<TournamentRegistration>> watchRegistrations(String tournamentId) {
    return _registrations(tournamentId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => TournamentRegistration.fromFirestore(
                doc as DocumentSnapshot<Map<String, dynamic>>))
            .toList());
  }

  Future<List<TournamentRegistration>> getRegistrationsOnce(
      String tournamentId) async {
    final snap = await _registrations(tournamentId)
        .orderBy('submittedAt')
        .get();
    return snap.docs
        .map((doc) => TournamentRegistration.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList();
  }

  /// Returns a CSV string of all registrations for a given tournament.
  Future<String> exportRegistrationsCsv(
      String tournamentId, String tournamentName) async {
    final regs = await getRegistrationsOnce(tournamentId);
    final rows = <List<String>>[
      ['Tournament: $tournamentName'],
      ['Exported: ${DateTime.now().toIso8601String()}'],
      [],
      TournamentRegistration.csvHeaders,
      ...regs.map((r) => r.toCsvRow()),
    ];
    return const ListToCsvConverter().convert(rows);
  }

  // ── Specials ──────────────────────────────────────────────────────────────

  Stream<List<GolfSpecial>> watchActiveSpecials({
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) {
    Query<Map<String, dynamic>> query = _specials
        .where('isActive', isEqualTo: true)
        .where('validTo', isGreaterThan: Timestamp.now())
        .orderBy('validTo')
        .orderBy('publishedAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.snapshots().map((snap) => snap.docs
        .map((doc) => GolfSpecial.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList());
  }

  Future<void> publishSpecial(GolfSpecial special) async {
    if (special.id.isEmpty) {
      await _specials.add(special.toFirestore());
    } else {
      await _specials
          .doc(special.id)
          .set(special.toFirestore(), SetOptions(merge: true));
    }
  }

  // ── Rules ─────────────────────────────────────────────────────────────────

  Future<List<GolfRule>> getRulesByCategory(String category) async {
    final snap = await _rules
        .where('category', isEqualTo: category)
        .orderBy('order')
        .get();
    return snap.docs
        .map((doc) => GolfRule.fromFirestore(
            doc.data(), doc.id))
        .toList();
  }

  Future<List<String>> getRuleCategories() async {
    final snap = await _rules.get();
    final categories = snap.docs
        .map((d) => d.data()['category'] as String? ?? '')
        .toSet()
        .toList()
      ..sort();
    return categories;
  }

  Stream<List<GolfRule>> watchAllRules() {
    return _rules
        .orderBy('category')
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => GolfRule.fromFirestore(doc.data(), doc.id))
            .toList());
  }
}
