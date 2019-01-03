// language packages
import 'package:flutter/material.dart';

// language add-ons
import 'package:shared_preferences/shared_preferences.dart';

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/my_navigation.dart';
import 'package:my_glide/utils/session.dart';

// my glide data providers

// my glide own widgets
import 'package:my_glide/widget/my_glide_logo.dart';

// my glide pages

class HoofdMenu extends StatefulWidget {
  @override
  _HoofdMenuState createState() => _HoofdMenuState();
}

class _HoofdMenuState extends State<HoofdMenu> {

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
                    onTap: (){MyNavigator.goMijnLogboek(context);}
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
                        serverSession.logout();
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
    if (!_clubVlieger())
      return Container(width: 0, height: 0);

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
    if (!_clubVlieger())
      return Container(width: 0, height: 0);   

    return 
      ListTile(
        title: Text("Aanmelden vliegdag",
          style: TextStyle(color: MyGlideConst.frontColor)
        ),
        trailing: Icon(Icons.announcement, color: MyGlideConst.frontColor),
      );     
  }

  // is de ingelogde persoon een club vlieger
  bool _clubVlieger() {
    if ((serverSession.userInfo['LIDTYPE_ID'] == "601") ||       // 601 = Erelid
        (serverSession.userInfo['LIDTYPE_ID'] == "602") ||       // 602 = Lid 
        (serverSession.userInfo['LIDTYPE_ID'] == "602") ||       // 602 = Jeugdlid 
        (serverSession.userInfo['LIDTYPE_ID'] == "606"))         // 606 = Donateur
      return true;

    return false;   // geen clubvlieger
  }

}