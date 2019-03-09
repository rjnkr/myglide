// language packages
import 'package:flutter/material.dart';

// language add-ons

// my glide utils

// my glide data providers

// my glide own widgets

// my glide pages

class MyGlideConst {
  static const String AppName = "My Glide";
  static const int logboekRefreshRate = 300;   // iedere 5 minuten (300 / 60) logboek ophalen

  static const Color _yellowRGB = Color.fromRGBO(213,172,73,1);
  static const Color _blueRGB = Color.fromRGBO(37,65,121,1);

  static const Color disabled = Colors.grey; 

  static const Color frontColor = _yellowRGB;
  static const Color backgroundColor = _blueRGB;

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

  static const Color showLoadingBackground = Colors.white;

  static const double labelSizeExtraLarge = 35;
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

  static const String defaultURL = "https://startadmin.gezc.org";

  static const double breedteLogoekDetails = 325;
  static const double breedteAanwezigDetails = 1;

  static const double takeOffSpeed = 50 / 3.6;    // takeOffSpeed in m/s,  50 km/h
  static const double noStallAltitude = 100;      // Onder de 100 mag snelheid niet onder takeOffSpeed komen, anders zijn we geland

  static Color appBarBackground() {
    return backgroundColor;
  }

  static TextStyle appBarTextColor() {
    return TextStyle(color: frontColor);
  }
}