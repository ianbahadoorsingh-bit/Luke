import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/models/scorecard_model.dart';
import '../../shared/services/data_store.dart';
import 'scoring_screen.dart';

class RoundSummaryScreen extends StatelessWidget {
  final ScorecardRound round;
  final bool fromActive;

  const RoundSummaryScreen({
    super.key,
    required this.round,
    this.fromActive = false,
  });

  Future<void> _saveRound(BuildContext context) async {
    await DataStore.instance.saveRound(round);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Round saved!'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ScoringScreen()),
      (route) => route.isFirst,
    );
  }

  void _newRound(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ScoringScreen()),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('EEE d MMM yyyy');
    final is18 = round.totalHoles == 18;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Scorecard',
                style: TextStyle(color: Colors.white, fontSize: 16)),
            Text(
              round.courseName,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.8), fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Date + stats bar
          Container(
            color: AppColors.surfaceGreen,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 14, color: AppColors.mediumGray),
                const SizedBox(width: 6),
                Text(df.format(round.date),
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.darkGray)),
                const Spacer(),
                Text('${round.totalHoles} Holes  ·  Par ${round.totalPar}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoal)),
              ],
            ),
          ),

          // Scorecard table
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  if (is18) ...[
                    _ScorecardTable(
                      round: round,
                      startHole: 0,
                      endHole: 9,
                      label: 'OUT',
                    ),
                    const SizedBox(height: 16),
                    _ScorecardTable(
                      round: round,
                      startHole: 9,
                      endHole: 18,
                      label: 'IN',
                    ),
                  ] else
                    _ScorecardTable(
                      round: round,
                      startHole: 0,
                      endHole: 9,
                      label: 'OUT',
                    ),
                  const SizedBox(height: 16),
                  _TotalsCard(round: round),
                ],
              ),
            ),
          ),

          // Action buttons
          if (fromActive)
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
                    child: OutlinedButton(
                      onPressed: () => _newRound(context),
                      child: const Text('New Round'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Save Round'),
                      onPressed: () => _saveRound(context),
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

class _ScorecardTable extends StatelessWidget {
  final ScorecardRound round;
  final int startHole;
  final int endHole;
  final String label;

  const _ScorecardTable({
    required this.round,
    required this.startHole,
    required this.endHole,
    required this.label,
  });

  Color _cellColor(int? score, int par) {
    if (score == null) return Colors.transparent;
    final diff = score - par;
    if (diff <= -2) return AppColors.accentGold.withOpacity(0.25);
    if (diff == -1) return AppColors.success.withOpacity(0.2);
    if (diff == 0) return Colors.transparent;
    if (diff == 1) return AppColors.error.withOpacity(0.15);
    return AppColors.error.withOpacity(0.3);
  }

  Color _textColor(int? score, int par) {
    if (score == null) return AppColors.mediumGray;
    final diff = score - par;
    if (diff < 0) return AppColors.success;
    if (diff > 0) return AppColors.error;
    return AppColors.charcoal;
  }

  @override
  Widget build(BuildContext context) {
    final holes =
        List.generate(endHole - startHole, (i) => startHole + i);
    // subtotal par for this section
    final sectionPar = holes.fold(
        0, (sum, h) => sum + round.pars[h]);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            border: TableBorder.all(
                color: AppColors.lightGray, width: 0.5),
            columnWidths: {
              0: const FixedColumnWidth(60),
              for (int i = 1; i <= holes.length; i++)
                i: const FixedColumnWidth(36),
              holes.length + 1: const FixedColumnWidth(44),
            },
            children: [
              // Header: hole numbers
              TableRow(
                decoration: const BoxDecoration(
                    color: AppColors.primaryGreen),
                children: [
                  _HeaderCell('HOLE'),
                  ...holes.map((h) => _HeaderCell('${h + 1}')),
                  _HeaderCell(label),
                ],
              ),
              // Par row
              TableRow(
                decoration: const BoxDecoration(
                    color: AppColors.surfaceGreen),
                children: [
                  _LabelCell('Par'),
                  ...holes.map((h) =>
                      _LabelCell('${round.pars[h]}')),
                  _LabelCell('$sectionPar',
                      bold: true),
                ],
              ),
              // Player rows
              ...round.playerNames.map((player) {
                final sectionTotal = holes.fold(
                    0,
                    (sum, h) =>
                        sum +
                        (round.holeScores[h][player] ?? 0));
                return TableRow(
                  children: [
                    _LabelCell(player, small: true),
                    ...holes.map((h) {
                      final score =
                          round.holeScores[h][player];
                      return TableCell(
                        child: Container(
                          height: 32,
                          alignment: Alignment.center,
                          color: _cellColor(
                              score, round.pars[h]),
                          child: Text(
                            score != null ? '$score' : '-',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _textColor(
                                  score, round.pars[h]),
                            ),
                          ),
                        ),
                      );
                    }),
                    TableCell(
                      child: Container(
                        height: 32,
                        alignment: Alignment.center,
                        color: AppColors.surfaceGreen,
                        child: Text(
                          '$sectionTotal',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoal,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return TableCell(
      child: Container(
        height: 28,
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _LabelCell extends StatelessWidget {
  final String text;
  final bool bold;
  final bool small;

  const _LabelCell(this.text, {this.bold = false, this.small = false});

  @override
  Widget build(BuildContext context) {
    return TableCell(
      child: Container(
        height: 32,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          text,
          style: TextStyle(
            fontSize: small ? 10 : 12,
            fontWeight:
                bold ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.charcoal,
          ),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  final ScorecardRound round;
  const _TotalsCard({required this.round});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primaryGreen,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Final Totals',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
            const SizedBox(height: 12),
            ...round.playerNames.map((player) {
              final total = round.totalForPlayer(player);
              final diff = total - round.totalPar;
              final diffStr =
                  diff == 0 ? 'E' : (diff > 0 ? '+$diff' : '$diff');
              final diffColor = diff < 0
                  ? AppColors.accentGold
                  : diff > 0
                      ? AppColors.error
                      : Colors.white;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(player,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14)),
                    ),
                    Text(
                      '$total',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        diffStr,
                        style: TextStyle(
                          color: diffColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const Divider(color: Colors.white24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Course Par',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 13)),
                Text(
                  '${round.totalPar}',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
