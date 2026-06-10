import 'package:belaraby/app/util/convert_arabic_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatLessonDate', () {
    test('uses Arabic-Indic numerals and Arabic months for ar', () {
      expect(formatLessonDate('2024-02-10', 'ar'), '١٠ فبراير ٢٠٢٤');
    });

    test('uses Western numerals and English months otherwise', () {
      expect(formatLessonDate('2024-02-10', 'en'), '10 February 2024');
    });

    test('returns an empty string for null or invalid input', () {
      expect(formatLessonDate(null, 'ar'), '');
      expect(formatLessonDate('not-a-date', 'en'), '');
    });
  });
}
