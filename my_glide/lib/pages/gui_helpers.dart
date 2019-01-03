 // language packages
import 'package:flutter/material.dart';

// language add-ons


// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';

// my glide own widgets

// my glide pages
 
class GUIHelper {
  // Toon een enkel veld in het scherm
  static Widget showDetailsField(String titel, String info, {bool titleTop = false}) {
    return 
      Column (
        children: <Widget> [
          Row (
            children: <Widget> [
              SizedBox(
                width: 120,
                 height: 22, 
                child: Text(titel)
              ),
              SizedBox(
                height: 22,
                child: Text (titleTop ? ' ' : info, style: TextStyle(fontWeight: FontWeight.bold))
              )
            ]
          ), 
          titleTop ? 
            SizedBox(
              width: double.infinity,
              child: 
                Text(info, style: TextStyle(fontWeight: FontWeight.bold))
            )
            :
            Container(width: 0, height: 0)  //Label staat links en niet erboven
        ]
      );
  }
}