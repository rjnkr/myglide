import 'package:flutter/material.dart';

class MyGlideConst {
  static const String AppName = "My Glide";

  static const Color YellowRGB = Color.fromRGBO(213,172,73,1);
  static const Color BlueRGB = Color.fromRGBO(37,65,121,1);

  static const Color frontColor = Color.fromRGBO(213,172,73,1);
  static const Color backgroundColor = Color.fromRGBO(37,65,121,1);

  static const Color hintColorLight = Colors.grey;
  static const Color hintColorDark = Colors.black;

  static const Color labelColorLight = frontColor;
  static const Color labelColorDark = Colors.black; 

  static const Color errorColorLight = Colors.redAccent;
  static const Color errorColorDark = Colors.red; 

  static const Color textInputLight = Colors.white;
  static const Color textInputDark = Colors.black;

  static const Color splashScreenTextColor = Colors.white;
  static const Color logoTextColor = Colors.white;

  static const Color gridBackgroundColor = Colors.white;
  static const Color gridTextColor = Colors.black;
  static const Color starttijdColor = Colors.green;
  static const Color landingstijdColor = Colors.red;

  static const double labelSizeLarge = 25;
  static const double labelSizeMedium = 20;
  static const double labelSizeNormal = 15;
  static const double labelSizeSmall= 10;

  static const double hintSizeLarge = 25;
  static const double hintSizeMedium = 20;
  static const double hintSizeNormal = 15;
  static const double hintSizeSmall= 10;

  static const double textInputSizeLarge = 25;
  static const double textInputSizeMedium = 20;
  static const double textInputSizeNormal = 15;
  static const double textInputSizeSmall= 10;

  static const double errorSizeLarge = 25;
  static const double errorSizeMedium = 20;
  static const double errorSizeNormal = 15;
  static const double errorSizeSmall= 10;

  static const double gridTextLarge = 20;
  static const double gridTextedium = 20;
  static const double gridTextNormal = 12;
  static const double gridTextSmall= 10;

  static Color appBarBackground() {
    return backgroundColor;
  }

  static TextStyle appBarTextColor() {
    return TextStyle(color: frontColor);
  }
}