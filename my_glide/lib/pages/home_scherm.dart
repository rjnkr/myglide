import 'package:flutter/material.dart';

import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/my_navigation.dart';
import 'package:my_glide/utils/session.dart';
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

  List _logboekItems;

  @override
  void initState() {
    super.initState();

/*
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
    */
    Startlijst.getLogboek().then((response) {
      setState(() {
        _logboekItems = response;
      });
    });
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
      drawer: Drawer(                                         // menu
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            decoration: BoxDecoration(
              color: MyGlideConst.BlueRGB
            ),
            child: ListView(
              children: <Widget>[
                Container(
                  height:240.0,
                  child:
                  DrawerHeader(
                    child: MyGlideLogo(),
                    decoration: BoxDecoration(
                      color: MyGlideConst.BlueRGB
                    )
                  ),  
                ),
                ListTile(
                  title: Text("Aanmelden",
                    style: TextStyle(color: MyGlideConst.YellowRGB)
                  ),
                  trailing: Icon(Icons.flight_takeoff, color: MyGlideConst.YellowRGB),
                ),
                ListTile(
                  title: Text("Instellingen", 
                    style: TextStyle(color: MyGlideConst.YellowRGB)
                  ),
                  trailing: Icon(Icons.settings, color: MyGlideConst.YellowRGB),
                ),
                Divider(color: MyGlideConst.YellowRGB, height: 6.0),
                ListTile(
                  title: Text("Uitloggen",
                  style: TextStyle(color: MyGlideConst.YellowRGB)
                  ),
                  trailing: Icon(Icons.exit_to_app, color: MyGlideConst.YellowRGB),
                  onTap: () {
                    serverSession.logout();
                    MyNavigator.goToLogin(context);
                  },
                ),
                Divider(color: MyGlideConst.YellowRGB, height: 6.0),
                ],
              ),
          )
        )
      ),
      body: ListView.builder(
        itemCount:  _logboekItems == null ? 0 : _logboekItems.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
                elevation: 1.5,
                child: Container(
                  padding: EdgeInsets.all(4.0),
                  child: Row (
                    children: <Widget>[
                        CircleAvatar(
                        radius: 12.0, 
                        backgroundColor: MyGlideConst.BlueRGB,
                        child: Text(
                          (index+1).toString(),
                          style: TextStyle(color:MyGlideConst.YellowRGB, fontSize: 13.0)
                        )
                      ),
                      Padding(padding: EdgeInsets.only(right: 10.0)),
                      
                      Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[ 
                              SizedBox(
                                width:90, 
                                child: Text(
                                _logboekItems[index]['DATUM'])
                              ),
                              SizedBox(
                                width: 50, 
                                child: Text(
                                  _logboekItems[index]['STARTTIJD'],
                                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)
                                )
                              ),
                              SizedBox(
                                width:50, 
                                child: Text(
                                  _logboekItems[index]['LANDINGSTIJD'],
                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
                                  )
                                ),
                              SizedBox(
                                width:100, 
                                child: Text(
                                  _logboekItems[index]['REG_CALL'],
                                  )
                                )                              
                            ]
                          ),
                          Row(
                            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[ 
                              SizedBox(
                                width:140, 
                                child: Text(
                                _logboekItems[index]['VLIEGERNAAM'])
                              ),
                              
                              SizedBox(
                                width:150, 
                                child: Text(
                                _logboekItems[index]['INZITTENDENAAM'] ?? '')
                              )
                            ]
                          )
                        ]),
                        PhysicalModel(
                          color: MyGlideConst.YellowRGB,
                          borderRadius: BorderRadius.circular(5.0),
                          child: 
                              SizedBox(
                                height:30,
                                width:30,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[Text("L")]
                                )
                              )
                        )
                    ]),
            ));
        }),
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
