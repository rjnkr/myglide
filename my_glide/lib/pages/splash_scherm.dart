// language packages
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:core';

// language add-ons
import 'package:connectivity/connectivity.dart';

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/my_navigation.dart';
import 'package:my_glide/utils/session.dart';

// my glide own widgets
import 'package:my_glide/widget/my_glide_logo.dart';

// my glide pages

class SplashScreen extends StatefulWidget {
  final dynamic navigateTo;

  SplashScreen(
    {
      this.navigateTo,
    }
  );


  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  ConnectivityResult _netwerkStatus;
  String _lastLoginResult = "init";

  @override
  void initState() {
    super.initState();

    Timer.periodic(Duration(seconds: 1), (Timer t)
    {
      if ((_netwerkStatus != null) && (_lastLoginResult != "init"))
      {
        t.cancel();

        Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => widget.navigateTo));
        
        if ((serverSession.lastUsername == null) || (serverSession.lastPassword == null) || (serverSession.lastUrl == null))   
          MyNavigator.goToLogin(context);                     // nog geen inlog gevens bekend, toon inlogscherm
        else if (_netwerkStatus == ConnectivityResult.none)   // geen netwerk
          return;                                             // Dus toon mijn logboek
        else if (_lastLoginResult != null)
          MyNavigator.goToLogin(context);                     // mislukt om opnieuw in te loggen, dus toon login scherm
      }
    });

    // controleer of er een netwerk verbinding is
    Connectivity().checkConnectivity().then((result)
    {
      _netwerkStatus = result;
    });    

    // opnieuw inloggen met laatst bekende credentials
    serverSession.lastLogin().then((response) {  _lastLoginResult = response; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(color: MyGlideConst.backgroundColor),
          width: double.infinity,
          child: Column(
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
                    CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(MyGlideConst.frontColor)),
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
                          color: MyGlideConst.splashScreenTextColor
                        ),
                    )
                  ],
                ),
              )
            ],
          )
        )
      ),
    );
  }
}
