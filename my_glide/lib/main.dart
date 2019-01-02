// language packages
import 'package:flutter/material.dart';

// language add-ons

// my glide utils
import 'package:my_glide/utils/session.dart';
import 'package:my_glide/utils/my_glide_const.dart';

// my glide data providers

// my glide own widgets

// my glide pages
import 'package:my_glide/pages/mijn_logboek_scherm.dart';
import 'package:my_glide/pages/login_scherm.dart';
import 'package:my_glide/pages/splash_scherm.dart';
import 'package:my_glide/pages/settings_scherm.dart';
import 'package:my_glide/pages/vliegtuig_logboek_scherm.dart';

var routes = <String, WidgetBuilder>{
  "/mijnlogboek": (BuildContext context) => MijnLogboekScreen(), 
  "/login": (BuildContext context) => LoginScreen(),
  "/settings": (BuildContext context) => SettingsScreen(),
  "/vliegtuigen": (BuildContext context) => VliegtuigLogboekScreen(),
};   


void main() {
  // niet verwijderen, zorgt dat serverSession class wordt opgebouwd, doet verder niets
  print (serverSession.lastUrl);      

  runApp(new MaterialApp(
    title: MyGlideConst.AppName,
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
    routes: routes
  ));
}