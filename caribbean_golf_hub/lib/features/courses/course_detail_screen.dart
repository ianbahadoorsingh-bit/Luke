import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../shared/models/course_model.dart';
import '../../shared/widgets/amenity_chip.dart';
import '../../shared/widgets/gold_badge.dart';

class CourseDetailScreen extends StatelessWidget {
  final GolfCourse course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _CourseHeroSliver(course: course),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LocationRow(location: course.location),
                  const SizedBox(height: 16),
                  _ContactActions(course: course),
                  const SizedBox(height: 20),
                  _Divider(label: 'About'),
                  const SizedBox(height: 12),
                  Text(
                    course.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  if (course.amenities.isNotEmpty) ...[
                    _Divider(label: 'Amenities'),
                    const SizedBox(height: 12),
                    AmenityChipList(amenities: course.amenities),
                    const SizedBox(height: 20),
                  ],
                  _Divider(label: 'Rates & Specials'),
                  const SizedBox(height: 12),
                  _RatesCard(rates: course.rates),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseHeroSliver extends StatelessWidget {
  final GolfCourse course;

  const _CourseHeroSliver({required this.course});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: AppColors.primaryGreen,
      iconTheme: const IconThemeData(color: AppColors.white),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          course.name,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            course.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: course.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: AppColors.surfaceGreen),
                    errorWidget: (_, __, ___) =>
                        Container(color: AppColors.surfaceGreen),
                  )
                : Container(
                    color: AppColors.mediumGreen,
                    child: const Icon(Icons.golf_course,
                        size: 80, color: AppColors.surfaceGreen),
                  ),
            // Gradient for text legibility
            const DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.heroGradient),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  final String location;

  const _LocationRow({required this.location});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.location_on, color: AppColors.lightGreen, size: 18),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            location,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.darkGray),
          ),
        ),
      ],
    );
  }
}

class _ContactActions extends StatelessWidget {
  final GolfCourse course;

  const _ContactActions({required this.course});

  Future<void> _launchPhone(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  Future<void> _launchWhatsApp(String number) async {
    final cleaned = number.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('https://wa.me/$cleaned');
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _launchMap(String? mapLink) async {
    if (mapLink == null) return;
    final uri = Uri.parse(mapLink);
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.phone,
            label: AppStrings.callCourse,
            color: AppColors.primaryGreen,
            onTap: () => _launchPhone(course.contactNumber),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            icon: Icons.chat,
            label: AppStrings.whatsapp,
            color: const Color(0xFF25D366),
            onTap: () => _launchWhatsApp(course.whatsappNumber),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            icon: Icons.directions,
            label: AppStrings.getDirections,
            color: AppColors.info,
            onTap: () => _launchMap(course.mapLink),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final String label;

  const _Divider({required this.label});

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

class _RatesCard extends StatelessWidget {
  final CourseRates rates;

  const _RatesCard({required this.rates});

  @override
  Widget build(BuildContext context) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Local rates
            Row(
              children: [
                const GoldBadge(label: 'LOCAL'),
                const SizedBox(width: 8),
                Text(
                  rates.currencyLocal,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.mediumGray),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _RateRow(
              label: AppStrings.weekday,
              amount: rates.local.weekday,
              currency: rates.currencyLocal,
            ),
            _RateRow(
              label: AppStrings.weekend,
              amount: rates.local.weekend,
              currency: rates.currencyLocal,
            ),
            if (rates.local.twilight != null)
              _RateRow(
                label: AppStrings.twilight,
                amount: rates.local.twilight,
                currency: rates.currencyLocal,
              ),
            const Divider(height: 24),
            // Tourist rates
            Row(
              children: [
                const GoldBadge(label: 'TOURIST'),
                const SizedBox(width: 8),
                Text(
                  rates.currencyTourist,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.mediumGray),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _RateRow(
              label: AppStrings.weekday,
              amount: rates.tourist.weekday,
              currency: rates.currencyTourist,
            ),
            _RateRow(
              label: AppStrings.weekend,
              amount: rates.tourist.weekend,
              currency: rates.currencyTourist,
            ),
            if (rates.tourist.twilight != null)
              _RateRow(
                label: AppStrings.twilight,
                amount: rates.tourist.twilight,
                currency: rates.currencyTourist,
              ),
            if (rates.notes != null && rates.notes!.isNotEmpty) ...[
              const Divider(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      size: 14, color: AppColors.mediumGray),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      rates.notes!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RateRow extends StatelessWidget {
  final String label;
  final double? amount;
  final String currency;

  const _RateRow(
      {required this.label, required this.amount, required this.currency});

  @override
  Widget build(BuildContext context) {
    if (amount == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            '$currency ${amount!.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
          ),
        ],
      ),
    );
  }
}
