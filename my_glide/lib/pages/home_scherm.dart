import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:async';

import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/my_navigation.dart';
import 'package:my_glide/utils/startlijst.dart';

import 'package:my_glide/widget/my_glide_logo.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  AnimationController animCtrl;
  Animation<double> animation;

  AnimationController animCtrl2;
  Animation<double> animation2;

  bool showFirst = true;

  @override
  void initState() {
    super.initState();

    // Animation init
    animCtrl = AnimationController(
        duration: Duration(milliseconds: 500), vsync: this);
    animation = CurvedAnimation(parent: animCtrl, curve: Curves.easeOut);
    animation.addListener(() {
      this.setState(() {});
    });
    animation.addStatusListener((AnimationStatus status) {});

    animCtrl2 = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);
    animation2 = CurvedAnimation(parent: animCtrl2, curve: Curves.easeOut);
    animation2.addListener(() {
      this.setState(() {});
    });
    animation2.addStatusListener((AnimationStatus status) {});

    Startlijst().Logboek();
  }

  @override
  void dispose() {
    animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyGlideConst.BlueRGB,
        iconTheme: IconThemeData(color: MyGlideConst.YellowRGB),
        title: Text(
          MyGlideConst.AppName,
          style: TextStyle(color: MyGlideConst.YellowRGB),
        ),
        actions: <Widget>[
          Padding(
            child: Icon(Icons.search, color: MyGlideConst.YellowRGB),
            padding: const EdgeInsets.only(right: 20.0),
          ),
          Padding(
            child: Icon(Icons.refresh, color: MyGlideConst.YellowRGB),
            padding: const EdgeInsets.only(right: 10.0),
          )
        ],
      ),
      drawer: Drawer(                         // menu
          child: ListView(
            //padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: MyGlideLogo(),
                decoration: BoxDecoration(
                  color: MyGlideConst.BlueRGB
                )
              )
            ]
          ),
      ),
      body: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(20.0),
          children: <Widget>[
            new Container(
              height: 200.0,
              color: Colors.blue,
            ),
            new Container(
              height: 200.0,
              color: Colors.red,
            ),
            new Container(
              height: 200.0,
              color: Colors.green,
            ),
          ],
        )
      ); 
  }
}

class CardView extends StatelessWidget {
  final double cardSize;
  CardView(this.cardSize);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: SizedBox.fromSize(
      size: Size(cardSize, cardSize),
    ));
  }
}
