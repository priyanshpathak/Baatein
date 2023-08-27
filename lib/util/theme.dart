import 'package:flutter/material.dart';
import 'package:message/cons/all_cons.dart';

final appTheme = ThemeData(
  primaryColor: AppColors.white,
  scaffoldBackgroundColor: AppColors.spaceCadet,
  appBarTheme: const AppBarTheme(backgroundColor: AppColors.spaceCadet),
  colorScheme: ColorScheme.fromSwatch().copyWith(secondary: AppColors.orangeWeb),
);