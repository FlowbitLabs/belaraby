// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ar locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ar';

  static String m0(level) => "البحث بالمستوى: ${level}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "app_title": MessageLookupByLibrary.simpleMessage("بالعربي"),
    "home_filter": m0,
    "home_free_stories": MessageLookupByLibrary.simpleMessage("قصص مجانية"),
    "home_hide_learnt": MessageLookupByLibrary.simpleMessage("إخفاء ما تعلمت"),
    "home_more_stories": MessageLookupByLibrary.simpleMessage("المزيد"),
    "home_title": MessageLookupByLibrary.simpleMessage("اكتشف بالعربي"),
    "lesson_tab_grammar": MessageLookupByLibrary.simpleMessage("نحو"),
    "lesson_tab_keywords": MessageLookupByLibrary.simpleMessage("كلمات"),
    "lesson_tab_quiz": MessageLookupByLibrary.simpleMessage("اختبار"),
    "lesson_tab_story": MessageLookupByLibrary.simpleMessage("قصة"),
    "library_favorites": MessageLookupByLibrary.simpleMessage("قصص مفضلة"),
    "library_learned_stories": MessageLookupByLibrary.simpleMessage(
      "قصص تعلمتها",
    ),
    "navbar_my_library": MessageLookupByLibrary.simpleMessage("مكتبتي"),
    "navbar_stories": MessageLookupByLibrary.simpleMessage("قصص"),
    "navbar_training": MessageLookupByLibrary.simpleMessage("تدريبات"),
  };
}
