import 'package:flutter/material.dart';

import 'package:my_glide/pages/home_screen.dart';
//import 'package:flutkart/pages/intro_screen.dart';
import 'package:my_glide/pages/splash_screen.dart';

var routes = <String, WidgetBuilder>{
  "/home": (BuildContext context) => HomeScreen(), 
//  "/login": (BuildContext context) => LoginScreen(), 
 // "/intro": (BuildContext context) => IntroScreen(), 
};

void main() => runApp(new MaterialApp(
    theme:
        ThemeData(primaryColor: Colors.red, accentColor: Colors.yellowAccent),
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
    routes: routes));
