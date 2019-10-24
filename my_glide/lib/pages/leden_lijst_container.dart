// language packages
import 'package:flutter/material.dart';

// language add-ons

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/debug.dart';

// my glide data providers

// my glide own widgets

// my glide pages
import 'package:my_glide/pages/leden_lijst_details.dart';
import 'package:my_glide/pages/leden_lijst_grid.dart';
import 'package:my_glide/pages/gui_helpers.dart';

class LedenlijstContainer extends StatefulWidget {
  final List ledenlijst;
  const LedenlijstContainer({Key key, this.ledenlijst}) : super (key: key);

  @override
  _LedenlijstContainerState createState() =>
      _LedenlijstContainerState();
}

class _LedenlijstContainerState extends State<LedenlijstContainer> {
 
  Map _lidData;
  
  @override
  Widget build(BuildContext context) 
  {
    MyGlideDebug.info("_LedenlijstContainerState.build(context)");    

    if (GUIHelper.isTablet(context)) 
      return _buildTabletLayout();
    else
      return _buildMobileLayout();
  }  

  // Laat startlijst zien op een mobiel
  Widget _buildMobileLayout() {
    MyGlideDebug.info("_LedenlijstContainerState._buildMobileLayout()"); 

    return         
      LidListing(
        leden: widget.ledenlijst,
        lidSelectedCallback: (lid) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) {
                return LidDetailsScreen(   
                  isInTabletLayout: false,
                  lid: lid,
                );
              },
            ),
          );
        },
      );
  }

  // Laat startlijst zien op een tablet
  Widget _buildTabletLayout() {
    MyGlideDebug.info("_LedenlijstContainerState._buildTabletLayout()"); 

    double breedteScherm = MediaQuery.of(context).size.width; 
    int flexDetails = (100 * MyGlideConst.breedteLidDetails / breedteScherm).round();

    return Row(
      children: <Widget>[
        Flexible(
          flex: 100-flexDetails,
          child: Material(
            elevation: 4.0,
            child: LidListing(
              leden: widget.ledenlijst,
              lidSelectedCallback: (item) {
                setState(() {
                  _lidData = item;
                });
              },
              selectedLid: _lidData,
            ),
          ),
        ),
        Flexible(
          flex: flexDetails,
          child: 
            LidDetailsScreen(     
              isInTabletLayout: true,
              lid: _lidData,
            ), 
        ),
      ],
    );
  }
}

// Toon de master data
class LidListing extends StatelessWidget {

  LidListing({
    @required this.lidSelectedCallback,
    @required this.leden,
    this.selectedLid
  });

  final ValueChanged<Map> lidSelectedCallback;
  final Map selectedLid;
  final List leden;

  @override
  Widget build(BuildContext context) {
    MyGlideDebug.info("LidListing.build(context)"); 

    if (leden.length == 0)
      return GUIHelper.geenData(bericht: "Geen data, pas uw zoekcriteria en/of filters aan");

    return 
      ListView(
        children: leden.map((lid) {
          return 
            new ListTile(
            title: LedenLijstGrid.lidRegel(context, lid),  
            onTap: () => lidSelectedCallback(lid),
            selected: selectedLid == lid,
            contentPadding: EdgeInsets.fromLTRB(2, 0, 0, 0),
          );
        }).toList(),
      );
  }  
}
