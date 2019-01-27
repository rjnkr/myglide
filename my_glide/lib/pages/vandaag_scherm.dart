// language packages
import 'package:flutter/material.dart';
import 'dart:async';

// language add-ons
import 'package:connectivity/connectivity.dart';

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/storage.dart';

// my glide data providers
import 'package:my_glide/data/aanwezig.dart';

// my glide own widgets
import 'package:my_glide/widget/hoofd_menu.dart';

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
      body: _toonGrid(context)

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
        _sortVandaag();
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

    // Sorteeer de dataset op basis van de keuze van de gebruiker
  _sortVandaag({int index=-1, bool asc=true}) {
    if (index < 0) {
      index = _sortColIdx;
      asc = _sortAsc;
    }

    switch (index)
    {
      case 0: {
        _ledenAanwezig.sort((a,b) {
          String sa = a['AANKOMST'] ?? "00:00";
          String sb = b['AANKOMST'] ?? "00:00";

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
      case 1: {
        _ledenAanwezig.sort((a,b) {
          String sa = a['NAAM'] ?? " ";
          String sb = b['NAAM'] ?? " ";

          return (asc) ? sa.compareTo(sb) : sb.compareTo(sa);
        });
        break;        
      }
      case 2: {
        _ledenAanwezig.sort((a,b) {
          int va = int.parse(a['STARTLIJST_VANDAAG'] ?? 0);
          int vb = int.parse(b['STARTLIJST_VANDAAG'] ?? 0);

          return ((asc) ? va.compareTo(vb) : vb.compareTo(va));
        });
        break;        
      }
      case 3: {
        _ledenAanwezig.sort((a,b) {
          String sa = a['VLIEGTIJD_VANDAAG'] ?? "00:00";
          String sb = b['VLIEGTIJD_VANDAAG'] ?? "00:00";

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
    List<DataColumn> _columns = List<DataColumn>();

    // Kolom headers
    _columns.add(DataColumn(
      label: Text("#"),
      onSort: (int columnIndex, bool ascending) {
        setState(() {
          _sortVandaag(index: columnIndex, asc: ascending);
          _sortColIdx = columnIndex;
          _sortAsc = ascending;
        });
      }
    ));

    _columns.add(DataColumn(
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

    _columns.add(DataColumn(
      label: Text("Starts"),
      onSort: (int columnIndex, bool ascending) {
        setState(() {
          _sortVandaag(index: columnIndex, asc: ascending);
          _sortColIdx = columnIndex;
          _sortAsc = ascending;
        });
      }
    ));

    _columns.add(DataColumn(
      label: Text("Vandaag"),
      onSort: (int columnIndex, bool ascending) {
        setState(() {
          _sortVandaag(index: columnIndex, asc: ascending);
          _sortColIdx = columnIndex;
          _sortAsc = ascending;
        });
      }
    ));

    _columns.add(DataColumn(
      label: Text("V/W/I"),
      tooltip: "Rood = wachttijd, Groen = vliegtijd huidige vlucht, Zwart = ingedeeld op",
      onSort: (int columnIndex, bool ascending) {},
    ));

    _columns.add(DataColumn(
      label: Text("Voorkeur"),
      onSort: (int columnIndex, bool ascending) {},
    ));

    _columns.add(DataColumn(
      label: Text("Opmerking"),   
      onSort: (int columnIndex, bool ascending) {},
    ));

    List<DataRow> _rows = List.generate(_ledenAanwezig.length, (int index) => DataRow(
        cells: [
          DataCell(_nummer(index), onTap: () => _showDetails(index)),
          DataCell(_naam(_ledenAanwezig[index]), onTap: () => _showDetails(index)),
          DataCell(_startsVandaag(_ledenAanwezig[index]), onTap: () => _showDetails(index)),
          DataCell(_vliegtijdVandaag(_ledenAanwezig[index]), onTap: () => _showDetails(index)),
          DataCell(_showVliegtWachtVolgende(_ledenAanwezig[index]), onTap: () => _showDetails(index)),            
          DataCell(_voorkeurType(_ledenAanwezig[index]), onTap: () => _showDetails(index)),
          DataCell(_opmerking(_ledenAanwezig[index]), onTap: () => _showDetails(index))
        ]
      )
    );

    return ListView(
      padding: EdgeInsets.all(20.0), 
      children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            sortColumnIndex: _sortColIdx,
            sortAscending: _sortAsc,
            rows: _rows,
            columns: _columns,
          ),
        ),
      ]);
  }

  void _showDetails(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return AanwezigDetailsScreen(
            isInTabletLayout: false,
            aanwezig: _ledenAanwezig[index],
          );
        },
      ),
    );
  }

  Widget _nummer(int nr) {
    return CircleAvatar(
      radius: 12.0, 
      backgroundColor: MyGlideConst.backgroundColor,
      child: Text(
        (nr+1).toString(),
        style: TextStyle(fontSize: 13.0)
      )
    );
  }

  Widget _naam(Map aanwezigData) {
    return Text(
      aanwezigData['NAAM'],
      style: _gridTextStyle()
    );
  }

  Widget _startsVandaag(Map aanwezigData) {
    return Text(
      aanwezigData['STARTLIJST_VANDAAG'] ?? '0',
      style: _gridTextStyle(weight: FontWeight.bold)
    );
  }

  Widget _vliegtijdVandaag(Map aanwezigData) {
    return Text(
      aanwezigData['VLIEGTIJD_VANDAAG'] ?? ' '.toString().replaceFirst(new RegExp(r'0'), ''),
      style: _gridTextStyle(weight: FontWeight.bold)
    );
  }

  Widget _voorkeurType(Map aanwezigData)
  {
    return Text(
      aanwezigData['VOORKEUR_TYPE'] ?? ' ',
      style: _gridTextStyle()
    );
  }

  Widget _wachtTijd(Map aanwezigData)
  {
    return Text(
      aanwezigData['WACHTTIJD'] ?? ' ',
      style: _gridTextStyle(color: MyGlideConst.landingstijdColor)
    );
  }

  Widget _vliegtijdTijd(Map aanwezigData)
  {
    return Text(
      aanwezigData['ACTUELE_VLIEGTIJD'] ?? ' ',
      style: _gridTextStyle(color: MyGlideConst.starttijdColor)
    );
  }

  Widget _ingedeeldOp(Map aanwezigData)
  {
    return Text(
      aanwezigData['VOLGEND_CALLSIGN'] ?? ' ',
      style: _gridTextStyle()
    );
  }  

  Widget _opmerking(Map aanwezigData)
  {
    return Text(
      aanwezigData['OPMERKING'] ?? ' ',
      style: _gridTextStyle()
    );
  }   

  // Laat zien 
  // (a) hoe lang de vlieger al vliegt 
  // (b) op welke kist hij/zij is ingedeeld voor de volgende vlucht
  // (c) Hoe lang hij al staat te wachten 
  Widget _showVliegtWachtVolgende(Map aanwezigData) {
    if (aanwezigData['ACTUELE_VLIEGTIJD'] != null)
      return _vliegtijdTijd(aanwezigData);
    else if (aanwezigData['VOLGEND_CALLSIGN'] != null)
      return _ingedeeldOp(aanwezigData);
    else
      return _wachtTijd(aanwezigData);
  }

  // Hoe wordt het veld in het grid vertoond
  TextStyle _gridTextStyle({color = MyGlideConst.gridTextColor, weight = FontWeight.normal, fontSize = MyGlideConst.gridTextNormal}) {
    return TextStyle (
      color: color,
      fontWeight: weight,
      fontSize: fontSize
    );
  }    
}