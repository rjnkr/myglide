
// language packages
import 'package:flutter/material.dart';

// language add-ons
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:flutter_picker/flutter_picker.dart';

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/session.dart';

// my glide data providers
import 'package:my_glide/data/startlijst.dart';

// my glide own widgets
import 'package:my_glide/widget/hoofd_menu.dart';

// my glide pages



class LogboekDetailsScreen extends StatefulWidget {
  final Map details;

  LogboekDetailsScreen({Key key, @required this.details}) : super(key: key);

  @override
  _LogboekDetailsScreenState createState() => _LogboekDetailsScreenState();
}


class _LogboekDetailsScreenState extends State<LogboekDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyGlideConst.appBarBackground(),
        iconTheme: IconThemeData(color: MyGlideConst.frontColor),
        title: Text(
          "Details",
          style: MyGlideConst.appBarTextColor()
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 3,
              child :SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child:
                  Column (
                    children: <Widget>[
                      _showDetailsField("Datum", widget.details['DATUM']),
                      _showDetailsField("Vliegtuig", widget.details['REG_CALL']) ?? ' ',
                      _showDetailsField("Start methode", widget.details['STARTMETHODE'] ?? ' '),
                      Divider(),
                      _showDetailsField("Starttijd", widget.details['STARTTIJD'] ?? ' '),
                      _showDetailsField("Landingstijd", widget.details['LANDINGSTIJD'] ?? ' '),
                      _showDetailsField("Duur", widget.details['DUUR'] ?? ' '),
                      Divider(),
                      _showDetailsField("Vlieger", widget.details['VLIEGERNAAM'] ?? ' '),
                      _showDetailsField("Inzittende", widget.details['INZITTENDENAAM'] ?? ' '),
                      Divider(),
                      _showDetailsField("Opmerking", widget.details['OPMERKING'] ?? ' ', titleTop: true),
                    ]
                  )
              )
            ),
            Expanded(
              child: Row (
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  PhysicalModel(
                    borderRadius: BorderRadius.circular(20.0),
                    color: MyGlideConst.backgroundColor,
                    child: MaterialButton(
                      height: 50.0,
                      minWidth: 150.0,
                      textColor: MyGlideConst.frontColor,
                      child: Icon(Icons.email,
                        color: MyGlideConst.frontColor ),
                        onPressed: () => _sendEmail(),    
                    )
                  ),
                  Padding (padding: EdgeInsets.all(10)),

                  widget.details['LANDINGSTIJD'] != null ? 
                    Container(width: 0, height: 0)                      // Landingstijd is ingevuld, geen button tonen
                  :  
                    PhysicalModel(                                      // toon landingstijd button om vlucht af te sluiten
                      borderRadius: BorderRadius.circular(20.0),
                      color: MyGlideConst.landingstijdColor,
                      child: MaterialButton(
                        height: 50.0,
                        minWidth: 150.0,
                        textColor: MyGlideConst.frontColor,
                        child: Icon(
                          Icons.flight_land, color: MyGlideConst.frontColor ,),
                          onPressed: () => _landingsTijd(context),    
                      )
                    ),                  
                ]
              )
            )
          ])
        )
      );
  }

  // Toon een enkel veld in het scherm
  Widget _showDetailsField(String titel, String info, {bool titleTop = false}) {
    return 
      Column (
        //crossAxisAlignment: CrossAxisAlignment.end,
        //mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget> [
          Row (
            children: <Widget> [
              SizedBox(
                width: 120,
                height: 30, 
                child: Text(titel)
              ),
              SizedBox(
                height: 30,
                child: Text (titleTop ? ' ' : info, style: TextStyle(fontWeight: FontWeight.bold))
              )
            ]
          ), 
          titleTop ? 
            SizedBox(
              width: double.infinity,
              child: 
                Text(info, style: TextStyle(fontWeight: FontWeight.bold))
            )
            :
            Container(width: 0, height: 0)  //Label staat links en niet erboven
        ]
      );
  }


  void _landingsTijd(BuildContext context) async {
    Picker(
      looping: true,
        adapter: NumberPickerAdapter(data: [
          NumberPickerColumn(begin: 0, end: 24, initValue: TimeOfDay.now().hour),
          NumberPickerColumn(begin: 0, end: 59, initValue: TimeOfDay.now().minute),
        ]),
        delimiter: [
          PickerDelimiter(child: Container(
            width: 30.0,
            alignment: Alignment.center,
            child: Text(':',style: TextStyle(fontWeight: FontWeight.bold),)
          ))
        ],
        hideHeader: true,
        title: Text("Landingstijd"),
        onSelect: (Picker picker, int i, List value) {
          print(value.toString());
          print(picker.getSelectedValues());
        },
        onConfirm: (Picker picker, List value) {
          print(value.toString());
          print(picker.getSelectedValues());
        }
    ).showDialog(context);
  }

  // email versturen naar beheerder
  void _sendEmail() async {
    String emailBody = "Goedendag,<br><br>Ik zou graag het volgende willen wijzigen in mijn logboek.<br><br> << hier uw tekst >> <br><br>Met vriendelijke groet,<br><br>";
    emailBody += "${serverSession.userInfo['NAAM']}<br><br><br><br>";

    emailBody += "Datum: ${widget.details['DATUM']}<br>";
    emailBody += "Vliegtuig: ${widget.details['REG_CALL']}<br>";
    emailBody += "Start methode: ${widget.details['STARTMETHODE']}<br>";
    emailBody += "Starttijd: ${widget.details['STARTTIJD']}<br>";
    emailBody += "Landingstijd: ${widget.details['LANDINGSTIJD']}<br>";
    emailBody += "Duur: ${widget.details['DUUR']}<br>";
    emailBody += "Vliegernaam: ${widget.details['VLIEGERNAAM']}<br>";
    emailBody += "Inzittende: ${widget.details['INZITTENDENAAM']}<br>";
    emailBody += "Opmerking: ${widget.details['OPMERKING']}<br>";

    final MailOptions mailOptions = MailOptions(
      body: emailBody,
      subject: 'Verzoek wijziging van mijn logboek',
    //  recipients: ['example@example.com'],
      isHTML: true,
    );

    await FlutterMailer.send(mailOptions);
  }
}

