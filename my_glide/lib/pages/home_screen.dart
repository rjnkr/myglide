import 'package:flutter/material.dart';
import 'package:my_glide/utils/my_glide_const.dart';

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
        title: Text(MyGlideConst.lblAppName),
        actions: <Widget>[
          Padding(
            child: Icon(Icons.search),
            padding: const EdgeInsets.only(right: 10.0),
          )
        ],
      ),
      drawer: Drawer(),
      body: Center(
          child: Stack(
        children: <Widget>[
          Center(
            child: DragTarget(onWillAccept: (_) {
              print('red');
              return true;
            }, onAccept: (_) {
              setState(() => showFirst = false);
              animCtrl.forward();
              animCtrl2.forward();
            }, builder: (_, _1, _2) {
              return SizedBox.expand(
                child: Container(color: Colors.red),
              );
            }),
          ),
          Center(
            child: DragTarget(onWillAccept: (_) {
              print('green');
              return true;
            }, builder: (_, _1, _2) {
              return SizedBox.fromSize(
                size: Size(350.0, 350.0),
                child: Container(color: Colors.green),
              );
            }),
          ),
          Stack(alignment: FractionalOffset.center, children: <Widget>[
            Align(
              alignment: Alignment(0.0, 0.5 - animation.value * 0.15),
              child: CardView(200.0 + animation.value * 60),
            ),
            Align(
                alignment: Alignment(0.0, 0.35 - animation2.value * 0.35),
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => HomeScreen())),
                  child: CardView(260.0 + animation2.value * 80),
                )),
            Draggable(
              feedback: CardView(340.0),
              child: showFirst ? CardView(340.0) : Container(),
              childWhenDragging: Container(),
            )
          ]),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () => {},
        child: Icon(Icons.arrow_forward, color: Colors.white),
      ),
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
