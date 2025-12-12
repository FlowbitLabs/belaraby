import 'package:belaraby/app/home/view/home_page.dart';
import 'package:belaraby/app/lesson/view/lesson_page.dart';
import 'package:belaraby/app/my_library/view/my_library_page.dart';
import 'package:belaraby/data/data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// The main shell of the application handling top-level navigation.
/// 
/// Uses an [IndexedStack] to preserve the state of:
/// 1. Home (Stories/Lessons)
/// 2. Training (Placeholder)
/// 3. My Library (Favorites/History)
///
/// This approach avoids rebuilding tabs when switching between them.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    Center(child: Text('Training - Coming Soon')),
    MyLibraryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
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
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.library_books),
            label: 'navbar_stories'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.line_weight),
            label: 'navbar_training'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.menu_book),
            label: 'navbar_my_library'.tr(),
          ),
        ],
      ),
    );
  }
}

/// Navigates to the [LessonPage] for a specific [lesson].
/// 
/// Uses [MaterialPageRoute] for standard platform transitions.
void navigateToLesson(BuildContext context, Lesson lesson) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => LessonPage(lesson),
    ),
  );
}
