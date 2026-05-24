import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'shared/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase — replace DefaultFirebaseOptions with the generated
  // file from `flutterfire configure` before building for production.
  await Firebase.initializeApp();

  // Initialize FCM + local notifications
  await NotificationService.instance.initialize();

  runApp(const CaribbeanGolfHubApp());
}
