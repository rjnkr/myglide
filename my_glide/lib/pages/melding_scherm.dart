// language packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';

// language add-ons
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:my_glide/pages/gui_helpers.dart';
import 'package:intl/intl.dart';

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';

// my glide data providers
import 'package:my_glide/data/session.dart';
import 'package:my_glide/data/myGlideData.dart';
import 'package:my_glide/utils/debug.dart';

// my glide own widgets

// my glide pages

class MeldingScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    MyGlideDebug.info("MeldingScreen.build(context)");

    return 
      Scaffold(
      appBar: AppBar(
        backgroundColor: MyGlideConst.appBarBackground(),
        iconTheme: IconThemeData(color: MyGlideConst.frontColor),
        title: Text('Melding',
          style: MyGlideConst.appBarTextColor(),
        )
      ),
      body:
        Center(
          child: 
            Column(children: <Widget>[
              _rollendMelding(context),         // button om rollend melding te maken
              _vliegendMelding(context),        // button om vliegend melding te maken
              Expanded(child: Container()),
              Container (
                padding: EdgeInsets.fromLTRB(20, 60, 20, 0),
                child:
                  PhysicalModel(                                      
                    borderRadius: BorderRadius.circular(20.0),
                    color: MyGlideConst.frontColor,
                    child: MaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return IncidentMeldingScreen(); 
                            },
                          ),
                        );  
                      },
                      height: 50.0,
                      minWidth: 120.0,
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                            child: Icon(Icons.report, color: MyGlideConst.backgroundColor)),
            
                          Text("Incident melding", style: TextStyle(color: MyGlideConst.backgroundColor))
                        ]
                      )
                    )
                  )
              ),
              Container(height: 30)     // beetje ruimte aan de onderkant
              ]) 
        )
      );
  }

  // knop om rollend knop te maken
  Widget _rollendMelding(BuildContext context) {
    MyGlideDebug.info("MeldingScreen._rollendMelding(context)");

    if (!serverSession.login.isClubVlieger)            // meldingen is alleen voor leden en donateurs
        return Container(width: 0, height: 0);    

    return 
      Container (
        padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: 
          PhysicalModel(                                      
            borderRadius: BorderRadius.circular(20.0),
            color: MyGlideConst.backgroundColor,
            child: MaterialButton(
              onPressed: () {
                Navigator.pop(context);
                _sendEmail(context, MyGlideConst.emailCommRollend);
              },
              height: 50.0,
              minWidth: 120.0,
              child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                    child: Icon(Icons.rv_hookup, color: MyGlideConst.frontColor)),
    
                  Text("Melding rollend", style: TextStyle(color: MyGlideConst.frontColor))
                ]
              )   
            )
          ),
      );
  }

  // knop om button te maken voor vliegend
  Widget _vliegendMelding(BuildContext context) {
    MyGlideDebug.info("MeldingScreen._vliegendMelding(context)");

    if (!serverSession.login.isClubVlieger)            // meldingen is alleen voor leden en donateurs
        return Container(width: 0, height: 0);  

    return
      Container (
        padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: 
          PhysicalModel(                                      
            borderRadius: BorderRadius.circular(20.0),
            color: MyGlideConst.backgroundColor,
            child: MaterialButton(
              onPressed: () {
                Navigator.pop(context);
                _sendEmail(context, MyGlideConst.emailCommVliegend);
              },
              height: 50.0,
              minWidth: 120.0,
              child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                    child: Icon(Icons.airplanemode_active, color: MyGlideConst.frontColor)),
    
                  Text("Melding vliegend", style: TextStyle(color: MyGlideConst.frontColor))
                ]
              )   
            )
          ),
      );       
  }

  // email versturen naar een commisaris
  // we maken alvast een template met ietswat tekst
  void _sendEmail(BuildContext context, String emailAdres) async {
    MyGlideDebug.info("MeldingScreen._sendEmail($emailAdres)");

    if (serverSession.isDemo)
    {
      GUIHelper.ackAlert(context, "Demo", "Deze functie is niet in demo mode beschikbaar");
      return;
    }
      
    if (serverSession.login.userInfo == null)       // we weten niet wie ingelogd is
      return ;

    String emailBody = "Beste commissaris,<br><br><< hier uw melding en voeg foto toe >> <br><br>Met vriendelijke groet,<br><br>";
    emailBody += "${serverSession.login.userInfo['NAAM']}<br><br><em>Deze mail is verstuurd vanuit de GeZC MyGlide app</em>";

    final MailOptions mailOptions = MailOptions(
      subject: "Melding schade of defect",
      body: emailBody,
      recipients: [emailAdres],
      isHTML: true,
    );
    await FlutterMailer.send(mailOptions);
  }   
}

class IncidentMeldingScreen extends StatefulWidget {
  @override
  _IncidentMeldingScreenState createState() => _IncidentMeldingScreenState();
}

class _IncidentMeldingScreenState extends State<IncidentMeldingScreen> {
  int _schermNummer;

  // scherm 1
  bool _voorvalTerPlaatseBesproken;
  TextEditingController _toelichtingTerPlaatse = TextEditingController();

  TextEditingController nameController = TextEditingController();
  // scherm 2
  DateTime _datumVoorval;
  TextEditingController _tijdVoorval = TextEditingController();// = DateFormat('kk:00').format(DateTime.now());
  TextEditingController _locatieVoorval = TextEditingController();
  TextEditingController _betrokkenen = TextEditingController();
  TextEditingController _handeling = TextEditingController();
  TextEditingController _meteo = TextEditingController();

  // scherm 3
  TextEditingController _omschrijving = TextEditingController();

  // scherm 4
  TextEditingController _mitigatie = TextEditingController();

  // scherm 5
  bool _anoniemVerzenden;

  // scherm 6 (samenvatting)
  String _htmlPagina;

  @override
  void initState() {
    MyGlideDebug.info("IncidentMeldingScreenState.initState()");

    setState(() {
      _schermNummer = 0;
      _datumVoorval = DateTime.now();
      _tijdVoorval.text = DateFormat('kk:00').format(DateTime.now());
    });
    rootBundle.loadString("assets/incident formulier.html").then((html) => _htmlPagina = html); 
    super.initState();
  }

  @override
  dispose() {
    MyGlideDebug.info("IncidentMeldingScreenState.dispose()");

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MyGlideDebug.info("IncidentMeldingScreenState.build(context)");
    
     // Voor mobiele telefoons onderstenen we alleen portrait mode
    if (GUIHelper.isTablet(context) == false) {
      if (GUIHelper.isLandscape(context)) {
        MyGlideDebug.trace("ncidentMeldingScreenState.build: isLandscape");
        return GUIHelper.moetInPortraitMode();
      }
      
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitDown,
        DeviceOrientation.portraitUp,
      ]);
    }
    
    return
      Scaffold(
        appBar: AppBar(
          backgroundColor: MyGlideConst.appBarBackground(),
          iconTheme: IconThemeData(color: MyGlideConst.frontColor),
          title: Text('Incident Melding',
            style: MyGlideConst.appBarTextColor(),
          )
        ),
        body:
          Container( 
            padding: EdgeInsets.all(20),
            child: _wizard(context)
          )
        );
  }

  Widget _wizard(BuildContext context) {
    MyGlideDebug.info("IncidentMeldingScreenState._wizard(context)");
    MyGlideDebug.trace("IncidentMeldingScreenState._wizard: _schermNummer = $_schermNummer");

    switch (_schermNummer)
    {
      case 0: return _scherm0(context); break;
      case 1: return _scherm1(context); break;
      case 2: return _scherm2(context); break;
      case 3: return _scherm3(context); break;
      case 4: return _scherm4(context); break;
      case 5: return _scherm5(context); break;
      case 6: return _scherm6(context); break;
    }
    return Container(child: Text("oeps...."));
  }
  
  Widget _scherm0(BuildContext context) { 
    MyGlideDebug.info("IncidentMeldingScreenState._scherm0(context)");

    return
      Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.info, color: MyGlideConst.frontColor),
                  Text(" Alle velden moeten ingevoerd worden.")
                ])
            )
          ),
          _vorigeVolgende(false, true)
        ]
      );
  }

  Widget _scherm1(BuildContext context) {    
    MyGlideDebug.info("IncidentMeldingScreenState._scherm1(context)");

    return
      Column(
        children: <Widget>[
        Row(
          children: <Widget>[
            Text("Voorval ter plekke besproken?"),
            Checkbox(
              activeColor: MyGlideConst.frontColor,
              tristate: false,
              value: _voorvalTerPlaatseBesproken ?? false,
              onChanged: (bool value) 
              {
                setState(() {
                  _voorvalTerPlaatseBesproken = value;
                });
              }
            ),
          ]),
         
        Expanded(
          child:
            GUIHelper.scrollableTextInput(
              context, 
              controller: _toelichtingTerPlaatse,
              onTextChanged: (newText) => setState(() {}),        // Als tekst is ingevoerd moet de button "Volgende" geactiveerd worden
              labelText: "Toelichting",
              hintText:  (_voorvalTerPlaatseBesproken == true) ? "Resultaat van de bespreking." : "Wat is de reden dat het niet besproken is?",
              maxLines: null)
          ),
         _vorigeVolgende(false, true)
      ]);
  }

  Widget _scherm2(BuildContext context) {
    MyGlideDebug.info("IncidentMeldingScreenState._scherm2(context)");

    double ruimte = 10;
    TextEditingController datum = TextEditingController();

    datum.text = DateFormat('dd-MM-yyyy').format(_datumVoorval);

    return
      Column(children: <Widget>[
        Expanded(
          child: 
            ListView(children: <Widget>[
              Row(children: <Widget>[
                Flexible(
                  child: GUIHelper.textInput(
                    context,
                    enabled: false,         // alleen aanpassen via de datum picker
                    controller: datum,
                    labelText: "Datum voorval", 
                    hintText: "dag-maand-jaar",
                    maxLines: 1,
                  ),
                ),
                Container (width: 5),     // Geef ruimte in tussen textinvoer en knop
                Column(
                  children: <Widget>[
                    Container(height: 5), // Geef ruimte boven de button
                    Container(            // Maak een knop
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: MyGlideConst.backgroundColor,
                      ), 
                      child:  GestureDetector(
                        onTap: () =>
                          showDatePicker(
                            context: context,
                            initialDate: _datumVoorval,
                            firstDate: DateTime.now().subtract(Duration(days: 30)),
                            lastDate: DateTime.now()
                          ).then((datum) 
                            {
                              setState(() {
                                _datumVoorval = datum;
                              });
                            }
                        ),
                        child:
                          Container (  
                            height: 40,
                            width: 40,           
                            child: Icon(Icons.today, color: MyGlideConst.frontColor),
                          )
                        )
                      ),
                    ])
                ]),
              Container(height: ruimte),     // Geef ruimte
      
              Row(children: <Widget>[
                Flexible(
                  child: GUIHelper.textInput(
                    context,
                    enabled: false,         // alleen aanpassen via de tijd picker
                    controller: _tijdVoorval,
                    labelText: "Tijdstip voorval", 
                    hintText: "uren:minuten",
                    maxLines: 1,
                  ),  
                ),
                Container (width: 5),     // Geef ruimte in tussen textinvoer en knop
                Column(
                  children: <Widget>[
                    Container(height: 5), // Geef ruimte boven de button
                    Container(            // Maak een knop
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: MyGlideConst.backgroundColor,
                      ), 
                      child:  GestureDetector(
                        onTap: () => GUIHelper.tijdPicker(context, 
                          tijd: _tijdVoorval.text,
                          onConfirm: (val)
                          {
                            setState(() {
                              _tijdVoorval.text = val;
                            });
                          }
                        ),
                        child:  // child of GestureDetector
                          Container (  
                            height: 40,
                            width: 40,           
                            child: Icon(Icons.access_time, color: MyGlideConst.frontColor),
                          )
                        )
                      ) 
                    ])
                ]),
              Container(height: ruimte),     // Geef ruimte
              
              GUIHelper.textInput(
                context,
                controller: _locatieVoorval,
                onTextChanged: (newText) => setState(() {}),        // Als tekst is ingevoerd moet de button "Volgende" geactiveerd worden
                labelText: "Locatie voorval", 
                hintText: "Bijv EHTL, 22R",
                maxLines: 1
              ),
              Container(height: ruimte),     // Geef ruimte
              
              GUIHelper.textInput(
                context,
                controller: _betrokkenen,
                onTextChanged: (newText) => setState(() {}),        // Als tekst is ingevoerd moet de button "Volgende" geactiveerd worden
                labelText: "Betrokkene(n)", 
                hintText: "Toestel / Persoon / Voertuig",
                maxLines: 1
              ),
              Container(height: ruimte),     // Geef ruimte
              
              GUIHelper.textInput(
                context,
                controller: _handeling,
                onTextChanged: (newText) => setState(() {}),        // Als tekst is ingevoerd moet de button "Volgende" geactiveerd worden
                labelText: "Uitgevoerde handeling", 
                hintText: "Vluchtfase, handeling, maneuvre",
                maxLines: 1
              ),
              Container(height: ruimte),     // Geef ruimte

              GUIHelper.textInput(
                context,
                controller: _meteo,
                onTextChanged: (newText) => setState(() {}),        // Als tekst is ingevoerd moet de button "Volgende" geactiveerd worden
                labelText: "Meteo condities", 
                hintText: "Weersomstandigheden",
                maxLines: 1
              ),                           
            ]),
        ),
        _vorigeVolgende(true, true)
      ]);  
  }

  Widget _scherm3(BuildContext context) { 
    MyGlideDebug.info("IncidentMeldingScreenState._scherm3(context)");

    return
      Column(
        children: <Widget>[    
          Expanded(
            child:
              GUIHelper.scrollableTextInput(
                context, 
                controller: _omschrijving,
                onTextChanged: (newText) => setState(() {}),        // Als tekst is ingevoerd moet de button "Volgende" geactiveerd worden
                labelText: "Omschrijving voorval",
                hintText:  "Korte omschrijving, oorzaak, gevolg, factoren",
                maxLines: null,
              ),
          ),
          _vorigeVolgende(true, true)
      ]);
  }
  

  Widget _scherm4(BuildContext context) {  
    MyGlideDebug.info("IncidentMeldingScreenState._scherm4(context)");  

    return
      Column(
        children: <Widget>[    
          Expanded(
            child:
              GUIHelper.scrollableTextInput(
                context, 
                controller: _mitigatie,
                onTextChanged: (newText) => setState(() {}),        // Als tekst is ingevoerd moet de button "Volgende" geactiveerd worden
                labelText: "Mogelijke mitigatie",
                hintText:  "Voorstel tot preventieve maatregel",
                maxLines: null,
              ),
          ),
          _vorigeVolgende(true, true)
      ]);
  }

  Widget _scherm5(BuildContext context) {    
    MyGlideDebug.info("IncidentMeldingScreenState._scherm5(context)");

    return
      Column(
        children: <Widget>[
        Row(
          children: <Widget>[
            Text("Anoniem melden?"),
            Checkbox(
              activeColor: MyGlideConst.frontColor,
              tristate: false,
              value: _anoniemVerzenden ?? false,
              onChanged: (value) 
              {
                setState(() {
                  _anoniemVerzenden = value;
                });
              }
            ),
          ]),
          _toonGebruikerInfo(),
         
          Expanded(child: Container()),   // Zorg dat de knoppen aan de onderkant van het scherm zitten
         _vorigeVolgende(true, true)
      ]);
  }

  Widget _scherm6(BuildContext context)  {
    MyGlideDebug.info("IncidentMeldingScreenState._scherm6(context)");

    String samenvatting = _samenvatting();

    return
      Column(children: <Widget>[
        Expanded(
          child: 
            ListView(children: <Widget>[
              Html(data: samenvatting)                       
            ]),
        ),
        _vorigeBevestigen()
      ]);  
  }

  String _samenvatting() {
    MyGlideDebug.info("IncidentMeldingScreenState._samenvatting()");

    String retVal = _htmlPagina;

    // scherm 1
    retVal = retVal.replaceAll("{_voorvalTerPlaatseBesproken}", (_voorvalTerPlaatseBesproken == true) ? "JA" : "NEE");
    retVal = retVal.replaceAll("{_toelichtingTerPlaatse}", _toelichtingTerPlaatse.text);

    // scherm 2
    retVal = retVal.replaceAll("{_datumVoorval}", DateFormat('dd-MM-yyyy').format(_datumVoorval));
    retVal = retVal.replaceAll("{_tijdVoorval}", _tijdVoorval.text);
    retVal = retVal.replaceAll("{_locatieVoorval}", _locatieVoorval.text);
    retVal = retVal.replaceAll("{_betrokkenen}", _betrokkenen.text);
    retVal = retVal.replaceAll("{_handeling}", _handeling.text);
    retVal = retVal.replaceAll("{_meteo}", _meteo.text);

    // scherm 3
    retVal = retVal.replaceAll("{_omschrijving}", _omschrijving.text);

    // scherm 4
    retVal = retVal.replaceAll("{_mitigatie}", _mitigatie.text); 

    // scherm 5
    retVal = retVal.replaceAll("{naam}", (_anoniemVerzenden == true) ? "anoniem" : serverSession.login.userInfo['NAAM']);   
    retVal = retVal.replaceAll("{email}", (_anoniemVerzenden == true) ? "-" : serverSession.login.userInfo['EMAIL']); 
    retVal = retVal.replaceAll("{telefoon}", (_anoniemVerzenden) == true ? "-" : serverSession.login.userInfo['TELEFOON']); 
    retVal = retVal.replaceAll("{mobiel}", (_anoniemVerzenden == true) ? "-" : serverSession.login.userInfo['MOBIEL']); 

    retVal = retVal.replaceAll("{datum}", DateFormat('dd-MM-yyyy').format(DateTime.now()));     

    return retVal;
  }

  Widget _toonGebruikerInfo() {
    MyGlideDebug.info("IncidentMeldingScreenState._toonGebruikerInfo()");
    MyGlideDebug.trace("_anoniemVerzenden = $_anoniemVerzenden");

    if (_anoniemVerzenden == true)
      return Container();

    return 
      Align(
        alignment: Alignment.topLeft,
        child: Container(        
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
            
            Text("Gegevens melder", style: TextStyle(color: MyGlideConst.frontColor)),
            Container(height: 10),     // Geef ruimte
            Text(serverSession.login.userInfo['NAAM']),
            Text(serverSession.login.userInfo['EMAIL']),
            Text(serverSession.login.userInfo['TELEFOON']),
            Text(serverSession.login.userInfo['MOBIEL'])
          ])
        )
      );
  }


  Widget _vorigeVolgende(bool vorige, bool volgende) {
    MyGlideDebug.info("IncidentMeldingScreenState._vorigeVolgende($vorige, $volgende)");

    return
      Container(     // Onderin de pagina
        padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
        height: 45,
        child: Row (
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _vorige (vorige),
            _volgende(volgende)
          ]
        )
      );
  }

  Widget _vorigeBevestigen() {
    MyGlideDebug.info("IncidentMeldingScreenState._vorigeBevestigen()");

    return
      Container(     // Onderin de pagina
        padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
        height: 45,
        child: Row (
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _vorige (true),
            _bevestigen()
          ]
        )
      );
  }

  Widget _vorige (bool vorige) {
    MyGlideDebug.info("IncidentMeldingScreenState._vorige($vorige)");

    if (vorige == false)
      return Container();

    return
      PhysicalModel(
        borderRadius: BorderRadius.circular(20.0),
        color: MyGlideConst.backgroundColor,
        child: MaterialButton(
          height: 50.0,
          minWidth: 20.0,
          textColor: MyGlideConst.frontColor,
          child: Icon(Icons.navigate_before,
            color: MyGlideConst.frontColor ),
            onPressed: () {
              setState(() => _schermNummer--);
            }   
        )
      );
  }
  
  Widget _volgende (bool volgende) {
    MyGlideDebug.info("IncidentMeldingScreenState._volgende($volgende)");

    bool magVerder = true;

    if (volgende == false)
      return Container();
    
    switch (_schermNummer)
    {
      case 1: 
      {
        if (_toelichtingTerPlaatse.text.length == 0) 
          magVerder = false;
        break;
      } 
      case 2: 
      {
        if (_locatieVoorval.text.length == 0) 
          magVerder = false;

        if (_betrokkenen.text.length == 0) 
          magVerder = false;   

        if (_handeling.text.length == 0) 
          magVerder = false;     

        if (_meteo.text.length == 0) 
          magVerder = false;                           
      
        break;
      }       
      case 3: 
      {
        if (_omschrijving.text.length == 0) 
          magVerder = false;      

        break;
      }       
      case 4: 
      {
        if (_mitigatie.text.length == 0) 
          magVerder = false;      

        break;
      }                  
    }

    MyGlideDebug.trace("IncidentMeldingScreenState._volgende: magVerder = $magVerder");

    if (magVerder)
      return
        PhysicalModel(
          borderRadius: BorderRadius.circular(20.0),
          color: MyGlideConst.backgroundColor,
          child: MaterialButton(
            height: 50.0,
            minWidth: 20.0,
            textColor: MyGlideConst.frontColor,
            child: Icon(Icons.navigate_next,
              color: MyGlideConst.frontColor ),
              onPressed: () {
                setState(() => _schermNummer++);
              }   
          )
        );

    return
      PhysicalModel(
        borderRadius: BorderRadius.circular(20.0),
        color: MyGlideConst.backgroundColor,
        child: MaterialButton(
          height: 50.0,
          minWidth: 20.0,
          textColor: MyGlideConst.frontColor,
          child: Icon(Icons.error,
            color: MyGlideConst.frontColor ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Fout"),
                    content: Text("Niet alle velden zijn ingevoerd"),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("Sluiten"),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                  );
                }
              );
            }   
        )
      );
  }  

  Widget _bevestigen () {
    MyGlideDebug.info("IncidentMeldingScreenState._bevestigen()");

    return
      PhysicalModel(
        borderRadius: BorderRadius.circular(20.0),
        color: MyGlideConst.backgroundColor,
        child: MaterialButton(
          height: 50.0,
          minWidth: 20.0,
          textColor: MyGlideConst.frontColor,
          child: Text("Bevestig"),
            onPressed: () {
              MyGlideData.incidentPostMelding(_samenvatting(), serverSession.login.userInfo['NAAM'], serverSession.login.userInfo['EMAIL'], _anoniemVerzenden ?? false).then((gelukt)
              {
                if (gelukt)
                  Navigator.of(context).pop();    

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Incident melding"),
                    content: gelukt ? Text("De melding is geslaagd") : Text("De melding is mislukt")
                  )
                ); 
              });
            }   
        )
      );
  }  
}