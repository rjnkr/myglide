// language packages

// language add-ons
import 'package:http/http.dart' as http;

// my glide utils
import 'package:my_glide/utils/debug.dart';

// my glide data providers
import 'package:my_glide/data/session.dart';

// my glide own widgets

class ZonOpkomstOndergang {
  
  // Haal van de server hoe laat de zon opkomt
  static Future<DateTime> zonOpkomst(String url) async {
    String function = "ZonOpkomstOndergang.zonOpkomst";
    MyGlideDebug.info("$function($url)");

    final now = DateTime.now();
    DateTime retVal = DateTime(now.year, now.month, now.day, 5);       // Zon komt nooit eerder op dan 5 uur
    try { 
      if (!serverSession.isDemo) 
      {
        String request = '$url/php/main.php?Action=ZonOpOnder.ZonOpkomst';

        http.Response response = await serverSession.get(request);
        retVal = DateTime(now.year, now.month, now.day, int.parse(response.body.substring(0,2)), int.parse(response.body.substring(3,5)));
      }
    }
    catch (e)
    {
      MyGlideDebug.error("$function:" + e.toString());
    }

    MyGlideDebug.trace("$function: return $retVal");
    return retVal;
  }

  // Haal van de server hoe laat de zon onder gaat
  static Future<DateTime> zonOndergang(String url) async {
    String function = "ZonOpkomstOndergang.zonOndergang";
    MyGlideDebug.info("$function($url)");

    final now = DateTime.now();
    DateTime retVal = DateTime(now.year, now.month, now.day, 23);    // Zon gaat nooit na 23 uur onder
    
    try {
      if (!serverSession.isDemo) 
      {
        String request = '$url/php/main.php?Action=ZonOpOnder.ZonOnder';

        http.Response response = await serverSession.get(request);
        retVal = DateTime(now.year, now.month, now.day, int.parse(response.body.substring(0,2)), int.parse(response.body.substring(3,5)));
      }
    }
    catch (e)
    {
      MyGlideDebug.error("$function:" + e.toString());
    }
    MyGlideDebug.trace("$function: return $retVal");
    return retVal;
  }  
}