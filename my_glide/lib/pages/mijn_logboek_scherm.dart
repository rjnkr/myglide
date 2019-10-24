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
import 'package:my_glide/data/startlijst.dart';
import 'package:my_glide/data/session.dart';

// my glide own widgets
import 'package:my_glide/widget/hoofd_menu.dart';

// my glide pages
import 'package:my_glide/pages/gui_helpers.dart';
import 'package:my_glide/pages/startlijst_container.dart';

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
    MyGlideDebug.info("_MijnLogboekScreenState()");
    // check iedere seconde of we logboek automatisch moeten ophalen
    // reageert daarmee (bijna) direct op instelling
    _autoUpdateTimer = Timer.periodic(Duration(seconds: 1), (Timer t) => _autoOphalenLogboek()); 
  }

  @override
  void initState() {
    MyGlideDebug.info("_MijnLogboekScreenState.initState()");
    super.initState();

    _ophalenLogboek(false);
  }

  @override
  void dispose() {
    MyGlideDebug.info("_MijnLogboekScreenState.dispose()");
    super.dispose();

    _autoUpdateTimer.cancel();    // Stop de timer, anders krijgen we parallele sessie
  }
  

  @override
  Widget build(BuildContext context) {
    MyGlideDebug.info("_MijnLogboekScreenState.build(context");

    // Er is nog geen data om te tonen
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
      body: StartlijstContainer(starts:_logboekItems)   // Hier is het om te doen, het logboek van de vlieger
    );
  }
  
  
  void _showAangemeld() {
    MyGlideDebug.info("_MijnLogboekScreenState._showAangemeld()");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Aanmelding"),
        content: serverSession.login.isAangemeld ? Text("U bent aangemeld voor de vliegdag van vandaag") : Text("U bent nog NIET aangemeld voor vandaag") ,
      )
    ); 
  }

  void _ophalenLogboek(bool handmatig) {
    MyGlideDebug.info("_MijnLogboekScreenState._ophalenLogboek($handmatig)");

    bool volledig = false;
    if (handmatig)
    {
      final int lastRefresh = DateTime.now().difference(_lastRefreshButton).inSeconds;
      if (lastRefresh < 5) volledig = true;
    }
    
    Startlijst.getLogboek(force: volledig).then((response) {
      // setState alleen als dit scherm er nog is
      if (mounted)      
      {
        setState(() {
          _logboekItems = response;
          _lastRefresh = DateTime.now();
        });
      }
    });
  }

  void _autoOphalenLogboek()
  {
    MyGlideDebug.info("_MijnLogboekScreenState._autoOphalenLogboek()");

    final DateTime now = DateTime.now();
    final int lastRefresh = now.difference(_lastRefresh).inSeconds;

    if (_isAangemeld != serverSession.login.isAangemeld)
    {
      // setState alleen als dit scherm er nog is
      if (mounted)      
      {
        setState(() {
          _isAangemeld = serverSession.login.isAangemeld;     
        });
      }    
    }
    Connectivity().checkConnectivity().then((result)
    {
      // setState alleen als dit scherm er nog is
      if (mounted)      
      {
        if (_netwerkStatus != result) {
          setState(() {
            _netwerkStatus = result;
          });
        }
      }       
    });

    // We halen iedere 5 miniuten
    if (lastRefresh < MyGlideConst.logboekRefreshRate)
      return;

    // We gaan geen data ophalen als de zon onder is. Zuinig zijn met data
    if ((serverSession.zonOpkomst != null) && (serverSession.zonOndergang != null))
      if (now.isBefore(serverSession.zonOpkomst) || now.isAfter(serverSession.zonOndergang))
          return;

    // ophalen logboek indien autoLoadLogboek = true, indien niet gezet dan gebeurd er niets
    Storage.getBool('autoLoadLogboek', defaultValue: false).then((value) { 
      if (value) 
        _ophalenLogboek(false); 
    });
  }
}