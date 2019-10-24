
// language packages
import 'package:flutter/material.dart';

// language add-ons

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';
import "package:my_glide/utils/storage.dart";
import 'package:my_glide/utils/debug.dart';

// my glide data providers

// my glide own widgets

// my glide pages

class VliegtuigenFilterScreen extends StatefulWidget {
  @override
  _VliegtuigenFilterScreenState createState() => _VliegtuigenFilterScreenState();
}

class _VliegtuigenFilterScreenState extends State<VliegtuigenFilterScreen> {
  
  bool _clubkisten = false;
  bool _favorite = false;
  bool _all = false;

  @override
  void initState() {
    MyGlideDebug.info("_VliegtuigenFilterScreenState.initState()");

    Storage.getBool('toonAlleenClubKisten', defaultValue: true).then((val) 
    {
      setState(() { _clubkisten = val; });
    });
    Storage.getBool('toonAlleenFavoriten', defaultValue: true).then((val)
    {
      setState(() { _favorite = val; });
    });
    Storage.getBool('toonAlleKisten', defaultValue: false).then((val) 
    {
      setState(() { _all = val; });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    double hoogte = 150.0;

    MyGlideDebug.info("_VliegtuigenFilterScreenState.build(context)");

    return AlertDialog(
      title: Text("Kies filter"),
      contentPadding: EdgeInsets.all(0),
      content: Container(
        height: hoogte,
        width: 300,
        child: ListView(
          children: <Widget>[
            CheckboxListTile(
              title: Text("Club vliegtuigen"),
              dense: true,
              activeColor: MyGlideConst.frontColor,
              value: _clubkisten,
              secondary: Icon(Icons.card_membership),
              onChanged: (bool value) {
                setState(() {
                  _clubkisten = value;
                  if ((_clubkisten == true) && (_all == true))
                    _all = false;

                  if ((_clubkisten == false) && (_favorite == false) && (_all == false))
                    _all = true;
                });
              }                
            ),
            CheckboxListTile(
              title: Text("Favoriete vliegtuig"),
              dense: true,
              activeColor: MyGlideConst.frontColor,
              value: _favorite,
              secondary: Icon(Icons.star),
              onChanged: (bool value) {
                setState(() {
                  _favorite = value;

                  if ((_favorite == true) && (_all == true))
                    _all = false;

                  if ((_favorite == false) && (_clubkisten == false) && (_all))
                    _clubkisten = true;
                });
              }
            ),
            CheckboxListTile(
              title: Text("Alle vliegtuigen"),
              dense: true,
              activeColor: MyGlideConst.frontColor,
              value: _all,
              secondary: Icon(Icons.all_inclusive),
              onChanged: (bool value) {
                setState(() {
                  _all = value;
                  if (_all == true) {
                    _clubkisten = false;
                    _favorite = false;
                  }
                  else
                  {
                    if ((_clubkisten == false) && (_favorite == false))
                      _clubkisten = true;
                  }
                });
              }
            ),
          ]
        ), 
      ),

      actions: <Widget>[
        FlatButton(
          child: const Text('Annuleren'),
          onPressed: () => Navigator.of(context).pop(null),
        ),
        FlatButton(
          child: const Text('Toepassen'),
          onPressed: () {
            Storage.setBool('toonAlleenClubKisten', _clubkisten);
            Storage.setBool('toonAlleenFavoriten', _favorite);
            Storage.setBool('toonAlleKisten', _all);

            Navigator.of(context).pop("$_clubkisten, $_favorite, $_all");
          }
        )
      ],
    ); 
  }
}