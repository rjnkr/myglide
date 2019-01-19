
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
import 'package:my_glide/pages/startlijst_grid.dart';


class AanwezigDetailsScreen extends StatefulWidget {
  final Map details;

  AanwezigDetailsScreen({Key key, @required this.details}) : super(key: key);

  @override
  _AanwezigDetailsScreenState createState() => _AanwezigDetailsScreenState();
}


class _AanwezigDetailsScreenState extends State<AanwezigDetailsScreen> {
  List _startsVandaag;
  Map _recency;

  @override
  void initState() {
    super.initState();

    Startlijst.getStartsVandaag(widget.details['LID_ID']).then((response) {
      setState(() {
        _startsVandaag = response;
      });
    });

    Startlijst.getRecency(widget.details['LID_ID']).then((response) {
      setState(() {
        _recency = response;
      });
    });    
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: (serverSession.login.isInstructeur) ? 3 : 2,
      child: 
        Scaffold(
        appBar: AppBar(
          backgroundColor: MyGlideConst.appBarBackground(),
          iconTheme: IconThemeData(color: MyGlideConst.frontColor),
          title: Text(
            widget.details['NAAM'],
            style: MyGlideConst.appBarTextColor()
          ),
          bottom: TabBar(
            tabs:  _toonTabbladen(),
            labelStyle: TextStyle(fontSize: MyGlideConst.labelSizeLarge),
            labelColor: MyGlideConst.frontColor,
            indicatorColor: MyGlideConst.frontColor,
         //   isScrollable: true,
          )
        ),
        body: TabBarView(
          children: _tabbladInhoud()
          )
        )
      );
  }

  List<Widget> _toonTabbladen() {
    List<Widget> retVal = List<Widget>();

    retVal.add(Icon(Icons.today));
    retVal.add(Icon(Icons.flight_takeoff));

    if (serverSession.login.isInstructeur) 
      retVal.add(Icon(Icons.history));
    
    return retVal;
  }

  List<Widget> _tabbladInhoud() {
    List<Widget> retVal = List<Widget>();

    retVal.add(_samenvatting());            // tabblad met samenvattign van vandaag
    retVal.add(_vluchtenVandaag());

    if (serverSession.login.isInstructeur) 
      retVal.add(_toonRecency());
    return retVal;
  }

  Widget _vluchtenVandaag() {
  if (_startsVandaag == null) return CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(MyGlideConst.frontColor));
  
  return
    ListView.builder (
      itemCount:  _startsVandaag.length,
      itemBuilder: (BuildContext context, int index) =>
        StartlijstGrid.toonVlucht(context, _startsVandaag[index], index)  // Toon logboek regel
    ); 
  }

  Widget _samenvatting() {
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
                      GUIHelper.showDetailsField("Voorkeur types", widget.details['VOORKEUR_TYPE'] ?? ' '),
                      GUIHelper.showDetailsField("Overland", widget.details['VOORKEUR_REGCALL'] ?? ' '),
                      Divider(),
                      GUIHelper.showDetailsField("Aantal starts", widget.details['STARTLIJST_VANDAAG']) ?? '0',
                      GUIHelper.showDetailsField("Vliegtijd", widget.details['VLIEGTIJD_VANDAAG'] ?? '--:--'),
                      Divider(),
                      GUIHelper.showDetailsField("Duur", widget.details['ACTUELE_VLIEGTIJD'] ?? '--:--'),
                      GUIHelper.showDetailsField("Wacht", widget.details['WACHTTIJD'] ?? '--:--'),
                      GUIHelper.showDetailsField("Ingedeeld op", widget.details['VOLGEND_CALLSIGN'] ?? ' '),
                      Divider(),
                      GUIHelper.showDetailsField("Opmerking", widget.details['OPMERKING'] ?? ' ', titleTop: true)
                    ]
                  )
                )
              ),
              Expanded(
                  child: Container(height: 50, width:50),
                /*
                child: Row (
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    PhysicalModel(
                      borderRadius: BorderRadius.circular(20.0),
                      color: MyGlideConst.backgroundColor,
                      child: MaterialButton(
                        height: 50.0,
                        minWidth: 150.0,
                        child: Text("Indelen",
                          style: TextStyle(color: MyGlideConst.frontColor, fontSize: MyGlideConst.labelSizeMedium),
                        )
                     //     onPressed: () => _sendEmail(),    
                      )
                    )
                  ]
                )*/
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
                      GUIHelper.showDetailsField("Recency",  "${_recency['startsBarometer']} starts met ${_recency['urenBarometer']} uren"),
                      Padding(padding: EdgeInsets.all(5)),

                      _barometerStatus(),

                      Padding(padding: EdgeInsets.all(5)),
                      GUIHelper.showDetailsField("Laatste 3 mnd",  "${_recency['startsDrieMnd']} starts met ${_recency['urenDrieMnd']} uren"),
                      Padding(padding: EdgeInsets.all(5)),
                      GUIHelper.showDetailsField(DateTime.now().year.toString() ,  "${_recency['startsDitJaar']} starts met ${_recency['urenDitJaar']} uren"),
                      Padding(padding: EdgeInsets.all(5)),
                      GUIHelper.showDetailsField((DateTime.now().year-1).toString(),  "${_recency['startsVorigJaar']} starts met ${_recency['urenVorigJaar']} uren"),
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
            child: MaterialButton(
             // height: 10.0,
              minWidth: 170.0,
              child: Text(tekst,
                style: TextStyle(color: textKleur, fontSize: MyGlideConst.labelSizeNormal)
              )
            )
          )    
        ]
      );    
  }
}