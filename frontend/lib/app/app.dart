import 'package:belaraby/app/router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// The prompt root widget of the application.
///
/// Configures [MaterialApp] with:
/// - Localization delegates from [EasyLocalization].
/// - Global theme settings.
/// - [MainScreen] as the home route.
class BelArabyApp extends StatelessWidget {
  const BelArabyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BelAraby',
      
      // Easy localization setup
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      
      theme: ThemeData(useMaterial3: true),
      home: const MainScreen(),
    );
  }
}
