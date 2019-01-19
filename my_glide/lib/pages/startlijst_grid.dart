  
// language packages
import 'package:flutter/material.dart';

// language add-ons
import 'package:flutter_slidable/flutter_slidable.dart';

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';

// my glide data providers

// my glide own widgets

// my glide pages
import 'package:my_glide/pages/mijn_logboek_details_scherm.dart';


class StartlijstGrid
{
  static final double _breedteCirkel = 25;
  static final double _breedteDatum = 50;
  static final double _breedteRegCall = 100;
  static final double _breedteStartTijd = 40;
  static final double _breedteLandingsTijd = 40;
  static final double _breedteDuur = 35;
  static final double _breedteVlieger = 150;
  static final double _breedteInzittende = 150;
  static double _breedteScherm;

  // De kaart met de vlucht info
  static Widget toonVlucht(BuildContext context, Map vluchtData, int nr) {
    _breedteScherm = MediaQuery.of(context).size.width;

    return 
      Card(
        elevation: 1.5,
        child: _vluchtRegel(context, vluchtData, nr)
      );
  }

  // Toon de basis informatie 
  static Widget _vluchtRegel(BuildContext context, Map vluchtData, int nr) { 
    String datum = vluchtData['DATUM'].substring(8,10) + "-" + vluchtData['DATUM'].substring(5,7) + "-" + vluchtData['DATUM'].substring(0,4);

    return
      Slidable(
          direction: Axis.horizontal,
          secondaryActions: <Widget>[
            new IconSlideAction(
              caption: 'Details',
              color: Colors.grey,
              icon: Icons.more_horiz,
              onTap: () => 
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LogboekDetailsScreen(details: vluchtData),
                  ),
                ),
            ),
          ],
          delegate: SlidableDrawerDelegate(),
          child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[ 
                SizedBox(
                  width:_breedteCirkel, 
                  child: 
                  CircleAvatar(
                    radius: 12.0, 
                    backgroundColor: MyGlideConst.backgroundColor,
                    child: Text(
                      (nr+1).toString(),
                      style: TextStyle(fontSize: 13.0)
                    )
                  )
                ),
                Padding (padding: EdgeInsets.all(5)),
                SizedBox(
                  width:_breedteDatum, 
                  child: Text(
                  datum.substring(0,5),
                  style: _gridTextStyle()
                  )
                ),
                SizedBox(
                  width: _breedteStartTijd, 
                  child: Text(
                    vluchtData['STARTTIJD'] ?? ' ',
                    style: _gridTextStyle(color: MyGlideConst.starttijdColor, weight: FontWeight.bold)
                  )
                ),
                SizedBox(
                  width:_breedteLandingsTijd, 
                  child: Text(
                    vluchtData['LANDINGSTIJD'] ?? ' ',
                    style: _gridTextStyle(color: MyGlideConst.landingstijdColor, weight: FontWeight.bold)
                  )
                ),
                _toonVluchtDuur(vluchtData['DUUR']),
                SizedBox(
                  width:_breedteRegCall, 
                  child: Text(
                    vluchtData['REG_CALL'],
                    style: _gridTextStyle()
                  )
                ),
                _toonVlieger((vluchtData['VLIEGERNAAM'] != null) ? vluchtData['VLIEGERNAAM']  : vluchtData['VLIEGERNAAM_LID'] ),
                _toonInzittende((vluchtData['INZITTENDENAAM'] != null) ? vluchtData['INZITTENDENAAM'] : vluchtData['INZITTENDENAAM_LID'])
              ]
            )
          )
        )
      );
  }
  
  static Widget _toonVluchtDuur(String duur){
    double minBreedte = 10 + _breedteCirkel + _breedteDatum + _breedteStartTijd + _breedteLandingsTijd + _breedteRegCall; // 10 extra marge

    // standaard = hh:mm, maar er zijn maar weining vluchten van 10 uur of langer. Zonde van de ruimte
    String vliegtijd = duur.toString().replaceFirst(new RegExp(r'0'), '');

    if ((minBreedte + _breedteDuur) < _breedteScherm)
      return
        SizedBox(
          width: _breedteDuur, 
          child: Text(
            vliegtijd,
            style: _gridTextStyle(weight: FontWeight.bold)
          )
        );

    return Container(width: 0, height: 0);
  }  

  static Widget _toonVlieger(String vliegerNaam) {
    double minBreedte = 10 + _breedteCirkel + _breedteDatum + _breedteStartTijd + _breedteLandingsTijd + _breedteRegCall + _breedteDuur; // 10 extra marge

    if (((minBreedte + _breedteVlieger) < _breedteScherm) && (vliegerNaam != null))
      return
        SizedBox(
          width: _breedteVlieger, 
          child: Text(
            vliegerNaam,
            style: _gridTextStyle()
          )
        );

    return Container(width: 0, height: 0);
  }  

  static Widget _toonInzittende(String inzittendeNaam) {
  double minBreedte = 10 + _breedteCirkel + _breedteDatum + _breedteStartTijd + _breedteLandingsTijd + _breedteRegCall + _breedteDuur + _breedteVlieger; // 10 extra marge

  if (((minBreedte + _breedteInzittende) < _breedteScherm) && (inzittendeNaam != null))
    return
      SizedBox(
        width: _breedteInzittende, 
        child: Text(
          inzittendeNaam,
          style: _gridTextStyle()
        )
      );

  return Container(width: 0, height: 0);
  }

  static TextStyle _gridTextStyle({color = MyGlideConst.gridTextColor, weight = FontWeight.normal}) {
    return TextStyle (
      color: color,
      fontWeight: weight,
      fontSize: MyGlideConst.gridTextNormal
    );
  }    
}