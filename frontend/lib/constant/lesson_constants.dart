/// Arabic grade level filter labels shown in the home screen filter bar.
const List<String> levelsFilterList = [
  'الكل',
  'الأول ابتدائي',
  'الثاني ابتدائي',
  'الثالث ابتدائي',
  'الرابع ابتدائي',
];

/// Maps each Arabic filter label to its corresponding DB grade value.
/// A null value means "no filter" (show all).
const Map<String, String?> levelGradeFilters = {
  'الكل': null,
  'الأول ابتدائي': '1',
  'الثاني ابتدائي': '2',
  'الثالث ابتدائي': '3',
  'الرابع ابتدائي': '4',
};
