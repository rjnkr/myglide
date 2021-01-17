 
// language packages
import 'package:flutter/material.dart';

// language add-ons

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/debug.dart';

// my glide data providers

// my glide own widgets

// my glide pages
import 'package:my_glide/pages/gui_helpers.dart';

class StartLijstGrid extends StatelessWidget {

  static final double _breedteCirkel = 25;
  static final double _breedteDatum = 50;
  static final double _breedteRegCall = 100;
  static final double _breedteStartTijd = 40;
  static final double _breedteLandingsTijd = 40;
  static final double _breedteDuur = 35;
  static final double _breedteVlieger = 150;
  static final double _breedteInzittende = 150;
  static double _breedteScherm;

  @override
  Widget build(BuildContext context) {
    MyGlideDebug.info("StartLijstGrid.build(context)"); 

    return Container();
  }
  
  // Toon de basis informatie 
  static Widget vluchtRegel(BuildContext context, Map vluchtData, int nr) { 
    MyGlideDebug.info("StartLijstGrid.vluchtRegel(context. $vluchtData, $nr)"); 

    String datum = vluchtData['DATUM'].substring(8,10) + "-" + vluchtData['DATUM'].substring(5,7) + "-" + vluchtData['DATUM'].substring(0,4);
    
    String vlieger = (vluchtData['VLIEGERNAAM'] != null) ? vluchtData['VLIEGERNAAM']  : vluchtData['VLIEGERNAAM_LID'];
    String inzittende = (vluchtData['INZITTENDENAAM'] != null) ? vluchtData['INZITTENDENAAM'] : vluchtData['INZITTENDENAAM_LID'];

    if (GUIHelper.isTablet(context))
      _breedteScherm = MediaQuery.of(context).size.width - MyGlideConst.breedteLogoekDetails;
    else
      _breedteScherm = MediaQuery.of(context).size.width;

    return
      ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 50, maxWidth: double.infinity),
        child:Card(
          elevation: 2,
          margin: EdgeInsets.all(1),       
          child: Container(
            height: 50,
            margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
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
                  style: GUIHelper.gridTextStyle()
                  )
                ),
                SizedBox(
                  width: _breedteStartTijd, 
                  child: Text(
                    vluchtData['STARTTIJD'] ?? '',
                    style: GUIHelper.gridTextStyle(color: MyGlideConst.starttijdColor, weight: FontWeight.bold)
                  )
                ),
                SizedBox(
                  width:_breedteLandingsTijd, 
                  child: Text(
                    vluchtData['LANDINGSTIJD'] ?? '',
                    style: GUIHelper.gridTextStyle(color: MyGlideConst.landingstijdColor, weight: FontWeight.bold, underline: true)
                  )
                ),
                _toonVluchtDuur(vluchtData['DUUR']),
                SizedBox(
                  width: _breedteRegCall, 
                  child: Text(
                    vluchtData['REG_CALL'],
                    style: GUIHelper.gridTextStyle()
                  )
                ),
                _toonVlieger(vlieger),
                _toonInzittende(inzittende),
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
            style: GUIHelper.gridTextStyle(weight: FontWeight.bold)
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
            style: GUIHelper.gridTextStyle()
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
            style: GUIHelper.gridTextStyle()
          )
        );

    return Container(width: 0, height: 0);
  }
}
