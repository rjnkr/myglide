
// language packages
import 'package:flutter/material.dart';

// language add-ons
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:intl/intl.dart';

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';

// my glide data providers
import 'package:my_glide/data/session.dart';
import 'package:my_glide/data/startlijst.dart';

// my glide own widgets

// my glide pages
import 'package:my_glide/pages/gui_helpers.dart';


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
                      GUIHelper.showDetailsField("Datum", widget.details['DATUM']),
                      GUIHelper.showDetailsField("Vliegtuig", widget.details['REG_CALL']) ?? ' ',
                      GUIHelper.showDetailsField("Start methode", widget.details['STARTMETHODE'] ?? ' '),
                      Divider(),
                      GUIHelper.showDetailsField("Starttijd", widget.details['STARTTIJD'] ?? ' '),
                      GUIHelper.showDetailsField("Landingstijd", widget.details['LANDINGSTIJD'] ?? ' '),
                      GUIHelper.showDetailsField("Duur", widget.details['DUUR'] ?? ' '),
                      Divider(),
                      GUIHelper.showDetailsField("Vlieger", widget.details['VLIEGERNAAM'] ?? ' '),
                      GUIHelper.showDetailsField("Inzittende", widget.details['INZITTENDENAAM'] ?? ' '),
                      Divider(),
                      GUIHelper.showDetailsField("Opmerking", widget.details['OPMERKING'] ?? ' ', titleTop: true),
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
                  _buttonLandingOrDelete()
                ]
              )
            )
          ])
        )
      );
  }

  Widget _buttonLandingOrDelete() {
    if ((widget.details['STARTTIJD'] != null) && (widget.details['LANDINGSTIJD'] == null)) {
      return
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
        );
    }

    String vandaag = DateFormat('dd-MM-yyyy').format(DateTime.now()).toString();

    if ((widget.details['STARTTIJD'] == null) && (widget.details['LANDINGSTIJD'] == null) &&
        (widget.details['DATUM'] != vandaag)) {
      return
        PhysicalModel(                                      // toon delete button om vlucht weg te gooien
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.red,
          child: MaterialButton(
            height: 50.0,
            minWidth: 150.0,
            textColor: Colors.white,
            child: Icon(
              Icons.delete, color: Colors.white,),
              onPressed: () => _verwijderVlucht(),    
          )
        );
    }
    
    return Container(width: 0, height: 0);
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

  void _verwijderVlucht()
  {
    Startlijst.verwijderVlucht(widget.details['ID']).then((gelukt)  {
      Startlijst.getLogboek();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Verwijderen vlucht"),
          content: gelukt ? Text("De vlucht is verwijderd") : Text("Er is iets mis gegaan, probeer het nogmaals of neem contact op met de beheerder")
        ));          
    });
    Navigator.pop(context);
  }

  // email versturen naar beheerder
  void _sendEmail() async {
    String emailBody = "Goedendag,<br><br>Ik zou graag het volgende willen wijzigen in mijn logboek.<br><br> << hier uw tekst >> <br><br>Met vriendelijke groet,<br><br>";
    emailBody += "${serverSession.login.userInfo['NAAM']}<br><br><br><br>";

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

