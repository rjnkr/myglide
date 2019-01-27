 // language packages
import 'package:flutter/material.dart';

// language add-ons

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';

// my glide data providers
import 'package:my_glide/data/session.dart';

// my glide own widgets

// my glide pages
import 'package:my_glide/widget/my_glide_logo.dart';

 
enum ConfirmAction { JA, NEE }
enum DemoGebruiker { DDWV, LID, STARTLEIDER, INSTRUCTEUR }

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

  // Popup window JA/NEE
  static Future<ConfirmAction> confirmDialog(BuildContext context, String title, String message) async {
    return showDialog<ConfirmAction>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title ?? ' '),
          content: Text(message ?? ' '),
          actions: <Widget>[
            FlatButton(
              child: const Text('Nee'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.NEE);
              },
            ),
            FlatButton(
              child: const Text('Ja'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.JA);
              },
            )
          ],
        );
      },
    );
  }

  // Popup windows met bericht
  static Future<void> ackAlert(BuildContext context, String title, String message) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title ?? ' '),
          content: Text(message ?? ' '),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Widget demoOverlay(BuildContext context)
  {
    if (serverSession.isDemo) 
    {
      return 
        Container(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
          height: 60,
          width: 60,
          child: Image.asset('assets/images/demo_marker.png')
        ); 
    }
    
    return Container(width: 0, height: 0);
  }

  // Welke permissies krijgt de demo gebruiker
  static Future<DemoGebruiker> demoDialog(BuildContext context) async {
    return await showDialog<DemoGebruiker>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Rol voor vandaag'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, DemoGebruiker.DDWV);
                },
                child: const Text('> DDWV\'er'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, DemoGebruiker.LID);
                },
                child: const Text('> Lid'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, DemoGebruiker.STARTLEIDER);
                },
                child: const Text('> Startleider'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, DemoGebruiker.INSTRUCTEUR);
                },
                child: const Text('> Instructeur'),
              )
            ],
          );
        }
      );
    }

    static bool isTablet(BuildContext context) {
      return (MediaQuery.of(context).size.shortestSide > 600);
    }
}