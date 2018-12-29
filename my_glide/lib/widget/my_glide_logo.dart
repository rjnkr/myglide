import 'package:flutter/material.dart';
import 'package:my_glide/utils/my_glide_const.dart';


class MyGlideLogo extends StatefulWidget {
  @override
  _MyGlideLogoState createState() => _MyGlideLogoState();
}


class _MyGlideLogoState extends State<MyGlideLogo> with SingleTickerProviderStateMixin {

  Animation<double> _iconAnimation;
  AnimationController _iconAnimationController;

  @override
  void initState() {
    super.initState();
    _iconAnimationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 500));
    _iconAnimation = CurvedAnimation(
      parent: _iconAnimationController,
      curve: Curves.bounceOut,
    );
    _iconAnimation.addListener(() => this.setState(() {}));
    _iconAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            backgroundColor: MyGlideConst.BlueRGB,
            radius: _iconAnimation.value * 80.0,
            child: Image.asset('assets/images/silzweef.png' ),
          ),
          Text(
            MyGlideConst.AppName,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24.0),
          )
        ],
      )
    );
  }
}