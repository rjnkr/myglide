
// language packages
import 'package:flutter/material.dart';

// language add-ons

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';

// my glide data providers
import 'package:my_glide/data/startlijst.dart';
import 'package:my_glide/data/session.dart';

// my glide own widgets

// my glide pages
import 'package:my_glide/pages/gui_helpers.dart';
import 'package:my_glide/pages/startlijst_container.dart';


class AanwezigDetailsScreen extends StatefulWidget {
  final Map aanwezig;

  AanwezigDetailsScreen({Key key, @required this.aanwezig}) : super(key: key);

  @override
  _AanwezigDetailsScreenState createState() => _AanwezigDetailsScreenState();
}


class _AanwezigDetailsScreenState extends State<AanwezigDetailsScreen> {
  String _vertoondLidID;
  List _startsVandaag;
  Map _recency;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    if (widget.aanwezig == null)
      return Container(width: 0, height: 0);

    // haal de overige data op
    if (_vertoondLidID != widget.aanwezig['LID_ID'])
    {
      Startlijst.getStartsVandaag(widget.aanwezig['LID_ID']).then((response) {
        setState(() {   
          _startsVandaag = response;
        });
      });
    }

    if (_vertoondLidID != widget.aanwezig['LID_ID'])  
    {
      Startlijst.getRecency(widget.aanwezig['LID_ID']).then((response) {
        setState(() {
          _recency = response;
        });
      });  
    }  

    // dit voorkomt dat de data contininue geladen wordt
    if (_vertoondLidID != widget.aanwezig['LID_ID']) 
      _vertoondLidID = widget.aanwezig['LID_ID'];

    return DefaultTabController(
      length: (serverSession.login.isInstructeur) ? 3 : 2,
      child: 
        Scaffold(
        appBar: AppBar(
          backgroundColor: MyGlideConst.appBarBackground(),
          iconTheme: IconThemeData(color: MyGlideConst.frontColor),
          title: Text(
            widget.aanwezig['NAAM'],
            style: MyGlideConst.appBarTextColor()
          ),
          bottom: _toonTabbladen()
        ),
        body: _tabbladInhoud()
        )
      );
  }

  Widget _toonTabbladen() {
    List<Widget> tabs = List<Widget>();

    if ((serverSession.login.isInstructeur) || (serverSession.login.isBeheerder))
      tabs.add(Icon(Icons.history));

    tabs.add(Icon(Icons.today));
    tabs.add(Icon(Icons.flight_takeoff));

    return TabBar(
      labelStyle: TextStyle(fontSize: MyGlideConst.labelSizeLarge),
      labelColor: MyGlideConst.frontColor,
      indicatorColor: MyGlideConst.frontColor,      
      tabs: tabs);
  }

  Widget _tabbladInhoud() {
    List<Widget> pages = List<Widget>();

    if ((serverSession.login.isInstructeur) || (serverSession.login.isBeheerder))
      pages.add(_toonRecency());                                    // Instructeurs zien recente ervaring van vlieger

    pages.add(_samenvatting());                                     // tabblad met samenvattign van vandaag
    pages.add(StartlijstContainer(starts: _startsVandaag));         // Welke starts heeft deze vlieger vandaag al gemaakt
 
    return TabBarView(children: pages);
  }

  // Samenvatting voor deze vlieger, voor vandaag. Eigenlijk meer details als zichtbaar op eerste blad
  Widget _samenvatting() {
    return
      Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 3,
                child :ListView(
                    children: <Widget>[
                      GUIHelper.showDetailsField("Overland", widget.aanwezig['VOORKEUR_REGCALL'] ?? ' '),
                      GUIHelper.showDetailsField("Voorkeur types", widget.aanwezig['VOORKEUR_TYPE'] ?? ' ', titleTop: true),
                      Divider(),
                      GUIHelper.showDetailsField("Aantal starts", widget.aanwezig['STARTLIJST_VANDAAG']) ?? '0',
                      GUIHelper.showDetailsField("Vliegtijd", widget.aanwezig['VLIEGTIJD_VANDAAG'] ?? '--:--'),
                      Divider(),
                      GUIHelper.showDetailsField("Duur", widget.aanwezig['ACTUELE_VLIEGTIJD'] ?? '--:--'),
                      GUIHelper.showDetailsField("Wacht", widget.aanwezig['WACHTTIJD'] ?? '--:--'),
                      GUIHelper.showDetailsField("Ingedeeld op", widget.aanwezig['VOLGEND_CALLSIGN'] ?? ' '),
                      Divider(),
                      GUIHelper.showDetailsField("Opmerking", widget.aanwezig['OPMERKING'] ?? ' ', titleTop: true)
                    ]
                )
              ),
              Expanded(
                  child: Container(height: 50, width:50),
              ) 
            ]
          )
        );  
  }

  Widget _toonRecency() {
    if (_recency == null)  return Container(width: 0, height: 0);
    
    return
      Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 3,
              child :SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column (
                  children: <Widget>[
                    GUIHelper.showDetailsField("Recency",  "${_recency['startsBarometer']} starts, ${_recency['urenBarometer']} uren"),
                    Padding(padding: EdgeInsets.all(5)),

                    _barometerStatus(),

                    Padding(padding: EdgeInsets.all(5)),
                    GUIHelper.showDetailsField("Laatste 3 mnd", "${_recency['startsDrieMnd']} starts, ${_recency['urenDrieMnd']} uren"),
                    Padding(padding: EdgeInsets.all(5)),
                    GUIHelper.showDetailsField(DateTime.now().year.toString(), "${_recency['startsDitJaar']} starts, ${_recency['urenDitJaar']} uren"),
                    Padding(padding: EdgeInsets.all(5)),
                    GUIHelper.showDetailsField((DateTime.now().year-1).toString(), "${_recency['startsVorigJaar']} starts, ${_recency['urenVorigJaar']} uren"),
                  ]
                )
              )
            ),
          ]
        )
      );
  }

  Widget _barometerStatus() {
    Color statusKleur;
    Color textKleur;
    String tekst;

    switch (_recency['statusBarometer'])
    {
      case "groen" : {
        statusKleur = Colors.green;
        textKleur = MyGlideConst.backgroundColor;
        tekst = "GROENE ZONE";
        break;
      }
      case "geel" : {
        statusKleur = Colors.yellow;
        textKleur = MyGlideConst.backgroundColor;
        tekst = "GELE ZONE";
        break;
      }
      case "rood" : {
        statusKleur = Colors.red;
        textKleur = MyGlideConst.frontColor;
        tekst = "RODE ZONE";
        break;
      }  
      default : {
        statusKleur = Colors.grey;
        textKleur = MyGlideConst.backgroundColor;
        tekst = "ONBEKEND";
        break;
      }                
    }

    return
      Row (
        children: <Widget> [          
          SizedBox(
            width: 120,
            height: 22, 
            child: Text("Status")
          ),
          PhysicalModel(
            borderRadius: BorderRadius.circular(10.0),
            color: statusKleur,
            child: SizedBox(
              width: 150.0,
              height: 40,
              child: Center(
                child: Text(tekst,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textKleur, fontSize: MyGlideConst.labelSizeNormal)
                )
              )
            )
          )
        ]
      );
  }
}