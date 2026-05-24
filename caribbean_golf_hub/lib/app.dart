import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'features/home/home_screen.dart';

class CaribbeanGolfHubApp extends StatelessWidget {
  const CaribbeanGolfHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const HomeScreen(),
    );
  }
}
