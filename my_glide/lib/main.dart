import 'package:flutter/material.dart';

import 'package:my_glide/pages/home_scherm.dart';
import 'package:my_glide/pages/login_scherm.dart';
import 'package:my_glide/pages/splash_scherm.dart';
import 'package:my_glide/pages/settings_scherm.dart';
import 'package:my_glide/pages/vliegtuig_logboek_scherm.dart';

import 'package:my_glide/utils/session.dart';
import 'package:my_glide/utils/my_glide_const.dart';

var routes = <String, WidgetBuilder>{
  "/home": (BuildContext context) => HomeScreen(), 
  "/login": (BuildContext context) => LoginScreen(),
  "/settings": (BuildContext context) => SettingsScreen(),
  "/vliegtuigen": (BuildContext context) => VliegtuigLogboekScreen(),
// "/intro": (BuildContext context) => IntroScreen(), 
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