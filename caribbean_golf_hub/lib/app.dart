import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'features/home/home_screen.dart';
import 'features/admin/admin_gate.dart';

class CaribbeanGolfHubApp extends StatelessWidget {
  final bool useMockData;

  const CaribbeanGolfHubApp({super.key, this.useMockData = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: HomeScreen(useMockData: useMockData),
      routes: {
        '/admin': (_) => const AdminGate(),
      },
    );
  }
}
