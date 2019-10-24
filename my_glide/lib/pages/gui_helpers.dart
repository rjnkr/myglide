 // language packages
import 'package:flutter/material.dart';

// language add-ons
import 'package:flutter_picker/flutter_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/debug.dart';

// my glide data providers
import 'package:my_glide/data/session.dart';

// my glide own widgets

// my glide pages
import 'package:my_glide/widget/my_glide_logo.dart';

 
enum ConfirmAction { JA, NEE }
enum DemoGebruiker { DDWV, LID, STARTLEIDER, INSTRUCTEUR }

typedef OnConfirmCallback = void Function(String newValue);
typedef TextChangedCallback = void Function(String newValue);

class GUIHelper {
  // Toon een enkel veld in het scherm met een label (erboven of ervoor)
  static Widget showDetailsField(String titel, String info, {bool titleTop = false, bool bold = true}) {
    MyGlideDebug.info("GUIHelper.showDetailsField($titel, $info, $titleTop)");
    return 
      Column(
        children: <Widget> [
          Row(
            children: <Widget> [
              SizedBox(
                width: 120,
                height: 22, 
                child: Text(titel, textAlign: TextAlign.start)
              ),
              Expanded(
                child: SizedBox(
                  height: 22,
                  child: Text (titleTop ? ' ' : info, 
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal))
                )
              )
            ]
          ), 
          titleTop ? 
            SizedBox(
              width: double.infinity,
              child: 
                Text(info, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal))
            )
            :
            Container(width: 0, height: 0)  //Label staat links en niet erboven
        ]
      );
  }

  // Een label met een checkbox erachter
  static Widget showLabelCheckbox(String titel, bool val)  {
    return
      Row(
        children: <Widget>[
          SizedBox (
            width: 120,
            height: 22,
            child: Text(titel)
          ),
          Icon(val == true ? Icons.check_box : Icons.check_box_outline_blank, color: MyGlideConst.frontColor,)
        ],
      ); 
  }

  // Laat een laad scherm zien zolang we bezig zijn met op halen van data
  static Widget showLoading()
  {
    MyGlideDebug.info("GUIHelper.showLoading()");

    return Scaffold(
        appBar: AppBar(
          backgroundColor: MyGlideConst.appBarBackground(),
          iconTheme: IconThemeData(color: MyGlideConst.frontColor),
          title: Text(
            " ",
            style: MyGlideConst.appBarTextColor()
          )
        ),
        body: Center(
        child: Container(
          decoration: BoxDecoration(color: MyGlideConst.showLoadingBackground),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: MyGlideLogo(showLabel: false, image: "assets/images/gezc_geel-blauw.png", size: 220)
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0),
              ),
              Text(
                "Even wachten ...",
                softWrap: true,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                    color: MyGlideConst.backgroundColor
                  ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(MyGlideConst.frontColor)),
                  ],
                ),
              )
            ],
          )
        )
      ),
    );
  }

  // Laat de gebruiker zien dat hij zijn apparaat moet draaien in portrait mode
  static Widget moetInPortraitMode()
  {
    MyGlideDebug.info("GUIHelper.showLoading()");

    return Scaffold(
        appBar: AppBar(
          backgroundColor: MyGlideConst.appBarBackground(),
          iconTheme: IconThemeData(color: MyGlideConst.frontColor),
          title: Text(
            "MyGlide",
            style: MyGlideConst.appBarTextColor()
          )
        ),
        body: Center(
        child: Container(
          decoration: BoxDecoration(color: MyGlideConst.showLoadingBackground),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Image.asset("assets/images/rotate_to_portrait.png", color: Colors.black54),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0),
              ),
              Expanded(
                flex: 1,
                child:
                  Text(
                    "Draai het scherm ...",
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: MyGlideConst.frontColor
                      ),
                  ),
              ),
            ],
          )
        )
      ),
    );
  } 

  // Popup window JA/NEE
  static Future<ConfirmAction> confirmDialog(BuildContext context, String title, String message) async {
    MyGlideDebug.info("GUIHelper.confirmDialog(context, $title, $message)");

    return showDialog<ConfirmAction>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title ?? ' '),
          content: Text(message ?? ' '),
          actions: <Widget>[
            FlatButton(
              child: const Text('Nee'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.NEE);
              },
            ),
            FlatButton(
              child: const Text('Ja'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.JA);
              },
            )
          ],
        );
      },
    );
  }

  // Popup windows met bericht
  static Future<void> ackAlert(BuildContext context, String title, String message) {
    MyGlideDebug.info("GUIHelper.ackAlert(context, $title, $message)");

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title ?? ' '),
          content: Text(message ?? ' '),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Zet in het menu dat we in demo mode zitten
  static Widget demoOverlay(BuildContext context)
  {
    MyGlideDebug.info("GUIHelper.demoOverlay(context)");

    if (serverSession.isDemo) 
    {
      return 
        Container(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
          height: 60,
          width: 60,
          child: Image.asset('assets/images/demo_marker.png')
        ); 
    }
    
    return Container(width: 0, height: 0);
  }

  // Welke permissies krijgt de demo gebruiker
  static Future<DemoGebruiker> demoDialog(BuildContext context) async {
    MyGlideDebug.info("GUIHelper.demoDialog(context)");

    return await showDialog<DemoGebruiker>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Rol voor vandaag'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, DemoGebruiker.DDWV);
              },
              child: const Text('> DDWV\'er'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, DemoGebruiker.LID);
              },
              child: const Text('> Lid'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, DemoGebruiker.STARTLEIDER);
              },
              child: const Text('> Startleider'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, DemoGebruiker.INSTRUCTEUR);
              },
              child: const Text('> Instructeur'),
            )
          ],
        );
      }
    );
  }

  // Werken we op een tablet ?  Zo nee, dan is het een mobiele telefoon
  static bool isTablet(BuildContext context) {
    MyGlideDebug.info("GUIHelper.isTablet(context)");
    return (MediaQuery.of(context).size.shortestSide > 600);
  }

  // Is het scherm in landscape mode
  static bool isLandscape(BuildContext context) {
    MyGlideDebug.info("GUIHelper.isLandscape(context)");

    Orientation orientation = MediaQuery.of(context).orientation;
    return (orientation == Orientation.landscape);
  }

  // Is het scherm in portrait mode
  static bool isPortrait(BuildContext context) {
    MyGlideDebug.info("GUIHelper.isPortrait(context)");
    
    Orientation orientation = MediaQuery.of(context).orientation;
    return (orientation == Orientation.portrait);
  }

  // Hoe wordt het veld in het grid vertoond
  static TextStyle gridTextStyle({color = MyGlideConst.gridTextColor, weight = FontWeight.normal, fontSize = MyGlideConst.gridTextNormal, bool underline = false}) {
    if (underline) {
      return TextStyle (
        color: color,
        fontWeight: weight,
        fontSize: fontSize,
        decoration: TextDecoration.underline
      );
    } 

    return TextStyle (
      color: color,
      fontWeight: weight,
      fontSize: fontSize
    );
  }

  // Toon de avatar met de afbeelding van het lid
  static Widget avatar(String avatarUrl, double size) {
    MyGlideDebug.info("GUIHelper.avatar($avatarUrl, $size)"); 

    if (avatarUrl == null) 
      return CircleAvatar(
        radius: size,
        backgroundColor: Colors.white,
        backgroundImage: AssetImage("assets/images/no_avatar.png")
      );

    if (!avatarUrl.toLowerCase().contains("http")) 
      return CircleAvatar(
        radius: size,
        backgroundImage: AssetImage(avatarUrl)
        );  
    
    return CachedNetworkImage(
      imageUrl: avatarUrl,
      placeholder: (context, url) => CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(MyGlideConst.frontColor)),
      errorWidget: (context, url, error) => Icon(Icons.error),
      imageBuilder: ((context, imageProvider) {
        return CircleAvatar(
          radius: size,
          backgroundImage: imageProvider);
      })
    );
  }

  // create the illusion of a beautifully scrolling text box
  static Widget scrollableTextInput(
      BuildContext context, 
      {
        TextEditingController controller,
        final TextChangedCallback onTextChanged,
        final double minHeight = 40, final double maxHeight = double.maxFinite, 
        final double minWidth = 20, final double maxWidth = double.maxFinite,
        final String labelText, final String hintText, final int maxLines = 1, 
        final Widget suffixIcon, final TextInputType keyboardType, final bool enabled = true}
      ) 
  {      
    return
      Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
            child:
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: MyGlideConst.frontColor),
                  borderRadius: BorderRadius.circular(5)
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                    maxWidth: maxWidth,
                    minHeight: minHeight,
                    maxHeight: maxHeight,
                  ),
                  child: 
                    ListView(                 // Listview neemt alle ruimte die het krijgen kan
                      children: <Widget>[
                        SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          padding: EdgeInsets.fromLTRB(0, 2, 0, 0),
                          // here's the actual text box
                          child:  TextField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              enabled: enabled,
                              hintText: hintText,
                              suffixIcon: suffixIcon,
                            ),
                            keyboardType: keyboardType,
                            maxLines: maxLines, // null = grow automatically
                            onChanged: (val) => onTextChanged(val),
                            controller: controller
                          ),// ends the actual text box
                        ),
                      ]),
                  )
                ),
              ),
            Positioned(
              top: -3,
              left: 7,
              child: Text(" $labelText ",
                style: TextStyle (
                  color: MyGlideConst.frontColor,
                  backgroundColor: Colors.white)
              )
            ),  
        ]);  
  }

  // Vergelijkbaar met hierboven, maar nu niet scrollen in het text veld. Gebruik voor enkel regel input
  static Widget textInput(
      BuildContext context, 
      {
        TextEditingController controller,
        final TextChangedCallback onTextChanged,
        final String labelText, final String hintText, final int maxLines = 1, 
        final Widget suffixIcon, final TextInputType keyboardType, final bool enabled = true}
      ) 
  {      
    return
      Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
            child:
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: MyGlideConst.frontColor),
                  borderRadius: BorderRadius.circular(5)
                ),
                
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabled: enabled,
                    hintText: hintText,
                    suffixIcon: suffixIcon
                  ),
                  keyboardType: keyboardType,
                  maxLines: maxLines, // null = grow automatically
                  onChanged: (val) => onTextChanged(val),
                  controller: controller,
                ),// ends the actual text box
              )
            ),
            Positioned(
              top: -3,
              left: 7,
              child: Text(" $labelText ",
                style: TextStyle (
                  color: MyGlideConst.frontColor,
                  backgroundColor: Colors.white)
              )
            ),  
        ]);  
  }

  // popup om een tijd te kunnen kiezen
  static void tijdPicker(BuildContext context, { OnConfirmCallback onConfirm, String tijd, String titel}) {
    MyGlideDebug.info("GUIHelper.tijdPicker(context, $tijd)"); 

    int uren = TimeOfDay.now().hour;
    int min = TimeOfDay.now().minute;

    if (tijd != null)
    {
      try {
        List t = tijd.split(":");

        uren = int.parse(t[0]);
        min = int.parse(t[1]);
      }
      catch(e) {}
    }

    Picker(
      looping: true,
        adapter: NumberPickerAdapter(data: [
          NumberPickerColumn(begin: 0, end: 24, initValue: uren),
          NumberPickerColumn(begin: 0, end: 59, initValue: min),
        ]),
        delimiter: [
          PickerDelimiter(child: Container(
            width: 30.0,
            alignment: Alignment.center,
            child: Text(':',style: TextStyle(fontWeight: FontWeight.bold),)
          ))
        ],
        hideHeader: true,
        title: Text(titel ?? ""),
        onConfirm: (Picker picker, List value) =>
          onConfirm("${value[0].toString().padLeft(2,'0')}:${value[1].toString().padLeft(2,'0')}")
    ).showDialog(context);

    return null;
  }  

  static Widget geenData({String bericht = "Geen data om te tonen", Icon icon}) { 
    MyGlideDebug.info("GUIHelper.geenData()");

    return
      Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.fromLTRB(20, 0, 0, 0)),
                  Icon((icon == null) ? Icons.warning : icon, color: MyGlideConst.frontColor),
                  Padding(padding: EdgeInsets.fromLTRB(20, 0, 0, 0)),
                  Expanded(child: Text("$bericht"))
                ])
            )
          ),
        ]
      );
  }

  // Controleer of gebruikersnaam (goed) ingevuld is
  static String isIngevuld(String value) {
    MyGlideDebug.info("GUIHelper.isIngevuld($value)");

    if (value.trim().isEmpty) 
      return "Veld mag niet leeg zijn";

    return null;
  }

  // De verschillende styles
  static TextStyle hintStyle()  {
    MyGlideDebug.info("GUIHelper._hintStyle()");

    return TextStyle(
      color: MyGlideConst.hintColorLight,
      fontSize: MyGlideConst.hintSizeSmall
    );
  }

  static TextStyle labelStyle()  {
    MyGlideDebug.info("GUIHelper._labelStyle()");
    return TextStyle(
      color: MyGlideConst.labelColorLight,
      fontSize: MyGlideConst.labelSizeNormal
    );
  }

  static TextStyle body1Style()  {
    MyGlideDebug.info("GUIHelper._inputStyle()");

    return TextStyle(
      color: Colors.red, // MyGlideConst.textInputDark, 
      fontSize: MyGlideConst.textInputSizeNormal
    );
  }

  static TextStyle errorStyle()  {
    MyGlideDebug.info("GUIHelper._errorStyle()");

    return TextStyle(
      color: MyGlideConst.errorColorLight,
      fontSize: MyGlideConst.errorSizeNormal
      
    );
  }
}