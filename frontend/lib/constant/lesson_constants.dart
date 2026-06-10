/// Translation keys for the grade level filter chips on the home screen.
///
/// The chips display the localized label (`key.tr()`) while
/// [levelFilterGrades] maps each key to the raw DB `grade` value, so the
/// lesson filtering keeps matching the database regardless of locale.
const List<String> levelFilterKeys = [
  'level_filter_all',
  'level_filter_grade_1',
  'level_filter_grade_2',
  'level_filter_grade_3',
  'level_filter_grade_4',
];

/// Maps each filter translation key to its corresponding DB grade value.
/// A null value means "no filter" (show all).
const Map<String, String?> levelFilterGrades = {
  'level_filter_all': null,
  'level_filter_grade_1': '1',
  'level_filter_grade_2': '2',
  'level_filter_grade_3': '3',
  'level_filter_grade_4': '4',
};
