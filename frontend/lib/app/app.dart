import 'package:belaraby/app/lesson/cubit/favorite_cubit.dart';
import 'package:belaraby/app/lesson/cubit/learned_cubit.dart';
import 'package:belaraby/app/router.dart';
import 'package:belaraby/app/subscription/cubit/subscription_cubit.dart';
import 'package:belaraby/app/widgets/web_frame.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/data/services/purchases_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Allows drag-scrolling with any pointer, not just touch — without this
/// the carousels and lists don't respond to mouse drags on web/desktop.
class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
  };
}

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

        // One palette everywhere: purple is the brand color, yellow the
        // accent (see constant/colors.dart for the semantic aliases).
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: purple140,
            primary: purple140,
            secondary: yellow120,
          ),
          scaffoldBackgroundColor: appBackground,
          fontFamily: 'Cairo',
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: yellow120,
          ),
          snackBarTheme: const SnackBarThemeData(
            backgroundColor: grey180,
            contentTextStyle: TextStyle(
              color: Colors.white,
              fontFamily: 'Cairo',
            ),
          ),
        ),
        scrollBehavior: const _AppScrollBehavior(),
        // On wide web viewports the app is centered in a phone-width frame
        // instead of stretching the mobile layout across the window.
        builder: kIsWeb
            ? (context, child) => WebFrame(child: child!)
            : null,
        home: const MainScreen(),
      ),
    );
  }
}
