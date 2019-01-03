// language packages
import 'package:flutter/material.dart';

// language add-ons

// my glide utils

// my glide data providers

// my glide own widgets

// my glide pages
import 'package:my_glide/pages/mijn_logboek_scherm.dart';
import 'package:my_glide/pages/login_scherm.dart';
import 'package:my_glide/pages/settings_scherm.dart';
import 'package:my_glide/pages/vliegtuig_logboek_scherm.dart';

var routes = <String, WidgetBuilder>{
  "/mijnlogboek": (BuildContext context) => MijnLogboekScreen(), 
  "/login": (BuildContext context) => LoginScreen(),
  "/settings": (BuildContext context) => SettingsScreen(),
  "/vliegtuigen": (BuildContext context) => VliegtuigLogboekScreen(),
};   

class MyNavigator {
  static void goMijnLogboek(BuildContext context) {
    Navigator.pushReplacementNamed(context, "/mijnlogboek");
  }

  static void goToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, "/login");
  }
  
  static void goToSettings(BuildContext context) {  
    Navigator.pushReplacementNamed(context, "/settings");
  }

  static void goToVliegtuigen(BuildContext context) {
    Navigator.pushReplacementNamed(context, "/vliegtuigen");
  } 
}