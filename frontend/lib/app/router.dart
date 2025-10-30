import 'package:belaraby/app/authentication/view/welcome_page.dart';
import 'package:belaraby/app/home/view/home_page.dart';
import 'package:belaraby/app/lesson/view/lesson_page.dart';
import 'package:belaraby/app/my_library/view/my_library_page.dart';
import 'package:belaraby/data/data.dart';
import 'package:belaraby/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          ScaffoldWithBottomNavigation(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/', builder: (context, state) => const HomePage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/training',
              builder: (context, state) => const SizedBox(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/library',
              builder: (context, state) => const MyLibraryPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/authentication',
              builder: (context, state) => const WelcomePage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/lesson',
      name: 'lesson',
      builder: (BuildContext context, GoRouterState state) {
        final lesson = state.extra;
        if (lesson is! Lesson) {
          // You could navigate to an error page or return a fallback widget
          return const Scaffold(
            body: Center(child: Text('Invalid lesson data')),
          );
        }
        return LessonPage(lesson);
      },
    ),
  ],
);

class ScaffoldWithBottomNavigation extends StatelessWidget {
  const ScaffoldWithBottomNavigation({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  List<BottomNavigationBarItem> _allNavigationItems(BuildContext context) => [
    BottomNavigationBarItem(
      icon: const Icon(Icons.library_books),
      label: L10n.of(context).navbar_stories,
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.line_weight),
      label: L10n.of(context).navbar_training,
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.menu_book),
      label: L10n.of(context).navbar_my_library,
    ),
    //This should be removed later
    BottomNavigationBarItem(
      icon: const Icon(Icons.login),
      label: L10n.of(context).navbar_my_welcome_page,
    ),
  ];

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavigationBar(
        pageIndex: navigationShell.currentIndex,
        onItemSelected: _goBranch,
        items: _allNavigationItems(context),
      ),
    );
  }
}

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    required this.pageIndex,
    required this.items,
    required this.onItemSelected,
    super.key,
  });

  final int pageIndex;
  final List<BottomNavigationBarItem> items;
  final void Function(int) onItemSelected;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedIconTheme: IconThemeData(size: 25, color: Colors.yellow[800]),
      unselectedIconTheme: const IconThemeData(size: 22, color: Colors.grey),
      selectedItemColor: Colors.yellow[800],
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.6,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.6,
      ),
      currentIndex: pageIndex,
      onTap: onItemSelected,
      items: items,
    );
  }
}
