// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class L10n {
  L10n();

  static L10n? _current;

  static L10n get current {
    assert(
      _current != null,
      'No instance of L10n was loaded. Try to initialize the L10n delegate before accessing L10n.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<L10n> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = L10n();
      L10n._current = instance;

      return instance;
    });
  }

  static L10n of(BuildContext context) {
    final instance = L10n.maybeOf(context);
    assert(
      instance != null,
      'No instance of L10n present in the widget tree. Did you add L10n.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static L10n? maybeOf(BuildContext context) {
    return Localizations.of<L10n>(context, L10n);
  }

  /// `بالعربي`
  String get app_title {
    return Intl.message(
      'بالعربي',
      name: 'app_title',
      desc: 'Title for the app',
      args: [],
    );
  }

  /// `اكتشف بالعربي`
  String get home_title {
    return Intl.message(
      'اكتشف بالعربي',
      name: 'home_title',
      desc: 'Title for the home screen',
      args: [],
    );
  }

  /// `قصص مجانية`
  String get home_free_stories {
    return Intl.message(
      'قصص مجانية',
      name: 'home_free_stories',
      desc: 'Label for free stories title section',
      args: [],
    );
  }

  /// `المزيد`
  String get home_more_stories {
    return Intl.message(
      'المزيد',
      name: 'home_more_stories',
      desc: 'Label for the more stories button on the home screen',
      args: [],
    );
  }

  /// `إخفاء ما تعلمت`
  String get home_hide_learnt {
    return Intl.message(
      'إخفاء ما تعلمت',
      name: 'home_hide_learnt',
      desc: 'Label for the stories section in the navbar',
      args: [],
    );
  }

  /// `البحث بالمستوى: {level}`
  String home_filter(Object level) {
    return Intl.message(
      'البحث بالمستوى: $level',
      name: 'home_filter',
      desc: 'Label for the more stories button on the home screen',
      args: [level],
    );
  }

  /// `قصص`
  String get navbar_stories {
    return Intl.message(
      'قصص',
      name: 'navbar_stories',
      desc: 'Label for the stories section in the navbar',
      args: [],
    );
  }

  /// `تدريبات`
  String get navbar_training {
    return Intl.message(
      'تدريبات',
      name: 'navbar_training',
      desc: 'Label for the training section in the navbar',
      args: [],
    );
  }

  /// `مكتبتي`
  String get navbar_my_library {
    return Intl.message(
      'مكتبتي',
      name: 'navbar_my_library',
      desc: 'Label for the My Library section in the navbar',
      args: [],
    );
  }

  /// `قصص مفضلة`
  String get library_favorites {
    return Intl.message(
      'قصص مفضلة',
      name: 'library_favorites',
      desc: 'Label for the favorites section in the library',
      args: [],
    );
  }

  /// `قصص تعلمتها`
  String get library_learned_stories {
    return Intl.message(
      'قصص تعلمتها',
      name: 'library_learned_stories',
      desc: 'Label for the learned stories section in the library',
      args: [],
    );
  }

  /// `قصة`
  String get lesson_tab_story {
    return Intl.message(
      'قصة',
      name: 'lesson_tab_story',
      desc: 'Label for the story tab in the lesson view',
      args: [],
    );
  }

  /// `اختبار`
  String get lesson_tab_quiz {
    return Intl.message(
      'اختبار',
      name: 'lesson_tab_quiz',
      desc: 'Label for the quiz tab in the lesson view',
      args: [],
    );
  }

  /// `كلمات`
  String get lesson_tab_keywords {
    return Intl.message(
      'كلمات',
      name: 'lesson_tab_keywords',
      desc: 'Label for the keywords tab in the lesson view',
      args: [],
    );
  }

  /// `نحو`
  String get lesson_tab_grammar {
    return Intl.message(
      'نحو',
      name: 'lesson_tab_grammar',
      desc: 'Label for the grammar tab in the lesson view',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<L10n> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[Locale.fromSubtags(languageCode: 'ar')];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<L10n> load(Locale locale) => L10n.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
