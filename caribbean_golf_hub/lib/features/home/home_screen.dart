import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../courses/courses_list_screen.dart';
import '../tournaments/tournaments_screen.dart';
import '../specials/specials_screen.dart';
import '../rules/rules_screen.dart';
import '../scoring/scoring_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool useMockData;

  const HomeScreen({super.key, this.useMockData = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  List<Widget> get _tabs => [
    CoursesListScreen(useMockData: widget.useMockData),
    TournamentsScreen(useMockData: widget.useMockData),
    SpecialsScreen(useMockData: widget.useMockData),
    const RulesScreen(),
    const ScoringScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.golf_course_outlined),
            activeIcon: Icon(Icons.golf_course),
            label: AppStrings.navCourses,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            activeIcon: Icon(Icons.emoji_events),
            label: AppStrings.navTournaments,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer_outlined),
            activeIcon: Icon(Icons.local_offer),
            label: AppStrings.navSpecials,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: AppStrings.navRules,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_score_outlined),
            activeIcon: Icon(Icons.sports_score),
            label: 'Scoring',
          ),
        ],
      ),
    );
  }
}

// ── App splash / hero header shown on first tab ─────────────────────────────

class AppHeroHeader extends StatelessWidget {
  const AppHeroHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.greenGradient,
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sports_golf,
                  color: AppColors.accentGold, size: 28),
              const SizedBox(width: 10),
              Text(
                AppStrings.appName,
                style:
                    Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                        ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.tagline,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.white.withOpacity(0.75),
                ),
          ),
        ],
      ),
    );
  }
}
