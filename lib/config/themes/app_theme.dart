import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nft_marketplace_mobile/config/themes/app_palette.dart';

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      primaryColor: AppPalette.primary,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: AppPalette.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        bodyLarge: TextStyle(
          fontSize: 16.sp,
          color: Colors.black,
        ),
        bodyMedium: TextStyle(
          fontSize: 14.sp,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
