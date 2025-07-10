import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:orion/ui/welcome_screen.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:isar/isar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (!kIsWeb) {
    await Isar.initializeIsarCore(download: true);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return shadcn.ShadcnApp(
      title: 'Orion',
      theme: shadcn.ThemeData(
        colorScheme: shadcn.ColorSchemes.darkZinc(),
        radius: 0.5,
      ),
      home: WelcomeScreen(),
    );
  }
}
