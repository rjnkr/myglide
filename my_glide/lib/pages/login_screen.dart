import 'package:flutter/material.dart';

import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/my_navigator.dart';
import 'package:my_glide/utils/my_glide_logo.dart';

class LoginScreen extends StatefulWidget {
  @override
  State createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  Animation<double> _iconAnimation;
  AnimationController _iconAnimationController;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

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
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: MyGlideConst.BlueRGB,
      body: Stack(fit: StackFit.expand, children: <Widget>[
        Theme(
          data: ThemeData(
              inputDecorationTheme: InputDecorationTheme(
                hintStyle: TextStyle(color: MyGlideConst.YellowRGB, fontSize: 20.0),
                labelStyle:
                    TextStyle(color: MyGlideConst.YellowRGB, fontSize: 25.0),
              )),
          isMaterialAppTheme: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              MyGlideLogo(),
              Container(
                padding: const EdgeInsets.all(40.0),
                child: Form(
                  key: this._formKey,
                  autovalidate: true,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: MyGlideConst.lblUserName, 
                          hintText: MyGlideConst.hintUserName,
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 10.0,
                          ),
                          fillColor: Colors.white
                        ),
                        keyboardType: TextInputType.text,
                        style: TextStyle(
                          color: Colors.white
                        ),
                        validator: this._validateUserName, 
                        onSaved: (val) => _myUsername = val,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: MyGlideConst.lblPassword,
                          hintText: MyGlideConst.hintPassword,
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 10.0,
                          ),                          
                        ),
                        obscureText: true,
                        keyboardType: TextInputType.text,
                        style: TextStyle(
                          color: Colors.white
                        ),
                        validator: this._validatePassword,
                        onSaved: (val) => _myPassword = val,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: MyGlideConst.lblUrl,
                          hintText: MyGlideConst.hintUrl,
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 10.0,
                          ),
                          labelStyle: TextStyle(color: MyGlideConst.YellowRGB, 
                          fontSize: 20.0
                          ),
                        ),
                        keyboardType: TextInputType.url,
                        initialValue: "https://startadmin.gezc.org",
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
                      MaterialButton(
                        height: 50.0,
                        minWidth: 150.0,
                        color: Colors.green,
                        splashColor: Colors.teal,
                        textColor: Colors.white,
                        child: Icon(Icons.arrow_forward, color: Colors.white),
                        onPressed: () => logMeIn(),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ]),
    );
  }

  // Controleer of gebruikersnaam (goed) ingevuld is
  String _validateUserName(String value) {
    if (value.isEmpty) 
      return MyGlideConst.errEmptyUser;

    if (value.length < 5) 
      return MyGlideConst.errUserLen;
    
    return null;
  }

  // Controleer of wachtwoord (goed) ingevuld is
  String _validatePassword(String value) {
    if (value.isEmpty) 
      return MyGlideConst.errEmptyPassword;

    if (value.length < 3) 
      return MyGlideConst.errPasswordLen;
    
    return null;
  }

  // Controleer of Url ingevuld is en voldoet aan het formaat
  String _validateUrl(String value) {
    if (value.isEmpty) 
      return MyGlideConst.errEmptyUrl;

    if (value.length < 3) 
      return MyGlideConst.errUrlIncorrect;
    
    return null;
  } 
  
  // Nu gaat het gebeuren, we gaan inloggen
  void logMeIn() {
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save(); // Save our form now.

      print('Username: ${_myUsername}');
      print('Password: ${_myPassword}');
    }
    else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(MyGlideConst.dlgTitleLogin),
            content: Text(MyGlideConst.dlgMsgLogin),
          )
      );
    }
  }
}