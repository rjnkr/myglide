// language packages
import 'package:flutter/material.dart';

// language add-ons
import 'package:shared_preferences/shared_preferences.dart';
import 'package:numberpicker/numberpicker.dart';

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';

// my glide own widgets
import 'package:my_glide/widget/hoofd_menu.dart';

// my glide pages

class SettingsScreen extends StatefulWidget {
  @override
  State createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  int _nrLogboekItems;
  bool _autoLoadLogboek;

  @override
  void initState() {
    super.initState();  

    SharedPreferences.getInstance().then((prefs)
    {
      setState(() {
        _autoLoadLogboek = (prefs.getBool('autoLoadLogboek') ?? false);
        _nrLogboekItems = (prefs.getInt('nrLogboekItems') ?? 50);
      });
    });
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
                        SharedPreferences.getInstance().then((prefs)
                        {
                          prefs.setBool('autoLoadLogboek', value);
                        });            
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

        SharedPreferences.getInstance().then((prefs)  {
          prefs.setInt('nrLogboekItems', newValue);
        });  
      }
    });
  }
}