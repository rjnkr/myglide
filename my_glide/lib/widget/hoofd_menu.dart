import 'package:flutter/material.dart';
import 'package:my_glide/widget/my_glide_logo.dart';

import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/my_navigation.dart';
import 'package:my_glide/utils/session.dart';

class HoofdMenu extends StatefulWidget {
  @override
  _HoofdMenuState createState() => _HoofdMenuState();
}

class _HoofdMenuState extends State<HoofdMenu> {
  bool _expanded = false;

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
                color: MyGlideConst.BlueRGB
              ),
              child: ListView(
                children: <Widget>[
                  Container(
                    height:240.0,
                    child:
                    DrawerHeader(
                      child: MyGlideLogo(),
                      decoration: BoxDecoration(
                        color: MyGlideConst.BlueRGB
                      )
                    ),  
                  ),
                  ListTile(
                    title: Text("Aanmelden",
                      style: TextStyle(color: MyGlideConst.YellowRGB)
                    ),
                    trailing: Icon(Icons.announcement, color: MyGlideConst.YellowRGB),
                  ),
                  ListTile(
                    title: Text("Mijn logboek",
                      style: TextStyle(color: MyGlideConst.YellowRGB)
                    ),
                    trailing: Icon(Icons.assignment_ind, color: MyGlideConst.YellowRGB),
                    onTap: (){MyNavigator.goToHome(context);}
                  ),
                  ExpansionTile(
                    trailing: _expanded ? 
                    Icon(Icons.arrow_drop_up, color: MyGlideConst.YellowRGB):
                    Icon(Icons.arrow_drop_down, color: MyGlideConst.YellowRGB),
                    onExpansionChanged: (state) { setState(() { _expanded = state;} );},
                    title: Text('Vliegtuigen logboek',
                    style: TextStyle(color: MyGlideConst.YellowRGB, fontSize: 14.0, fontWeight: FontWeight.bold)
                    ),
                      children: <Widget>[
                        ListTile(
                          title: Text ('E1',
                            style: TextStyle(color: MyGlideConst.YellowRGB)), 
                        )
                    ],
                  ),
                  ListTile(
                    title: Text("Instellingen", 
                      style: TextStyle(color: MyGlideConst.YellowRGB)
                    ),
                    trailing: Icon(Icons.settings, color: MyGlideConst.YellowRGB),
                    onTap: (){MyNavigator.goToSettings(context);},
                  ),
                  Divider(color: MyGlideConst.YellowRGB, height: 6.0),
                  ListTile(
                    title: Text("Uitloggen",
                    style: TextStyle(color: MyGlideConst.YellowRGB)
                    ),
                    trailing: Icon(Icons.exit_to_app, color: MyGlideConst.YellowRGB),
                    onTap: () {
                      serverSession.logout();
                      MyNavigator.goToLogin(context);
                    },
                  ),
                  Divider(color: MyGlideConst.YellowRGB, height: 6.0),
                  ],
                ),
            )
          )
        )
    );
  } 
}