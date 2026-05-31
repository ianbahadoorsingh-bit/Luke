import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../shared/models/tournament_model.dart';
import '../../shared/services/firestore_service.dart';
import '../../shared/widgets/caribbean_app_bar.dart';
import '../../shared/widgets/loading_shimmer.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/amenity_chip.dart';
import '../../shared/services/data_store.dart';
import 'tournament_detail_screen.dart';

class TournamentsScreen extends StatefulWidget {
  final bool useMockData;

  const TournamentsScreen({super.key, this.useMockData = false});

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  String? _selectedCountry;

  static const _countries = [
    ('All', null),
    ('Trinidad & Tobago', 'TT'),
    ('Barbados', 'BB'),
    ('Jamaica', 'JM'),
    ('Bahamas', 'BS'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CaribbeanAppBar(
        title: AppStrings.tournamentsTitle,
        showGoldAccent: true,
      ),
      body: Column(
        children: [
          _CountryFilter(
            selected: _selectedCountry,
            countries: _countries,
            onSelect: (c) => setState(() => _selectedCountry = c),
          ),
          Expanded(
            child: widget.useMockData
                ? _MockTournamentList(country: _selectedCountry)
                : StreamBuilder<List<Tournament>>(
                    stream: FirestoreService.instance
                        .watchUpcomingTournaments(country: _selectedCountry),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const ShimmerList(count: 3, cardHeight: 200);
                      }
                      if (snap.hasError) {
                        return const EmptyState(
                          emoji: '⚠️',
                          title: 'Unable to load tournaments',
                          subtitle: 'Please check your connection',
                        );
                      }
                      final tournaments = snap.data ?? [];
                      if (tournaments.isEmpty) {
                        return const EmptyState(
                          emoji: '🏆',
                          title: 'No upcoming tournaments',
                          subtitle: 'Check back soon for new events',
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: tournaments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, i) =>
                            TournamentCard(tournament: tournaments[i]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CountryFilter extends StatelessWidget {
  final String? selected;
  final List<(String, String?)> countries;
  final ValueChanged<String?> onSelect;

  const _CountryFilter({
    required this.selected,
    required this.countries,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryGreen,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: countries.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final (label, code) = countries[i];
            final isSelected = selected == code;
            return GestureDetector(
              onTap: () => onSelect(code),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentGold
                      : AppColors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? AppColors.charcoal : AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class TournamentCard extends StatelessWidget {
  final Tournament tournament;

  const TournamentCard({super.key, required this.tournament});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('EEE d MMM yyyy');
    final statusColor = tournament.isAcceptingRegistrations
        ? AppColors.success
        : AppColors.error;
    final statusLabel = tournament.isFull
        ? 'Full'
        : tournament.registrationOpen
            ? 'Open'
            : 'Closed';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                TournamentDetailScreen(tournament: tournament)),
      ),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header image
            Stack(
              children: [
                SizedBox(
                  height: 130,
                  width: double.infinity,
                  child: tournament.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: tournament.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: AppColors.surfaceGreen),
                          errorWidget: (_, __, ___) =>
                              Container(color: AppColors.mediumGreen),
                        )
                      : Container(
                          color: AppColors.mediumGreen,
                          child: const Icon(Icons.emoji_events,
                              size: 50, color: Colors.white24),
                        ),
                ),
                // Registration status badge
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusLabel,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tournament.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    text: df.format(tournament.startDate),
                  ),
                  const SizedBox(height: 4),
                  _InfoRow(
                    icon: Icons.golf_course_outlined,
                    text: tournament.courseName,
                  ),
                  const SizedBox(height: 4),
                  _InfoRow(
                    icon: Icons.format_list_bulleted,
                    text: tournament.format,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (tournament.tags.isNotEmpty)
                        Expanded(
                          child: AmenityChipList(
                            amenities: tournament.tags.take(3).toList(),
                          ),
                        ),
                      Text(
                        '${tournament.feeCurrency} ${tournament.entryFee.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.primaryGreen,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.mediumGray),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.darkGray,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _MockTournamentList extends StatelessWidget {
  final String? country;
  const _MockTournamentList({this.country});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Tournament>>(
      initialData: country == null
          ? DataStore.instance.tournaments
          : DataStore.instance.tournaments
              .where((t) => t.country == country)
              .toList(),
      stream: DataStore.instance.watchTournaments(country: country),
      builder: (context, snap) {
        final list = snap.data ?? [];
        if (list.isEmpty) {
          return const EmptyState(
              emoji: '🏆', title: 'No upcoming tournaments');
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (_, i) => TournamentCard(tournament: list[i]),
        );
      },
    );
  }
}
