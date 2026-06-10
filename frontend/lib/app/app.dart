import 'package:belaraby/app/lesson/cubit/favorite_cubit.dart';
import 'package:belaraby/app/lesson/cubit/learned_cubit.dart';
import 'package:belaraby/app/router.dart';
import 'package:belaraby/app/subscription/cubit/subscription_cubit.dart';
import 'package:belaraby/data/services/purchases_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The root widget of the application.
///
/// Configures [MaterialApp] with:
/// - Localization delegates from [EasyLocalization].
/// - Global theme settings.
/// - Global cubits ([SubscriptionCubit], [FavoriteCubit], [LearnedCubit])
///   above the router.
/// - [MainScreen] as the home route.
class BelArabyApp extends StatelessWidget {
  const BelArabyApp({super.key, this.purchasesService});

  /// The configured billing service; a no-op stub is used when omitted.
  final PurchasesService? purchasesService;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SubscriptionCubit(
            purchasesService: purchasesService ?? PurchasesService(),
          )..load(),
        ),
        BlocProvider(create: (_) => FavoriteCubit()..loadFavorites()),
        BlocProvider(create: (_) => LearnedCubit()..loadLearned()),
      ],
      child: MaterialApp(
        title: 'BelAraby',

        // Easy localization setup
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,

        theme: ThemeData(useMaterial3: true),
        home: const MainScreen(),
      ),
    );
  }
}
