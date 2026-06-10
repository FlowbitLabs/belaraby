/// Formats [dateStr] (ISO `yyyy-mm-dd`) for the given [languageCode].
///
/// Arabic gets Arabic-Indic numerals and Arabic month names; every other
/// locale gets Western numerals and English month names.
String formatLessonDate(String? dateStr, String languageCode) {
  if (dateStr == null) return '';

  final date = DateTime.tryParse(dateStr);
  if (date == null) return '';

  if (languageCode == 'ar') {
    final day = _toArabicNumerals(date.day);
    final month = _arabicMonthName(date.month);
    final year = _toArabicNumerals(date.year);
    return '$day $month $year';
  }

  final month = _englishMonthName(date.month);
  return '${date.day} $month ${date.year}';
}

String _arabicMonthName(int month) {
  const months = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];
  return months[month - 1];
}

String _englishMonthName(int month) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return months[month - 1];
}

String _toArabicNumerals(int number) {
  const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return number
      .toString()
      .split('')
      .map((digit) => arabicDigits[int.parse(digit)])
      .join();
}
