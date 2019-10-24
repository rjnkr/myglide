// language packages
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:core';

// language add-ons
import 'package:connectivity/connectivity.dart';

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/my_navigation.dart';
import 'package:my_glide/utils/storage.dart';
import 'package:my_glide/utils/debug.dart';

// my glide data providers
import 'package:my_glide/data/session.dart';

// my glide own widgets
import 'package:my_glide/widget/my_glide_logo.dart';

// my glide pages
import 'package:my_glide/pages/gui_helpers.dart';

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
  bool _suspent = false;
  
  @override
  void initState()  {
    MyGlideDebug.info("_SplashScreenState.initState()");

    super.initState();

    Timer.periodic(Duration(seconds: 3), (Timer t)
    {
      if (_suspent) return;

      if ((_netwerkStatus != null) && (_lastLoginResult != "init"))
      {
        t.cancel(); 
        
        if (_netwerkStatus == ConnectivityResult.none)   // geen netwerk
        {
          if (serverSession.login.getLastUsername() == null)  // er is geen laatste username bekend, waarschijnlijk nog nooit ingelogd
            MyNavigator.goToLogin(context);               // Toon login pagina
          else
            return;                                       // Toon mijn logboek
        }    

        serverSession.getLastUrl().then((lasturl)
        {
          if (lasturl == "demo")
            MyNavigator.goToLogin(context);                // vorige keer zaten we in demo mode, nu naar login scherm
          else if (_lastLoginResult == "false")   
            MyNavigator.goToLogin(context);                // mislukt om opnieuw in te loggen, of nog geen inlog gevens bekend. Toon inlogscherm           
          else if (_lastLoginResult == "true")  {
            // hoofdpagina
            Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => widget.navigateTo));
            if (!serverSession.login.isAangemeld)
            {
              MyNavigator.goToAanmelden(context, pop: false); // Vlieger is nog niet aangemeld voor vandaag
            }
          }  
        });
      }
    });

    // controleer of er een netwerk verbinding is
    Connectivity().checkConnectivity().then((result)
    {
      _netwerkStatus = result;
    });    

    // opnieuw inloggen met laatst bekende credentials
    serverSession.login.lastLogin().then((response) {  _lastLoginResult = response.toString(); });
  }

  @override
  Widget build(BuildContext context) {
    MyGlideDebug.info("_SplashScreenState.build(contexy)");

    int size = 300;
    double labelSize = MyGlideConst.labelSizeExtraLarge;

    // In ladscape maken we het logo (en tekst) kleiner
    if (MediaQuery.of(context).orientation == Orientation.landscape)
    {
      labelSize = MyGlideConst.labelSizeMedium;
      size = 200;
    }

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
                child: GestureDetector(
                  onLongPress: () => _resetCredentialsDialog(),
                  child: MyGlideLogo(size: size, labelTextSize: labelSize)
                )
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

  void _resetCredentialsDialog() {
    MyGlideDebug.info("_SplashScreenState._resetCredentialsDialog()");

    _suspent = true;
    GUIHelper.confirmDialog(context, "Reset instellingen", "Alle informatie op het apparaat wissen?").then((response) {
      if (response == ConfirmAction.NEE) {
        _suspent = false;                       // We gaan door met volgende scherm
      }
      else
      {
        serverSession.login.logout();
        Storage.clear();

        GUIHelper.ackAlert(context, "Informatie verwijderd", "Start applicatie opnieuw op.");
      }
    });
  }
}
