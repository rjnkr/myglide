 
// language packages
import 'package:flutter/material.dart';

// language add-ons
import 'package:auto_size_text/auto_size_text.dart';

// my glide utils
import 'package:my_glide/utils/debug.dart';

// my glide data providers
import 'package:my_glide/data/session.dart';

// my glide own widgets

// my glide pages
import 'package:my_glide/pages/gui_helpers.dart';

class LedenLijstGrid extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    MyGlideDebug.info("LedenLijstGrid.build(context)"); 

    return Container();
  }
  
  // Toon de basis informatie 
  static Widget lidRegel(BuildContext context, Map lidData) { 
    MyGlideDebug.info("LedenLijstGrid.lidRegel(context, $lidData)"); 

    Color kleur = Colors.white;

    if (((serverSession.login.isBeheerderDDWV) || (serverSession.login.isBeheerder) || (serverSession.isDemo)) && (lidData['HEEFT_BETAALD'] == "0"))
      kleur = Colors.grey;

    return 
      Card(
        elevation: 2,
        margin: EdgeInsets.all(3),  
        color: kleur,            
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child:Container(
            height: 70,
            margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: <Widget>[
                  GUIHelper.avatar(lidData['AVATAR'], 25),

                  Container (
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Column (
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(lidData['NAAM'], style: TextStyle(fontWeight: FontWeight.bold)),
                        _telefoonnummers(lidData),
                        AutoSizeText(lidData['EMAIL'] ?? ' ', overflow: TextOverflow.ellipsis)
                      ]
                    )
                  )
                ],
              )
            )
          )
        )
      );
  }

  // Toon het telefoonnummer en het mobiele nummer in 1 regel
  static Widget _telefoonnummers(Map lidData) {
    return Container(
      child: Row (
        children: <Widget>[
          _telnummer(lidData),
          _mobnummer(lidData)
        ],
      ),
    );
  }

  // Toon het telefoonnummer als het is ingevuld
  static Widget _telnummer(Map lidData) {
    if (lidData['TELEFOON'] == null)
      return Container(width: 0, height: 0);

    return 
      SizedBox(
        width: 120,
        child: Text(lidData['TELEFOON'])
      );
  }

  // Toon het mobiele nummer als het is ingevuld
  static Widget _mobnummer(Map lidData) {
    if (lidData['MOBIEL'] == null)
      return Container(width: 0, height: 0);

    return 
      Text(lidData['MOBIEL']);
  }
}
