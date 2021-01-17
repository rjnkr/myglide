// language packages
import 'package:flutter/material.dart';

// language add-ons

// my glide utils

// my glide data providers

// my glide own widgets

// my glide pages

class MyGlideConst {
  static const String AppName = "My Glide";
  static const int logboekRefreshRate =
      300; // iedere 5 minuten (300 / 60) logboek ophalen

  static const Color _yellowRGB = Color.fromRGBO(213, 172, 73, 1);
  static const Color _blueRGB = Color.fromRGBO(37, 65, 121, 1);

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

  static const double labelSizeExtraLarge = 35.0;
  static const double labelSizeLarge = 25.0;
  static const double labelSizeMedium = 20.0;
  static const double labelSizeNormal = 15.0;
  static const double labelSizeSmall = 10.0;

  static const double hintSizeLarge = 25.0;
  static const double hintSizeMedium = 20.0;
  static const double hintSizeNormal = 15.0;
  static const double hintSizeSmall = 10.0;

  static const double textInputSizeLarge = 25.0;
  static const double textInputSizeMedium = 20.0;
  static const double textInputSizeNormal = 14.0;
  static const double textInputSizeSmall = 10.0;

  static const double errorSizeLarge = 25.0;
  static const double errorSizeMedium = 20.0;
  static const double errorSizeNormal = 15.0;
  static const double errorSizeSmall = 10.0;

  static const double gridTextLarge = 20.0;
  static const double gridTextMedium = 20.0;
  static const double gridTextNormal = 12.0;
  static const double gridTextSmall = 10.0;

  static const String defaultURL = "https://startadmin.gezc.org";

  static const String emailVeiligheidsManager =
      "ict@gezc.org"; //"veiligheidsmanager@gezc.org";
  static const String emailCommRollend = "comrijdendmaterieel@Gezc.org";
  static const String emailCommVliegend = "comvliegendmaterieel@gezc.org";
  static const String emailStartAdmin = "startadmin@gezc.org";

  static const double breedteLogoekDetails = 325.0;
  static const double breedteLidDetails = 400;
  static const double breedteAanwezigDetails = 1.0;

  static const double takeOffSpeed = 50 / 3.6; // takeOffSpeed in m/s,  50 km/h
  static const double noStallAltitude =
      150; // Onder de 150 meter mag snelheid niet onder takeOffSpeed komen, anders zijn we geland

  static Color appBarBackground() {
    return backgroundColor;
  }

  static TextStyle appBarTextColor() {
    return TextStyle(color: frontColor);
  }

  static const TextTheme myGlideTextTheme = TextTheme(
    headline1: TextStyle(
        debugLabel: 'blackCupertino display1',
        fontFamily: '.SF UI Display',
        inherit: true,
        color: Colors.black54,
        decoration: TextDecoration.none),
    headline2: TextStyle(
        debugLabel: 'blackCupertino display2',
        fontFamily: '.SF UI Display',
        inherit: true,
        color: Colors.black54,
        decoration: TextDecoration.none),
    headline3: TextStyle(
        debugLabel: 'blackCupertino display3',
        fontFamily: '.SF UI Display',
        inherit: true,
        color: Colors.black54,
        decoration: TextDecoration.none),
    headline4: TextStyle(
        debugLabel: 'blackCupertino display4',
        fontFamily: '.SF UI Display',
        inherit: true,
        color: Colors.black54,
        decoration: TextDecoration.none),
    headline5: TextStyle(
        debugLabel: 'blackCupertino headline',
        fontFamily: '.SF UI Display',
        inherit: true,
        color: Colors.black87,
        decoration: TextDecoration.none),
    headline6: TextStyle(
        debugLabel: 'blackCupertino title',
        fontFamily: '.SF UI Display',
        inherit: true,
        color: Colors.black87,
        decoration: TextDecoration.none),
    subtitle1: TextStyle(
        debugLabel: 'blackCupertino subhead',
        fontFamily: '.SF UI Text',
        inherit: true,
        color: Colors.black87,
        decoration: TextDecoration.none),
    subtitle2: TextStyle(
        debugLabel: 'blackCupertino subtitle',
        fontFamily: '.SF UI Text',
        inherit: true,
        color: Colors.black,
        decoration: TextDecoration.none),
    bodyText1: TextStyle(
        debugLabel: 'blackCupertino body2',
        fontFamily: '.SF UI Text',
        inherit: true,
        color: Colors.black87,
        decoration: TextDecoration.none),
    bodyText2: TextStyle(
        debugLabel: 'blackCupertino body1',
        fontFamily: '.SF UI Text',
        inherit: true,
        color: Colors.black,
        decoration: TextDecoration.none),
    caption: TextStyle(
        debugLabel: 'blackCupertino caption',
        fontFamily: '.SF UI Text',
        inherit: true,
        color: Colors.black54,
        decoration: TextDecoration.none),
    button: TextStyle(
        debugLabel: 'blackCupertino button',
        fontFamily: '.SF UI Text',
        inherit: true,
        color: Colors.black87,
        decoration: TextDecoration.none),
    overline: TextStyle(
        debugLabel: 'blackCupertino overline',
        fontFamily: '.SF UI Text',
        inherit: true,
        color: Colors.black,
        decoration: TextDecoration.none),
  );
}
