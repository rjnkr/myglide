import 'package:flutter/material.dart';
import 'package:my_glide/utils/my_glide_const.dart';

class MyGlideLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            backgroundColor: MyGlideConst.YellowRGB,
            radius: 80.0,
            child: Image.asset('assets/images/silzweef.png' ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          Text(
            MyGlideConst.lblAppName,
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