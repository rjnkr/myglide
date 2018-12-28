import 'package:flutter/material.dart';

import 'package:my_glide/pages/home_screen.dart';
import 'package:my_glide/pages/login_screen.dart';
import 'package:my_glide/pages/splash_screen.dart';
import 'package:my_glide/utils/session.dart';





void main() {
   Session session = Session();

  var routes = <String, WidgetBuilder>{
    "/home": (BuildContext context) => HomeScreen(session), 
    "/login": (BuildContext context) => LoginScreen(session), 
  // "/intro": (BuildContext context) => IntroScreen(), 
};   

   runApp(new MaterialApp(
    theme:
        ThemeData(primaryColor: Colors.red, accentColor: Colors.yellowAccent),
    debugShowCheckedModeBanner: false,
    home: SplashScreen(session),
    routes: routes));
}

