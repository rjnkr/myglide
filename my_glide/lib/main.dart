import 'package:flutter/material.dart';

import 'package:my_glide/pages/home_scherm.dart';
import 'package:my_glide/pages/login_scherm.dart';
import 'package:my_glide/pages/splash_scherm.dart';
import 'package:my_glide/pages/settings_scherm.dart';

import 'package:my_glide/utils/session.dart';

var routes = <String, WidgetBuilder>{
  "/home": (BuildContext context) => HomeScreen(), 
  "/login": (BuildContext context) => LoginScreen(),
  "/settings": (BuildContext context) => SettingsScreen(),
// "/intro": (BuildContext context) => IntroScreen(), 
};   


void main() {
  // niet verwijderen, zorgt dat serverSession class wordt opgebouwd, doet verder niets
  print (serverSession.lastUrl);      

  runApp(new MaterialApp(
  theme:
      ThemeData(primaryColor: Colors.red, accentColor: Colors.yellowAccent),
  debugShowCheckedModeBanner: false,
  home: SplashScreen(),
  routes: routes));
}

/*

class ExpansionTileSample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ExpansionTile'),
        ),
        body: ListView.builder(
          itemBuilder: (BuildContext context, int index) =>
              EntryItem(data[index]),
          itemCount: data.length,
        ),
      ),
    );
  }
}

// One entry in the multilevel list displayed by this app.
class Entry {
  Entry(this.title, [this.children = const <Entry>[]]);

  final String title;
  final List<Entry> children;
}

// The entire multilevel list displayed by this app.
final List<Entry> data = <Entry>[
  Entry(
    'Chapter A',
    <Entry>[
      Entry('Section A0'),
      Entry('Section A1'),
      Entry('Section A2'),
    ],
  ),
  Entry(
    'Chapter B',
    <Entry>[
      Entry('Section B0'),
      Entry('Section B1'),
    ],
  )
];

// Displays one Entry. If the entry has children then it's displayed
// with an ExpansionTile.
class EntryItem extends StatelessWidget {
  const EntryItem(this.entry);

  final Entry entry;

  Widget _buildTiles(Entry root) {
    if (root.children.isEmpty) return ListTile(title: Text(root.title));
    return ExpansionTile(
   //   key: PageStorageKey<Entry>(root),
      title: Text(root.title),
      children: <Widget>[
        PhysicalModel(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(5.0),
        child: 
            SizedBox(
              height:20,
              width:20,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[Text("L")]
              )
            )
      ),
      PhysicalModel(
        color: Colors.red,
        borderRadius: BorderRadius.circular(5.0),
        child: 
            SizedBox(
              height:20,
              width:20,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[Text("L")]
              )
            )
      )
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(entry);
  }
}

void main() {
  runApp(ExpansionTileSample());
}

*/