import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../shared/models/tournament_model.dart';
import '../../shared/widgets/amenity_chip.dart';
import 'registration_form_screen.dart';

class TournamentDetailScreen extends StatelessWidget {
  final Tournament tournament;

  const TournamentDetailScreen({super.key, required this.tournament});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('EEEE, d MMMM yyyy');
    final dfShort = DateFormat('d MMM');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _TournamentHero(tournament: tournament),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + format badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          tournament.name,
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      ),
                      const SizedBox(width: 12),
                      AmenityChip(label: tournament.format, gold: true),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Info grid
                  _InfoGrid(tournament: tournament, df: df, dfShort: dfShort),
                  const SizedBox(height: 20),
                  // Description
                  _SectionHeader(label: 'About This Tournament'),
                  const SizedBox(height: 10),
                  Text(
                    tournament.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  if (tournament.tags.isNotEmpty) ...[
                    _SectionHeader(label: 'Tags'),
                    const SizedBox(height: 10),
                    AmenityChipList(amenities: tournament.tags),
                    const SizedBox(height: 20),
                  ],
                  // Registration CTA
                  _RegistrationPanel(tournament: tournament),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TournamentHero extends StatelessWidget {
  final Tournament tournament;

  const _TournamentHero({required this.tournament});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: AppColors.primaryGreen,
      iconTheme: const IconThemeData(color: AppColors.white),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            tournament.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: tournament.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: AppColors.mediumGreen),
                  )
                : Container(
                    color: AppColors.mediumGreen,
                    child: const Icon(Icons.emoji_events,
                        size: 80, color: Colors.white24),
                  ),
            const DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.heroGradient),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final Tournament tournament;
  final DateFormat df;
  final DateFormat dfShort;

  const _InfoGrid({
    required this.tournament,
    required this.df,
    required this.dfShort,
  });

  @override
  Widget build(BuildContext context) {
    final dateRange = tournament.startDate == tournament.endDate
        ? df.format(tournament.startDate)
        : '${dfShort.format(tournament.startDate)} – ${df.format(tournament.endDate)}';

    return Card(
      elevation: 0,
      color: AppColors.offWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.lightGray),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _InfoTile(
              icon: Icons.calendar_today,
              label: 'Dates',
              value: dateRange,
            ),
            const Divider(height: 16),
            _InfoTile(
              icon: Icons.golf_course,
              label: 'Venue',
              value: tournament.courseName,
            ),
            const Divider(height: 16),
            _InfoTile(
              icon: Icons.timer_outlined,
              label: 'Registration Closes',
              value: df.format(tournament.registrationDeadline),
            ),
            const Divider(height: 16),
            _InfoTile(
              icon: Icons.group_outlined,
              label: 'Capacity',
              value:
                  '${tournament.registrationCount ?? 0} / ${tournament.maxParticipants} players',
            ),
            const Divider(height: 16),
            _InfoTile(
              icon: Icons.payments_outlined,
              label: 'Entry Fee',
              value:
                  '${tournament.feeCurrency} ${tournament.entryFee.toStringAsFixed(0)}',
              valueColor: AppColors.primaryGreen,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.lightGreen),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: valueColor,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.accentGold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.headlineSmall),
      ],
    );
  }
}

class _RegistrationPanel extends StatelessWidget {
  final Tournament tournament;

  const _RegistrationPanel({required this.tournament});

  @override
  Widget build(BuildContext context) {
    if (!tournament.registrationOpen) {
      return _StatusBanner(
        icon: Icons.lock_outline,
        message: AppStrings.registrationClosed,
        color: AppColors.error,
      );
    }
    if (tournament.isFull) {
      return _StatusBanner(
        icon: Icons.group_off_outlined,
        message: 'Tournament is full — join the waitlist',
        color: AppColors.warning,
      );
    }

    final spotsLeft =
        tournament.maxParticipants - (tournament.registrationCount ?? 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (spotsLeft <= 10)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: AppColors.warning, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Only $spotsLeft spots remaining!',
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ElevatedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  RegistrationFormScreen(tournament: tournament),
            ),
          ),
          icon: const Icon(Icons.how_to_reg),
          label: const Text(AppStrings.registerNow),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;

  const _StatusBanner({
    required this.icon,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
