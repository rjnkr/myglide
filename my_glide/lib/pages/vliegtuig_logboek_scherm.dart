
// language packages
import 'package:flutter/material.dart';

// language add-ons

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';

// my glide data providers
import 'package:my_glide/data/vliegtuigen.dart';
import 'package:my_glide/data/startlijst.dart';

// my glide own widgets
import 'package:my_glide/widget/hoofd_menu.dart';

// my glide pages
import 'package:my_glide/pages/gui_helpers.dart';

class VliegtuigLogboekTabScreen extends StatefulWidget {
  @override
  _VliegtuigLogboekTabScreenState createState() => _VliegtuigLogboekTabScreenState();
}

class _VliegtuigLogboekTabScreenState extends State<VliegtuigLogboekTabScreen> {
  Map _vliegtuigen;

  @override
  void initState() {
    super.initState();

    Vliegtuigen.getClubKisten().then((response) {
      setState(() {
        _vliegtuigen = response;
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (_vliegtuigen == null) return GUIHelper.showLoading();

    return DefaultTabController(
      length: int.parse(_vliegtuigen['total']),
      child: 
        Scaffold(
          appBar: AppBar(
            backgroundColor: MyGlideConst.appBarBackground(),
            iconTheme: IconThemeData(color: MyGlideConst.frontColor),
            title: Text(
              "Vliegtuig logboek",
              style: MyGlideConst.appBarTextColor()
            ),
            bottom: TabBar(
              tabs:  _toonTabbladen(),
              labelStyle: TextStyle(fontSize: MyGlideConst.labelSizeLarge),
              labelColor: MyGlideConst.frontColor,
              indicatorColor: MyGlideConst.frontColor,
              isScrollable: true
            )
          ),
          drawer: HoofdMenu(),
          body: TabBarView(
            children: _tabBladenInhoud(),
         )
        ),
    );
  }

  List<Widget> _toonTabbladen(){
    List<Widget> retVal = List<Widget>();

    for (int i=0; i< int.parse(_vliegtuigen['total']); i++) {
      retVal.add(Text(_vliegtuigen['results'][i]['CALLSIGN']));
    }
    return retVal;
  }

  List<Widget> _tabBladenInhoud() {
    List<Widget> retVal = List<Widget>();

    for (int i=0; i< int.parse(_vliegtuigen['total']); i++) {
      retVal.add(VliegtuigLogboekTab(vliegtuigID:_vliegtuigen['results'][i]['ID']));
    }
    return retVal;
  }
}

class VliegtuigLogboekTab extends StatefulWidget {
  final String vliegtuigID;

  VliegtuigLogboekTab (
  {
    @required this.vliegtuigID
  });
  
  @override
  _VliegtuigLogboekTabState createState() => _VliegtuigLogboekTabState();
}

class _VliegtuigLogboekTabState extends State<VliegtuigLogboekTab> {
  List _logboekItems;
  
  @override
  void initState() {
    super.initState();

    Startlijst.getVliegtuigLogboek(widget.vliegtuigID).then((logboek)
    {
      setState(() {
        _logboekItems = logboek;      
      });
    });
  }

@override
  Widget build(BuildContext context) {
    return  
      ListView.builder (
        itemCount:  _logboekItems == null ? 0 : _logboekItems.length,
        itemBuilder: (BuildContext context, int index) =>
          _logboekItem(index)  // Toon logboek regel
      );
  }
  
  // De kaart waarin de informatie getoond wordt
  Widget _logboekItem(int index) {
    return 
    Card(
      elevation: 1.5,
      child: _logboekRegel(index)
    );
  }

  // Toon de informatie van de vliegdag
  Widget _logboekRegel(index) { 
    String datum = _logboekItems[index]['DATUM'].toString();

    if (datum != null)
      datum = datum.substring(8,10) + "-" + datum.substring(5,7) + "-" + datum.substring(0,4);
    
    return
      Container(
        height: 130,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column (
            children: <Widget>[
              GUIHelper.showDetailsField("Datum", datum),
              GUIHelper.showDetailsField("Vluchten", _logboekItems[index]['VLUCHTEN']),
              GUIHelper.showDetailsField("Vliegtijd", _logboekItems[index]['VLIEGTIJD']),
              GUIHelper.showDetailsField("Lierstarts", _logboekItems[index]['LIERSTARTS']),
              GUIHelper.showDetailsField("Sleepstarts", _logboekItems[index]['SLEEPSTARTS']),
            ]
          )
        )
      );
  }
}