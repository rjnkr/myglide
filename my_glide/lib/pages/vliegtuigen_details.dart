
// language packages
import 'package:flutter/material.dart';

// language add-ons

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/debug.dart';

// my glide data providers
import 'package:my_glide/data/startlijst.dart';

// my glide own widgets

// my glide pages
import 'package:my_glide/pages/gui_helpers.dart';

class VliegtuigDetailsScreen extends StatefulWidget {
  final String vliegtuigID;
  final String callSign;
  final bool isInTabletLayout;

  const VliegtuigDetailsScreen({
    Key key, 
    this.isInTabletLayout,
    @required this.vliegtuigID,
    @required this.callSign }) : super (key: key);

  @override
  _VliegtuigDetailsScreenState createState() => _VliegtuigDetailsScreenState();
}

class _VliegtuigDetailsScreenState extends State<VliegtuigDetailsScreen> {
  List _logboekItems;
  String lastVliegtuigID;
  
  @override
  void initState() {
    MyGlideDebug.info("_VliegtuigDetailsScreenState.initState()");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MyGlideDebug.info("_VliegtuigDetailsScreenState.build(context)");

    if (widget.vliegtuigID != null)       // null wordt gebruikt in tablet mode, er is dan niets geselecteerd
    {
      if (lastVliegtuigID != widget.vliegtuigID) {
        Startlijst.getVliegtuigLogboek(widget.vliegtuigID).then((logboek)
        {
          setState(() {
            _logboekItems = logboek;      
          });
        });
        lastVliegtuigID = widget.vliegtuigID;
      }
    }

    if (widget.vliegtuigID == null)  return Container();     // null wordt gebruikt in tablet mode, er is dan niets geselecteerd
    if (_logboekItems == null) return GUIHelper.showLoading();

    Widget content =
      ListView.builder (
        itemCount:  _logboekItems == null ? 0 : _logboekItems.length,
        itemBuilder: (BuildContext context, int index) =>
          _logboekItem(index)  // Toon logboek regel
      );

    if (_logboekItems.length == 0)
      content = GUIHelper.geenData(bericht: "U heeft geen rechten om het logboek in te zien of er zijn geen vluchten.");

    if (widget.isInTabletLayout) {
        return 
          Column(children: <Widget>[
            Container(
              child: Text("Logboek  ${widget.callSign}")
            ),
            Divider(),
            Flexible(
              child: Center(child: content)
            )
          ]);
    }

    // We hebben een popup op een smartphone, toon Scaffold 
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyGlideConst.appBarBackground(),
        iconTheme: IconThemeData(color: MyGlideConst.frontColor),
        title: Text(
          "Logboek  ${widget.callSign}",
          style: MyGlideConst.appBarTextColor()
        ),
      ),

      body: Center(child: content),
    );    
  }
  
  // De kaart waarin de informatie getoond wordt
  Widget _logboekItem(int index) {
    MyGlideDebug.info("_VliegtuigDetailsScreenState._logboekItem($index)");

    return 
    Card(
      elevation: 1.5,
      child: _logboekRegel(index)
    );
  }

  // Toon de informatie van de vliegdag
  Widget _logboekRegel(index) {
    MyGlideDebug.info("_VliegtuigDetailsScreenState._logboekRegel($index)");

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