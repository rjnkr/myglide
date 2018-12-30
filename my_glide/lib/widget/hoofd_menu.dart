import 'package:flutter/material.dart';
import 'package:my_glide/widget/my_glide_logo.dart';

import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/my_navigation.dart';
import 'package:my_glide/utils/session.dart';

class HoofdMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(                                         
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
                    trailing: Icon(Icons.flight_takeoff, color: MyGlideConst.YellowRGB),
                  ),
                  ListTile(
                    title: Text("Instellingen", 
                      style: TextStyle(color: MyGlideConst.YellowRGB)
                    ),
                    trailing: Icon(Icons.settings, color: MyGlideConst.YellowRGB),
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
        );
  } 
}