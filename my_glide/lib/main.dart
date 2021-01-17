// language packages
import 'package:flutter/material.dart';
import 'package:my_glide/pages/gui_helpers.dart';

// language add-ons

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/my_navigation.dart';

// my glide data providers

// my glide own widgets

// my glide pages
import 'package:my_glide/pages/splash_scherm.dart';
import 'package:my_glide/pages/mijn_logboek_scherm.dart';


ThemeData myGlideTheme() {

  final ThemeData base = ThemeData();
  return base.copyWith(

    accentColor: Colors.red,
    hintColor: MyGlideConst.hintColorLight,
    primaryColor: MyGlideConst.frontColor,

    textTheme: MyGlideConst.myGlideTextTheme,

    inputDecorationTheme: InputDecorationTheme(
      contentPadding: EdgeInsets.all(10),
      border: OutlineInputBorder(),
      hintStyle: GUIHelper.hintStyle(),
      labelStyle: GUIHelper.labelStyle(),
      errorStyle: GUIHelper.errorStyle()
    ),
    
  );
}

void main() async {
  runApp(new MaterialApp(
    title: MyGlideConst.AppName,
    debugShowCheckedModeBanner: false,
    home: MyGlideApp(),
    routes: routes,
    theme: myGlideTheme()
  ));
}

class MyGlideApp extends StatefulWidget {
  @override
  _MyGlideAppState createState() => new _MyGlideAppState();
}

class _MyGlideAppState extends State<MyGlideApp> {
  @override
  Widget build(BuildContext context) {
    return  SplashScreen(
      navigateTo:  MijnLogboekScreen(),
    );
  }
}