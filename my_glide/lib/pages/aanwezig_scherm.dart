// language packages
import 'package:flutter/material.dart';
import 'dart:async';

// language add-ons
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:connectivity/connectivity.dart';

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/storage.dart';

// my glide data providers
import 'package:my_glide/data/aanwezig.dart';

// my glide own widgets
import 'package:my_glide/widget/hoofd_menu.dart';

// my glide pages
import 'package:my_glide/pages/aanwezig_details_scherm.dart';
import 'package:my_glide/pages/gui_helpers.dart';

class AanwezigScreen extends StatefulWidget {
  @override
  _AanwezigScreenState createState() => _AanwezigScreenState();
}

class _AanwezigScreenState extends State<AanwezigScreen> with TickerProviderStateMixin {
  final double _breedteCirkel = 25;
  final double _breedteNaam = 120;
  final double _breedteTijd = 45;
  final double _breedteStarts = 15;
  final double _breedteCallsign = 45;
  
  List _ledenAanwezig;
  
  DateTime _lastRefresh = DateTime.now();
  DateTime _lastRefreshButton = DateTime.now().add(Duration(days: -1));

  ConnectivityResult _netwerkStatus;

  Timer _autoUpdateTimer;

  _AanwezigScreenState()
  {
    // check iedere 10 seconden we data automatisch moeten ophalen
    // reageert daarmee (bijna) direct op instelling
    _autoUpdateTimer = Timer.periodic(Duration(seconds: 10), (Timer t) => _autoOphalenData()); 
  }

  @override
  void initState() {
    super.initState();

    _ophalenData(false);
  }

  @override
  void dispose() {
    super.dispose();

    _autoUpdateTimer.cancel();    // Stop de timer, de class wordt verwijderd
  }

  @override
  Widget build(BuildContext context) {
    if (_ledenAanwezig == null) return GUIHelper.showLoading();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyGlideConst.appBarBackground(),
        iconTheme: IconThemeData(color: MyGlideConst.frontColor),
        title: Text(
          "Vandaag aanwezig",
          style: MyGlideConst.appBarTextColor()
        ),
        actions: <Widget>[
          IconButton (
            onPressed: _netwerkStatus == ConnectivityResult.none  ? null : () => _ophalenData(true),
            icon: Icon(_netwerkStatus == ConnectivityResult.none  ? Icons.cloud_off : Icons.refresh, 
              color: MyGlideConst.frontColor),
            padding: const EdgeInsets.only(right: 10.0)              
          )

        ],
      ),
      drawer: HoofdMenu(),
      body: ListView.builder (
        itemCount:  _ledenAanwezig == null ? 0 : _ledenAanwezig.length,
        itemBuilder: (BuildContext context, int index) =>
            _lidAanwezig(index)  // Toon logboek regel
        )
    );
  }

  // De kaart met de vlucht info
  Widget _lidAanwezig(int index) {
    return 
      Card(
        elevation: 1.5,
        child: _lidRegel(index)
      );
  }

  // Toon de basis informatie 
  Widget _lidRegel(index) {
    return
      Slidable(
        delegate: SlidableDrawerDelegate(),        
        direction: Axis.horizontal,
        secondaryActions: <Widget>[
          new IconSlideAction(
            caption: 'Details',
            color: Colors.grey,
            icon: Icons.more_horiz,
            onTap: () => 
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AanwezigDetailsScreen(details: _ledenAanwezig[index]),
                ),
              ),
          ),
        ],
        child: _velden(index)
      );
  }

  // hier gaat het om
  Widget _velden(int index) {
    return
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget> [
            SizedBox(
              width:_breedteCirkel, 
              child: CircleAvatar(
                radius: 12.0, 
                backgroundColor: MyGlideConst.backgroundColor,
                child: Text(
                  (index+1).toString(),
                  style: TextStyle(fontSize: 13.0)
                )
              )
            ),
            Padding (padding: EdgeInsets.all(3)), 
            Container(
              height: 40,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, 
                children: <Widget>[
                  _basisData(index),
                  _showOpmerking(index),
                ]
              )
            )
          ]
        )
    );  
  }

  Widget _basisData(int index) {
    return Row( 
      children: <Widget> [
        SizedBox(
          width:_breedteNaam, 
          child: Text(
          _ledenAanwezig[index]['NAAM'],
          style: _gridTextStyle()
          )
        ),
        _showVliegtWachtVolgende(index),
        SizedBox(
          width: _breedteStarts, 
          child: Text(
            _ledenAanwezig[index]['STARTLIJST_VANDAAG'] ?? '0',
            style: _gridTextStyle(weight: FontWeight.bold)
          )
        ),
        SizedBox(
          width:_breedteTijd, 
          child: Text(
            _ledenAanwezig[index]['VLIEGTIJD_VANDAAG'] ?? ' '.toString().replaceFirst(new RegExp(r'0'), ''),
            style: _gridTextStyle(weight: FontWeight.bold)
          )
        ),
        Text(
          _ledenAanwezig[index]['VOORKEUR_TYPE'] ?? ' ',
          style: _gridTextStyle()
        )
      ]
    );    
  }
  

  
  // Laat zien 
  // (a) hoe lang de vlieger al vliegt 
  // (b) op welke kist hij/zij is ingedeeld voor de volgende vlucht
  // (c) Hoe lang hij al staat te wachten 
  Widget _showVliegtWachtVolgende(int index) {
    if (_ledenAanwezig[index]['ACTUELE_VLIEGTIJD'] != null)
      return
        SizedBox(
          width: _breedteCallsign, 
          child: Text(
            _ledenAanwezig[index]['ACTUELE_VLIEGTIJD'].toString().replaceFirst(new RegExp(r'0'), ''),
            style: _gridTextStyle(color: MyGlideConst.starttijdColor)
          )
        );
    else if (_ledenAanwezig[index]['VOLGEND_CALLSIGN'] != null)
      return
        SizedBox(
          width: _breedteCallsign, 
          child: Text(
            _ledenAanwezig[index]['VOLGEND_CALLSIGN'],
            style: _gridTextStyle(color: MyGlideConst.starttijdColor)
          )
        );
    else
      return
        SizedBox(
          width: _breedteCallsign, 
          child: Text(
            _ledenAanwezig[index]['WACHTIJD'] ?? ''.toString().replaceFirst(new RegExp(r'0'), ''),
            style: _gridTextStyle(color: MyGlideConst.landingstijdColor)
          )
        );
  }

  // toon de eventuele opmerking die de vlieger aangegeven heeft bij het aanmelden
  _showOpmerking(int index) {
    if (_ledenAanwezig[index]['OPMERKING']  == null)
      return Container(width: 0, height: 0);

    return
      Container(
        width: 311,
        child: 
          Text(
            _ledenAanwezig[index]['OPMERKING'],
            style: _gridTextStyle(fontSize: MyGlideConst.gridTextSmall)
          )
      );
  }

  // Hoe wordt het veld in het grid vertoond
  TextStyle _gridTextStyle({color = MyGlideConst.gridTextColor, weight = FontWeight.normal, fontSize = MyGlideConst.gridTextNormal}) {
    return TextStyle (
      color: color,
      fontWeight: weight,
      fontSize: fontSize
    );
  }    
  
  void _ophalenData(bool handmatig) {
    bool volledig = false;

    if (handmatig)
    {
      int lastRefresh = DateTime.now().difference(_lastRefreshButton).inSeconds;
      if (lastRefresh < 5) volledig = true;
    }
    
    Aanwezig.ledenAanwezig(force: volledig).then((response) {
      setState(() {
        _lastRefresh = DateTime.now();
        _ledenAanwezig = response;
      });
    });
  }

  void _autoOphalenData()
  {
    int lastRefresh = DateTime.now().difference(_lastRefresh).inSeconds;

    Connectivity().checkConnectivity().then((result)
    {
        if (_netwerkStatus != result) {
          setState(() {
            _netwerkStatus = result;
          });
        }
    });

    // We halen iedere 5 miniuten
    if (lastRefresh < MyGlideConst.logboekRefreshRate)
      return;

    // ophalen logboek indien autoLoadLogboek = true, indien niet gezet dan gebeurd er niets
    Storage.getBool('autoLoadLogboek').then((value) { if (value) _ophalenData(false); });
  }
}