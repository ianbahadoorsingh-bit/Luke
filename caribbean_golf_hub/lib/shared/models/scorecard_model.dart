class ScorecardRound {
  final String id;
  final String courseId;
  final String courseName;
  final DateTime date;
  final int totalHoles;
  final List<String> playerNames;
  // holeScores[i] = {playerName: score} for hole i+1; score is null if not entered
  final List<Map<String, int?>> holeScores;
  final List<int> pars;
  final String? tournamentId;
  final String? tournamentName;

  ScorecardRound({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.date,
    required this.totalHoles,
    required this.playerNames,
    required this.holeScores,
    required this.pars,
    this.tournamentId,
    this.tournamentName,
  });

  static List<int> defaultPars(int holes) {
    if (holes == 9) return [4, 4, 3, 4, 5, 4, 3, 4, 4];
    return [4, 4, 3, 4, 5, 4, 3, 4, 4, 4, 4, 3, 5, 4, 4, 3, 4, 5];
  }

  int totalForPlayer(String name) =>
      holeScores.fold(0, (sum, hole) => sum + (hole[name] ?? 0));

  int enteredHolesForPlayer(String name) =>
      holeScores.where((h) => h[name] != null).length;

  int get totalPar => pars.fold(0, (a, b) => a + b);

  bool get isComplete => holeScores.every(
        (hole) => playerNames.every((p) => hole[p] != null),
      );

  ScorecardRound copyWith({List<Map<String, int?>>? holeScores}) => ScorecardRound(
        id: id,
        courseId: courseId,
        courseName: courseName,
        date: date,
        totalHoles: totalHoles,
        playerNames: playerNames,
        holeScores: holeScores ?? this.holeScores,
        pars: pars,
        tournamentId: tournamentId,
        tournamentName: tournamentName,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseId': courseId,
        'courseName': courseName,
        'date': date.toIso8601String(),
        'totalHoles': totalHoles,
        'playerNames': playerNames,
        'holeScores': holeScores
            .map((h) => h.map((k, v) => MapEntry(k, v)))
            .toList(),
        'pars': pars,
        if (tournamentId != null) 'tournamentId': tournamentId,
        if (tournamentName != null) 'tournamentName': tournamentName,
      };

  factory ScorecardRound.fromJson(Map<String, dynamic> map) {
    final players = List<String>.from(map['playerNames'] as List);
    return ScorecardRound(
      id: map['id'] as String,
      courseId: map['courseId'] as String,
      courseName: map['courseName'] as String,
      date: DateTime.parse(map['date'] as String),
      totalHoles: map['totalHoles'] as int,
      playerNames: players,
      holeScores: (map['holeScores'] as List).map((h) {
        final hm = Map<String, dynamic>.from(h as Map);
        return Map<String, int?>.fromEntries(
          players.map((p) => MapEntry(p, hm[p] as int?)),
        );
      }).toList(),
      pars: List<int>.from(map['pars'] as List),
      tournamentId: map['tournamentId'] as String?,
      tournamentName: map['tournamentName'] as String?,
    );
  }
}
