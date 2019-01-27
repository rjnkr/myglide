/*
// language packages
import 'package:flutter/material.dart';

// language add-ons

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';

// my glide data providers


// my glide own widgets

// my glide pages

class VandaagGrid extends StatefulWidget {
    VandaagGrid({
    @required this.vandaagSelectedCallback,
    @required this.aanwezig,
  });

  final ValueChanged<Map> vandaagSelectedCallback;
  final List aanwezig;

  @override
  _VandaagGridState createState() => _VandaagGridState();
}

class _VandaagGridState extends State<VandaagGrid> {
  int _sortColIdx = 0;
  bool _sortAsc = true;

  @override
  Widget build(BuildContext context) {
    List<DataColumn> _columns = List<DataColumn>();

    // Kolom headers
    _columns.add(DataColumn(
      label: Text("#"),
      onSort: (int columnIndex, bool ascending) {
        setState(() {
          sortVandaag(index: columnIndex, asc: ascending);
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
          sortVandaag(index: columnIndex, asc: ascending);
          _sortColIdx = columnIndex;
          _sortAsc = ascending;
        });
      }
    ));

    _columns.add(DataColumn(
      label: Text("Starts"),
      onSort: (int columnIndex, bool ascending) {
        setState(() {
          sortVandaag(index: columnIndex, asc: ascending);
          _sortColIdx = columnIndex;
          _sortAsc = ascending;
        });
      }
    ));

    _columns.add(DataColumn(
      label: Text("Vandaag"),
      onSort: (int columnIndex, bool ascending) {
        setState(() {
          sortVandaag(index: columnIndex, asc: ascending);
          _sortColIdx = columnIndex;
          _sortAsc = ascending;
        });
      }
    ));

    _columns.add(DataColumn(
      label: Text("Voorkeur"),
      onSort: (int columnIndex, bool ascending) {},
    ));

    _columns.add(DataColumn(
      label: Text("V/W/I"),
      tooltip: "Rood = wachttijd, Groen = vliegtijd huidige vlucht, Zwart = ingedeeld op",
      onSort: (int columnIndex, bool ascending) {},
    ));

    _columns.add(DataColumn(
      label: Text("Opmerking"),   
      onSort: (int columnIndex, bool ascending) {},
    ));


    List<DataRow> _rows = List.generate(widget.aanwezig.length, (int index) => DataRow(
        cells: [
          new DataCell(_nummer(index)),
          new DataCell(_naam(widget.aanwezig[index])),
          new DataCell(_startsVandaag(widget.aanwezig[index])),
          new DataCell(_vliegtijdVandaag(widget.aanwezig[index])),
          new DataCell(_voorkeurType(widget.aanwezig[index])),
          new DataCell(_showVliegtWachtVolgende(widget.aanwezig[index])),          
          new DataCell(_opmerking(widget.aanwezig[index])),
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

  // Sorteeer de dataset op basis van de keuze van de gebruiker
  sortVandaag({int index=-1, bool asc=true, List data}) {
    if (index < 0) {
      index = _sortColIdx;
      asc = _sortAsc;
    }

    if (data == null)
      data = widget.aanwezig;

    switch (index)
    {
      case 0: {
        data.sort((a,b) {
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
        data.sort((a,b) {
          String sa = a['NAAM'] ?? " ";
          String sb = b['NAAM'] ?? " ";

          return (asc) ? sa.compareTo(sb) : sb.compareTo(sa);
        });
        break;        
      }
      case 2: {
        data.sort((a,b) {
          int va = int.parse(a['STARTLIJST_VANDAAG'] ?? 0);
          int vb = int.parse(b['STARTLIJST_VANDAAG'] ?? 0);

          return ((asc) ? va.compareTo(vb) : vb.compareTo(va));
        });
        break;        
      }
      case 3: {
        data.sort((a,b) {
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
}

*/