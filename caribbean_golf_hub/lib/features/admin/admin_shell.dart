import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'tabs/admin_courses_tab.dart';
import 'tabs/admin_tournaments_tab.dart';
import 'tabs/admin_specials_tab.dart';
import 'tabs/admin_rules_tab.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryGreen,
          leading: IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            tooltip: 'Exit Admin',
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Admin Dashboard',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700)),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            indicatorColor: AppColors.accentGold,
            tabs: [
              Tab(icon: Icon(Icons.golf_course), text: 'Courses'),
              Tab(icon: Icon(Icons.emoji_events), text: 'Tournaments'),
              Tab(icon: Icon(Icons.local_offer), text: 'Specials'),
              Tab(icon: Icon(Icons.menu_book), text: 'Rules'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AdminCoursesTab(),
            AdminTournamentsTab(),
            AdminSpecialsTab(),
            AdminRulesTab(),
          ],
        ),
      ),
    );
  }
}
