// language packages
import 'package:flutter/material.dart';

// language add-ons
import 'package:flutter_mailer/flutter_mailer.dart';

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/debug.dart';

// my glide data providers
import 'package:my_glide/data/session.dart';
import 'package:my_glide/data/leden.dart';

// my glide own widgets
import 'package:my_glide/widget/hoofd_menu.dart';

// my glide pages
import 'package:my_glide/pages/gui_helpers.dart';
import 'package:my_glide/pages/leden_lijst_filter.dart';
import 'package:my_glide/pages/leden_lijst_container.dart';

class LedenLijstScreen extends StatefulWidget {
  @override
  _LedenLijstScreenState createState() => _LedenLijstScreenState();
}

class _LedenLijstScreenState extends State<LedenLijstScreen> {
  List _ledenlijst;
  List _toonlijst = new List();

  String _zoekTekst;
  bool _lierist = false;
  bool _instructeur = false;
  bool _startleider = false;
  bool _aanwezig = false;

  TextEditingController searchController = new TextEditingController();

  @override
  void initState() {
    MyGlideDebug.info("_LedenLijstScreenState.initState()");

    super.initState();

    searchController.addListener(() {
      _zoekTekst = searchController.text;
      _toepassenLedenFilter();
    });

    Leden.getLeden().then((response) {
      // setState alleen als dit scherm er nog is
      if (mounted)      
      {
        setState(() {
          _ledenlijst = response;
          _toepassenLedenFilter();
        });
      }
    }); 
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }  

  @override
  Widget build(BuildContext context) {
    MyGlideDebug.info("_LedenLijstScreenState.build(context)");
   
    if (_ledenlijst == null) return GUIHelper.showLoading();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyGlideConst.appBarBackground(),
        iconTheme: IconThemeData(color: MyGlideConst.frontColor),
        title: Text(
          "Ledenlijst",
          style: MyGlideConst.appBarTextColor()
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () => _sendEmail(),
            padding: const EdgeInsets.only(right: 20.0), 
            icon: Icon(Icons.email,
              color: MyGlideConst.frontColor),
          ),
          IconButton (
            onPressed: () { _filterLedenLijst(context); },
            icon: Icon(Icons.tune,
              color: MyGlideConst.frontColor),
            padding: const EdgeInsets.only(right: 10.0)              
          )
        ],
      ),
      drawer: HoofdMenu(),
      body: 
        Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Zoek lid',
                  suffixIcon: IconButton(
                      icon: Icon(Icons.cancel),
                      onPressed: () {
                        searchController.clear();
                      }),
                  contentPadding: EdgeInsets.fromLTRB(15.0, 5.0, 5.0, 5.0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                ),
              ),
            ),  
            Expanded(
              child: LedenlijstContainer(ledenlijst: _toonlijst,)   // Hier is het om te doen, de ledenlijst
            )
          ]
        )
    );
  }      

  void _filterLedenLijst(BuildContext context) async {
    String result = await showDialog(
        context: context,
        barrierDismissible: false, // user must tap button for close dialog!
        builder: (_) {
          return LedenLijstFilterScreen();
      });
    
    if (result != null) {
      List<String> filters = result.split(",");

      _aanwezig = filters[0].toLowerCase() == 'true';
      _lierist = filters[1].toLowerCase() == 'true';
      _instructeur = filters[2].toLowerCase() == 'true';
      _startleider = filters[3].toLowerCase() == 'true';

      _toepassenLedenFilter();
    }

  }

  void _toepassenLedenFilter()
  {
    MyGlideDebug.info("_LedenlijstContainerState._toepassenLedenFilter filter = $_zoekTekst / $_aanwezig / $_lierist / $_instructeur / $_startleider");  
    setState(() {
      
      _toonlijst.clear();
      for (int i=0 ; i < _ledenlijst.length ; i++)
      {
        bool voldoet = false;

        if ((_zoekTekst == null) || (_zoekTekst == ""))
          voldoet = true;
        else if (_ledenlijst[i]["NAAM"].toLowerCase().contains(searchController.text.toLowerCase()))
          voldoet = true;

        if (voldoet) {
          print(_ledenlijst[i]["AANWEZIG"].toString());
          if ((_aanwezig) && (_ledenlijst[i]["AANWEZIG"].toString() != "1")) {
              voldoet = false;
          }
          else
          {
            if ((_lierist) && (_ledenlijst[i]["LIERIST"].toString() != "1"))
              voldoet = false;   

            if ((_instructeur) && (_ledenlijst[i]["INSTRUCTEUR"].toString() != "1"))
              voldoet = false;   

            if ((_startleider) && (_ledenlijst[i]["STARTLEIDER"].toString() != "1"))
              voldoet = false;           
          }
        }

        if (voldoet) 
          _toonlijst.add(_ledenlijst[i]);  
      } 
    });
  }

  // email versturen naar een lid
  // we maken alvast een template met ietswat tekst
  void _sendEmail() async {
    MyGlideDebug.info("_LidDetailsScreenState._sendEmail()");

    if (serverSession.login.userInfo == null)       // we weten niet wie ingelogd is
      return ;

    // wie krijgen er allemaal een email ?
    List<String> ontvangers = List<String>();
    for (Map lid in _toonlijst) {
      if ((lid["EMAIL"] != null) && (lid["EMAIL"].contains("@"))) 
        ontvangers.add(lid["EMAIL"]);
    }

    String emailBody = "<< hier uw tekst >> <br><br>Met vriendelijke groet,<br><br>";
    emailBody += "${serverSession.login.userInfo['NAAM']}<br><br><em>Deze mail is verstuurd vanuit de GeZC MyGlide app</em>";

    final MailOptions mailOptions = MailOptions(
      body: emailBody,
      recipients: ontvangers,
      isHTML: true,
    );
    await FlutterMailer.send(mailOptions);
  }  
}