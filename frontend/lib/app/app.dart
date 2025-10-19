import 'package:belaraby/app/router.dart';
import 'package:belaraby/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class BelArabyApp extends StatelessWidget {
  const BelArabyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BelAraby',
      localizationsDelegates: const [
        L10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: L10n.delegate.supportedLocales,
      locale: L10n.delegate.supportedLocales.first,
      routerConfig: router,
      theme: ThemeData(useMaterial3: true),
    );
  }
}
