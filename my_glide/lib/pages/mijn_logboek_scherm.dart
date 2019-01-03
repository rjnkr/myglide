// language packages
import 'package:flutter/material.dart';
import 'dart:async';

// language add-ons
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';

// my glide data providers
import 'package:my_glide/data/startlijst.dart';

// my glide own widgets
import 'package:my_glide/widget/hoofd_menu.dart';

// my glide pages
import 'package:my_glide/pages/mijn_logboek_details_scherm.dart';

class MijnLogboekScreen extends StatefulWidget {
  @override
  _MijnLogboekScreenState createState() => _MijnLogboekScreenState();
}

class _MijnLogboekScreenState extends State<MijnLogboekScreen> with TickerProviderStateMixin {
  List _logboekItems;
  
  final double _breedteCirkel = 25;
  final double _breedteDatum = 50;
  final double _breedteRegCall = 100;
  final double _breedteStartTijd = 40;
  final double _breedteLandingsTijd = 40;
  final double _breedteDuur = 35;
  final double _breedteVlieger = 150;
  final double _breedteInzittende = 150;
  double _breedteScherm;
  
  DateTime _lastRefresh = DateTime.now();
  DateTime _lastRefreshButton = DateTime.now().add(Duration(days: -1));

  Timer _autoUpdateTimer;

  _MijnLogboekScreenState()
  {
    // check iedere 10 seconden we logboek automatisch moeten ophalen
    // reageert daarmee (bijna) direct op instelling
    _autoUpdateTimer = Timer.periodic(Duration(seconds: 10), (Timer t) => _autoOphalenLogboek()); 
  }

  @override
  void initState() {
    super.initState();

    _ophalenLogboek(false);
  }

  @override
  void dispose() {
    super.dispose();

    _autoUpdateTimer.cancel();    // Stop de timer, anders krijgen we parallele sessie
  }

  @override
  Widget build(BuildContext context) {
    _breedteScherm = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyGlideConst.appBarBackground(),
        iconTheme: IconThemeData(color: MyGlideConst.frontColor),
        title: Text(
          "Mijn logboek",
          style: MyGlideConst.appBarTextColor()
        ),
        actions: <Widget>[
          IconButton (
            onPressed: () => _ophalenLogboek(true),
            icon: Icon(Icons.refresh, color: MyGlideConst.frontColor),
            padding: const EdgeInsets.only(right: 10.0)              
          )
        ],
      ),
      drawer: HoofdMenu(),
      body: ListView.builder (
        itemCount:  _logboekItems == null ? 0 : _logboekItems.length,
        itemBuilder: (BuildContext context, int index) =>
              _logboekItem(index)  // Toon logboek regel
        )
    );
  }
  
  // De kaart met de vlucht info
  Widget _logboekItem(int index) {
    return 
    Card(
      elevation: 1.5,
      child: _logboekRegel(index)
    );
  }

  // Toon de basis informatie 
  Widget _logboekRegel(index) { 
    return
      Slidable(
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
                    builder: (context) => LogboekDetailsScreen(details: _logboekItems[index]),
                  ),
                ),
            ),
          ],
          delegate: SlidableDrawerDelegate(),
          child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[ 
                SizedBox(
                  width:_breedteCirkel, 
                  child: 
                  CircleAvatar(
                    radius: 12.0, 
                    backgroundColor: MyGlideConst.backgroundColor,
                    child: Text(
                      (index+1).toString(),
                      style: TextStyle(fontSize: 13.0)
                    )
                  )
                ),
                Padding (padding: EdgeInsets.all(5)),
                SizedBox(
                  width:_breedteDatum, 
                  child: Text(
                  _logboekItems[index]['DATUM'].toString().substring(0,5),
                  style: _gridTextStyle()
                  )
                ),
                SizedBox(
                  width: _breedteStartTijd, 
                  child: Text(
                    _logboekItems[index]['STARTTIJD'],
                    style: _gridTextStyle(color: MyGlideConst.starttijdColor, weight: FontWeight.bold)
                  )
                ),
                SizedBox(
                  width:_breedteLandingsTijd, 
                  child: Text(
                    _logboekItems[index]['LANDINGSTIJD'] ?? ' ',
                    style: _gridTextStyle(color: MyGlideConst.landingstijdColor, weight: FontWeight.bold)
                  )
                ),
                _toonVluchtDuur(index),
                SizedBox(
                  width:_breedteRegCall, 
                  child: Text(
                    _logboekItems[index]['REG_CALL'],
                    style: _gridTextStyle()
                  )
                ),
                _toonVlieger(index),
                _toonInzittende(index)
              ]
            )
          )
        )
      );
  }
  
  Widget _toonVluchtDuur(int index){
    double minBreedte = 10 + _breedteCirkel + _breedteDatum + _breedteStartTijd + _breedteLandingsTijd + _breedteRegCall; // 10 extra marge

    // standaard = hh:mm, maar er zijn maar weining vluchten van 10 uur of langer. Zonde van de ruimte
    String vliegtijd = _logboekItems[index]['DUUR'].toString().replaceFirst(new RegExp(r'0'), '');

    if ((minBreedte + _breedteDuur) < _breedteScherm)
      return
        SizedBox(
          width: _breedteDuur, 
          child: Text(
            vliegtijd,
            style: _gridTextStyle(weight: FontWeight.bold)
          )
        );

    return Container(width: 0, height: 0);
  }  

  Widget _toonVlieger(int index){
  double minBreedte = 10 + _breedteCirkel + _breedteDatum + _breedteStartTijd + _breedteLandingsTijd + _breedteRegCall + _breedteDuur; // 10 extra marge

  if (((minBreedte + _breedteVlieger) < _breedteScherm) && (_logboekItems[index]['VLIEGERNAAM'] != null))
    return
      SizedBox(
        width: _breedteVlieger, 
        child: Text(
          _logboekItems[index]['VLIEGERNAAM'],
          style: _gridTextStyle()
        )
      );

  return Container(width: 0, height: 0);
  }  

  Widget _toonInzittende(int index){
  double minBreedte = 10 + _breedteCirkel + _breedteDatum + _breedteStartTijd + _breedteLandingsTijd + _breedteRegCall + _breedteDuur + _breedteVlieger; // 10 extra marge

  if (((minBreedte + _breedteInzittende) < _breedteScherm) && (_logboekItems[index]['INZITTENDENAAM'] != null))
    return
      SizedBox(
        width: _breedteInzittende, 
        child: Text(
          _logboekItems[index]['INZITTENDENAAM'],
          style: _gridTextStyle()
        )
      );

  return Container(width: 0, height: 0);
  }

  TextStyle _gridTextStyle({color = MyGlideConst.gridTextColor, weight = FontWeight.normal}) {
    return TextStyle (
      color: color,
      fontWeight: weight,
      fontSize: MyGlideConst.gridTextNormal
    );
  }    
     

  void _ophalenLogboek(bool handmatig) {
    bool volledig = false;

    if (handmatig)
    {
      int lastRefresh = DateTime.now().difference(_lastRefreshButton).inSeconds;
      if (lastRefresh < 5) volledig = true;
    }

    SharedPreferences.getInstance().then((prefs)
    {
      // haal aantal op als opgeslagen in 'nrLogboekItems' anders max 50
      Startlijst.getLogboek(prefs.getInt('nrLogboekItems') ?? 50, force: volledig).then((response) {
        setState(() {
          _logboekItems = response;
          _lastRefresh = DateTime.now();
        });
      });
    });
  }

  void _autoOphalenLogboek()
  {
    int lastRefresh = DateTime.now().difference(_lastRefresh).inSeconds;

    // We halen iedere 5 miniuten
    if (lastRefresh < MyGlideConst.logboekRefreshRate)
      return;

    SharedPreferences.getInstance().then((prefs)
    {
      // ophalen logboek indien autoLoadLogboek = true, indien niet gezet dan gebeurd er niets
      if ((prefs.getBool('autoLoadLogboek') ?? false) == true)
        _ophalenLogboek(false); 
    });
  }

}