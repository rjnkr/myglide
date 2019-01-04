// language packages
import 'package:flutter/material.dart';
import 'dart:async';

// language add-ons
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/session.dart';

// my glide data providers
import 'package:my_glide/data/vliegtuigen.dart';
import 'package:my_glide/data/aanwezig.dart';

// my glide own widgets

// my glide pages

class VliegtuigTypeSel {
  final String id;
  final String omschrijving;
  bool isChecked = false;

  VliegtuigTypeSel(this.id, this.omschrijving, this.isChecked);
}

class AanmeldenScreen extends StatefulWidget {
  @override
  _AanmeldenScreenState createState() => _AanmeldenScreenState();
}

class _AanmeldenScreenState extends State<AanmeldenScreen> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  List<VliegtuigTypeSel> _types = List();     // Lijst met vliegtuig types die we op de club hebben
  String _opmerking;                          // De ingevoerde opmerking

  ConnectivityResult _netwerkStatus;          // Actuele netwerk status
  Timer _checkNetwerkTimer;                   // Timer om netwerk status te controleren
                       
  @override
  void initState() {
    super.initState();
      SharedPreferences.getInstance().then((prefs)
      {
         String lastCSV = prefs.getString("aanmelden") ?? "";   // Vliegtuig types die gebruikt is bij laatste keer aanmelden

          Vliegtuigen.getClubKisten().then((response) {
          setState(() {
            for (int i=0 ; i < response['types'].length ; i++) {
              _types.add(
                VliegtuigTypeSel(response['types'][i]['TYPE_ID'],
                                 response['types'][i]['VLIEGTUIGTYPE'], 
                                 lastCSV.contains(response['types'][i]['TYPE_ID'])));
            }
          });
      });

      // check iedere seconde of er een netwerk is
      _checkNetwerkTimer = Timer.periodic(Duration(seconds: 1), (Timer t) => _checkConnectionState());   
    });
  }  

  @override
  void dispose() {
    super.dispose();

    _checkNetwerkTimer.cancel();    // Stop de timer, anders krijgen exception omdat scherm niet meer bestaand
  }

  @override
  Widget build(BuildContext context) {
    if (_types.length == 0)
      return Container(width: 10, height: 10,);   

    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyGlideConst.appBarBackground(),
        iconTheme: IconThemeData(color: MyGlideConst.frontColor),
        title: Text(
          "Aanmelden vliegdag",
          style: MyGlideConst.appBarTextColor()
        ),
      ),
      body: Form(
        key: this._formKey,
        
        child: ListView(          
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: 
                _buildCheckboxList()
            ),
            Padding(
              padding: const EdgeInsets.only(top: 100.0),
            ),
            PhysicalModel(
              borderRadius: BorderRadius.circular(20.0),
              color: _buttonColor(),
              child: MaterialButton(
                height: 50.0,
                minWidth: 150.0,
                textColor: Colors.white,
                child: _statusIcon(),
                onPressed: (_netwerkStatus == ConnectivityResult.none) ? null:  () => _meldMijAan(context),    // disable button als er geen netwerk is
              )
            )
          ]),
      )
    );
  }

  List <Widget> _buildCheckboxList() {
    List<Widget> retVal = List<Widget>();

    for (int i=0 ; i < _types.length ; i++) {
      retVal.add (
        Row(
          children: <Widget>[
            new Expanded(child: new Text(_types[i].omschrijving)),
            new Checkbox(
                tristate: false,
                value: _types[i].isChecked, 
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (bool value) {
                  setState(() {
                    _types[i].isChecked = value;
                  }
                );
            })
          ],
        )
      ); 
    }

    retVal.add(
      TextFormField(
        decoration: InputDecoration(
          labelText: "Opmerking",
        ),
        keyboardType: TextInputType.text,
        onSaved: (val) => _opmerking = val.trim(),
      ) 
    );
    return retVal;
  }

  // Nu gaat het gebeuren, we gaan inloggen
  void _meldMijAan(BuildContext context) {
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();

      String csv = "";
      for (int i=0 ; i < _types.length ; i++) {
        if (_types[i].isChecked) {
          if (csv != "")
            csv += ",";
          
          csv += _types[i].id;
        }
      }
      SharedPreferences.getInstance().then((prefs)
      {
        prefs.setString("aanmelden", csv);
      });
      Aanwezig.aanmeldenLidVandaag(csv);
      serverSession.isAangemeld = true;
      Navigator.pop(context);
    }
  }

  // controleer of apparaat nog netwerk verbinding heeft
  void _checkConnectionState()
  {
    Connectivity().checkConnectivity().then((result)
    {
      setState(() {
        _netwerkStatus = result;
      });
    });
  }

  // Het icoontje voor de login knop
  Widget _statusIcon() {
    if (_netwerkStatus == ConnectivityResult.none)
      return Icon(Icons.cloud_off, size: 40, color: Colors.white);

    return Icon(Icons.arrow_forward, size: 40, color: Colors.white);
  }

  // De kleur van de login knop
  Color _buttonColor() {
    if (_netwerkStatus == ConnectivityResult.none)  
      return Colors.black;
    
    return Colors.teal;
  }  
}
