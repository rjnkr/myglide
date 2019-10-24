
// language packages
import 'package:flutter/material.dart';

// language add-ons
import 'package:flutter_mailer/flutter_mailer.dart';

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/debug.dart';

// my glide data providers
import 'package:my_glide/data/session.dart';

// my glide own widgets

// my glide pages
import 'package:my_glide/pages/gui_helpers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:my_glide/pages/aanmelden_scherm.dart';


class LidDetailsScreen extends StatefulWidget {
  final Map lid;
  final bool isInTabletLayout;

  const LidDetailsScreen({
    Key key, 
    this.isInTabletLayout,
    this.lid}) : super (key: key);

  @override
  _LidDetailsScreenState createState() => _LidDetailsScreenState();
}

class _LidDetailsScreenState extends State<LidDetailsScreen> {
  LidHelper _lidHelper;
  
  // Toon de details van het lid
  @override
  Widget build(BuildContext context) {
    MyGlideDebug.info("LidDetailsScreen.build(context)"); 

    if (widget.lid == null)
      return Container(width: 0, height: 0);

    _lidHelper = LidHelper(widget.lid, widget.isInTabletLayout);

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
                      GUIHelper.avatar(widget.lid["AVATAR"], 50),
                      Divider(),

                      GUIHelper.showDetailsField("Naam", widget.lid["NAAM"]),
                      GUIHelper.showDetailsField("", widget.lid["LIDTYPE"], bold: false),

                      Divider(),

                      GUIHelper.showDetailsField("Telefoon", widget.lid["TELEFOON"] ?? ""),
                      GUIHelper.showDetailsField("Mobiel", widget.lid["MOBIEL"] ?? ""),
                      _noodNummer(),

                      Divider(),
                      GUIHelper.showDetailsField("Email", widget.lid["EMAIL"] ?? ""),

                      Divider(),

                      GUIHelper.showLabelCheckbox("Lierist", widget.lid["LIERIST"] == "1"),
                      GUIHelper.showLabelCheckbox("Startleider", widget.lid["STARTLEIDER"] == "1"),
                      GUIHelper.showLabelCheckbox("Instructeur", widget.lid["INSTRUCTEUR"] == "1"),

                      Divider(),

                      _showLidNr()
                    ]
                  )
              )
            ),
            Expanded(
              flex: 1,
              child: Row (
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _aanmeldButton(),
                  _contactButton(),
                ]
              )
            )
          ])
        );

    if (widget.isInTabletLayout) {
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

    // Toon het lidnummer in het lid detail scherm
  Widget _showLidNr() {
    MyGlideDebug.info("_LidDetailsScreenState._showLidNr()");

    if ((serverSession.login.isBeheerderDDWV) || (serverSession.login.isBeheerder) || (serverSession.isDemo))
      return GUIHelper.showDetailsField("Lidnummer", widget.lid["LIDNR"] ?? "");

    return Container();
  }

  // Toon het mood nummer in het lid detail scherm
  Widget _noodNummer() {
    MyGlideDebug.info("_LidDetailsScreenState._noodNummer()");

    if (_lidHelper.heeftNoodNummer())
      return GUIHelper.showDetailsField("Noodnummer", widget.lid["NOODNUMMER"] ?? "");

    return Container();
  }
  
  // De button om iemand anders aan te melden. 
  Widget _aanmeldButton() {
    MyGlideDebug.info("_LidDetailsScreenState._aanmeldButton()");

    // Als je niet aangemeld bent, mag je ook niet iemand anders aanmelden, behalve functionarissen
    if ((serverSession.login.isAangemeld) || (serverSession.login.isBeheerder) || (serverSession.login.isBeheerderDDWV) ||
        (serverSession.login.isInstructeur) || (serverSession.login.isStartleider) || (serverSession.login.isLocal)) {

      return
        PhysicalModel(
          borderRadius: BorderRadius.circular(20.0),
          color: MyGlideConst.frontColor,
          child: MaterialButton(
            height: 50.0,
            minWidth: 120.0,
            textColor: MyGlideConst.gridBackgroundColor,
            child: Icon(Icons.person_add,
              color: MyGlideConst.backgroundColor),
              onPressed: () =>  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return AanmeldenScreen(
                          id: widget.lid["ID"],
                          naam: widget.lid["NAAM"]
                        );
                      },
                    ),
                  )   
          )
        );
      }
      return Container();
  }

  Widget _contactButton() {
    MyGlideDebug.info("_LidDetailsScreenState._contactButton()");

    // Bij tablet alleen email communicatie
    if (widget.isInTabletLayout) {
      if ((widget.lid["EMAIL"] != null) && (widget.lid["EMAIL"].contains("@"))) {
        return
          PhysicalModel(
            borderRadius: BorderRadius.circular(20.0),
            color: MyGlideConst.backgroundColor,
            child: MaterialButton(
              height: 50.0,
              minWidth: 120.0,
              onPressed: () =>  _sendEmail(),
              textColor: MyGlideConst.frontColor,
              child: 
                Icon(Icons.email,
                  color: MyGlideConst.frontColor)
            )
          );
      }
    }
    else
    {
      if ((widget.lid["EMAIL"] != null) && (widget.lid["EMAIL"].contains("@")) || _lidHelper.heeftTelefonie()) {
        return
          PhysicalModel(
            borderRadius: BorderRadius.circular(20.0),
            color: MyGlideConst.backgroundColor,
            child: MaterialButton(
              height: 50.0,
              minWidth: 120.0,
              textColor: MyGlideConst.frontColor,
              onPressed: () =>  _bodemPopUp(context),
              child: 
                Image.asset("assets/images/communicatie.png",
                color: MyGlideConst.frontColor, 
                height:37),
            )
          );
      }
    }

    return Container();
  }

  // Bodum popup scherm met de verschillende mogelijkheden om met het lid te communiceren (telefoon, email, whatsapp)
  void _bodemPopUp(context){
    MyGlideDebug.info("_LidDetailsScreenState._bodemPopUp(context)");
    
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc){
        return Container(
          decoration: BoxDecoration(color: MyGlideConst.backgroundColor),
          child: new Wrap(
            children: <Widget>[
              _telButton(),
              _emailButton(),
              _whatsAppButton()  
            ],
          ),
        );
      }
    );
    
  }  

  // Toon de telefoon button in het bottom popup scherm
  Widget _telButton() {
    MyGlideDebug.info("_LidDetailsScreenState._telButton()");

    // Er zijn geen telefoonnummers, dus geen button
    if ((_lidHelper.heeftTelefonie() == false) || (GUIHelper.isTablet(context)))
      return Container();

    return 
      ListTile(
        leading: Icon(Icons.phone, color: Colors.white),
        title: Text('Telefoon', style: TextStyle(color: MyGlideConst.frontColor)),
        onTap: () {
          Navigator.pop(context);
          _belTelefoonNummer(context);
        },         
      ); 
  }

  // Toon de email button in het bottom popup scherm
  Widget _emailButton() {
    MyGlideDebug.info("_LidDetailsScreenState._emailButton()");

    if ((widget.lid["EMAIL"] != null) && (widget.lid["EMAIL"].contains("@"))) {
      return 
        ListTile(
          leading: Icon(Icons.email, color: Color.fromRGBO(138,194, 235, 1)),
          title: Text('E-mail', style: TextStyle(color: MyGlideConst.frontColor)),
          onTap: () {
            Navigator.pop(context);
            _sendEmail();
          },         
        );
    }

    return Container();   // Er is geen geldig email adres, dus geen button
  }

  // Toon de whatsappp button in het bottom popup scherm
  Widget _whatsAppButton() {
    String whatsappUrl;

    MyGlideDebug.info("_LidDetailsScreenState._whatsAppButton()");

    if (_lidHelper.heeftMobiel() == false) 
        return Container();   // Er is geen mobiel, dus geen whatsapp, dus geen button

    // we nemen aan dat op iedere mobiel, whatsapp beschikbaar is (= risico)     
    String nummer = widget.lid["MOBIEL"].toString().replaceFirst(RegExp("^06"), "+316");
    whatsappUrl = "whatsapp://send?phone=$nummer";
  
    return 
      ListTile(
        leading: Image.asset("assets/images/whatsapp.png", width: 25),
        title: Text('WhatsApp', style: TextStyle(color: MyGlideConst.frontColor)),
        onTap: () {
          Navigator.pop(context);
          
          launch(whatsappUrl);
        }     
      );
  }  

  // De gebruiker heeft gekozen om te gaan bellen. Het kan zijn dat er meerdere telefoonnummers beschikbaar zijn
  // in dat geval zal de gebruiker eerst moeten kiezen naar welke telefoonnummer hij wil bellen
  void _belTelefoonNummer(BuildContext context) async {
    MyGlideDebug.info("_LidDetailsScreenState._belTelefoonNummer(context)");

    // als er maar 1 nummer is, selecteer deze. De pop up wordt niet getoond omdat het zinloos is
    if (_lidHelper.aantalTelefonie() == 1)
    {
      String telnummer = _lidHelper.telefonieNummer();    
      launch("tel:$telnummer");
    }
    else
    { 
      showDialog(
        context: context,
        barrierDismissible: false, // user must tap button for close dialog!
        builder: (_) {
          return SelecteerTelefoon(widget.lid, _lidHelper);
      });
    } 
  }
  
  // email versturen naar een lid
  // we maken alvast een template met ietswat tekst
  void _sendEmail() async {
    MyGlideDebug.info("_LidDetailsScreenState._sendEmail()");

    if (serverSession.login.userInfo == null)       // we weten niet wie ingelogd is
      return ;

    String emailBody = "<< hier uw tekst >> <br><br>Met vriendelijke groet,<br><br>";
    emailBody += "${serverSession.login.userInfo['NAAM']}<br><br><em>Deze mail is verstuurd vanuit de GeZC MyGlide app</em>";

    final MailOptions mailOptions = MailOptions(
      body: emailBody,
      recipients: [widget.lid["EMAIL"]],
      isHTML: true,
    );
    await FlutterMailer.send(mailOptions);
  }   
}


// een alertDialog is stateless en ververst niet als je een radio button klikt. 
// Nu in een statefull class
// In deze popup kun je kiezen naar welk telefoon nummer je wilt bellen
class SelecteerTelefoon extends StatefulWidget {
  final Map lidData;
  final LidHelper lidHelper;

  const SelecteerTelefoon(
    this.lidData, this.lidHelper, {Key key} ) : super (key: key);

  @override
  _SelecteerTelefoonState createState() => _SelecteerTelefoonState();
}


class _SelecteerTelefoonState extends State<SelecteerTelefoon> {

  @override
  Widget build(BuildContext context) {
    double maxHoogte = 10.0;

    MyGlideDebug.info("_SelecteerTelefoonState.build(context)");

    // hiermee voorkomen dat de Listview alle hoogte inneemt
    switch(widget.lidHelper.aantalTelefonie())
    {
      case 1: maxHoogte = 50; break;
      case 2: maxHoogte = 85; break;
      case 3: maxHoogte = 145; break;
    }

    return AlertDialog(
      title: Text("Kies telefoon"),
      contentPadding: EdgeInsets.all(0),
      content: ConstrainedBox(
        constraints: new BoxConstraints(
          minHeight: 35.0,
          maxHeight: maxHoogte),
        child: ListView(
          children: widget.lidHelper.telefoonNummers.keys.map((String key) {
            return 
              RadioListTile(
                groupValue: true,
                title: Text(key),
                dense: true,
                activeColor: MyGlideConst.frontColor,
                value: widget.lidHelper.telefoonNummers[key].selected,
                secondary: Icon(widget.lidHelper.telefoonNummers[key].prefixIcon),
                onChanged: (bool value) {
                  setState(() {
                    for (var nummer in widget.lidHelper.telefoonNummers.keys) 
                      widget.lidHelper.telefoonNummers[nummer].selected =  false;

                    widget.lidHelper.telefoonNummers[key].selected = true;
                  });
                },
              );
          }).toList(),
        )
      ),
      actions: <Widget>[
        FlatButton(
          child: const Text('Annuleren'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        FlatButton(
          child: const Text('Bellen'),
          onPressed: () { 
            String telnummer;
            for (var nummer in widget.lidHelper.telefoonNummers.keys) {
              if (widget.lidHelper.telefoonNummers[nummer].selected == true)
                telnummer = nummer;
            }
            Navigator.of(context).pop();
            launch("tel:$telnummer");
          }
        )
      ],
    );
  }
}


// Class voor telefoon helper functies
class LidHelper {
  final Map lidData;
  final bool isInTabletLayout;

  Map<String, TelefoonCheckboxData> telefoonNummers = Map<String, TelefoonCheckboxData>();

  LidHelper (this.lidData, this.isInTabletLayout)
  {
    MyGlideDebug.info("LidHelper(${this.lidData})");

    telefoonNummers.clear();

    if ((lidData["TELEFOON"] != null) && (lidData["TELEFOON"] != "")) {
      telefoonNummers[lidData["TELEFOON"]] = TelefoonCheckboxData(Icons.home);     
    }

    // Is er een mobiel nummer
    if ((lidData["MOBIEL"] != null) && (lidData["MOBIEL"] != "")) {
      telefoonNummers[lidData["MOBIEL"]] = TelefoonCheckboxData(Icons.phone_iphone);
      telefoonNummers[lidData["MOBIEL"]].selected = true;
    }

    // Is er een noodnummer
    if ((serverSession.login.isBeheerderDDWV) || 
      (serverSession.login.isBeheerder) || 
      (serverSession.login.isInstructeur) || 
      (serverSession.login.isStartleider)) {

      if ((lidData["NOODNUMMER"] != null) && (lidData["NOODNUMMER"] != "")) {
        telefoonNummers[lidData["NOODNUMMER"]] = TelefoonCheckboxData(Icons.local_hospital);
      }
    }
  }

  bool heeftTelefonie() 
  {
    MyGlideDebug.info("LidHelper.heeftTelefonie()");

    // We nemen aan dat een tablet geen telefoon is
    if (isInTabletLayout)
      return false;
      
    // Is er een telefoon
    if (heeftTelefoon()) return true;

    // Is er een mobiel nummer
    if (heeftMobiel()) return true;
      
    // Is er een noodnummer
    if (heeftNoodNummer()) return true;

    return false;
  }

  // Hoeveel telefoon nummers zijn er beschikbaar voor dit lid
  int aantalTelefonie() {
    MyGlideDebug.info("LidHelper.aantalTelefonie() return ${telefoonNummers.length} ");
    return telefoonNummers.length;
  }

  // Geef het eerste telefoon nummer. Wordt gebruikt als er maar 1 telefoonnummer is
  // Misschien niet zo fraai met een for loop, maar ik weet ff niet beter 
  String telefonieNummer() {
    MyGlideDebug.info("LidHelper.telefonieNummer()");

    for (var nummer in telefoonNummers.keys) 
      return nummer;

    return null;
  }


  // Heeft het lid een vaste telefoon
  bool heeftTelefoon() {
    MyGlideDebug.info("LidHelper.heeftTelefoon()");

    // We nemen aan dat een tablet geen telefoon is
    if (isInTabletLayout)
      return false;

    if ((lidData["TELEFOON"] != null) && (lidData["TELEFOON"] != "")) 
      return true;

    return false;    
  }

  // Heeft het lid een mobiel
  bool heeftMobiel() {
    // We nemen aan dat een tablet geen telefoon is
    if (isInTabletLayout)
      return false;

    MyGlideDebug.info("LidHelper.heeftMobiel()");

    if ((lidData["MOBIEL"] != null) && (lidData["MOBIEL"] != "")) 
      return true;

    return false;    
  }

  // Is er een nood nummer? Zo ja, dat mag alleen door een beperkte groep gebruikt worden
  bool heeftNoodNummer() {
    MyGlideDebug.info("LidHelper.heeftNoodNummer()");

    // We nemen aan dat een tablet geen telefoon is
    if (isInTabletLayout)
      return false;

    if ((serverSession.login.isBeheerderDDWV) || 
      (serverSession.login.isBeheerder) || 
      (serverSession.login.isInstructeur) || 
      (serverSession.login.isStartleider)) {

      if ((lidData["NOODNUMMER"] != null) && (lidData["NOODNUMMER"] != "")) 
        return true;
    }
    return false;
  }
}

// Class voor de telefoon popup scherm
class TelefoonCheckboxData {
  final IconData prefixIcon;
  bool selected = false;

  TelefoonCheckboxData(this.prefixIcon);
}