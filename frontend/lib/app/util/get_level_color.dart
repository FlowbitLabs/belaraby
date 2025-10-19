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

Color getFilterColor(String filter) {
  if (filter == 'الأول ابتدائي') {
    return const Color(0xFFDFF5E3);
  } else if (filter == 'الثاني ابتدائي' || filter == 'الثالث ابتدائي') {
    return const Color(0xFFD9F0FF);
  } else if (filter == 'الرابع ابتدائي') {
    return const Color(0xFFEFE3FF);
  } else {
    return const Color.fromARGB(255, 255, 196, 59); // default gray
  }
}
