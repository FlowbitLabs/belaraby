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
  TextStyle get displayMediumReg => _baseCairo.copyWith(
    fontSize: 26,
    fontWeight: FontWeight.w400,
    height: 36 / 26,
    letterSpacing: 0,
  );
  TextStyle get displaySmallMed => _baseCairo.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 35 / 24,
    letterSpacing: 0,
  );
  TextStyle get h1Semibold => _baseCairo.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.15,
  );
  TextStyle get h1Medium => _baseCairo.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.15,
  );
  TextStyle get h1Regular => _baseCairo.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0.15,
  );
  TextStyle get h2Medium => _baseCairo.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.43,
    letterSpacing: 0.17,
  );
  TextStyle get h3Semibold => _baseCairo.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.15,
  );
  TextStyle get h3Medium => _baseCairo.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.15,
  );
  TextStyle get h3Regular => _baseCairo.copyWith(
    fontSize: 16,
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
  TextStyle get title2Bold => _baseCairo.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 0.15,
  );
  TextStyle get title2Semibold => _baseCairo.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.15,
  );
  TextStyle get title2Medium => _baseCairo.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.15,
  );
  TextStyle get title2Regular => _baseCairo.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0.15,
  );
  TextStyle get title3Medium => _baseCairo.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: 0.15,
  );
  TextStyle get title3Regular => _baseCairo.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    letterSpacing: 0.15,
  );
  TextStyle get body1Semibold => _baseAmiri.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0,
  );
  TextStyle get body1Medium => _baseAmiri.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0,
  );
  TextStyle get body1Regular => _baseAmiri.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
  );
  TextStyle get body2Medium => _baseAmiri.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: 0,
  );
  TextStyle get body2Regular => _baseAmiri.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
    letterSpacing: 0,
  );
  TextStyle get body3Semibold => _baseAmiri.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.45,
    letterSpacing: 0,
  );
  TextStyle get body3Medium => _baseAmiri.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: 0,
  );
  TextStyle get body3Regular => _baseAmiri.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.45,
    letterSpacing: 0,
  );
  TextStyle get buttonLarge => _baseCairo.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.15,
  );
  TextStyle get buttonMedium => _baseAmiri.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0,
  );
  TextStyle get buttonSmall => _baseAmiri.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0,
  );
  TextStyle get inputValue => _baseAmiri.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0,
  );
  TextStyle get inputValueSmall => _baseAmiri.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0,
  );
  TextStyle get inputLabel => _baseCairo.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0.15,
  );
  TextStyle get inputHelper => _baseAmiri.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.2,
    letterSpacing: 0,
  );
  TextStyle get label => _baseCairo.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 21 / 10,
    letterSpacing: 0.5,
  );
  TextStyle get subtitle => _baseAmiri.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0,
  );
  TextStyle get caption => _baseAmiri.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0,
  );
}

// Developer-friendly API that just delegates to extension
// Usage: BTextStyles.of(context).displaySmall
class BTextStyles {
  BTextStyles.of(BuildContext context) : _theme = Theme.of(context).textTheme;

  final TextTheme _theme;

  TextStyle get displayLarge => _theme.displayLargeMed;
  TextStyle get displayMedium => _theme.displayMediumReg;
  TextStyle get displaySmall => _theme.displaySmallMed;

  TextStyle get h1Semibold => _theme.h1Semibold;
  TextStyle get h1Medium => _theme.h1Medium;
  TextStyle get h1 => _theme.h1Regular;
  TextStyle get h2 => _theme.h2Medium;
  TextStyle get h3Semibold => _theme.h3Semibold;
  TextStyle get h3Medium => _theme.h3Medium;
  TextStyle get h3 => _theme.h3Regular;

  TextStyle get title1 => _theme.title1;
  TextStyle get title2Bold => _theme.title2Bold;
  TextStyle get title2Semibold => _theme.title2Semibold;
  TextStyle get title2Medium => _theme.title2Medium;
  TextStyle get title2 => _theme.title2Regular;
  TextStyle get title3Medium => _theme.title3Medium;
  TextStyle get title3 => _theme.title3Regular;

  TextStyle get body1Semibold => _theme.body1Semibold;
  TextStyle get body1Medium => _theme.body1Medium;
  TextStyle get body1 => _theme.body1Regular;
  TextStyle get body2Medium => _theme.body2Medium;
  TextStyle get body2 => _theme.body2Regular;
  TextStyle get body3Semibold => _theme.body3Semibold;
  TextStyle get body3Medium => _theme.body3Medium;
  TextStyle get body3 => _theme.body3Regular;

  TextStyle get buttonLarge => _theme.buttonLarge;
  TextStyle get buttonMedium => _theme.buttonMedium;
  TextStyle get buttonSmall => _theme.buttonSmall;
  TextStyle get inputValue => _theme.inputValue;
  TextStyle get inputValueSmall => _theme.inputValueSmall;
  TextStyle get inputLabel => _theme.inputLabel;
  TextStyle get inputHelper => _theme.inputHelper;
  TextStyle get label => _theme.label;
  TextStyle get subtitle => _theme.subtitle;
  TextStyle get caption => _theme.caption;
}
