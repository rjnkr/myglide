// language packages

// language add-ons
import 'package:http/http.dart' as http;

// my glide utils

// my glide data providers
import 'package:my_glide/data/session.dart';

// my glide own widgets

class ZonOpkomstOndergang {
  
  // Haal van de server hoe laat de zon opkomt
  static Future<DateTime> zonOpkomst() async {
    final now = DateTime.now();

    try {
      String url = await serverSession.getLastUrl();
      String request = '$url/php/main.php?Action=ZonOpOnder.ZonOpkomst';

      http.Response response = await serverSession.get(request);
      return DateTime(now.year, now.month, now.day, int.parse(response.body.substring(0,2)), int.parse(response.body.substring(3,5)));
    }
    catch (e)
    {
      print (e);
    }
    
    return DateTime(now.year, now.month, now.day, 5);       // Zon komt nooit eerder op dan 5 uur
  }

  // Haal van de server hoe laat de zon onder gaat
  static Future<DateTime> zonOndergang() async {
    final now = DateTime.now();

    try {
      String url = await serverSession.getLastUrl();
      String request = '$url/php/main.php?Action=ZonOpOnder.ZonOndergang';

      http.Response response = await serverSession.get(request);
      return DateTime(now.year, now.month, now.day, int.parse(response.body.substring(0,2)), int.parse(response.body.substring(3,5)));
    }
    catch (e)
    {
      print (e);
    }
    
    return DateTime(now.year, now.month, now.day, 23);    // Zon gaat nooit na 23 uur onder
  }  
}