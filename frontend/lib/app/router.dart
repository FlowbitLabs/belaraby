import 'package:belaraby/app/home/view/home_page.dart';
import 'package:belaraby/app/lesson/cubit/favorite_cubit.dart';
import 'package:belaraby/app/lesson/view/lesson_page.dart';
import 'package:belaraby/app/lesson/view/lesson_unlock_page.dart';
import 'package:belaraby/app/my_library/view/my_library_page.dart';
import 'package:belaraby/app/paywall/view/paywall_page.dart';
import 'package:belaraby/app/practice/view/practice_page.dart';
import 'package:belaraby/app/settings/view/settings_page.dart';
import 'package:belaraby/app/subscription/cubit/subscription_cubit.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/data/data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The main shell of the application handling top-level navigation.
///
/// Uses an [IndexedStack] to preserve the state of:
/// 1. Home (Stories/Lessons)
/// 2. My Library (Favorites/History)
///
/// This approach avoids rebuilding tabs when switching between them.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  static const List<Widget> _pages = [
    HomePage(),
    PracticePage(),
    MyLibraryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<FavoriteCubit, FavoriteState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage.isNotEmpty,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage.tr())),
        );
      },
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedIconTheme: const IconThemeData(
            size: 25,
            color: yellow120,
          ),
          unselectedIconTheme: const IconThemeData(
            size: 22,
            color: grey140,
          ),
          selectedItemColor: yellow120,
          unselectedItemColor: grey140,
          selectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.6,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 1.6,
          ),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.library_books),
              label: 'navbar_stories'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.style),
              label: 'navbar_practice'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.menu_book),
              label: 'navbar_my_library'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Navigates to the [LessonPage] for a specific [lesson].
///
/// Uses [MaterialPageRoute] for standard platform transitions.
/// The returned future completes when the lesson page is popped.
Future<void> navigateToLesson(BuildContext context, Lesson lesson) {
  return Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (context) => LessonPage(lesson)),
  );
}

/// Navigates to [lesson], routing through the paywall when it is locked.
///
/// Paid lessons require an active premium subscription; non-premium users
/// see the [PaywallPage] first and continue to the lesson after a
/// successful purchase. Because the story body stays masked server-side
/// until the RevenueCat webhook lands, a successful purchase continues to
/// the [LessonUnlockPage], which polls with bounded backoff before opening
/// the lesson. The same page handles a premium user holding a lesson whose
/// body is still masked (RevenueCat and the server can briefly disagree —
/// webhook delay/outage or expiry mismatch), instead of opening a blank
/// story. The returned future completes when the user returns to the
/// caller.
Future<void> navigateToLessonGated(
  BuildContext context,
  Lesson lesson,
) async {
  final isPremium = context.read<SubscriptionCubit>().state.isPremium;
  if (!lesson.isPaid || isPremium) {
    if (lesson.isBodyMasked) {
      // Client says premium but the server still masks the body: refetch
      // through the unlock page (poll + manual retry) rather than rendering
      // an empty story with no recovery path.
      return Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (context) => LessonUnlockPage(lesson),
        ),
      );
    }
    return navigateToLesson(context, lesson);
  }
  final purchased = await navigateToPaywall(context);
  if ((purchased ?? false) && context.mounted) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => LessonUnlockPage(lesson),
      ),
    );
  }
}

/// Opens the [PaywallPage].
///
/// Resolves to `true` when the user ends up with an active subscription.
/// On web — where store billing doesn't exist — a dialog explains that
/// subscriptions are only available in the mobile app instead.
Future<bool?> navigateToPaywall(BuildContext context) {
  if (kIsWeb) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.phone_iphone, color: yellow120, size: 40),
        title: Text('paywall_web_only_title'.tr()),
        content: Text(
          'paywall_web_only_message'.tr(),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('paywall_web_only_ok'.tr()),
          ),
        ],
      ),
    );
  }
  return Navigator.push<bool>(
    context,
    MaterialPageRoute<bool>(builder: (context) => const PaywallPage()),
  );
}

/// Opens the [SettingsPage].
Future<void> navigateToSettings(BuildContext context) {
  return Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (context) => const SettingsPage()),
  );
}
