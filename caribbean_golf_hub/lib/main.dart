import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'shared/services/notification_service.dart';
import 'shared/services/data_store.dart';

/// Set to true once flutterfire configure has been run and
/// firebase_options.dart contains real credentials.
const bool kFirebaseConfigured = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataStore.instance.initialize();

  if (kFirebaseConfigured) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await NotificationService.instance.initialize();
  }

  runApp(CaribbeanGolfHubApp(useMockData: !kFirebaseConfigured));
}
