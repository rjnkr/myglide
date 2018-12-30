import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:async';

import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/my_navigation.dart';
import 'package:my_glide/utils/session.dart';

import 'package:my_glide/widget/my_glide_logo.dart';

class LoginScreen extends StatefulWidget {
  @override
  State createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  Animation<double> _iconAnimation;
  AnimationController _iconAnimationController;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  int _buttonState = 0;  // -1 = geen network, 0 = wacht op login, 1 = bezig, 2 = gelukt, 3 = mislukt

  String _myUsername;
  String _myPassword;
  String _url;  

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
      backgroundColor: MyGlideConst.backgroundColor,
      body: ListView(          
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
                      labelStyle: _labelStyle(),
                      hintText: "GeZC inlognaam van leden website",
                      hintStyle: _hintStyle(),
                      errorStyle: _errorStyle()
                    ),
                    style: _inputStyle(),
                    keyboardType: TextInputType.text,
                    initialValue: serverSession.lastUsername,
                    validator: this._validateUserName, 
                    onSaved: (val) => _myUsername = val,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Wachtwoord",
                      labelStyle: _labelStyle(),
                      hintText: "GeZC wachtwoord van leden website",
                      hintStyle: _hintStyle(),
                      errorStyle: _errorStyle()
                    ),
                    style: _inputStyle(),
                    obscureText: true,
                    keyboardType: TextInputType.text,
                    initialValue: serverSession.lastPassword,
                    validator: this._validatePassword,
                    onSaved: (val) => _myPassword = val,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Url",
                      labelStyle: _labelStyle(),
                      hintText: "website van de GeZC start administratie",
                      hintStyle: _hintStyle(),
                      errorStyle: _errorStyle()                      
                    ),
                    style: _inputStyle(),
                    keyboardType: TextInputType.url,
                    initialValue: serverSession.lastUrl != null ? serverSession.lastUrl : "https://startadmin.gezc.org",
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
        ]),
    );
  }

  TextStyle _hintStyle()  {
    return TextStyle(
      color: MyGlideConst.hintColorLight,
      fontSize: MyGlideConst.hintSizeSmall
    );
  }

  TextStyle _labelStyle()  {
    return TextStyle(
      color: MyGlideConst.labelColorLight,
      fontSize: MyGlideConst.labelSizeMedium
    );
  }

  TextStyle _inputStyle()  {
    return TextStyle(
      color: MyGlideConst.textInputLight,
      fontSize: MyGlideConst.textInputSizeMedium
    );
  }

  TextStyle _errorStyle()  {
    return TextStyle(
      color: MyGlideConst.errorColorLight,
      fontSize: MyGlideConst.errorSizeNormal
    );
  }

  // controleer of apparaat nog netwerk verbinding heeft
  void _checkConnectionState()
  {
    Connectivity().checkConnectivity().then((result)
    {
        setState(() {
          if (result.index == 2) // geen network
          _buttonState = -1;
          else if (_buttonState == -1)
            _buttonState = 0;
        });
    });

  }

  // Het icoontje voor de login knop
  Widget _statusIcon() {
    switch (_buttonState) {
      case -1: {  // geen network
        return Icon(Icons.airplanemode_inactive, size: 40, color: Colors.white);
      }
      case 0: { // begin state - wacht op login
        return Icon(Icons.arrow_forward, size: 40, color: Colors.white);
      }
      case 1: { // bezig
        return CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(MyGlideConst.YellowRGB));
      }
      case 2: { // gelukt
        return Icon(Icons.check, size: 40, color: Colors.white);
      }
      case 3: { // mislukt
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
      case 0: { // begin state - wacht op login
        return Colors.teal;
      }
      case 1: { // bezig
        return MyGlideConst.BlueRGB;
      }
      case 2: { // gelukt
        return Colors.green;
      }
      case 3: { // mislukt
        return Colors.red;
      }
    }
    return Colors.black;
  }

  // Controleer of gebruikersnaam (goed) ingevuld is
  String _validateUserName(String value) {
    if (value.isEmpty) 
      return "Gebruikersnaam kan niet leeg zijn";

    if (value.length < 4) 
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
      _formKey.currentState.save(); // sla input op in variablen

      setState(() {
        _buttonState = 1;     // bezig
      });

      serverSession.login(_myUsername, _myPassword, _url).then((response) {
        if (response == null) {   // null betekend dat het gelukt is
          setState(() {
            _buttonState = 2;   // login gelukt
          });
          Timer(Duration(seconds: 1), () => MyNavigator.goToHome(context));
        }
        else { // response bevat foutmelding
          setState(() {
            _buttonState = 3;   // login mislukt
          });

          // maak de knop weer beschikbaar voor de volgende poging
          Timer(Duration(seconds: 2), () =>        
            setState(() {
              _buttonState = 0;   // begin state
          }));

          // Toon foutmelding
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
      // Ingevoerde data is onvoldoende om in te loggen
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