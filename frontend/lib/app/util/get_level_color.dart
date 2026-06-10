import 'dart:ui';
import 'package:flutter/material.dart';

Color getLevelColor(String level) {
  final l = level.toLowerCase();
  if (l.startsWith('a')) {
    return const Color(0xFFDFF5E3);
  } else if (l.startsWith('b')) {
    return const Color(0xFFD9F0FF);
  } else if (l.startsWith('c')) {
    return const Color(0xFFEFE3FF);
  } else {
    return const Color(0xFFE0E0E0); // default gray
  }
}

/// Background color of a selected level filter chip, keyed by the filter
/// translation key (see `levelFilterKeys` in `constant/lesson_constants.dart`).
Color getFilterColor(String filterKey) {
  if (filterKey == 'level_filter_grade_1') {
    return const Color(0xFFDFF5E3);
  } else if (filterKey == 'level_filter_grade_2' ||
      filterKey == 'level_filter_grade_3') {
    return const Color(0xFFD9F0FF);
  } else if (filterKey == 'level_filter_grade_4') {
    return const Color(0xFFEFE3FF);
  } else {
    return const Color.fromARGB(255, 255, 196, 59); // "all" chip
  }
}
