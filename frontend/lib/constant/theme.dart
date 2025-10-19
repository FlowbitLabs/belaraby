import 'package:belaraby/constant/colors.dart';
import 'package:flutter/material.dart';

final ThemeData belarabyTheme =
    ThemeData.from(
      colorScheme: const ColorScheme.light(
        primary: purple100,
        secondary: green100,
        onSurface: grey170,
      ),
    ).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: grey0,
        centerTitle: true,
      ),
      dividerTheme: const DividerThemeData(color: grey140),
      checkboxTheme: const CheckboxThemeData(
        side: BorderSide(color: grey140),
      ),
      radioTheme: RadioThemeData(
        splashRadius: 10,
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return purple100;
          }
          return grey140;
        }),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: grey140,
        contentTextStyle: TextStyle(color: grey0),
      ),
    );
