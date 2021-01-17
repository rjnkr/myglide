
// language packages
import 'package:flutter/material.dart';

// language add-ons
import 'package:connectivity/connectivity.dart';

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/debug.dart';

// my glide data providers
import 'package:my_glide/data/session.dart';

// my glide own widgets

// my glide pages

class LedenLijstFilterScreen extends StatefulWidget {
  @override
  _LedenLijstFilterScreenState createState() => _LedenLijstFilterScreenState();
}

class _LedenLijstFilterScreenState extends State<LedenLijstFilterScreen> {
  ConnectivityResult _netwerkStatus;          // Actuele netwerk status
  
  bool _lierist = false;
  bool _instructeur = false;
  bool _startleider = false;
  bool _aanwezig = false;

  @override
  void initState() {
    MyGlideDebug.info("_LedenLijstFilterScreenState.initState()");
    Connectivity().checkConnectivity().then((result)
    {
      setState(() {
        _netwerkStatus = result;
      });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    double hoogte = 185.0;

    MyGlideDebug.info("_SelecteerTelefoonState.build(context)");

    return AlertDialog(
      title: Text("Kies filter"),
      contentPadding: EdgeInsets.all(0),
      content: Container(
        height: hoogte,
        width: 300,
        child: ListView(
          children: <Widget>[
            _aanwezigFilter(),
            CheckboxListTile(
              title: Text("Lierist"),
              dense: true,
              activeColor: MyGlideConst.frontColor,
              value: _lierist,
              secondary: Image.asset("assets/images/chute.png", color: Color.fromRGBO(140, 140, 140, 1), height: 27),
              onChanged: (bool value) {
                setState(() {
                  _lierist = value;
                });
              }                
            ),
            CheckboxListTile(
              title: Text("Startleider"),
              dense: true,
              activeColor: MyGlideConst.frontColor,
              value: _startleider,
              secondary: Icon(Icons.assignment),
              onChanged: (bool value) {
                setState(() {
                  _startleider = value;
                });
              }
            ),
            CheckboxListTile(
              title: Text("Instructeur"),
              dense: true,
              activeColor: MyGlideConst.frontColor,
              value: _instructeur,
              secondary: Icon(Icons.person),
              onChanged: (bool value) {
                setState(() {
                  _instructeur = value;
                });
              }
            ),
          ]
        ), 
      ),

      actions: <Widget>[
        FlatButton(
          child: const Text('Annuleren'),
          onPressed: () => Navigator.of(context).pop(null),
        ),
        FlatButton(
          child: const Text('Toepassen'),
          onPressed: () { 
            Navigator.of(context).pop("$_aanwezig,$_lierist,$_instructeur,$_startleider");
          }
        )
      ],
    ); 
  }

  Widget _aanwezigFilter() {

    if (_netwerkStatus == ConnectivityResult.none)
        return Container();

    if ((serverSession.login.isBeheerder) || (serverSession.login.isBeheerderDDWV) ||
        (serverSession.login.isInstructeur) || (serverSession.login.isStartleider) || (serverSession.login.isLocal)) {
      return 
        CheckboxListTile(
          title: Text("Alleen aanwezige leden"),
          dense: true,
          activeColor: MyGlideConst.frontColor,
          value: _aanwezig,
          secondary: Icon(Icons.group),
          onChanged: (bool value) {
            setState(() {
              _aanwezig = value;
            });
          }                
        );
    }

    return Container();
  }
}