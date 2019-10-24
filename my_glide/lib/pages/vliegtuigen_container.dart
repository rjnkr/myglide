// language packages
import 'package:flutter/material.dart';

// language add-ons

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/debug.dart';

// my glide data providers

// my glide own widgets

// my glide pages
import 'package:my_glide/pages/vliegtuigen_details.dart';
import 'package:my_glide/pages/vliegtuigen_grid.dart';
import 'package:my_glide/pages/gui_helpers.dart';

class VliegtuigenContainer extends StatefulWidget {
  final List vliegtuigen;
  final FavorietCallback onFavorietChanged;

  const VliegtuigenContainer({Key key, this.vliegtuigen, this.onFavorietChanged}) : super (key: key);

  @override
  _VliegtuigenContainerState createState() =>
      _VliegtuigenContainerState();
}

class _VliegtuigenContainerState extends State<VliegtuigenContainer> {
 
  Map _vliegtuigData;
  
  @override
  Widget build(BuildContext context) 
  {
    MyGlideDebug.info("_VliegtuigenContainerState.build(context)");    

    if (GUIHelper.isTablet(context)) 
      return _buildTabletLayout();
    else
      return _buildMobileLayout();
  }  

  // Laat startlijst zien op een mobiel
  Widget _buildMobileLayout() {
    MyGlideDebug.info("_VliegtuigenContainerState._buildMobileLayout()"); 

    return         
      VliegtuigListing(
        vliegtuigen: widget.vliegtuigen,
        onFavorietChanged: widget.onFavorietChanged,
        vliegtuigSelectedCallback: (vliegtuig) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) {
                return VliegtuigDetailsScreen(   
                  isInTabletLayout: false,
                  vliegtuigID: vliegtuig["ID"],
                  callSign: vliegtuig["REGCALL"] ?? ''
                );
              },
            ),
          );
        },
      );
  }

  // Laat startlijst zien op een tablet
  Widget _buildTabletLayout() {
    MyGlideDebug.info("_VliegtuigenContainerState._buildTabletLayout()"); 

    double breedteScherm = MediaQuery.of(context).size.width; 
    int flexDetails = (100 * MyGlideConst.breedteLidDetails / breedteScherm).round();

    return Row(
      children: <Widget>[
        Flexible(
          flex: 100-flexDetails,
          child: Material(
            elevation: 4.0,
            child: VliegtuigListing(
              vliegtuigen: widget.vliegtuigen, 
              onFavorietChanged: widget.onFavorietChanged,
              vliegtuigSelectedCallback: (item) {
                setState(() {
                  _vliegtuigData = item;
                });
              },
              selectedVliegtuig: _vliegtuigData,
            ),
          ),
        ),
        Flexible(
          flex: flexDetails,
          child: 
            VliegtuigDetailsScreen(     
              isInTabletLayout: true,
              vliegtuigID: (_vliegtuigData == null) ? null : _vliegtuigData["ID"],
              callSign: (_vliegtuigData == null) ? null : _vliegtuigData["REGCALL"] ?? ''
            ), 
        ),
      ],
    );
  }
}

// Toon de master data
class VliegtuigListing extends StatelessWidget {

  VliegtuigListing({
    @required this.vliegtuigSelectedCallback,
    @required this.vliegtuigen,
    this.onFavorietChanged,
    this.selectedVliegtuig
  });

  final ValueChanged<Map> vliegtuigSelectedCallback;
  final FavorietCallback onFavorietChanged;
  final Map selectedVliegtuig;
  final List vliegtuigen;

  @override
  Widget build(BuildContext context) {
    MyGlideDebug.info("LidListing.build(context)"); 

    if (vliegtuigen.length == 0)
      return GUIHelper.geenData(bericht: "Geen data, pas uw zoekcriteria en/of filters aan");
      
    return 
      ListView(
        children: vliegtuigen.map((vliegtuig) {
          return 
            ListTile(
              dense: true,
              title: VliegtuigenGrid.vliegtuigRegel(context, vliegtuig, onFavorietChanged: onFavorietChanged),  
              onTap: () => vliegtuigSelectedCallback(vliegtuig),
              selected: selectedVliegtuig == vliegtuig,
              contentPadding: EdgeInsets.fromLTRB(2, 0, 0, 0),
            );
        }).toList(),
      );
  }  
}
