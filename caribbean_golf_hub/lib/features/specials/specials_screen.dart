import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../shared/models/special_model.dart';
import '../../shared/services/firestore_service.dart';
import '../../shared/widgets/caribbean_app_bar.dart';
import '../../shared/widgets/loading_shimmer.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/gold_badge.dart';
import '../../shared/widgets/amenity_chip.dart';
import '../../shared/services/mock_data.dart';

class SpecialsScreen extends StatelessWidget {
  final bool useMockData;

  const SpecialsScreen({super.key, this.useMockData = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CaribbeanAppBar(
        title: AppStrings.specialsTitle,
        subtitle: AppStrings.specialsSubtitle,
        showGoldAccent: true,
      ),
      body: useMockData
          ? ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: MockData.specials.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (_, i) => _SpecialCard(special: MockData.specials[i]),
            )
          : StreamBuilder<List<GolfSpecial>>(
              stream: FirestoreService.instance.watchActiveSpecials(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const ShimmerList(count: 4, cardHeight: 200);
                }
                if (snap.hasError) {
                  return const EmptyState(
                    emoji: '⚠️',
                    title: 'Unable to load specials',
                    subtitle: 'Please check your connection',
                  );
                }
                final specials = snap.data ?? [];
                if (specials.isEmpty) {
                  return const EmptyState(
                    emoji: '🏌️',
                    title: 'No active specials',
                    subtitle: 'Enable notifications to be the first to know!',
                  );
                }
                return RefreshIndicator(
                  color: AppColors.primaryGreen,
                  onRefresh: () async {},
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: specials.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, i) =>
                        _SpecialCard(special: specials[i]),
                  ),
                );
              },
            ),
    );
  }
}

class _SpecialCard extends StatelessWidget {
  final GolfSpecial special;

  const _SpecialCard({required this.special});

  @override
  Widget build(BuildContext context) {
    final dfValid = DateFormat('d MMM yyyy');
    final remaining = special.timeRemaining;
    final urgentDays = remaining.inDays <= 3;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image + overlay badges
          Stack(
            children: [
              SizedBox(
                height: 160,
                width: double.infinity,
                child: special.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: special.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: AppColors.surfaceGreen),
                        errorWidget: (_, __, ___) =>
                            Container(color: AppColors.mediumGreen),
                      )
                    : Container(
                        color: AppColors.mediumGreen,
                        child: const Icon(Icons.local_offer,
                            size: 50, color: Colors.white24),
                      ),
              ),
              // Gradient
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: AppColors.heroGradient),
                ),
              ),
              // Course name
              Positioned(
                bottom: 10,
                left: 12,
                right: 12,
                child: Text(
                  special.courseName,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                  ),
                ),
              ),
              // Savings badge
              if (special.savingsPercent != null)
                Positioned(
                  top: 10,
                  right: 10,
                  child: SavingsBadge(percent: special.savingsPercent!),
                ),
            ],
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  special.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  special.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Price row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${special.currency} ${special.price.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: AppColors.primaryGreen,
                          ),
                    ),
                    if (special.originalPrice != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '${special.currency} ${special.originalPrice!.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.mediumGray,
                            ),
                      ),
                    ],
                    const Spacer(),
                    const GoldBadge(label: 'SPECIAL'),
                  ],
                ),
                const SizedBox(height: 10),
                // Validity + urgency
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: urgentDays ? AppColors.error : AppColors.mediumGray,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      urgentDays
                          ? 'Expires in ${remaining.inDays}d ${remaining.inHours % 24}h!'
                          : 'Valid until ${dfValid.format(special.validTo)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: urgentDays
                            ? AppColors.error
                            : AppColors.mediumGray,
                      ),
                    ),
                  ],
                ),
                if (special.tags.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  AmenityChipList(amenities: special.tags),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
