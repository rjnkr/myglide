import 'package:flutter/material.dart';

import 'package:my_glide/pages/home_scherm.dart';
import 'package:my_glide/pages/login_scherm.dart';
import 'package:my_glide/pages/splash_scherm.dart';

import 'package:my_glide/utils/session.dart';

var routes = <String, WidgetBuilder>{
  "/home": (BuildContext context) => HomeScreen(), 
  "/login": (BuildContext context) => LoginScreen(), 
// "/intro": (BuildContext context) => IntroScreen(), 
};   

void main() {
  // niet verwijderen, zorgt dat serverSession class wordt opgebouwd, doet verder niets
  print (serverSession.lastUrl);      

  runApp(new MaterialApp(
  theme:
      ThemeData(primaryColor: Colors.red, accentColor: Colors.yellowAccent),
  debugShowCheckedModeBanner: false,
  home: SplashScreen(),
  routes: routes));
}

/*
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final appTitle = 'Drawer Demo';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      home: MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('My Page!')),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the Drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Drawer Header'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Item 1'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Item 2'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
*/