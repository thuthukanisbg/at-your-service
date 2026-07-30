import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android)) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
  // Initialized here (not in AtYourServiceApp) so widget tests, which pump
  // the app widget directly, never depend on a live Firebase connection.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AtYourServiceApp());
}
