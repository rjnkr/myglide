// language packages
import 'package:flutter/material.dart';

// language add-ons

// my glide utils
import 'package:my_glide/utils/debug.dart';

// my glide data providers

// my glide own widgets

// my glide pages
import 'package:my_glide/pages/mijn_logboek_scherm.dart';
import 'package:my_glide/pages/leden_lijst_scherm.dart';
import 'package:my_glide/pages/login_scherm.dart';
import 'package:my_glide/pages/settings_scherm.dart';
import 'package:my_glide/pages/vliegtuigen_scherm.dart';
import 'package:my_glide/pages/aanmelden_scherm.dart';
import 'package:my_glide/pages/vandaag_scherm.dart';
import 'package:my_glide/pages/melding_scherm.dart';

var routes = <String, WidgetBuilder>{
  "/mijnlogboek": (BuildContext context) => MijnLogboekScreen(), 
  "/login": (BuildContext context) => LoginScreen(),
  "/settings": (BuildContext context) => SettingsScreen(),
  "/aanmelden": (BuildContext context) => AanmeldenScreen(),
  "/ledenlijst": (BuildContext context) => LedenLijstScreen(),
  "/vliegtuigen": (BuildContext context) => VliegtuigenScreen(),
  "/vandaag": (BuildContext context) => VandaagScreen(),  
  "/melding": (BuildContext context) => MeldingScreen(), 
};   

class MyNavigator {
  static void goToMijnLogboek(BuildContext context) {
    MyGlideDebug.info("MyNavigator.goToMijnLogboek(context)");

    Navigator.pushReplacementNamed(context, "/mijnlogboek");
  }

  static void goToAanwezig(BuildContext context) {
    MyGlideDebug.info("MyNavigator.goToAanwezig(context)");

    Navigator.pushReplacementNamed(context, "/vandaag");
  }

  static void goToLogin(BuildContext context) {
    MyGlideDebug.info("MyNavigator.goToLogin(context)");

    Navigator.pushReplacementNamed(context, "/login");
  }
  
  static void goToSettings(BuildContext context) {  
    Navigator.pushReplacementNamed(context, "/settings");
  }


  static void goToVliegtuigen(BuildContext context) {
    MyGlideDebug.info("MyNavigator.goToVliegtuigen(context)");

    Navigator.pushReplacementNamed(context, "/vliegtuigen");
  }  
  

  static void goToLedenLijst(BuildContext context) {
    MyGlideDebug.info("MyNavigator.goToLedenLijst(context)");

    Navigator.pushReplacementNamed(context, "/ledenlijst");
  }   

  static void goToAanmelden(BuildContext context, {bool pop = true}) {
    MyGlideDebug.info("MyNavigator.goToAanmelden(context, $pop)");

    if (pop)
      Navigator.popAndPushNamed(context, "/aanmelden");
    else
      Navigator.pushNamed(context, "/aanmelden");
  } 

  static void goToMelden(BuildContext context) {
    MyGlideDebug.info("MyNavigator.goToMelden(context)");

    Navigator.popAndPushNamed(context, "/melding");
  }
}