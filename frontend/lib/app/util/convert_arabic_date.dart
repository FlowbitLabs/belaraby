String formatArabicDate(String? dateStr) {
  if (dateStr == null) return '';

  final date = DateTime.tryParse(dateStr);
  if (date == null) return '';

  final day = date.day;
  final month = _arabicMonthName(date.month);
  final year = date.year;

  return '${_toArabicNumerals(day)} $month ${_toArabicNumerals(year)}';
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

String _toArabicNumerals(int number) {
  const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return number
      .toString()
      .split('')
      .map((digit) => arabicDigits[int.parse(digit)])
      .join();
}
