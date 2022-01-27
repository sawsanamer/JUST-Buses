import 'package:flutter/cupertino.dart';

import 'app_colors.dart';

class AppTypography {
  static const header = TextStyle(
    fontFamily: "Roboto",
    fontSize: 40,
    letterSpacing: 2,
  );
  static const header2 = TextStyle(
    fontFamily: "Roboto",
    fontSize: 32,
    height: 0.9,
    letterSpacing: 2,
    fontWeight: FontWeight.bold,
  );
  static const header3 = TextStyle(
    fontFamily: "Roboto",
    fontSize: 24,
    fontWeight: FontWeight.w500,
  );

  static const headerMedium = TextStyle(
    fontFamily: "Roboto",
    fontSize: 18,
    fontWeight: FontWeight.w400,
  );

  static const bodySmall = TextStyle(
      letterSpacing: 2,
      fontFamily: "Roboto",
      fontSize: 12,
      fontWeight: FontWeight.w100,
      height: 1.5);
  static const bodyNormal = TextStyle(
      fontFamily: "Roboto",
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 24 / 16);

  static const bodyNormal2 = TextStyle(
      fontFamily: "Roboto",
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 2,
      height: 2);
  static const bodyMedium2 = TextStyle(
      fontFamily: "Roboto",
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 2);
  static const bodyMedium = TextStyle(
      fontFamily: "Roboto",
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 24 / 16);
  static const answerPreview = TextStyle(
      fontFamily: "Roboto",
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.6);
  static const title = TextStyle(
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.bold,
    fontSize: 30.0,
  );
  static const buttonText = TextStyle(
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
    fontSize: 25.0,
    color: AppColors.darkBlue,
  );
}
