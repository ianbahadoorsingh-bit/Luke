import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/models/scorecard_model.dart';
import 'round_summary_screen.dart';

class ActiveRoundScreen extends StatefulWidget {
  final ScorecardRound round;

  const ActiveRoundScreen({super.key, required this.round});

  @override
  State<ActiveRoundScreen> createState() => _ActiveRoundScreenState();
}

class _ActiveRoundScreenState extends State<ActiveRoundScreen> {
  late ScorecardRound _round;
  int _currentHole = 0; // 0-indexed

  @override
  void initState() {
    super.initState();
    _round = widget.round;
  }

  void _updateScore(String player, int delta) {
    final currentScore = _round.holeScores[_currentHole][player];
    final newScore = (currentScore ?? _round.pars[_currentHole]) + delta;
    if (newScore < 1) return; // minimum 1 stroke
    final newHoleScores = List<Map<String, int?>>.from(
      _round.holeScores.map((h) => Map<String, int?>.from(h)),
    );
    newHoleScores[_currentHole] = Map<String, int?>.from(
        newHoleScores[_currentHole])..[player] = newScore;
    setState(() {
      _round = _round.copyWith(holeScores: newHoleScores);
    });
  }

  void _setScore(String player, int? score) {
    final newHoleScores = List<Map<String, int?>>.from(
      _round.holeScores.map((h) => Map<String, int?>.from(h)),
    );
    newHoleScores[_currentHole] = Map<String, int?>.from(
        newHoleScores[_currentHole])..[player] = score;
    setState(() {
      _round = _round.copyWith(holeScores: newHoleScores);
    });
  }

  void _goNext() {
    if (_currentHole < _round.totalHoles - 1) {
      setState(() => _currentHole++);
    }
  }

  void _goPrev() {
    if (_currentHole > 0) {
      setState(() => _currentHole--);
    }
  }

  void _finishRound() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RoundSummaryScreen(round: _round, fromActive: true),
      ),
    );
  }

  String _scoreDiffLabel(String player) {
    final total = _round.totalForPlayer(player);
    final entered = _round.enteredHolesForPlayer(player);
    if (entered == 0) return 'E';
    final parSoFar =
        _round.pars.take(entered).fold(0, (a, b) => a + b);
    final diff = total - parSoFar;
    if (diff == 0) return 'E';
    return diff > 0 ? '+$diff' : '$diff';
  }

  Color _scoreDiffColor(String player) {
    final total = _round.totalForPlayer(player);
    final entered = _round.enteredHolesForPlayer(player);
    if (entered == 0) return AppColors.mediumGray;
    final parSoFar =
        _round.pars.take(entered).fold(0, (a, b) => a + b);
    final diff = total - parSoFar;
    if (diff < 0) return AppColors.success;
    if (diff > 0) return AppColors.error;
    return AppColors.mediumGray;
  }

  @override
  Widget build(BuildContext context) {
    final hole = _currentHole + 1;
    final par = _round.pars[_currentHole];
    final isLast = _currentHole == _round.totalHoles - 1;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Exit Round?'),
                content: const Text(
                    'Your progress will be lost if you exit without saving.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Stay')),
                  ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Exit')),
                ],
              ),
            );
            if (ok == true && mounted) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _round.courseName,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          TextButton(
            onPressed: _finishRound,
            child: const Text('Finish',
                style: TextStyle(color: AppColors.accentGold)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Hole indicator
          Container(
            color: AppColors.mediumGreen,
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hole $hole of ${_round.totalHoles}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'Par $par',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14),
                    ),
                  ],
                ),
                // Progress dots
                Row(
                  children: List.generate(
                    _round.totalHoles,
                    (i) => Container(
                      margin: const EdgeInsets.only(left: 4),
                      width: i == _currentHole ? 10 : 6,
                      height: i == _currentHole ? 10 : 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < _currentHole
                            ? AppColors.accentGold
                            : i == _currentHole
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Running totals row
          Container(
            color: AppColors.surfaceGreen,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _round.playerNames.map((p) {
                return Column(
                  children: [
                    Text(p,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.darkGray)),
                    Text(
                      _scoreDiffLabel(p),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _scoreDiffColor(p),
                      ),
                    ),
                    Text(
                      '${_round.totalForPlayer(p)}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.mediumGray),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),

          const Divider(height: 1),

          // Player score inputs
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _round.playerNames.length,
              separatorBuilder: (_, __) => const Divider(height: 20),
              itemBuilder: (context, i) {
                final player = _round.playerNames[i];
                final score =
                    _round.holeScores[_currentHole][player];
                final displayScore = score ?? par;

                return _PlayerScoreRow(
                  playerName: player,
                  score: displayScore,
                  par: par,
                  onIncrement: () => _updateScore(player, 1),
                  onDecrement: () => _updateScore(player, -1),
                  onClear: score != null
                      ? () => _setScore(player, null)
                      : null,
                );
              },
            ),
          ),

          // Navigation buttons
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Previous'),
                    onPressed:
                        _currentHole > 0 ? _goPrev : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: isLast
                      ? ElevatedButton.icon(
                          icon: const Icon(Icons.flag),
                          label: const Text('Finish Round'),
                          onPressed: _finishRound,
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppColors.accentGold),
                        )
                      : ElevatedButton.icon(
                          icon: const Icon(Icons.chevron_right),
                          label: const Text('Next'),
                          onPressed: _goNext,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerScoreRow extends StatelessWidget {
  final String playerName;
  final int score;
  final int par;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback? onClear;

  const _PlayerScoreRow({
    required this.playerName,
    required this.score,
    required this.par,
    required this.onIncrement,
    required this.onDecrement,
    this.onClear,
  });

  Color get _scoreColor {
    final diff = score - par;
    if (diff < 0) return AppColors.success;
    if (diff > 0) return AppColors.error;
    return AppColors.charcoal;
  }

  String get _scoreLabel {
    final diff = score - par;
    if (diff == -2) return 'Eagle';
    if (diff == -1) return 'Birdie';
    if (diff == 0) return 'Par';
    if (diff == 1) return 'Bogey';
    if (diff == 2) return 'Dbl Bogey';
    if (diff > 2) return '+$diff';
    return '$diff';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Player name
        SizedBox(
          width: 90,
          child: Text(
            playerName,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 15),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Spacer(),

        // Decrement button
        _ScoreButton(
          icon: Icons.remove,
          onPressed: onDecrement,
          color: AppColors.error,
        ),
        const SizedBox(width: 12),

        // Score display
        Column(
          children: [
            Text(
              '$score',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: _scoreColor,
              ),
            ),
            Text(
              _scoreLabel,
              style: TextStyle(
                  fontSize: 11,
                  color: _scoreColor,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(width: 12),

        // Increment button
        _ScoreButton(
          icon: Icons.add,
          onPressed: onIncrement,
          color: AppColors.primaryGreen,
        ),

        if (onClear != null) ...[
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh,
                color: AppColors.mediumGray, size: 18),
            onPressed: onClear,
            tooltip: 'Reset to par',
          ),
        ],
      ],
    );
  }
}

class _ScoreButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  const _ScoreButton({
    required this.icon,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(50),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(50),
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(icon, color: color, size: 28),
        ),
      ),
    );
  }
}
