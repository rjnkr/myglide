
// language packages
import 'package:flutter/material.dart';

// language add-ons

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/debug.dart';

// my glide data providers

// my glide own widgets

// my glide pages
import 'package:my_glide/pages/startlijst_details.dart';
import 'package:my_glide/pages/startlijst_grid.dart';
import 'package:my_glide/pages/gui_helpers.dart';

class StartlijstContainer extends StatefulWidget {
  final List starts;

  const StartlijstContainer({Key key, @required this.starts}) : super (key: key);

  @override
  _StartlijstContainerState createState() =>
      _StartlijstContainerState();
}

class _StartlijstContainerState extends State<StartlijstContainer> {
  Map _vluchtData;

  @override
  Widget build(BuildContext context) 
  {
    MyGlideDebug.info("_StartlijstContainerState.build(context)");    

    if (widget.starts == null) return GUIHelper.showLoading();

    if (GUIHelper.isTablet(context)) 
      return _buildTabletLayout();
    else
      return _buildMobileLayout();
  }  

  // Laat startlijst zien op een mobiel
  Widget _buildMobileLayout() {
    MyGlideDebug.info("_StartlijstContainerState._buildMobileLayout()"); 

    return VluchtListing(
      starts: widget.starts,
      vluchtSelectedCallback: (start) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) {
              return LogboekDetailsScreen(
                isInTabletLayout: false,
                vlucht: start,
              );
            },
          ),
        );
      },
    );
  }

  // Laat startlijst zien op een tablet
  Widget _buildTabletLayout() {
    MyGlideDebug.info("_StartlijstContainerState._buildTabletLayout()"); 

    double breedteScherm = MediaQuery.of(context).size.width; 
    int flexDetails = (100 * MyGlideConst.breedteLogoekDetails / breedteScherm).round();

    return Row(
      children: <Widget>[
        Flexible(
          flex: 100-flexDetails,
          child: Material(
            elevation: 4.0,
            child: VluchtListing(
              starts: widget.starts,
              vluchtSelectedCallback: (item) {
                setState(() {
                  _vluchtData = item;
                });
              },
              selectedVlucht: _vluchtData,
            ),
          ),
        ),
        Flexible(
          flex: flexDetails,
          child: LogboekDetailsScreen(
            isInTabletLayout: true,
            vlucht: _vluchtData,
          ),
        ),
      ],
    );
  }
}


// Toon de master data
class VluchtListing extends StatelessWidget {

  VluchtListing({
    @required this.vluchtSelectedCallback,
    @required this.starts,
    this.selectedVlucht,
  });

  final ValueChanged<Map> vluchtSelectedCallback;
  final Map selectedVlucht;
  final List starts;

  @override
  Widget build(BuildContext context) {
    MyGlideDebug.info("VluchtListing.build(context)"); 

    int i=0;
    return ListView(
      children: starts.map((vlucht) {
        return 
          ListTile(
            title: StartLijstGrid.vluchtRegel(context, vlucht, i++),
            onTap: () => vluchtSelectedCallback(vlucht),
            selected: selectedVlucht == vlucht,
            contentPadding: EdgeInsets.fromLTRB(2, 0, 0, 0),
        );
      }).toList(),
    );
  }  
}
