// language packages
import 'package:flutter/material.dart';
import 'dart:async';

// language add-ons
import 'package:connectivity/connectivity.dart';

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/my_navigation.dart';
import 'package:my_glide/utils/storage.dart';

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
    super.initState();

    // check iedere seconde of er een netwerk is
    _checkConnectionState();
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
                            Storage.clear();
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
                    GUIHelper.demoOverlay(context),
                ])
              )
          )
        )
      );
  } 

  // menu item om te tonen wie er vandaag aanwezig zijn
  Widget _aanwezigMenuItem() {

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

  // menu item om vliegtuig logboeken te tonen
  Widget _vliegtuigLogboekMenuItem() {

    // als er geen netwerk is kunnen we niets tonen, behalve in demo mode. Want dan is de data lokaal beschikbaar
    if ((_netwerkStatus == ConnectivityResult.none) && (!serverSession.isDemo)) 
      return Container(width: 0, height: 0);


    if ((serverSession.login.isClubVlieger) ||        // aanmelden is alleen voor leden en donateurs
        (serverSession.login.isLocal))                // lokale gebruiker mag wel vliegtuig logboeken zien        
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

    return Container(width: 0, height: 0);
  }

  // menu item om de gebruiker voor de vliegdag aan te melden
  Widget _aanmeldenMenuItem() {

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

  Widget _toonNaam(BuildContext context)
  {
    return 
      Row ( 
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget> [
          Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 0)),
          Text(serverSession.login.userInfo['NAAM'],
            style: TextStyle(
              color: Colors.white70
            )
          )
        ]
      );
  }  
}