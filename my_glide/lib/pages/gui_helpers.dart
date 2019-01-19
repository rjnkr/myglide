 // language packages
import 'package:flutter/material.dart';

// language add-ons

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';

// my glide own widgets

// my glide pages
import 'package:my_glide/widget/my_glide_logo.dart';
 
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

  static Widget showLoading()
  {
      return Scaffold(
          appBar: AppBar(
            backgroundColor: MyGlideConst.appBarBackground(),
            iconTheme: IconThemeData(color: MyGlideConst.frontColor),
            title: Text(
              " ",
              style: MyGlideConst.appBarTextColor()
            )
          ),
          body: Center(
          child: Container(
            decoration: BoxDecoration(color: MyGlideConst.showLoadingBackground),
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: MyGlideLogo(showLabel: false, image: "assets/images/gezc_geel-blauw.png", size: 220)
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                ),
                Text(
                  "Even wachten ...",
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: MyGlideConst.backgroundColor
                    ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(MyGlideConst.frontColor)),
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