// language packages
import 'package:flutter/material.dart';
import 'dart:async';

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

class HoofdMenu extends StatefulWidget {
  @override
  _HoofdMenuState createState() => _HoofdMenuState();
}

class _HoofdMenuState extends State<HoofdMenu> {
  ConnectivityResult _netwerkStatus;
  Timer _statusUpdateTimer;


  @override
  void initState() {
    MyGlideDebug.info("_HoofdMenuState.initState()");
    super.initState();

    // check iedere seconde of er een netwerk is
    _checkConnectionState();
    _statusUpdateTimer = Timer.periodic(Duration(seconds: 1), (Timer t) => _checkConnectionState()); 
  }

  @override
  void dispose() {
    MyGlideDebug.info("_HoofdMenuState.dispose()");    
    super.dispose();

    _statusUpdateTimer.cancel();    // Stop de timer, de class wordt namelijk verwijderd
  }

  @override
  Widget build(BuildContext context) {
    MyGlideDebug.info("_HoofdMenuState.build(context)");  

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
              child: Stack(
                children: <Widget> [
                  ListView(
                    children: <Widget>[
                      Container(
                        height: 150,
                        child: DrawerHeader(
                          padding: EdgeInsets.all(0),
                          child: Column (
                            children: <Widget>[
                              MyGlideLogo(
                                size: 200,
                                labelTextSize: MyGlideConst.labelSizeMedium,
                                labelText: serverSession.login.isDDWV ? "DDWV" : "GeZC",
                              ), 
                              _toonNaam(context),
                            ],
                          ),
                          decoration: BoxDecoration(
                            color: MyGlideConst.backgroundColor
                          )
                        ),
                      ),
                      _aanmeldenMenuItem(),
                      _aanwezigMenuItem(),
                      _ledenLijst(),
                      _vliegtuigen(),
                      ListTile(
                        title: Text("Mijn logboek",
                          style: TextStyle(
                            color: MyGlideConst.frontColor,
                          )
                        ),
                        trailing: Icon(Icons.assignment_ind, color: MyGlideConst.frontColor),
                        onTap: (){MyNavigator.goToMijnLogboek(context);},
                      ),
                      _meldingMenuItem(),
                      ListTile(
                        title: Text("Instellingen", 
                          style: TextStyle(color: MyGlideConst.frontColor)
                        ),
                        trailing: Icon(Icons.settings, color: MyGlideConst.frontColor),
                        onTap: (){MyNavigator.goToSettings(context);},
                      ),
                      _loginMenuItem()
                     
                      
                      ],
                    ),
                    GUIHelper.demoOverlay(context),
                ])
              )
          )
        )
      );
  } 

  // Ton login of logout menu item
  Widget _loginMenuItem() {

    // als er geen netwerk is kunnen we niet inloggen, maar wel uitloggen (bijv om naar demo mode te gaan)
    if ((_netwerkStatus == ConnectivityResult.none) && (!serverSession.isIngelogd))   {
      return Container(width: 0, height: 0);
    }

// Divider(color: MyGlideConst.frontColor, height: 6.0),

    // als we ingelogd zijn, menu item voor uitloggen
    if (serverSession.isIngelogd || serverSession.isDemo) {
      return        
        ListTile(
          title: Text("Uitloggen",
          style: TextStyle(color: MyGlideConst.frontColor)
          ),
          trailing: Icon(Icons.exit_to_app, color: MyGlideConst.frontColor),
          onTap: () {
            serverSession.login.logout();
            MyNavigator.goToLogin(context);
            Storage.clear();
          }
        );
    }

    return
      ListTile(
        title: Text("Inloggen",
        style: TextStyle(color: MyGlideConst.frontColor)
        ),
        trailing: Icon(Icons.exit_to_app, color: MyGlideConst.frontColor),
        onTap: () {
          MyNavigator.goToLogin(context);
        }
      );
  }

  // menu item om te tonen wie er vandaag aanwezig zijn
  Widget _aanwezigMenuItem() {
    MyGlideDebug.info("_HoofdMenuState._aanwezigMenuItem()");  

    // als er geen netwerk is kunnen we niets tonen, behalve in demo mode. Want dan is de data lokaal beschikbaar
    if ((_netwerkStatus == ConnectivityResult.none) && (!serverSession.isDemo)) 
      return Container(width: 0, height: 0);

    
    if ((serverSession.login.isBeheerder) || (serverSession.login.isInstructeur) ||
        (serverSession.login.isStartleider)) {
     return                   
      ListTile(
        title: Text("Vandaag aanwezig",
          style: TextStyle(
            color: MyGlideConst.frontColor,
          )
        ),
        trailing: Icon(Icons.person, color: MyGlideConst.frontColor),
        onTap: (){MyNavigator.goToAanwezig(context);}
      );
    }

    return Container(width: 0, height: 0);
  } 

  // menu item om de gebruiker voor de vliegdag aan te melden
  Widget _aanmeldenMenuItem() {
    MyGlideDebug.info("_HoofdMenuState._aanmeldenMenuItem()");  

    // als er geen netwerk is kunnen we niets tonen, behalve in demo mode. Want dan is de data lokaal beschikbaar
    if ((_netwerkStatus == ConnectivityResult.none) && (!serverSession.isDemo))   
      return Container(width: 0, height: 0);


    if (!serverSession.login.isClubVlieger)            // aanmelden is alleen voor leden en donateurs
        return Container(width: 0, height: 0);       

    return 
      ListTile(
        title: Text("Aanmelden vliegdag",
          style: TextStyle(color: MyGlideConst.frontColor)
        ),
        trailing: Icon(Icons.person_add, color: MyGlideConst.frontColor),
        onTap: (){MyNavigator.goToAanmelden(context);},
      );     
  }

  // menu item om de gebruiker de leden lijst te laten zien
  Widget _ledenLijst() {
    MyGlideDebug.info("_HoofdMenuState._ledenLijst()");  

    // als er geen netwerk is kunnen we niets tonen, behalve in demo mode. Want dan is de data lokaal beschikbaar
    if ((_netwerkStatus == ConnectivityResult.none) && (!serverSession.isDemo))   
      return Container(width: 0, height: 0);


    if (!serverSession.login.isClubVlieger)            // ledenlijst is alleen voor leden en donateurs
        return Container(width: 0, height: 0);       

    return 
      ListTile(
        title: Text("Ledenlijst",
          style: TextStyle(color: MyGlideConst.frontColor)
        ),
        trailing: Icon(Icons.people, color: MyGlideConst.frontColor),
        onTap: (){MyNavigator.goToLedenLijst(context);},
      );     
  }

  // menu item voorvliegtuigen
  Widget _vliegtuigen() {
    MyGlideDebug.info("_HoofdMenuState._vliegtuigen()");  

    // als er geen netwerk is kunnen we niets tonen, behalve in demo mode. Want dan is de data lokaal beschikbaar
    if ((_netwerkStatus == ConnectivityResult.none) && (!serverSession.isDemo))   
      return Container(width: 0, height: 0);

    if (!serverSession.login.isClubVlieger)            // vliegtuigen zijn alleen voor leden en donateurs
        return Container(width: 0, height: 0);       

    return 
      ListTile(
        title: Text("Vliegtuigen",
          style: TextStyle(color: MyGlideConst.frontColor)
        ),
        trailing: Icon(Icons.airplanemode_active, color: MyGlideConst.frontColor),
        onTap: (){MyNavigator.goToVliegtuigen(context);},
      );     
  }  

  Widget _meldingMenuItem() {
    MyGlideDebug.info("_HoofdMenuState._ledenLijst()");  

    // als er geen netwerk is kunnen we niets tonen, behalve in demo mode. Want dan is de data lokaal beschikbaar
    if (_netwerkStatus == ConnectivityResult.none)   
      return Container(width: 0, height: 0);    

    return 
      ListTile(
        title: Text("Melding defect / incident", 
          style: TextStyle(color: MyGlideConst.frontColor)
        ),
        trailing: Icon(Icons.message, color: MyGlideConst.frontColor),
        onTap: (){MyNavigator.goToMelden(context);},
      );
  }

    // controleer of apparaat nog netwerk verbinding heeft
  void _checkConnectionState()
  {
    MyGlideDebug.info("_HoofdMenuState._checkConnectionState()");  

    Connectivity().checkConnectivity().then((result)
    {
      if (_netwerkStatus != result)
        setState(() {
          _netwerkStatus = result;
        });
    });
  }

  Widget _toonNaam(BuildContext context)
  {
    MyGlideDebug.info("_HoofdMenuState._toonNaam(context)");  

    String naam = "";

    if (serverSession.login.userInfo != null)
      naam = serverSession.login.userInfo['NAAM'] ?? "";

    return 
      Row ( 
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget> [
          Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 0)),
          Text(naam,
            style: TextStyle(
              color: Colors.white70
            )
          )
        ]
      );
  }  
}