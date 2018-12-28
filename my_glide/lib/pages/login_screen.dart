import 'package:flutter/material.dart';

import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/my_navigator.dart';
import 'package:my_glide/widget/my_glide_logo.dart';

import 'package:my_glide/utils/session.dart';
import 'dart:async';

import 'package:connectivity/connectivity.dart';


class LoginScreen extends StatefulWidget {
  Session _session;
  LoginScreen (Session session) { _session = session; }

  @override
  State createState() => LoginScreenState(_session);
}

class LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  Animation<double> _iconAnimation;
  AnimationController _iconAnimationController;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  int _buttonState = 0;  // -1 = no network, 0 = wait for login, 1 = busy, 2 = succesful, 3 = failed

  String _myUsername;
  String _myPassword;
  String _url;  
  Session _session;

  LoginScreenState (Session session) { _session = session; }

  @override
  void initState() {
    super.initState();
    _iconAnimationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 500));
    _iconAnimation = CurvedAnimation(
      parent: _iconAnimationController,
      curve: Curves.bounceOut,
    );
    _iconAnimation.addListener(() => this.setState(() {}));
    _iconAnimationController.forward();

  // check iedere seconde of er een netwerk is
    Timer.periodic(Duration(seconds: 1), (Timer t) => _checkConnectionState());   
  }

  @override
  Widget build(BuildContext context) {  
    return Scaffold(
      backgroundColor: MyGlideConst.BlueRGB,
      body: 
        Theme(
          data: ThemeData(
              inputDecorationTheme: InputDecorationTheme(
                hintStyle: TextStyle(color: MyGlideConst.YellowRGB, fontSize: 20.0),
                labelStyle:
                    TextStyle(color: MyGlideConst.YellowRGB, fontSize: 25.0),
              )),
          isMaterialAppTheme: true,
          child: ListView(          
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(2, 20, 2, 0),
            children: <Widget>[
              MyGlideLogo(),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Form(
                  key: this._formKey,
                  autovalidate: true,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Gebruiker", 
                          hintText: "GeZC inlognaam van leden website",
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 10.0,
                          ),
                          fillColor: Colors.white
                        ),
                        keyboardType: TextInputType.text,
                        initialValue: _session.lastUsername,
                        style: TextStyle(
                          color: Colors.white
                        ),
                        validator: this._validateUserName, 
                        onSaved: (val) => _myUsername = val,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Wachtwoord",
                          hintText: "GeZC wachtwoord van leden website",
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 10.0,
                          ),                          
                        ),
                        obscureText: true,
                        keyboardType: TextInputType.text,
                        initialValue: _session.lastPassword,
                        style: TextStyle(
                          color: Colors.white
                        ),
                        validator: this._validatePassword,
                        onSaved: (val) => _myPassword = val,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Url",
                          hintText: "website van de GeZC start administratie",
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 10.0,
                          ),
                          labelStyle: TextStyle(color: MyGlideConst.YellowRGB, 
                          fontSize: 20.0
                          ),
                        ),
                        keyboardType: TextInputType.url,
                        initialValue: _session.lastUrl != null ? _session.lastUrl : "https://startadmin.gezc.org",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                        ),
                        validator: this._validateUrl,
                        onSaved: (val) => _url = val,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 60.0),
                      ),
                      PhysicalModel(
                        borderRadius: BorderRadius.circular(20.0),
                        color: _buttonColor(),
                        child: MaterialButton(
                          height: 50.0,
                          minWidth: 150.0,
                          textColor: Colors.white,
                          child: _statusIcon(),
                          onPressed: _buttonState != 0 ? null:  logMeIn,    // disable button zodra inloggen gestart is
                        )
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
    );
  }

  void _checkConnectionState()
  {
    Connectivity().checkConnectivity().then((result)
    {
        setState(() {
          if (result.index == 2) // no network
          _buttonState = -1;
          else if (_buttonState == -1)
            _buttonState = 0;
        });
    });

  }

  // Het icoontje voor de login knop
  Widget _statusIcon() {
    switch (_buttonState) {
      case -1: {  // no network
        return Icon(Icons.airplanemode_inactive, size: 40, color: Colors.white);
      }
      case 0: { // init state - wait for login
        return Icon(Icons.arrow_forward, size: 40, color: Colors.white);
      }
      case 1: { // busy
        return CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(MyGlideConst.YellowRGB));
      }
      case 2: { // passed
        return Icon(Icons.check, size: 40, color: Colors.white);
      }
      case 3: { // failed
        return Icon(Icons.block, size: 40, color: Colors.white);
      }
    }
    return null;
  }

  // De kleur van de login knop
  Color _buttonColor() {
    switch (_buttonState) {
      case -1: {
        return Colors.black;
      }
      case 0: { // init state - wait for login
        return Colors.teal;
      }
      case 1: { // busy
        return MyGlideConst.BlueRGB;
      }
      case 2: { // passed
        return Colors.green;
      }
      case 3: { // failed
        return Colors.red;
      }
    }
    return Colors.black;
  }

  // Controleer of gebruikersnaam (goed) ingevuld is
  String _validateUserName(String value) {
    if (value.isEmpty) 
      return "Gebruikersnaam kan niet leeg zijn";

    if (value.length < 5) 
      return "Gebruikersnaam moet minimaal 5 tekens bevatten";
    
    return null;
  }

  // Controleer of wachtwoord (goed) ingevuld is
  String _validatePassword(String value) {
    if (value.isEmpty) 
      return "Wachtwoord moet ingevuld worden";

    if (value.length < 3) 
      return "Wachtwoord moet minimaal 3 tekens bevatten";
    
    return null;
  }

  // Controleer of Url ingevuld is en voldoet aan het formaat
  String _validateUrl(String value) {
    if (value.isEmpty) 
      return "Url moet ingevuld worden";

    if (value.length < 12) 
      return "Url formaat is onjuist";

    if (!value.contains('http'))
      return "Url moet een http(s) notatie zijn";

    RegExp regExp =  RegExp('[.]'); 
    if (regExp.allMatches(value).length < 2)
      return "Url adres is onjuist";

    return null;
  } 
  
  // Nu gaat het gebeuren, we gaan inloggen
  void logMeIn() {
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save(); // Save our form now.

      setState(() {
        _buttonState = 1;
      });

      _session.login(_myUsername, _myPassword, _url).then((response) {
        if (response == null) {
          setState(() {
            _buttonState = 2;   // login succesful
          });
          Timer(Duration(seconds: 2), () => MyNavigator.goToHome(context));
        }
        else {
          setState(() {
            _buttonState = 3;   // login failed
          });

          // make the login button available for the next run
          Timer(Duration(seconds: 2), () =>        
            setState(() {
              _buttonState = 0;   // initial state
          }));

          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Aanmelden"),
                content: Text(response),
              )
          );  
        }
      });
    }
    else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Aanmelden"),
            content: Text("Ingevoerde data onjuist"),
          )
      );
    }
  }
}