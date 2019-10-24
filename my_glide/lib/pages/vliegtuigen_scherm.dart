// language packages
import 'package:flutter/material.dart';
import 'dart:convert';

// language add-ons

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';
import "package:my_glide/utils/storage.dart";
import 'package:my_glide/utils/debug.dart';

// my glide data providers
import 'package:my_glide/data/vliegtuigen.dart';

// my glide own widgets
import 'package:my_glide/widget/hoofd_menu.dart';

// my glide pages
import 'package:my_glide/pages/gui_helpers.dart';
import 'package:my_glide/pages/vliegtuigen_filter.dart';
import 'package:my_glide/pages/vliegtuigen_container.dart';

class VliegtuigenScreen extends StatefulWidget {
  @override
  _VliegtuigenScreenState createState() => _VliegtuigenScreenState();
}

class _VliegtuigenScreenState extends State<VliegtuigenScreen> {
  List _vliegtuigenLijst;
  List _favorieten = new List();
  List _toonlijst = new List();
  bool _alleenClubKisten;
  bool _alleenFavorieten;
  bool _alleKisten;

  String _zoekTekst;

  TextEditingController searchController = new TextEditingController();

  @override
  void initState() {
    MyGlideDebug.info("_VliegtuigenScreenState.initState()");

    super.initState();

    searchController.addListener(() {
      _zoekTekst = searchController.text;
      _toepassenVliegtuigFilter();
    });

    Storage.getString('favorieteKisten').then((favorietenJSON) {
      if (favorietenJSON != null) {
        _favorieten = json.decode(favorietenJSON);
      }
    });

    _ladenVliegtuigen();    // Die moet in een eigen functie want await kan niet gebruikt worden in initState
  }

  void _ladenVliegtuigen() async {
    _alleenClubKisten = await Storage.getBool('toonAlleenClubKisten', defaultValue: true);
    _alleenFavorieten = await Storage.getBool('toonAlleenFavoriten', defaultValue: true);
    _alleKisten = await Storage.getBool('toonAlleKisten', defaultValue: false);

    Vliegtuigen.getVliegtuigen(
      alleenClubKisten: _alleenClubKisten,
      alleenFavorieten: _alleenFavorieten,
      alleKisten: _alleKisten).then((response) {
      // setState alleen als dit scherm er nog is
      if (mounted)      
      {
        setState(() {
          _vliegtuigenLijst = response;
          // aangevene welk vliegtuig favoriet is
          _vliegtuigenLijst.forEach((vliegtuig) {
            if (_favorieten.contains(vliegtuig["ID"]))
              vliegtuig["FAVORIET"] = true;
            else
              vliegtuig["FAVORIET"] = false;
          });

          _toepassenVliegtuigFilter();
        });
      }
    }); 
  }

  @override
  void dispose() {
    searchController.dispose();

    Storage.getBool('toonAlleKisten', defaultValue: false).then((toonAlleKisten) {
      if (toonAlleKisten) {
        Storage.setBool('toonAlleenClubKisten', true);
        Storage.setBool('toonAlleenFavoriten', true);
        Storage.setBool('toonAlleKisten', false);
      }
    });
    super.dispose();
  }  

  @override
  Widget build(BuildContext context) {
    MyGlideDebug.info("_VliegtuigenScreenState.build(context)");
   
    if (_vliegtuigenLijst == null) return GUIHelper.showLoading();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyGlideConst.appBarBackground(),
        iconTheme: IconThemeData(color: MyGlideConst.frontColor),
        title: Text(
          "Vliegtuigen",
          style: MyGlideConst.appBarTextColor()
        ),
        actions: <Widget>[
          IconButton (
            onPressed:  ()  { _filterVliegtuigenLijst(context); },
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
                  hintText: 'Zoek vliegtuig',
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
              child: VliegtuigenContainer(   // Hier is het om te doen, de vliegtuigen
                vliegtuigen: _toonlijst,
                onFavorietChanged: (id) => setState(() 
                {
                  int p = _vliegtuigenLijst.indexWhere((vliegtuig) => vliegtuig['ID'] == id);   

                  if (p < 0)
                    MyGlideDebug.error("Dit mag niet gebeuren :-(");
                  else 
                  {
                    if (_vliegtuigenLijst[p]["FAVORIET"]) 
                    {
                      // verwijderen uit de lijst met favorieten
                      int i = _favorieten.indexWhere((val) => val == id);
                      _favorieten.removeAt(i);

                      _vliegtuigenLijst[p]["FAVORIET"] = false;   // Verwijder de markering
                    }
                    else
                    {
                      _favorieten.add(id);                        // Toevoegen aan de lijst
                      _vliegtuigenLijst[p]["FAVORIET"] = true;    // Markeer het vliegtuig
                    }

                    String favorietenJSON = json.encode(_favorieten);
                    Storage.setString('favorieteKisten', favorietenJSON);
                  }
                })
              )
            )
          ]
        )
    );
  }      

  void _filterVliegtuigenLijst(BuildContext context) async {
    String result = await showDialog(
        context: context,
        barrierDismissible: false, // user must tap button for close dialog!
        builder: (_) {
          return VliegtuigenFilterScreen();
      });
    
    if (result != null) {
      _ladenVliegtuigen();
    }

  }

  void _toepassenVliegtuigFilter()
  {
    MyGlideDebug.info("_LedenlijstContainerState._toepassenLedenFilter filter = $_zoekTekst");  
    setState(() {
      
      _toonlijst.clear();
      for (int i=0 ; i < _vliegtuigenLijst.length ; i++)
      {
        bool voldoet = false;

        if ((_zoekTekst == null) || (_zoekTekst == ""))
          voldoet = true;
        else if (_vliegtuigenLijst[i]["REGCALL"].toLowerCase().contains(searchController.text.toLowerCase()))
          voldoet = true;

        if (voldoet) 
          _toonlijst.add(_vliegtuigenLijst[i]);  
      } 
    });
  }
}