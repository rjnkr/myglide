import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:async';

import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/my_navigation.dart';
import 'package:my_glide/utils/session.dart';

import 'package:my_glide/widget/my_glide_logo.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  ConnectivityResult _connectivityResult;

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), nextPage);

    // controleer of er een netwerk verbinding is
    Connectivity().checkConnectivity().then((result)
    {
      _connectivityResult = result;
    });
  }

  void nextPage() {
    if (_connectivityResult.index == 2)       // geen network
      MyNavigator.goToHome(context); 
    else if ((serverSession.lastUsername == null) || (serverSession.lastPassword == null) || (serverSession.lastUrl == null))   
      // nog geen inlog gevens bekend
      MyNavigator.goToLogin(context);
    else
    {
      // opnieuw inloggen met laatst bekende credentials
      serverSession.lastLogin().then((response) 
      {
        if (response == null)
          MyNavigator.goToHome(context);  // gelukt
        else
          MyNavigator.goToLogin(context); // mislukt dus toon login scherm
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: MyGlideConst.BlueRGB),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: MyGlideLogo()
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(MyGlideConst.YellowRGB)),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                    ),
                    Text(
                      "Online logboek \n en meer....",
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.white),
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}