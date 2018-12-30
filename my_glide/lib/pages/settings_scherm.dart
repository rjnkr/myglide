import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:async';

import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/my_navigation.dart';
import 'package:my_glide/utils/session.dart';
import 'package:my_glide/widget/hoofd_menu.dart';
import 'package:numberpicker/numberpicker.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  int _aantalVluchtenInLogboek=5;

  @override
  void initState() {
    super.initState();  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyGlideConst.appBarBackground(),
        iconTheme: IconThemeData(color: MyGlideConst.frontColor),
        title: Text('Instellingen',
          style: MyGlideConst.appBarTextColor(),
        )
      ),
      drawer: HoofdMenu(),
      body: ListView(          
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(2, 20, 2, 0),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Form(
              key: this._formKey,
              autovalidate: true,
              child: Column(
                children: <Widget> [
                  Padding(
                    padding: const EdgeInsets.only(top: 60.0),
                  ),
                  Column(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.topLeft,
                        child:
                        Text('Aantal getoonde vluchten in logboek',),
                      ),
                      Container(
                        width: 200,
                        height: 75,
                        color: Colors.pink,
                        alignment: Alignment.centerRight,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Gebruiker", 
                              hintText: "GeZC inlognaam van leden website",
                              hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 10.0, 
                              ),
                              fillColor: Colors.black
                            ),
                            keyboardType: TextInputType.text,
                            initialValue: serverSession.lastUsername,
                            style: TextStyle(
                              color: Colors.black
                            ),
                          )
                      )],
                    ),
                  PhysicalModel(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.pink,
                    child: MaterialButton(
                      height: 50.0,
                      minWidth: 150.0,
                      textColor: Colors.white,
                      child: Icon(Icons.aspect_ratio),
                    //  onPressed: _buttonState != 0 ? null:  logMeIn,    // disable button zodra inloggen gestart is
                    )
                  ),
                ],
              ),
            ),
          )
        ]
      )
    );
  }  
}