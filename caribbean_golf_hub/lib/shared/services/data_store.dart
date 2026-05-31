import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course_model.dart';
import '../models/tournament_model.dart';
import '../models/special_model.dart';
import '../models/rule_model.dart';
import '../models/scorecard_model.dart';
import 'mock_data.dart';

class DataStore {
  static final DataStore instance = DataStore._();
  DataStore._();

  List<GolfCourse> _courses = [];
  List<Tournament> _tournaments = [];
  List<GolfSpecial> _specials = [];
  List<GolfRule> _rules = [];
  List<ScorecardRound> _rounds = [];

  final _coursesCtrl = StreamController<List<GolfCourse>>.broadcast();
  final _tournamentsCtrl = StreamController<List<Tournament>>.broadcast();
  final _specialsCtrl = StreamController<List<GolfSpecial>>.broadcast();
  final _rulesCtrl = StreamController<List<GolfRule>>.broadcast();
  final _roundsCtrl = StreamController<List<ScorecardRound>>.broadcast();

  List<GolfCourse> get courses => List.unmodifiable(_courses);
  List<Tournament> get tournaments => List.unmodifiable(_tournaments);
  List<GolfSpecial> get specials => List.unmodifiable(_specials);
  List<GolfRule> get rules => List.unmodifiable(_rules);
  List<ScorecardRound> get rounds => List.unmodifiable(_rounds);

  Stream<List<GolfCourse>> watchCourses() => _coursesCtrl.stream;
  Stream<List<Tournament>> watchTournaments({String? country}) =>
      _tournamentsCtrl.stream.map(
        (list) =>
            country == null ? list : list.where((t) => t.country == country).toList(),
      );
  Stream<List<GolfSpecial>> watchSpecials() => _specialsCtrl.stream;
  Stream<List<GolfRule>> watchRules() => _rulesCtrl.stream;
  Stream<List<ScorecardRound>> watchRounds() => _roundsCtrl.stream;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    _courses = _load(
        prefs, 'ds_courses', MockData.courses, (e) => GolfCourse.fromJson(e));
    _tournaments = _load(prefs, 'ds_tournaments', MockData.tournaments,
        (e) => Tournament.fromJson(e));
    _specials = _load(
        prefs, 'ds_specials', MockData.specials, (e) => GolfSpecial.fromJson(e));
    _rules =
        _load(prefs, 'ds_rules', MockData.rules, (e) => GolfRule.fromJson(e));
    _rounds =
        _load(prefs, 'ds_rounds', [], (e) => ScorecardRound.fromJson(e));
  }

  List<T> _load<T>(SharedPreferences prefs, String key, List<T> fallback,
      T Function(Map<String, dynamic>) fromJson) {
    final raw = prefs.getString(key);
    if (raw == null) return List<T>.from(fallback);
    try {
      return (jsonDecode(raw) as List)
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return List<T>.from(fallback);
    }
  }

  // ── Courses ──────────────────────────────────────────────────────────────
  Future<void> saveCourse(GolfCourse course) async {
    final idx = _courses.indexWhere((c) => c.id == course.id);
    if (idx >= 0) {
      _courses[idx] = course;
    } else {
      _courses.add(course);
    }
    await _persist('ds_courses', _courses.map((c) => c.toJson()).toList());
    _coursesCtrl.add(List.from(_courses));
  }

  Future<void> deleteCourse(String id) async {
    _courses.removeWhere((c) => c.id == id);
    await _persist('ds_courses', _courses.map((c) => c.toJson()).toList());
    _coursesCtrl.add(List.from(_courses));
  }

  // ── Tournaments ───────────────────────────────────────────────────────────
  Future<void> saveTournament(Tournament t) async {
    final idx = _tournaments.indexWhere((x) => x.id == t.id);
    if (idx >= 0) {
      _tournaments[idx] = t;
    } else {
      _tournaments.add(t);
    }
    await _persist(
        'ds_tournaments', _tournaments.map((x) => x.toJson()).toList());
    _tournamentsCtrl.add(List.from(_tournaments));
  }

  Future<void> deleteTournament(String id) async {
    _tournaments.removeWhere((t) => t.id == id);
    await _persist(
        'ds_tournaments', _tournaments.map((x) => x.toJson()).toList());
    _tournamentsCtrl.add(List.from(_tournaments));
  }

  // ── Specials ──────────────────────────────────────────────────────────────
  Future<void> saveSpecial(GolfSpecial s) async {
    final idx = _specials.indexWhere((x) => x.id == s.id);
    if (idx >= 0) {
      _specials[idx] = s;
    } else {
      _specials.add(s);
    }
    await _persist('ds_specials', _specials.map((x) => x.toJson()).toList());
    _specialsCtrl.add(List.from(_specials));
  }

  Future<void> deleteSpecial(String id) async {
    _specials.removeWhere((s) => s.id == id);
    await _persist('ds_specials', _specials.map((x) => x.toJson()).toList());
    _specialsCtrl.add(List.from(_specials));
  }

  // ── Rules ─────────────────────────────────────────────────────────────────
  Future<void> saveRule(GolfRule r) async {
    final idx = _rules.indexWhere((x) => x.id == r.id);
    if (idx >= 0) {
      _rules[idx] = r;
    } else {
      _rules.add(r);
    }
    await _persist('ds_rules', _rules.map((x) => x.toJson()).toList());
    _rulesCtrl.add(List.from(_rules));
  }

  Future<void> deleteRule(String id) async {
    _rules.removeWhere((r) => r.id == id);
    await _persist('ds_rules', _rules.map((x) => x.toJson()).toList());
    _rulesCtrl.add(List.from(_rules));
  }

  // ── Rounds ────────────────────────────────────────────────────────────────
  Future<void> saveRound(ScorecardRound round) async {
    final idx = _rounds.indexWhere((r) => r.id == round.id);
    if (idx >= 0) {
      _rounds[idx] = round;
    } else {
      _rounds.add(round);
    }
    await _persist('ds_rounds', _rounds.map((r) => r.toJson()).toList());
    _roundsCtrl.add(List.from(_rounds));
  }

  Future<void> deleteRound(String id) async {
    _rounds.removeWhere((r) => r.id == id);
    await _persist('ds_rounds', _rounds.map((r) => r.toJson()).toList());
    _roundsCtrl.add(List.from(_rounds));
  }

  // ── Reset ─────────────────────────────────────────────────────────────────
  Future<void> resetToDefaults() async {
    _courses = List.from(MockData.courses);
    _tournaments = List.from(MockData.tournaments);
    _specials = List.from(MockData.specials);
    _rules = List.from(MockData.rules);
    _rounds = [];
    final prefs = await SharedPreferences.getInstance();
    for (final key in [
      'ds_courses',
      'ds_tournaments',
      'ds_specials',
      'ds_rules',
      'ds_rounds'
    ]) {
      await prefs.remove(key);
    }
    _coursesCtrl.add(List.from(_courses));
    _tournamentsCtrl.add(List.from(_tournaments));
    _specialsCtrl.add(List.from(_specials));
    _rulesCtrl.add(List.from(_rules));
    _roundsCtrl.add([]);
  }

  Future<void> _persist(String key, List<dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data));
  }
}
