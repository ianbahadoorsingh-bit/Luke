import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../shared/models/course_model.dart';
import '../../shared/services/firestore_service.dart';
import '../../shared/widgets/caribbean_app_bar.dart';
import '../../shared/widgets/amenity_chip.dart';
import '../../shared/widgets/loading_shimmer.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/services/data_store.dart';
import 'course_detail_screen.dart';

class CoursesListScreen extends StatefulWidget {
  final bool useMockData;

  const CoursesListScreen({super.key, this.useMockData = false});

  @override
  State<CoursesListScreen> createState() => _CoursesListScreenState();
}

class _CoursesListScreenState extends State<CoursesListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CaribbeanAppBar(
        title: AppStrings.coursesTitle,
        subtitle: AppStrings.coursesSubtitle,
        showGoldAccent: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_outlined,
                color: Colors.white),
            tooltip: 'Admin',
            onPressed: () => Navigator.pushNamed(context, '/admin'),
          ),
        ],
      ),
      body: Column(
        children: [
          _SearchBar(
            controller: _searchController,
            onChanged: (q) => setState(() => _searchQuery = q.toLowerCase()),
          ),
          Expanded(
            child: widget.useMockData
              ? _MockCourseList(searchQuery: _searchQuery)
              : StreamBuilder<List<GolfCourse>>(
                  stream: FirestoreService.instance.watchCourses(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const ShimmerList(count: 4, cardHeight: 160);
                    }
                    if (snap.hasError) {
                      return EmptyState(
                        emoji: '⚠️',
                        title: 'Unable to load courses',
                        subtitle: 'Please check your connection',
                      );
                    }
                    final courses = (snap.data ?? [])
                        .where((c) =>
                            _searchQuery.isEmpty ||
                            c.name.toLowerCase().contains(_searchQuery) ||
                            c.location.toLowerCase().contains(_searchQuery))
                        .toList();
                    if (courses.isEmpty) {
                      return EmptyState(
                        emoji: '⛳',
                        title: 'No courses found',
                        subtitle: 'Try a different search term',
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: courses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _CourseCard(course: courses[i]),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryGreen,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: AppColors.white),
        decoration: InputDecoration(
          hintText: 'Search courses...',
          hintStyle: TextStyle(color: AppColors.white.withOpacity(0.6)),
          prefixIcon: Icon(Icons.search, color: AppColors.white.withOpacity(0.8)),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon:
                      Icon(Icons.clear, color: AppColors.white.withOpacity(0.8)),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.mediumGreen,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final GolfCourse course;

  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CourseDetailScreen(course: course)),
      ),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image hero
            _CourseImage(imageUrl: course.imageUrl, name: course.name),
            // Info section
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: AppColors.mediumGray),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          course.location,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (course.amenities.isNotEmpty)
                    AmenityChipList(
                      amenities: course.amenities.take(4).toList(),
                    ),
                  const SizedBox(height: 10),
                  _RatePreview(rates: course.rates),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseImage extends StatelessWidget {
  final String? imageUrl;
  final String name;

  const _CourseImage({this.imageUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 140,
          width: double.infinity,
          child: imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppColors.surfaceGreen),
                  errorWidget: (_, __, ___) => _Placeholder(name: name),
                )
              : _Placeholder(name: name),
        ),
        // Gradient overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, AppColors.black.withOpacity(0.3)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String name;

  const _Placeholder({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceGreen,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.golf_course, size: 40, color: AppColors.lightGreen),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(color: AppColors.mediumGreen, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RatePreview extends StatelessWidget {
  final CourseRates rates;

  const _RatePreview({required this.rates});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (rates.local.weekday != null)
          _RatePill(
            label: 'Local',
            amount: rates.local.weekday!,
            currency: rates.currencyLocal,
          ),
        const SizedBox(width: 8),
        if (rates.tourist.weekday != null)
          _RatePill(
            label: 'Tourist',
            amount: rates.tourist.weekday!,
            currency: rates.currencyTourist,
            gold: true,
          ),
      ],
    );
  }
}

class _RatePill extends StatelessWidget {
  final String label;
  final double amount;
  final String currency;
  final bool gold;

  const _RatePill({
    required this.label,
    required this.amount,
    required this.currency,
    this.gold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: gold
            ? AppColors.paleGold
            : AppColors.surfaceGreen,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label  $currency ${amount.toStringAsFixed(0)}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: gold ? AppColors.charcoal : AppColors.primaryGreen,
        ),
      ),
    );
  }
}

class _MockCourseList extends StatelessWidget {
  final String searchQuery;
  const _MockCourseList({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GolfCourse>>(
      initialData: DataStore.instance.courses,
      stream: DataStore.instance.watchCourses(),
      builder: (context, snap) {
        final courses = (snap.data ?? [])
            .where((c) =>
                searchQuery.isEmpty ||
                c.name.toLowerCase().contains(searchQuery) ||
                c.location.toLowerCase().contains(searchQuery))
            .toList();
        if (courses.isEmpty) {
          return const EmptyState(emoji: '⛳', title: 'No courses found');
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: courses.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) => _CourseCard(course: courses[i]),
        );
      },
    );
  }
}
