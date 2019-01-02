
// language packages
import 'package:flutter/material.dart';

// language add-ons

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';

// my glide own widgets
import 'package:my_glide/widget/hoofd_menu.dart';

// my glide pages

class VliegtuigLogboekScreen extends StatefulWidget {
  @override
  _VliegtuigLogboekScreenState createState() => _VliegtuigLogboekScreenState();
}

class _VliegtuigLogboekScreenState extends State<VliegtuigLogboekScreen> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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
              isScrollable: true,
              
            ),
            actions: <Widget>[
              IconButton (
            //    onPressed: () => _ophalenLogboek(true),
                icon: Icon(Icons.refresh, color: MyGlideConst.frontColor),
                padding: const EdgeInsets.only(right: 10.0)              
              )
            ],
          ),
          drawer: HoofdMenu(),
         body: TabBarView(
           children: <Widget>[
             Icon(Icons.directions_car),
             Icon(Icons.directions_bike),
             Icon(Icons.directions_bus),
             Icon(Icons.directions_bus),
           ],
         )
        ),
    );
  }

  List<Widget> _toonTabbladen(){
    List<Widget> retVal = List<Widget>();

    for (int i=1; i< 10; i++) {
      retVal.add(_toonTabblad("E$i"));
    }
    return retVal;
  }

  Widget _toonTabblad(String callsign) {
    return Text(callsign);
  }
}