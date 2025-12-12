import 'package:belaraby/app/app.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

/// Entry point of the application.
/// 
/// Initializes critical services before running the app:
/// 1. [WidgetsFlutterBinding] for engine communication.
/// 2. [EasyLocalization] for i18n support.
/// 3. [Supabase] for backend services.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize easy_localization
  await EasyLocalization.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://hmgwrovvqeezkyfiqula.supabase.co',
    anonKey: 'sb_publishable_CCl-SQTxVV2Soi0cYDSpkg_nSQHlhuw',
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      child: const BelArabyApp(),
    ),
  );
}
