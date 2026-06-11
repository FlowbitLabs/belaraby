import 'package:belaraby/constant/colors.dart';
import 'package:flutter/material.dart';

/// Background tint of a level badge (A* green, B* blue, C* purple), drawn
/// from the app palette so the badges stay consistent with the rest of
/// the UI.
Color getLevelColor(String level) {
  final l = level.toLowerCase();
  if (l.startsWith('a')) {
    return green50;
  } else if (l.startsWith('b')) {
    return blue30;
  } else if (l.startsWith('c')) {
    return purple30;
  } else {
    return grey110;
  }
}

/// Background color of a selected level filter chip, keyed by the filter
/// translation key (see `levelFilterKeys` in `constant/lesson_constants.dart`).
Color getFilterColor(String filterKey) {
  if (filterKey == 'level_filter_grade_1') {
    return green50;
  } else if (filterKey == 'level_filter_grade_2' ||
      filterKey == 'level_filter_grade_3') {
    return blue30;
  } else if (filterKey == 'level_filter_grade_4') {
    return purple30;
  } else {
    return yellow100; // "all" chip
  }
}
