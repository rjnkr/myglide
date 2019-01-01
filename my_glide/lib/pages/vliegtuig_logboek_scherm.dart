import 'package:flutter/material.dart';
import 'package:my_glide/utils/my_glide_const.dart';

import 'package:my_glide/widget/hoofd_menu.dart';

class VliegtuigLogboekScreen extends StatefulWidget {
  @override
  _VliegtuigLogboekScreenState createState() => _VliegtuigLogboekScreenState();
}

class _VliegtuigLogboekScreenState extends State<VliegtuigLogboekScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyGlideConst.appBarBackground(),
        iconTheme: IconThemeData(color: MyGlideConst.frontColor),
        title: Text(
          "Vliegtuig logboek",
          style: MyGlideConst.appBarTextColor()
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
     // body: 
    );
  }
}