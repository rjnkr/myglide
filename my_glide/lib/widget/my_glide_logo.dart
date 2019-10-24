// language packages
import 'package:flutter/material.dart';

// language add-ons

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/debug.dart';

// my glide data providers

// my glide own widgets

// my glide pages


class MyGlideLogo extends StatefulWidget {
  final int size;
  final bool showLabel;
  final bool labelInside;
  final String image;
  final String labelText;

  final double labelTextSize;


  MyGlideLogo({Key key, 
    this.size = 300, 
    this.showLabel = true, 
    this.labelInside = true, 
    this.labelText = MyGlideConst.AppName, 
    this.labelTextSize = MyGlideConst.labelSizeExtraLarge,
    this.image = "assets/images/gezc_logo_transp.png" }) : super(key: key);

  @override
  _MyGlideLogoState createState() => _MyGlideLogoState();
}


class _MyGlideLogoState extends State<MyGlideLogo> with SingleTickerProviderStateMixin {

  Animation<double> _iconAnimation;
  AnimationController _iconAnimationController;

  @override
  void initState() {
    MyGlideDebug.info("_MyGlideLogoState.initState()"); 

    super.initState();
    _iconAnimationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 500)
      );

    _iconAnimation = CurvedAnimation(
      parent: _iconAnimationController,
      curve: Curves.easeIn,
    );
    
    _iconAnimation.addListener(() => this.setState(() {}));
    _iconAnimationController.forward();
  }

  @override
  void dispose() {
    MyGlideDebug.info("_MyGlideLogoState.dispose()"); 

    _iconAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MyGlideDebug.info("_MyGlideLogoState.build(context)"); 

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Stack (
            children: <Widget> [
              Container(
                margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                height: _iconAnimation.value * widget.size * 0.46875,
                width: _iconAnimation.value * widget.size,
                child: Image.asset(widget.image),
              ),
              _toonLabelInside(),
            ]),
            _toonLabelOnder(),
          ])
      );
  }

  Widget _toonLabelInside() {
    MyGlideDebug.info("_MyGlideLogoState._toonLabelInside()"); 

    if ((!widget.labelInside)  || (_iconAnimation.value < 1))
      return Container (height: 0, width: 0);

    return
      Positioned (
        right: 20,
        bottom: 20,
        child: _toonLabel()
      );
  }

  Widget _toonLabelOnder() {
    MyGlideDebug.info("_MyGlideLogoState._toonLabelOnder()"); 

    if ((widget.labelInside)  || (_iconAnimation.value < 1))
      return Container (height: 0, width: 0); 
    else 
      return _toonLabel();
  }

  Widget _toonLabel() {
    MyGlideDebug.info("_MyGlideLogoState._toonLabel()"); 

    if (!widget.showLabel) return Container (height: 0, width: 0);

    return 
      Text(
        widget.labelText,
        style: TextStyle(
          color: MyGlideConst.logoTextColor,
          fontWeight: FontWeight.bold,
          fontSize: widget.labelTextSize
        )
      );
  }
}