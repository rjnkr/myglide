import 'package:flutter/material.dart';

import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/startlijst.dart';

import 'package:my_glide/widget/hoofd_menu.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
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
  

  @override
  void initState() {
    super.initState();

    Startlijst.getLogboek().then((response) {
      setState(() {
        _logboekItems = response;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _breedteScherm = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyGlideConst.BlueRGB,
        iconTheme: IconThemeData(color: MyGlideConst.YellowRGB),
        title: Text(
          "Mijn logboek",
          style: TextStyle(color: MyGlideConst.YellowRGB),
        ),
        actions: <Widget>[
          Padding(
            child: Icon(Icons.refresh, color: MyGlideConst.YellowRGB),
            padding: const EdgeInsets.only(right: 10.0),
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
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[ 
          SizedBox(
            width:_breedteCirkel, 
            child: 
            CircleAvatar(
              radius: 12.0, 
              backgroundColor: MyGlideConst.BlueRGB,
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
            _logboekItems[index]['DATUM'])
          ),
          SizedBox(
            width: _breedteStartTijd, 
            child: Text(
              _logboekItems[index]['STARTTIJD'],
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)
            )
          ),
          SizedBox(
            width:_breedteLandingsTijd, 
            child: Text(
              _logboekItems[index]['LANDINGSTIJD'] ?? ' ',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
            )
          ),
          _toonVluchtDuur(index),
          SizedBox(
            width:_breedteRegCall, 
            child: Text(
              _logboekItems[index]['REG_CALL'],
            )
          ),
          _toonVlieger(index),
          _toonInzittende(index)
        ]
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
            style: TextStyle(fontWeight: FontWeight.bold)
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
            _logboekItems[index]['VLIEGERNAAM']
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
            _logboekItems[index]['INZITTENDENAAM']
          )
        );

    return Container(width: 0, height: 0);
  }    

}

/* achter de hand houden
          return Card(
                elevation: 1.5,
                child: Container(
                  padding: EdgeInsets.all(4.0),
                  child: Row (
                    children: <Widget>[
                      ,
 ,
                          
                        ]),
                        //startMethodeWidget(index)
                    ]),
            ));
*/