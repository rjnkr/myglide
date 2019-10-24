 
// language packages
import 'package:flutter/material.dart';

// language add-ons

// my glide utils
import 'package:my_glide/utils/debug.dart';
import 'package:my_glide/utils/my_glide_const.dart';

// my glide data providers

// my glide own widgets

// my glide pages

typedef FavorietCallback = void Function(String vliegtuigID);

class VliegtuigenGrid extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    MyGlideDebug.info("VliegtuigenGrid.build(context)"); 

    return Container();
  }
  
  // Toon de basis informatie 
  static Widget vliegtuigRegel(BuildContext context, 
    final Map vliegtuigData,
    { final FavorietCallback onFavorietChanged }) { 
    MyGlideDebug.info("VliegtuigenGrid.vliegtuigRegel(context, $vliegtuigData)"); 

    return 
      ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 120, maxWidth: double.infinity),
        child:
          Card(
            elevation: 2,
            margin: EdgeInsets.all(3),           
            child: Container(
              height: 50,
              margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 15.0, 
                      backgroundColor: MyGlideConst.backgroundColor,
                      child: Text(
                        vliegtuigData['CALLSIGN'] ?? '',
                        style: TextStyle(fontSize: 10.0)
                      )
                    ),
                    Padding (padding: EdgeInsets.all(5)),
                    SizedBox(
                      width:110,
                      child: Text(vliegtuigData['REGCALL'], style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Icon(Icons.airline_seat_recline_extra, color: MyGlideConst.frontColor),
                    (vliegtuigData['ZITPLAATSEN'] == "2") ? Icon(Icons.airline_seat_recline_extra, color: MyGlideConst.frontColor) : Container(width: 0),
                    Expanded(child: Container()),  
                    _iconButton(vliegtuigData, onFavorietChanged: onFavorietChanged)
                  ],
                )
              )
            )
          )
      );
  }

  static Widget _iconButton(Map vliegtuigData, { final FavorietCallback onFavorietChanged }) {
    if (vliegtuigData == null)    // Dit zou niet mogen voorkomen, maar ja .....
      return Container();

    if (vliegtuigData['CLUBKIST'] == "true")
      return Container();

    Color iconColor = Colors.black38;

    if (vliegtuigData["FAVORIET"])
      iconColor = Colors.green;

    return 
      IconButton(
        icon: Icon((vliegtuigData["FAVORIET"]) ? Icons.check_box: Icons.star_border , color: iconColor),
        onPressed: () => onFavorietChanged(vliegtuigData["ID"])
      );
  }
}
