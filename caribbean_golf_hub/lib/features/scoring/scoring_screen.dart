import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/models/scorecard_model.dart';
import '../../shared/services/data_store.dart';
import '../../shared/widgets/caribbean_app_bar.dart';
import '../../shared/widgets/empty_state.dart';
import 'round_setup_screen.dart';
import 'round_summary_screen.dart';

class ScoringScreen extends StatelessWidget {
  const ScoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CaribbeanAppBar(
        title: 'Scorecard',
        subtitle: 'Track your round',
        showGoldAccent: true,
      ),
      body: StreamBuilder<List<ScorecardRound>>(
        initialData: DataStore.instance.rounds,
        stream: DataStore.instance.watchRounds(),
        builder: (context, snap) {
          final rounds = snap.data ?? [];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Action buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start New Round'),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RoundSetupScreen()),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.emoji_events_outlined,
                          color: AppColors.primaryGreen),
                      label: const Text('Start Tournament Score Card'),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const RoundSetupScreen(isTournament: true)),
                      ),
                    ),
                  ],
                ),
              ),

              // Past rounds header
              if (rounds.isNotEmpty) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text(
                    'Past Rounds (${rounds.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.charcoal,
                    ),
                  ),
                ),
              ],

              // Rounds list
              Expanded(
                child: rounds.isEmpty
                    ? const EmptyState(
                        emoji: '⛳',
                        title: 'No rounds yet',
                        subtitle:
                            'Start a new round to begin tracking your score',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: rounds.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          // Show newest first
                          final round =
                              rounds[rounds.length - 1 - i];
                          return _RoundCard(
                            round: round,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    RoundSummaryScreen(round: round),
                              ),
                            ),
                            onDelete: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Delete Round'),
                                  content: Text(
                                      'Delete this round from ${round.courseName}?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      style:
                                          ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.error),
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (ok == true) {
                                await DataStore.instance
                                    .deleteRound(round.id);
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RoundCard extends StatelessWidget {
  final ScorecardRound round;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _RoundCard({
    required this.round,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('EEE d MMM yyyy');
    final playerScores = round.playerNames
        .map((p) => '$p: ${round.totalForPlayer(p)}')
        .join('  ·  ');

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.sports_score,
                    color: AppColors.primaryGreen, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(round.courseName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 3),
                    Text(df.format(round.date),
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.mediumGray)),
                    const SizedBox(height: 3),
                    Text(
                      '${round.totalHoles} holes  ·  Par ${round.totalPar}  ·  $playerScores',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.darkGray),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.error, size: 20),
                onPressed: onDelete,
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
