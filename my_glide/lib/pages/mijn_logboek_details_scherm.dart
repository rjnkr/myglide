
// language packages
import 'package:flutter/material.dart';

// language add-ons
import 'package:flutter_mailer/flutter_mailer.dart';

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';

// my glide own widgets
import 'package:my_glide/widget/hoofd_menu.dart';

// my glide pages

class LogboekDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> details;

  LogboekDetailsScreen({Key key, @required this.details}) : super(key: key);

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
      //drawer: HoofdMenu(),
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
                      _showDetailsField("Datum", details['DATUM']),
                      _showDetailsField("Vliegtuig", details['REG_CALL']) ?? ' ',
                      _showDetailsField("Start methode", details['STARTMETHODE'] ?? ' '),
                      Divider(),
                      _showDetailsField("Starttijd", details['STARTTIJD'] ?? ' '),
                      _showDetailsField("Landingstijd", details['LANDINGSTIJD'] ?? ' '),
                      _showDetailsField("Duur", details['DUUR'] ?? ' '),
                      Divider(),
                      _showDetailsField("Vlieger", details['VLIEGERNAAM'] ?? ' '),
                      _showDetailsField("Inzittende", details['INZITTENDENAAM'] ?? ' '),
                      Divider(),
                      _showDetailsField("Opmerking", details['OPMERKING'] ?? ' ', titleTop: true),
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

                  details['LANDINGSTIJD'] != null ? 
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
                        //onPressed: _buttonState != 0 ? null:  logMeIn,    
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

  // email versturen naar beheerder
  void _sendEmail() async
  {
    String emailBody = "Goedendag,<br><br>Ik zou graag het volgende willen wijzigen in mijn logboek.<br><br> << hier uw tekst >> <br><br>Met vriendelijke groet,<br><br><br><br>";

    emailBody += "Datum: ${details['DATUM']}<br>";
    emailBody += "Vliegtuig: ${details['REG_CALL']}<br>";
    emailBody += "Start methode: ${details['STARTMETHODE']}<br>";
    emailBody += "Starttijd: ${details['STARTTIJD']}<br>";
    emailBody += "Landingstijd: ${details['LANDINGSTIJD']}<br>";
    emailBody += "Duur: ${details['DUUR']}<br>";
    emailBody += "Vliegernaam: ${details['VLIEGERNAAM']}<br>";
    emailBody += "Inzittende: ${details['INZITTENDENAAM']}<br>";
    emailBody += "Opmerking: ${details['OPMERKING']}<br>";

    final MailOptions mailOptions = MailOptions(
      body: emailBody,
      subject: 'Verzoek wijziging van mijn logboek',
    //  recipients: ['example@example.com'],
      isHTML: true,
    );

    await FlutterMailer.send(mailOptions);
  }
}