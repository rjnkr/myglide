/*  
// language packages
import 'package:flutter/material.dart';

// language add-ons

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';

// my glide data providers

// my glide own widgets

// my glide pages
import 'package:my_glide/pages/vandaag_details.dart';
import 'package:my_glide/pages/vandaag_grid.dart';
import 'package:my_glide/pages/gui_helpers.dart';

class VandaagContainer extends StatefulWidget {
  final List aanwezig;

  const VandaagContainer({Key key, @required this.aanwezig}) : super (key: key);

  @override
  _VandaagContainerState createState() =>
      _VandaagContainerState();
}

class _VandaagContainerState extends State<VandaagContainer> {
  Map _lidData;

  @override
  Widget build(BuildContext context) 
  {
    if (widget.aanwezig == null) return GUIHelper.showLoading();

    if (GUIHelper.isTablet(context)) 
      return _buildTabletLayout();
    else
      return _buildMobileLayout();
  }  

  Widget _buildMobileLayout() {
    return VandaagGrid(
      aanwezig: widget.aanwezig,
      vandaagSelectedCallback: (lid) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) {
              return AanwezigDetailsScreen(
                isInTabletLayout: false,
                aanwezig: lid,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTabletLayout() {
    double breedteScherm = MediaQuery.of(context).size.width; 
    int flexDetails = (100 * MyGlideConst.breedteAanwezigDetails / breedteScherm).round();

    return Row(
      children: <Widget>[
        Flexible(
          flex: 100-flexDetails,
          child: Material(
            elevation: 4.0,
            child: VandaagGrid(
              aanwezig: widget.aanwezig,
              vandaagSelectedCallback: (item) {
                setState(() {
                  _lidData = item;
                });
              },
             // selectedLid: _lidData,
            ),
          ),
        ),
        Flexible(
          flex: flexDetails,
          child: AanwezigDetailsScreen(
            isInTabletLayout: true,
            aanwezig: _lidData,
          ),
        ),
      ],
    );
  }
}
*/

/*
// Toon de master data
class VandaagListing extends StatelessWidget {
  VandaagListing({
    @required this.vandaagSelectedCallback,
    @required this.aanwezig,
    this.selectedLid,
  });

  final ValueChanged<Map> vandaagSelectedCallback;
  final Map selectedLid;
  final List aanwezig;

  @override
  Widget build(BuildContext context) {
    int i=0;
    return ListView(
      children: aanwezig.map((lid) {
        return 
          new ListTile(
          title: VandaagGrid.aanwezigRegel(context, lid, i++),
          onTap: () => vandaagSelectedCallback(lid),
          selected: selectedLid == lid,
          contentPadding: EdgeInsets.fromLTRB(2, 0, 0, 0),
        );
      }).toList(),
    );
  }  
}
*/
