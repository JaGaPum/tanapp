import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Env.validate();
  if (!kIsWeb) {
    // Sin firebase_options.dart: en Android, google-services.json (procesado por el plugin de
    // Gradle) ya aporta toda la configuración que necesita, no hace falta pasar `options:`. En
    // web no hay app de Firebase configurada (el push, de momento, es solo Android) y
    // Firebase.initializeApp() fallaría sin ese config propio, así que aquí se salta.
    await Firebase.initializeApp();
  }
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseAnonKey,
  );
  runApp(const ProviderScope(child: TanApp()));
}
