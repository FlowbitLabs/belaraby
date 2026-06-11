import 'package:belaraby/constant/colors.dart';
import 'package:flutter/material.dart';

// Base styles
const _baseCairo = TextStyle(fontFamily: 'Cairo', color: grey170);
const _baseAmiri = TextStyle(fontFamily: 'Amiri', color: grey170);

extension BelarabyTextStyles on TextTheme {
  TextStyle get displayLargeMed => _baseCairo.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0,
  );
  TextStyle get displaySmallMed => _baseCairo.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 35 / 24,
    letterSpacing: 0,
  );
  TextStyle get h1Regular => _baseCairo.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0.15,
  );
  TextStyle get title1 => _baseAmiri.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0,
  );
  TextStyle get body1Regular => _baseAmiri.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
  );
  TextStyle get label => _baseCairo.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 21 / 10,
    letterSpacing: 0.5,
  );
  TextStyle get caption => _baseAmiri.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0,
  );
}

// Developer-friendly API that just delegates to the extension.
// Usage: BTextStyles.of(context).body1
class BTextStyles {
  BTextStyles.of(BuildContext context) : _theme = Theme.of(context).textTheme;

  final TextTheme _theme;

  TextStyle get displayLarge => _theme.displayLargeMed;
  TextStyle get displaySmall => _theme.displaySmallMed;
  TextStyle get h1 => _theme.h1Regular;
  TextStyle get title1 => _theme.title1;
  TextStyle get body1 => _theme.body1Regular;
  TextStyle get label => _theme.label;
  TextStyle get caption => _theme.caption;
}
