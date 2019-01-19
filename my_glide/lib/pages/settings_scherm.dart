// language packages
import 'package:flutter/material.dart';

// language add-ons
import 'package:numberpicker/numberpicker.dart';

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/storage.dart';

// my glide own widgets
import 'package:my_glide/widget/hoofd_menu.dart';

// my glide pages

class SettingsScreen extends StatefulWidget {
  @override
  State createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  int _nrLogboekItems;
  bool _autoLoadLogboek;

  @override
  void initState() {
    super.initState();  
    
      Storage.getBool('autoLoadLogboek', defaultValue: false).then((autoLoad) { 
        setState(() { _autoLoadLogboek = autoLoad; }); });

      Storage.getInt('nrLogboekItems', defaultValue: 50).then ((logboekItems) {
        setState(() { _nrLogboekItems = logboekItems; }); });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyGlideConst.appBarBackground(),
        iconTheme: IconThemeData(color: MyGlideConst.frontColor),
        title: Text('Instellingen',
          style: MyGlideConst.appBarTextColor(),
        )
      ),
      drawer: HoofdMenu(),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  SizedBox (
                    width: 220,
                    child: Text("Logboek automatisch verversen")
                  ),
                  Checkbox(
                    activeColor: MyGlideConst.frontColor,
                    value: _autoLoadLogboek ?? false,
                    tristate: false,
                    onChanged: (bool value)
                    {
                      setState(() {
                        _autoLoadLogboek = value;
                        Storage.setBool('autoLoadLogboek', value);        
                      });
                    },
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  SizedBox (
                    width: 235,
                    child: Text("Aantal items in logboek")
                  ),
                  Text(
                    _nrLogboekItems.toString(),
                    style: TextStyle(
                      color: MyGlideConst.frontColor
                    )
                  ),
                  
                  IconButton (
                    icon: Icon(Icons.more_horiz),
                    onPressed: _showNrLogboekItemsDialog
                  ) 
                ],
              )

            ])
          )
        )
      );
  }

  void _showNrLogboekItemsDialog() {
    showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return new NumberPickerDialog.integer(
          initialIntegerValue: _nrLogboekItems ?? 50,
          minValue: 5,
          step: 5,
          maxValue: 100,

        );
      }
    ).then((newValue) {
      if (newValue != null) {
        setState(() => _nrLogboekItems = newValue);
        Storage.setInt('nrLogboekItems', newValue);
      }
    });
  }
}