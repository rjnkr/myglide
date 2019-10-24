// language packages
import 'package:flutter/material.dart';
import 'dart:async';

// language add-ons
import 'package:connectivity/connectivity.dart';

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/storage.dart';
import 'package:my_glide/utils/debug.dart';

// my glide data providers
import 'package:my_glide/data/aanwezig.dart';

// my glide own widgets
import 'package:my_glide/widget/hoofd_menu.dart';
import 'package:my_glide/widget/my_data_table.dart';

// my glide pages
import 'package:my_glide/pages/vandaag_details.dart';
import 'package:my_glide/pages/gui_helpers.dart';

class VandaagScreen extends StatefulWidget {
  @override
  _VandaagScreenState createState() => _VandaagScreenState();
}

class _VandaagScreenState extends State<VandaagScreen> with TickerProviderStateMixin {
  List _ledenAanwezig;
  
  DateTime _lastRefresh = DateTime.now();
  DateTime _lastRefreshButton = DateTime.now().add(Duration(days: -1));

  ConnectivityResult _netwerkStatus;

  Timer _autoUpdateTimer;

  // Hoe is het grid gesorteerd
  int _sortColIdx = 0;
  bool _sortAsc = true;

  _VandaagScreenState()
  {
    MyGlideDebug.info("_VandaagScreenState()"); 

    // check iedere 10 seconden we data automatisch moeten ophalen
    // reageert daarmee (bijna) direct op instelling
    _autoUpdateTimer = Timer.periodic(Duration(seconds: 10), (Timer t) => _autoOphalenData()); 
  }

  @override
  void initState() {
    MyGlideDebug.info("_VandaagScreenState.initState()"); 
    super.initState();

    _ophalenData(false);
  }

  @override
  void dispose() {
    MyGlideDebug.info("_VandaagScreenState.dispose()"); 

    super.dispose();

    _autoUpdateTimer.cancel();    // Stop de timer, de class wordt verwijderd
  }

  @override
  Widget build(BuildContext context) {
    MyGlideDebug.info("_VandaagScreenState.build(context)"); 

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
      body: _toonGrid(context)

    );
  }

  void _ophalenData(bool handmatig) {
    MyGlideDebug.info("_VandaagScreenState._ophalenData($handmatig)"); 

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
        _sortVandaag();
      });
    });
  }

  void _autoOphalenData()
  {
    MyGlideDebug.info("_VandaagScreenState._autoOphalenData()"); 

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

  int _sortVolgorde (Map a, Map b, bool asc) {
    int va = int.parse(a['VOLGORDE'] ?? 0);
    int vb = int.parse(b['VOLGORDE'] ?? 0);

    return ((asc) ? va.compareTo(vb) : vb.compareTo(va));
  }

    // Sorteeer de dataset op basis van de keuze van de gebruiker
  void _sortVandaag({int index=-1, bool asc=true}) {
    MyGlideDebug.info("_VandaagScreenState._sortVandaag($index, $asc)"); 
    
    if (index < 0) {
      index = _sortColIdx;
      asc = _sortAsc;
    }

    switch (index)
    {
      case 0: {
        _ledenAanwezig.sort((a,b) {
          return _sortVolgorde(a, b, asc);
        });
        break;        
      }
      case 1: {
        _ledenAanwezig.sort((a,b) {
          String sa = a['NAAM'] ?? " ";
          String sb = b['NAAM'] ?? " ";

          if (sa == sb)
            return _sortVolgorde(a, b, asc);

          return (asc) ? sa.compareTo(sb) : sb.compareTo(sa);
        });
        break;        
      }
      case 2: {
        _ledenAanwezig.sort((a,b) {
          int va = int.parse(a['STARTLIJST_VANDAAG'] ?? 0);
          int vb = int.parse(b['STARTLIJST_VANDAAG'] ?? 0);
          
          if (va == vb)
            return _sortVolgorde(a, b, asc);

          return ((asc) ? va.compareTo(vb) : vb.compareTo(va));
        });
        break;        
      }
      case 3: {
        _ledenAanwezig.sort((a,b) {
          String sa = a['VLIEGTIJD_VANDAAG'] ?? "00:00";
          String sb = b['VLIEGTIJD_VANDAAG'] ?? "00:00";

          if (sa == sb)
            return _sortVolgorde(a, b, asc);

          int urenA, urenB;
          int minutenA, minutenB;

          try { urenA = int.parse(sa.substring(0,2)); }
          catch (e) { urenA = 0; }
          try { minutenA = int.parse(sa.substring(3,5)); }
          catch (e) { minutenA = 0; }

          try { urenB = int.parse(sb.substring(0,2)); }
          catch (e) { urenA = 0; }
          try { minutenB = int.parse(sb.substring(3,5)); }
          catch (e) { minutenB = 0; }

          minutenA = urenA * 60 + minutenA;
          minutenB = urenB * 60 + minutenB;

          return ((asc) ? minutenA.compareTo(minutenB) : minutenB.compareTo(minutenA));
        });
        break;        
      }
    }
  } 

  // Grid tonen
  Widget _toonGrid(BuildContext context) {
    MyGlideDebug.info("_VandaagScreenState._toonGrid(context)"); 

    List<MyDataColumn> _columns = List<MyDataColumn>();

    // Kolom headers
    _columns.add(MyDataColumn(
      label: Text("#"),
      onSort: (int columnIndex, bool ascending) {
        setState(() {
          _sortVandaag(index: columnIndex, asc: ascending);
          _sortColIdx = columnIndex;
          _sortAsc = ascending;
        });
      }
    ));

    _columns.add(MyDataColumn(
      label: Text("Naam"),
      onSort: (int columnIndex, bool ascending) 
      {
        setState(() {
          _sortVandaag(index: columnIndex, asc: ascending);
          _sortColIdx = columnIndex;
          _sortAsc = ascending;
        });
      }
    ));

    _columns.add(MyDataColumn(
      label: Text("Starts"),
      onSort: (int columnIndex, bool ascending) {
        setState(() {
          _sortVandaag(index: columnIndex, asc: ascending);
          _sortColIdx = columnIndex;
          _sortAsc = ascending;
        });
      }
    ));

    _columns.add(MyDataColumn(
      label: Text("Vandaag"),
      onSort: (int columnIndex, bool ascending) {
        setState(() {
          _sortVandaag(index: columnIndex, asc: ascending);
          _sortColIdx = columnIndex;
          _sortAsc = ascending;
        });
      }
    ));

    _columns.add(MyDataColumn(
      label: Text("V/W/I"),
      tooltip: "Rood = wachttijd, Groen = vliegtijd huidige vlucht, Zwart = ingedeeld op",
      onSort: (int columnIndex, bool ascending) {},
    ));

    _columns.add(MyDataColumn(
      label: Text("Voorkeur"),
      onSort: (int columnIndex, bool ascending) {},
    ));

    _columns.add(MyDataColumn(
      label: Text("Opmerking"),   
      onSort: (int columnIndex, bool ascending) {},
    ));

    List<MyDataRow> _rows = List.generate(_ledenAanwezig.length, (int index) => MyDataRow(
        cells: [
          MyDataCell(_nummer(_ledenAanwezig[index]), onTap: () => _showDetails(index)),
          MyDataCell(_naam(_ledenAanwezig[index]), onTap: () => _showDetails(index)),
          MyDataCell(_startsVandaag(_ledenAanwezig[index]), onTap: () => _showDetails(index)),
          MyDataCell(_vliegtijdVandaag(_ledenAanwezig[index]), onTap: () => _showDetails(index)),
          MyDataCell(_showVliegtWachtVolgende(_ledenAanwezig[index]), onTap: () => _showDetails(index)),            
          MyDataCell(_voorkeurType(_ledenAanwezig[index]), onTap: () => _showDetails(index)),
          MyDataCell(_opmerking(_ledenAanwezig[index]), onTap: () => _showDetails(index))
        ]
      )
    );

    return ListView(
      padding: EdgeInsets.all(20.0), 
      children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: MyDataTable(
            sortColumnIndex: _sortColIdx,
            sortAscending: _sortAsc,
            rows: _rows,
            columns: _columns,
          ),
        ),
      ]);
  }

  void _showDetails(int index) {
    MyGlideDebug.info("_VandaagScreenState._showDetails(context)"); 

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return AanwezigDetailsScreen(
            aanwezig: _ledenAanwezig[index],
          );
        },
      ),
    );
  }

  Widget _nummer(Map aanwezigData) {
    MyGlideDebug.info("_VandaagScreenState._nummer($aanwezigData)"); 

    // Kleuren schema voor status vliegen
    Color backgroundColor = MyGlideConst.starttijdColor;
    Color textColor = Colors.white;

 // Kleuren schema voor status ingedeeld
    if ((aanwezigData['ACTUELE_VLIEGTIJD'] == null) || (aanwezigData['VOLGEND_CALLSIGN'] != null))
    {
      backgroundColor = Colors.white;
      textColor = Colors.black;     
    }

    if ((aanwezigData['ACTUELE_VLIEGTIJD'] != null) || (aanwezigData['VOLGEND_CALLSIGN'] != null))
    {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: new BorderRadius.all(Radius.circular(5)),
          border: Border.all(
            color:MyGlideConst.starttijdColor
          )
        ),
        child: Center(
          child: Text(
            aanwezigData['VOLGORDE'] ?? '0',
            style: TextStyle(fontSize: 13.0, color: textColor)
          )
        )
      );
    }

    return CircleAvatar(
      radius: 12.0, 
      backgroundColor: MyGlideConst.backgroundColor,
      child: Text(
        aanwezigData['VOLGORDE'] ?? '0',
        style: TextStyle(fontSize: 13.0)
      )
    ); 
  }

  Widget _naam(Map aanwezigData) {
    MyGlideDebug.info("_VandaagScreenState._naam($aanwezigData)"); 

    return Text(
      aanwezigData['NAAM'],
      style: GUIHelper.gridTextStyle()
    );
  }

  Widget _startsVandaag(Map aanwezigData) {
    MyGlideDebug.info("_VandaagScreenState._startsVandaag($aanwezigData)"); 

    return Text(
      aanwezigData['STARTLIJST_VANDAAG'] ?? '0',
      style: GUIHelper.gridTextStyle(weight: FontWeight.bold)
    );
  }

  Widget _vliegtijdVandaag(Map aanwezigData) {
    MyGlideDebug.info("_VandaagScreenState._vliegtijdVandaag($aanwezigData)");

    return Text(
      aanwezigData['VLIEGTIJD_VANDAAG'] ?? ' '.toString().replaceFirst(new RegExp(r'0'), ''),
      style: GUIHelper.gridTextStyle(weight: FontWeight.bold)
    );
  }

  Widget _voorkeurType(Map aanwezigData)
  {
    MyGlideDebug.info("_VandaagScreenState._voorkeurType($aanwezigData)");

    return Text(
      aanwezigData['VOORKEUR_TYPE'] ?? ' ',
      style: GUIHelper.gridTextStyle()
    );
  }

  Widget _wachtTijd(Map aanwezigData)
  {
    MyGlideDebug.info("_VandaagScreenState._wachtTijd($aanwezigData)");

    return Text(
      aanwezigData['WACHTTIJD'] ?? ' ',
      style: GUIHelper.gridTextStyle(color: MyGlideConst.landingstijdColor, underline: true)
    );
  }

  Widget _vliegtijdTijd(Map aanwezigData)
  {
    MyGlideDebug.info("_VandaagScreenState._vliegtijdTijd($aanwezigData)");

    return Text(
      aanwezigData['ACTUELE_VLIEGTIJD'] ?? ' ',
      style: GUIHelper.gridTextStyle(color: MyGlideConst.starttijdColor)
    );
  }

  Widget _ingedeeldOp(Map aanwezigData)
  {
    MyGlideDebug.info("_VandaagScreenState._ingedeeldOp($aanwezigData)");
        
    return Text(
      aanwezigData['VOLGEND_CALLSIGN'] ?? ' ',
      style: GUIHelper.gridTextStyle()
    );
  }  

  Widget _opmerking(Map aanwezigData)
  {
    MyGlideDebug.info("_VandaagScreenState._opmerking($aanwezigData)");

    return Text(
      aanwezigData['OPMERKING'] ?? ' ',
      style: GUIHelper.gridTextStyle()
    );
  }   

  // Laat zien 
  // (a) hoe lang de vlieger al vliegt 
  // (b) op welke kist hij/zij is ingedeeld voor de volgende vlucht
  // (c) Hoe lang hij al staat te wachten 
  Widget _showVliegtWachtVolgende(Map aanwezigData) {
    MyGlideDebug.info("_VandaagScreenState._showVliegtWachtVolgende($aanwezigData)");

    if (aanwezigData['ACTUELE_VLIEGTIJD'] != null)
      return _vliegtijdTijd(aanwezigData);
    else if (aanwezigData['VOLGEND_CALLSIGN'] != null)
      return _ingedeeldOp(aanwezigData);
    else
      return _wachtTijd(aanwezigData);
  }
}