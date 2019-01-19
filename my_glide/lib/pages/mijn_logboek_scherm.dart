// language packages
import 'package:flutter/material.dart';
import 'dart:async';

// language add-ons
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:connectivity/connectivity.dart';

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/storage.dart';


// my glide data providers
import 'package:my_glide/data/startlijst.dart';
import 'package:my_glide/data/session.dart';

// my glide own widgets
import 'package:my_glide/widget/hoofd_menu.dart';

// my glide pages
import 'package:my_glide/pages/gui_helpers.dart';
import 'package:my_glide/pages/startlijst_grid.dart';

class MijnLogboekScreen extends StatefulWidget {
  @override
  _MijnLogboekScreenState createState() => _MijnLogboekScreenState();
}

class _MijnLogboekScreenState extends State<MijnLogboekScreen> with TickerProviderStateMixin {
  List _logboekItems;
    
  DateTime _lastRefresh = DateTime.now();
  DateTime _lastRefreshButton = DateTime.now().add(Duration(days: -1));

  ConnectivityResult _netwerkStatus;
  bool _isAangemeld;

  Timer _autoUpdateTimer;

  _MijnLogboekScreenState()
  {
    // check iedere seconde of we logboek automatisch moeten ophalen
    // reageert daarmee (bijna) direct op instelling
    _autoUpdateTimer = Timer.periodic(Duration(seconds: 1), (Timer t) => _autoOphalenLogboek()); 
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
    if (_logboekItems == null) return GUIHelper.showLoading();
   
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyGlideConst.appBarBackground(),
        iconTheme: IconThemeData(color: MyGlideConst.frontColor),
        title: Text(
          "Mijn logboek",
          style: MyGlideConst.appBarTextColor()
        ),
        actions: <Widget>[
          IconButton(
            onPressed: _showAangemeld,
            padding: const EdgeInsets.only(right: 20.0), 
            icon: Icon (serverSession.login.isAangemeld ? Icons.person : Icons.person_outline,
              color: serverSession.login.isAangemeld ? MyGlideConst.frontColor : MyGlideConst.disabled
            )
          ),
          IconButton (
            onPressed: _netwerkStatus == ConnectivityResult.none  ? null : () => _ophalenLogboek(true),
            icon: Icon(_netwerkStatus == ConnectivityResult.none  ? Icons.cloud_off : Icons.refresh, 
              color: MyGlideConst.frontColor),
            padding: const EdgeInsets.only(right: 10.0)              
          )

        ],
      ),
      drawer: HoofdMenu(),
      body: ListView.builder (
        itemCount:  _logboekItems == null ? 0 : _logboekItems.length,
        itemBuilder: (BuildContext context, int index) =>
              StartlijstGrid.toonVlucht(context, _logboekItems[index], index)  // Toon logboek regel
        )
    );
  }
  
  
  void _showAangemeld() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Aanmelding"),
          content: serverSession.login.isAangemeld ? Text("U bent aangemeld voor de vliegdag van vandaag") : Text("U bent nog NIET aangemeld voor vandaag") ,
        )
    ); 
  }

  void _ophalenLogboek(bool handmatig) {
    bool volledig = false;

    if (handmatig)
    {
      int lastRefresh = DateTime.now().difference(_lastRefreshButton).inSeconds;
      if (lastRefresh < 5) volledig = true;
    }
    
    Startlijst.getLogboek(force: volledig).then((response) {
      setState(() {
        _logboekItems = response;
        _lastRefresh = DateTime.now();
      });
    });
  }

  void _autoOphalenLogboek()
  {
    int lastRefresh = DateTime.now().difference(_lastRefresh).inSeconds;

    if (_isAangemeld != serverSession.login.isAangemeld)
    {
      setState(() {
        _isAangemeld = serverSession.login.isAangemeld;     
      });
    }
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
    Storage.getBool('autoLoadLogboek').then((value) { if (value) _ophalenLogboek(false); });
  }

}