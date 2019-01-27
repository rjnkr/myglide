
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

class LogboekDetailsScreen extends StatelessWidget {
  LogboekDetailsScreen({
    @required this.isInTabletLayout,
    @required this.vlucht,
  });

  final bool isInTabletLayout;
  final Map vlucht;

  // Toon de details van de vlucht
  @override
  Widget build(BuildContext context) {
    if (vlucht == null)
      return Container(width: 0, height: 0);

    String datum = vlucht['DATUM'].substring(8,10) + "-" + vlucht['DATUM'].substring(5,7) + "-" + vlucht['DATUM'].substring(0,4);
    
    String vlieger = (vlucht['VLIEGERNAAM'] != null) ? vlucht['VLIEGERNAAM']  : vlucht['VLIEGERNAAM_LID'];
    String inzittende = (vlucht['INZITTENDENAAM'] != null) ? vlucht['INZITTENDENAAM'] : vlucht['INZITTENDENAAM_LID'];

    final Widget content = 
      Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Expanded(
              flex:6,
              child :SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child:
                  Column (
                    children: <Widget>[
                      GUIHelper.showDetailsField("Datum", datum),
                      GUIHelper.showDetailsField("Vliegtuig", vlucht['REG_CALL']) ?? ' ',
                      GUIHelper.showDetailsField("Start methode", vlucht['STARTMETHODE'] ?? ' '),
                      Divider(),
                      GUIHelper.showDetailsField("Starttijd", vlucht['STARTTIJD'] ?? ' '),
                      GUIHelper.showDetailsField("Landingstijd", vlucht['LANDINGSTIJD'] ?? ' '),
                      GUIHelper.showDetailsField("Duur", vlucht['DUUR'] ?? ' '),
                      Divider(),
                      GUIHelper.showDetailsField("Vlieger", vlieger ?? ' '),
                      GUIHelper.showDetailsField("Inzittende", inzittende ?? ' '),
                      Divider(),
                      GUIHelper.showDetailsField("Opmerking", vlucht['OPMERKING'] ?? ' ', titleTop: true),
                    ]
                  )
              )
            ),
            Expanded(
              flex: 1,
              child: Row (
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  PhysicalModel(
                    borderRadius: BorderRadius.circular(20.0),
                    color: MyGlideConst.backgroundColor,
                    child: MaterialButton(
                      height: 50.0,
                      minWidth: 120.0,
                      textColor: MyGlideConst.frontColor,
                      child: Icon(Icons.email,
                        color: MyGlideConst.frontColor ),
                        onPressed: () => _sendEmail(vlucht),    
                    )
                  ),
                  _buttonLandingOrDelete(context, vlucht)
                ]
              )
            )
          ])
        );

    if (isInTabletLayout) {
      return Center(child: content);
    }

    // We hebben een popup op een smartphone, toon Scaffold 
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyGlideConst.appBarBackground(),
        iconTheme: IconThemeData(color: MyGlideConst.frontColor),
        title: Text(
          "Details",
          style: MyGlideConst.appBarTextColor()
        ),
      ),

      body: Center(child: content),
    );
  }
  
  Widget _buttonLandingOrDelete(BuildContext context, Map vluchtData) {
    if ((vluchtData['STARTTIJD'] != null) && (vluchtData['LANDINGSTIJD'] == null)) {
      return
        PhysicalModel(                                      // toon landingstijd button om vlucht af te sluiten
          borderRadius: BorderRadius.circular(20.0),
          color: MyGlideConst.landingstijdColor,
          child: MaterialButton(
            height: 50.0,
            minWidth: 120.0,
            textColor: MyGlideConst.frontColor,
            child: Icon(
              Icons.flight_land, color: MyGlideConst.frontColor ,),
              onPressed: () => _landingsTijdScherm(context, vluchtData['ID']),    
          )
        );
    }

    String vandaag = DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();

    if ((vluchtData['STARTTIJD'] == null) && (vluchtData['LANDINGSTIJD'] == null) &&
        (vluchtData['DATUM'] != vandaag)) {
      return
        PhysicalModel(                                      // toon delete button om vlucht weg te gooien
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.red,
          child: MaterialButton(
            height: 50.0,
            minWidth: 120.0,
            textColor: Colors.white,
            child: Icon(
              Icons.delete, color: Colors.white,),
              onPressed: () => _verwijderVlucht(context, vluchtData['ID']),    
          )
        );
    }
    
    return Container(width: 0, height: 0);
  }

  void _landingsTijdScherm(BuildContext context, String id) async {
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
        onConfirm: (Picker picker, List value) {
          _landingsTijd(context, id, value[0], value[1]);
        }
    ).showDialog(context);
  }

  void _landingsTijd(BuildContext context, String id, int uur, int minuten)
  {
    String tijd = "$uur:$minuten";

    Startlijst.opslaanLandingsTijd (id, tijd).then((gelukt)  {
      Startlijst.getLogboek();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Landingstijd"),
          content: gelukt ? Text("De landingstijd is aangepast") : Text("Er is iets mis gegaan, probeer het nogmaals of neem contact op met de beheerder")
        ));          
    });
    Navigator.pop(context);
  }

  void _verwijderVlucht(BuildContext context, String id)
  {
    Startlijst.verwijderVlucht(id).then((gelukt)  {
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
  void _sendEmail(Map vluchtData) async {
    String emailBody = "Goedendag,<br><br>Ik zou graag het volgende willen wijzigen in mijn logboek.<br><br> << hier uw tekst >> <br><br>Met vriendelijke groet,<br><br>";
    emailBody += "${serverSession.login.userInfo['NAAM']}<br><br><br><br>";

    emailBody += "Datum: ${vluchtData['DATUM']}<br>";
    emailBody += "Vliegtuig: ${vluchtData['REG_CALL']}<br>";
    emailBody += "Start methode: ${vluchtData['STARTMETHODE']}<br>";
    emailBody += "Starttijd: ${vluchtData['STARTTIJD']}<br>";
    emailBody += "Landingstijd: ${vluchtData['LANDINGSTIJD']}<br>";
    emailBody += "Duur: ${vluchtData['DUUR']}<br>";
    emailBody += "Vliegernaam: ${vluchtData['VLIEGERNAAM']}<br>";
    emailBody += "Inzittende: ${vluchtData['INZITTENDENAAM']}<br>";
    emailBody += "Opmerking: ${vluchtData['OPMERKING']}<br>";

    final MailOptions mailOptions = MailOptions(
      body: emailBody,
      subject: 'Verzoek wijziging van mijn logboek',
    //  recipients: ['example@example.com'],
      isHTML: true,
    );

    await FlutterMailer.send(mailOptions);
  }   
}