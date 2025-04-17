import 'package:flutter/material.dart';
import 'package:pixieapp/const/colors.dart';
import 'package:pixieapp/modules/scaler_module.dart';

// Custom TextStyle method
TextStyle getTextStyle({
  required ScalerModule scaler,
  required double fontSize,
  required FontWeight weight,
  required Color color,
  double? letterSpacing,
}) {
  return TextStyle(
    fontSize: scaler.scaleFontSize(fontSize),
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
    fontFamily: 'SF-Pro-Rounded',
  );
}

// App Theme
ThemeData appTheme(BuildContext context) {
  final ScalerModule scaler = ScalerModule(context);
  return ThemeData(
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color.fromARGB(
          255, 231, 201, 249), // Set your desired background color
      contentTextStyle: TextStyle(
        color: AppColors
            .primaryColor, // Set the text color for the SnackBar content
        fontSize: 16,
      ),
      actionTextColor: Colors.yellow, // Set action text color
    ),
    useMaterial3: true,
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.secondaryBackgroundColor,
    textTheme: TextTheme(
      displayLarge: getTextStyle(
          scaler: scaler,
          fontSize: 80,
          weight: FontWeight.w800,
          color: const Color(0xFF612ACE)),
      displayMedium: getTextStyle(
          scaler: scaler,
          fontSize: 45,
          weight: FontWeight.w600,
          color: AppColors.textColorblack),
      displaySmall: getTextStyle(
          scaler: scaler,
          fontSize: 36,
          weight: FontWeight.w400,
          color: AppColors.textColorblack),
      headlineLarge: getTextStyle(
          scaler: scaler,
          fontSize: 32,
          weight: FontWeight.w800,
          color: AppColors.textColorblack),
      headlineMedium: getTextStyle(
          scaler: scaler,
          fontSize: 28,
          weight: FontWeight.w600,
          color: const Color(0xFF612ACE)),
      headlineSmall: getTextStyle(
          scaler: scaler,
          fontSize: 20,
          weight: FontWeight.w400,
          color: AppColors.textColorblack),
      titleLarge: getTextStyle(
          scaler: scaler,
          fontSize: 22,
          weight: FontWeight.w600,
          color: AppColors.textColorblack),
      titleMedium: getTextStyle(
          scaler: scaler,
          fontSize: 16,
          letterSpacing: 0.15,
          weight: FontWeight.w500,
          color: AppColors.textColorblack),
      titleSmall: getTextStyle(
          scaler: scaler,
          fontSize: 14,
          color: AppColors.textColorblack,
          letterSpacing: 0.1,
          weight: FontWeight.w500),
      bodyLarge: getTextStyle(
          scaler: scaler,
          fontSize: 16,
          letterSpacing: 0.15,
          weight: FontWeight.w800,
          color: AppColors.textColorblack),
      bodyMedium: getTextStyle(
          scaler: scaler,
          fontSize: 20,
          letterSpacing: 0.25,
          weight: FontWeight.w400,
          color: AppColors.textColorblack),
      bodySmall: getTextStyle(
          scaler: scaler,
          fontSize: 12,
          letterSpacing: 0.4,
          weight: FontWeight.w300,
          color: AppColors.textColorblack),
      labelLarge: getTextStyle(
          scaler: scaler,
          fontSize: 14,
          letterSpacing: 0.1,
          color: AppColors.textColorblack,
          weight: FontWeight.w500),
      labelMedium: getTextStyle(
          scaler: scaler,
          fontSize: 12,
          color: AppColors.textColorblack,
          letterSpacing: 0.5,
          weight: FontWeight.w500),
      labelSmall: getTextStyle(
          scaler: scaler,
          color: AppColors.textColorblack,
          fontSize: 11,
          letterSpacing: 0.5,
          weight: FontWeight.w500),
    ),
    appBarTheme: AppBarTheme(
      color: AppColors.secondaryBackgroundColor,
      titleTextStyle: TextStyle(
        color: AppColors.textColorblack,
        fontSize: scaler.scaleFontSize(20.0),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textColorblack,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        // backgroundColor: AppColors.textColorWhite,
        foregroundColor: AppColors.textColorblack,
      ),
    ),
    cardColor: AppColors.secondaryColor,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.secondaryBackgroundColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            const BorderSide(color: AppColors.secondaryColor, width: 2.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            const BorderSide(color: AppColors.secondaryColor, width: 2.5),
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.textColorblack),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: AppColors.textColorblack,
    ),
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryColor,
      onPrimary: AppColors.textColorblack,
      secondary: AppColors.secondaryColor,
      onSecondary: AppColors.textColorblack,
      error: Color(0xFFE57373),
      onError: Color(0xFFE53935),
      background: AppColors.secondaryBackgroundColor,
      onBackground: AppColors.textColorblack,
      surface: AppColors.secondaryBackgroundColor,
      onSurface: AppColors.textColorblack,
    ),
  );
}
