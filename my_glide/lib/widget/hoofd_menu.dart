// language packages
import 'package:flutter/material.dart';
import 'dart:async';

// language add-ons
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/my_navigation.dart';

// my glide data providers
import 'package:my_glide/data/session.dart';

// my glide own widgets
import 'package:my_glide/widget/my_glide_logo.dart';

// my glide pages

class HoofdMenu extends StatefulWidget {
  @override
  _HoofdMenuState createState() => _HoofdMenuState();
}

class _HoofdMenuState extends State<HoofdMenu> {
  ConnectivityResult _netwerkStatus;
  Timer _statusUpdateTimer;


  @override
  void initState() {
    super.initState();

  // check iedere seconde of er een netwerk is
    _statusUpdateTimer = Timer.periodic(Duration(seconds: 1), (Timer t) => _checkConnectionState());   
  }

  @override
  void dispose() {
    super.dispose();

    _statusUpdateTimer.cancel();    // Stop de timer, de class wordt namelijk verwijderd
  }

  @override
  Widget build(BuildContext context) {
    return
      Theme(
        data: ThemeData(
          primaryTextTheme: TextTheme(
            title: TextStyle(color: Colors.pink)
          )
        ),
        isMaterialAppTheme: true,
        child: Drawer(                                         
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              decoration: BoxDecoration(
                color: MyGlideConst.backgroundColor
              ),
              child: ListView(
                children: <Widget>[
                  Container(
                    height:240.0,
                    child:
                    DrawerHeader(
                      child: MyGlideLogo(),
                      decoration: BoxDecoration(
                        color: MyGlideConst.backgroundColor
                      )
                    ),  
                  ),
                  _aanmeldenMenuItem(),
                  ListTile(
                    title: Text("Mijn logboek",
                      style: TextStyle(
                        color: MyGlideConst.frontColor,
                      )
                    ),
                    trailing: Icon(Icons.assignment_ind, color: MyGlideConst.frontColor),
                    onTap: (){MyNavigator.goToMijnLogboek(context);},
                  ),
                  _vliegtuigLogboekMenuItem(),
                  ListTile(
                    title: Text("Instellingen", 
                      style: TextStyle(color: MyGlideConst.frontColor)
                    ),
                    trailing: Icon(Icons.settings, color: MyGlideConst.frontColor),
                    onTap: (){MyNavigator.goToSettings(context);},
                  ),
                  Divider(color: MyGlideConst.frontColor, height: 6.0),
                  serverSession.isIngelogd ?
                    ListTile(
                      title: Text("Uitloggen",
                      style: TextStyle(color: MyGlideConst.frontColor)
                      ),
                      trailing: Icon(Icons.exit_to_app, color: MyGlideConst.frontColor),
                      onTap: () {
                        serverSession.login.logout();
                        MyNavigator.goToLogin(context);
                        SharedPreferences.getInstance().then((prefs) { prefs.clear(); });
                      }
                    )
                  :
                    ListTile(
                      title: Text("Inloggen",
                      style: TextStyle(color: MyGlideConst.frontColor)
                      ),
                      trailing: Icon(Icons.exit_to_app, color: MyGlideConst.frontColor),
                      onTap: () {
                        MyNavigator.goToLogin(context);
                      }
                    ),
                  Divider(color: MyGlideConst.frontColor, height: 6.0),
                  ],
                ),
              )
          )
        )
      );
  } 

  Widget _vliegtuigLogboekMenuItem() {
    if ((!serverSession.login.isClubVlieger) ||          // aanmelden is alleen voor leden en donateurs
        (_netwerkStatus == ConnectivityResult.none)) {   // als er geen netwerk is kunnen we geen logboeken tonen 

          if (!serverSession.login.isLocal)              // lokale gebruiker mag wel vliegtuig logboeken zien 
            return Container(width: 0, height: 0);
        }

    return                   
      ListTile(
        title: Text("Vliegtuig logboek",
          style: TextStyle(
            color: MyGlideConst.frontColor,
          )
        ),
        trailing: Icon(Icons.airplanemode_active, color: MyGlideConst.frontColor),
        onTap: (){MyNavigator.goToVliegtuigen(context);}
      );
  }

  Widget _aanmeldenMenuItem() {
    if ((!serverSession.login.isClubVlieger) ||          // aanmelden is alleen voor leden en donateurs
        (_netwerkStatus == ConnectivityResult.none)) {   // als er geen netwerk is kunnen we niet aanmelden
    
        return Container(width: 0, height: 0); 
    }  
        

    return 
      ListTile(
        title: Text("Aanmelden vliegdag",
          style: TextStyle(color: MyGlideConst.frontColor)
        ),
        trailing: Icon(Icons.person_add, color: MyGlideConst.frontColor),
        onTap: (){MyNavigator.goToAanmelden(context);},
      );     
  }

    // controleer of apparaat nog netwerk verbinding heeft
  void _checkConnectionState()
  {
    Connectivity().checkConnectivity().then((result)
    {
      if (_netwerkStatus != result)
        setState(() {
          _netwerkStatus = result;
        });
    });
  }
}