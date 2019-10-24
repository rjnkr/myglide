// language packages
import 'package:flutter/material.dart';
import 'dart:async';

// language add-ons
import 'package:connectivity/connectivity.dart';

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/storage.dart';

// my glide data providers
import 'package:my_glide/data/types.dart';
import 'package:my_glide/data/aanwezig.dart';
import 'package:my_glide/data/session.dart';
import 'package:my_glide/utils/debug.dart';
import 'package:my_glide/data/vliegtuigen.dart';

// my glide own widgets

// my glide pages
import 'package:my_glide/pages/gui_helpers.dart';

// De data definitie van de lijst met checkboxes voor aanmelden met vliegtuigtype
class VliegtuigTypeSel {
  final String id;
  final String omschrijving;
  bool isChecked = false;

  VliegtuigTypeSel(this.id, this.omschrijving, this.isChecked);
}

// De data definitie van de lijst met checkboxes voor aanmelden met een prive vliegtuig
class VliegtuigSel {
  final String id;
  final String regcall;
  bool isZelfstart = false;
  bool isChecked = false;

  VliegtuigSel(this.id, this.regcall, this.isZelfstart, this.isChecked);
}

// Het aanmeldscherm
class AanmeldenScreen extends StatefulWidget {
  final String naam;
  final String id;

  AanmeldenScreen({Key key, this.naam, this.id}) : super(key: key);
  @override
  _AanmeldenScreenState createState() => _AanmeldenScreenState();
}

class _AanmeldenScreenState extends State<AanmeldenScreen> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  List<VliegtuigTypeSel> _types = List();         // Lijst met vliegtuig types die we op de club hebben
  List<VliegtuigSel> _vliegtuigenLijst = List();  // Lijst met favoriete vliegtuigen
  String _opmerking;                          // De ingevoerde opmerking
  String _startMethode = "501";               // De start methode voor een prive vliegtuig

  ConnectivityResult _netwerkStatus;          // Actuele netwerk status
  Timer _checkNetwerkTimer;                   // Timer om netwerk status te controleren
  int _selectedIndex = 0;
                       
  @override
  void initState() {
    MyGlideDebug.info("_AanmeldenScreenState.initState()");

    super.initState();

    // Indien de vliegr heeft aangegeven (via instellingen) dat hij een prive vlieger is, dan selecteren we de andere pagina
    Storage.getBool('priveVlieger', defaultValue: false).then((priveVlieger) { 
      if (priveVlieger) {
        setState(() { _selectedIndex = 1; });
      }
    });

    // Haal de favoriete prive kisten op
    Vliegtuigen.getVliegtuigen(
        alleenClubKisten: false,
        alleenFavorieten: true,
        alleKisten: false
      ).then((vtuig) { 
        setState(() {
          for (int i=0 ; i < vtuig.length ; i++) {
            _vliegtuigenLijst.add(
              VliegtuigSel(vtuig[i]["ID"], vtuig[i]["REGCALL"],  vtuig[i]["ZELFSTART"] == "true", (i==0) ? true : false)
            );
          }
        });
      });    

    // Als widget.id null is, dan wordt het ingelogde lid aangemeld en kunnen we de vorige aanmelding gebruiken
    // Als het widget.id niet null is, melden we iemand anders aan. De opgeslagen types worden dan niet gebruikt
    Storage.getString("aanmelden", defaultValue: "").then((lastCSV) // Vliegtuig types die gebruikt is bij laatste keer aanmelden
    {
      if (lastCSV == null) lastCSV = "";          // lastCSV mag niet null zijn, contains statement hieronder gaat dan fout                             
        Types.getTypeGroep(4).then((response) {
        setState(() {
          for (int i=0 ; i < response.length ; i++) {
            _types.add(
              VliegtuigTypeSel(
                response[i]['ID'],
                response[i]['OMSCHRIJVING'], 
                (lastCSV.contains(response[i]['ID']) && widget.id == null) // Als we iemand anders aanmelden, is selectie altijd false
              )
            );
          }
        });
      });
    });
    
    // check iedere seconde of er een netwerk is
    _checkNetwerkTimer = Timer.periodic(Duration(seconds: 5), (Timer t) => _checkConnectionState());   
  }  

  @override
  void dispose() {
    MyGlideDebug.info("_AanmeldenScreenState.dispose()");

    // Alleen als we onszelf hebben aangemeld, worden de vliegtuigtypes opgeslagen voor de volgende keer aanmelden
    // Als de aanmelding voor iemand anders is, dan slaan we de vliegtuigtypes niet op
    if (widget.id == null)
      _opslaanTypes();

    super.dispose();

    _checkNetwerkTimer.cancel();    // Stop de timer, anders krijgen exception omdat scherm niet meer bestaand
  }

  @override
  Widget build(BuildContext context) {
    MyGlideDebug.info("_AanmeldenScreenState.build()");

    if (_types.length == 0)  return GUIHelper.showLoading();   

    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyGlideConst.appBarBackground(),
        iconTheme: IconThemeData(color: MyGlideConst.frontColor),
        title: Text(widget.id == null ? "Aanmelden vliegdag" : "Aanmelden ${widget.naam}",
          style: MyGlideConst.appBarTextColor()
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(                          // pagina met vliegtuig types
            icon: Icon(Icons.swap_horizontal_circle),
            title: Text('Club vliegtuigen'),
          ),
          BottomNavigationBarItem(                          // pagina met prive vliegtuigen
            icon: Icon(Icons.star),
            title: Text('Private owner'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: MyGlideConst.frontColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        backgroundColor: MyGlideConst.backgroundColor,
      ),
      body: _content()                                      // De aanmeld pagina
    );
  }

  // selecteer de gewenste pagina (0=types / 1=prive vliegtuig)
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // De aanmeldpagina
  Widget _content() {
    if (_selectedIndex == 0)
      return _clubTypes();

    return _priveKisten();
  }

  Widget _clubTypes() {
    return
      Form(
          key: this._formKey,
          child: 
            Column(children: <Widget>[
              Expanded(
                child:
                  ListView(          
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: 
                          _buildCheckboxTypesList()
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                      ),
                    ]),
              ),
              PhysicalModel(
                borderRadius: BorderRadius.circular(20.0),
                color: _buttonColor(),
                child: MaterialButton(
                  height: 50.0,
                  minWidth: 200.0,
                  textColor: MyGlideConst.frontColor,
                  child: _statusIcon(),
                  onPressed: (_netwerkStatus == ConnectivityResult.none) ? null:  () => _aanmeldenOpServerTypes(context),    // disable button als er geen netwerk is
                )
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0),) // Maar niet helemaal onderin, geef een beetje ruimte
            ]),
        );
  }

  List <Widget> _buildCheckboxTypesList() {
    MyGlideDebug.info("_AanmeldenScreenState._buildCheckboxTypesList()");
    List<Widget> retVal = List<Widget>();

    for (int i=0 ; i < _types.length ; i++) {
      retVal.add (
        Row(
          children: <Widget>[
            Expanded(child: new Text(_types[i].omschrijving)),
            Checkbox(
              tristate: false,
              value: _types[i].isChecked, 
              activeColor: MyGlideConst.frontColor,
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

  // Nu gaat het gebeuren, we gaan ons aanmelden met een vliegtuig type
  void _aanmeldenOpServerTypes(BuildContext context) async {
    MyGlideDebug.info("_AanmeldenScreenState._aanmeldenoOpServer()");

    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();

      Aanwezig.aanmeldenLidVandaagTypes(_types2CSV(), _opmerking, id: widget.id).then((gelukt)  {
        if (gelukt)
        {
          serverSession.login.isAangemeld = true;
        }

        String wie = widget.naam == null ? "U bent" : "${widget.naam} is ";
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Aanmelding"),
            content: serverSession.login.isAangemeld ? Text("$wie aangemeld voor de vliegdag van vandaag") : Text("Aanmelding is mislukt")
          ));          
      });
      Navigator.pop(context);
    }
  }

  Widget _priveKisten()  {
    if (_vliegtuigenLijst.length == 0) return GUIHelper.geenData(bericht: "U heeft geen favoriet vliegtuig. Ga naar vliegtuigen en selecteer uw favoriete vliegtuig");

    return
      Form(
        key: this._formKey,
        child: 
          Column(children: <Widget>[
            Expanded(
              child:
                ListView(          
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: 
                        _buildCheckboxVliegtuigList()
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                    ),
                  ]),
            ),
            PhysicalModel(
              borderRadius: BorderRadius.circular(20.0),
              color: _buttonColor(),
              child: MaterialButton(
                height: 50.0,
                minWidth: 200.0,
                textColor: MyGlideConst.frontColor,
                child: _statusIcon(),
                onPressed: (_netwerkStatus == ConnectivityResult.none) ? null:  () => _aanmeldenOpServerVliegtuig(context),    // disable button als er geen netwerk is
              )
            ),
            Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0),) // Maar niet helemaal onderin, geef een beetje ruimte
          ]),
      );
  }

  List <Widget> _buildCheckboxVliegtuigList() {
    MyGlideDebug.info("_AanmeldenScreenState._buildCheckboxVliegtuigList()");
    List<Widget> retVal = List<Widget>();

    for (int i=0 ; i < _vliegtuigenLijst.length ; i++) {
      retVal.add (
        Row(
          children: <Widget>[
            Expanded(child: new Text(_vliegtuigenLijst[i].regcall)),
            Checkbox(
              tristate: false,
              value: _vliegtuigenLijst[i].isChecked, 
              activeColor: MyGlideConst.frontColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (bool value) {
                setState(() {
                  for (int v=0 ; v < _vliegtuigenLijst.length ; v++) 
                    _vliegtuigenLijst[v].isChecked = false;

                  _vliegtuigenLijst[i].isChecked = value;
                }
              );   
            })
          ],
        )
      ); 
    }

    retVal.add(Divider());

    retVal.add(
      Row(
        children: <Widget>[
          Expanded(child: new Text("Lierstart")),
          Checkbox(
            tristate: false,
            value: _startMethode == "550",
            activeColor: MyGlideConst.frontColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: (bool value) {
              setState(() {
                _startMethode = "550";
              }
            );   
          })
        ],
      )
    );

    retVal.add(
      Row(
        children: <Widget>[
          Expanded(child: new Text("Sleepstart")),
          Checkbox(
            tristate: false,
            value: _startMethode == "501",
            activeColor: MyGlideConst.frontColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: (bool value) {
              setState(() {
                _startMethode = "501";
              }
            );   
          })
        ],
      )
    );    

    for (int i=0 ; i < _vliegtuigenLijst.length ; i++) {
      if ((_vliegtuigenLijst[i].isChecked) && (_vliegtuigenLijst[i].isZelfstart)) {
        retVal.add(
          Row(
            children: <Widget>[
              Expanded(child: new Text("Zelfstart")),
              Checkbox(
                tristate: false,
                value: _startMethode == "506",
                activeColor: MyGlideConst.frontColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (bool value) {
                  setState(() {
                    _startMethode = "506";
                  }
                );   
              })
            ],
          )
        );    
        break;
      }
    }
    retVal.add(Divider());

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

  // Nu gaat het gebeuren, we gaan ons aanmelden met een vliegtuig type
  void _aanmeldenOpServerVliegtuig(BuildContext context) async {
    MyGlideDebug.info("_AanmeldenScreenState._aanmeldenoOpServer()");

    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();

      for (int i=0 ; i < _vliegtuigenLijst.length ; i++) {
        if (_vliegtuigenLijst[i].isChecked) {        
          Aanwezig.aanmeldenLidVandaagVliegtuig(_vliegtuigenLijst[i].id, _opmerking, _startMethode, id: widget.id).then((gelukt)  {
            if (gelukt)
            {
              serverSession.login.isAangemeld = true;
            }

            String wie = widget.naam == null ? "U bent" : "${widget.naam} is ";
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Aanmelding"),
                content: serverSession.login.isAangemeld ? Text("$wie aangemeld voor de vliegdag van vandaag") : Text("Aanmelding is mislukt")
              )); 
          });
          Navigator.pop(context);
          break;
        }
      }
    }
  }


  // controleer of apparaat nog netwerk verbinding heeft
  void _checkConnectionState()
  {
    MyGlideDebug.info("_AanmeldenScreenState._checkConnectionState()");
    Connectivity().checkConnectivity().then((result)
    {
      if (result != _netwerkStatus) { // alleen setSate aanroepen als status anders is
        setState(() {
          _netwerkStatus = result;
        });
      }
    });
  }

  // Het icoontje voor de login knop
  Widget _statusIcon() {
    MyGlideDebug.info("_AanmeldenScreenState._statusIcon()");
    if (_netwerkStatus == ConnectivityResult.none)
      return Icon(Icons.cloud_off, size: 40, color: MyGlideConst.frontColor);

    return Icon(Icons.arrow_forward, size: 40, color: MyGlideConst.frontColor);
  }

  // De kleur van de login knop
  Color _buttonColor() {
    MyGlideDebug.info("_AanmeldenScreenState._buttonColor()");
    if (_netwerkStatus == ConnectivityResult.none)  
      return Colors.black;
    
    return MyGlideConst.backgroundColor;
  }  

  String _opslaanTypes()
  {
    String csv = _types2CSV();
    Storage.setString("aanmelden", csv);
    
    return csv;
  }

  String _types2CSV()
  {
      String csv = "";
      for (int i=0 ; i < _types.length ; i++) {
        if (_types[i].isChecked) {
          if (csv != "")
            csv += ",";
          
          csv += _types[i].id;
        }
      }
      
      return csv;
  }
}
