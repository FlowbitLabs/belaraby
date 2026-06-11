import 'package:belaraby/constant/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Pill-style tab bar switching between the story, quiz, keywords and
/// grammar tabs of a lesson.
class LessonTabBar extends StatelessWidget {
  const LessonTabBar({required this.controller, super.key});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    // Cairo with evenly distributed leading keeps the label optically
    // centered inside the pill — Arabic fonts reserve far more ascent than
    // descent, which otherwise pushes the glyphs off-center.
    const labelStyle = TextStyle(
      fontFamily: 'Cairo',
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 1.4,
      leadingDistribution: TextLeadingDistribution.even,
      color: grey0,
    );
    return TabBar(
      controller: controller,
      labelColor: grey0,
      labelPadding: EdgeInsets.zero,
      labelStyle: labelStyle,
      unselectedLabelColor: grey140,
      unselectedLabelStyle: labelStyle,
      indicator: BoxDecoration(
        color: yellow120,
        borderRadius: BorderRadius.circular(100),
      ),
      indicatorSize: TabBarIndicatorSize.label,
      indicatorWeight: 1,
      indicatorPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
      indicatorAnimation: TabIndicatorAnimation.linear,
      splashFactory: NoSplash.splashFactory,
      dividerColor: grey110,
      dividerHeight: 0.5,
      tabs: [
        _LessonTab(label: 'lesson_tab_story'.tr()),
        _LessonTab(label: 'lesson_tab_quiz'.tr()),
        _LessonTab(label: 'lesson_tab_keywords'.tr()),
        _LessonTab(label: 'lesson_tab_grammar'.tr()),
      ],
    );
  }
}

class _LessonTab extends StatelessWidget {
  const _LessonTab({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Tab(
        height: 46,
        child: Center(child: Text(label, textAlign: TextAlign.center)),
      ),
    );
  }
}
