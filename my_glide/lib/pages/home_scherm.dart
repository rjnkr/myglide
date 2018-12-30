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
  
  final double _breedteCirkel = 40;
  final double _breedteDatum = 100;
  final double _breedteRegCall = 100;
  final double _breedteStartTijd = 40;
  final double _breedteLandingsTijd = 40;
  final double _breedteDuur = 40;
  final double _breedteVlieger = 40;
  final double _breedteInzittende = 40;
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
          MyGlideConst.AppName,
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
    return Card(
      elevation: 1.5,
      child:ExpansionTile(
    //   key: _logboekItems[index]['ID'],
        title: _logboekRegel(index),
        children: _logboekDetails(index)
      )
    );
  }

  // Toon de basis informatie 
  Widget _logboekRegel(index) {
    return                       
      Row(
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
            ),
          ),
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
              _logboekItems[index]['LANDINGSTIJD'],
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
              )
            ),
          SizedBox(
            width:_breedteRegCall, 
            child: Text(
              _logboekItems[index]['REG_CALL'],
              )
            )                            
        ]
      );
  }

  // Toon de details als kaart is uitgeklapt
  List<Widget> _logboekDetails(int index) {
    return <Widget>[
      Row(
        children: <Widget>[ 
          SizedBox(
            width:140, 
            child: Text(
            _logboekItems[index]['VLIEGERNAAM'])
          ),
          
          SizedBox(
            width:150, 
            child: Text(
            _logboekItems[index]['INZITTENDENAAM'] ?? '')
          )
        ]
      ) 
    ];  
  }
  
  Widget _startMethodeWidget(int index) {
    return 
      PhysicalModel(
        color: MyGlideConst.YellowRGB,
        borderRadius: BorderRadius.circular(5.0),
        child: 
            SizedBox(
              height:20,
              width:20,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[Text("L")]
              )
            )
      );
  }

  bool _displayDuur(){
    double minBreedte = _breedteCirkel + _breedteDatum + _breedteStartTijd + _breedteLandingsTijd + _breedteRegCall;

    if ((minBreedte + _breedteDuur) < _breedteScherm)
      return true;

    return false;
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