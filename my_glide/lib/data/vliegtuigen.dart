// language packages
import 'dart:async';
import 'dart:convert';

// language add-ons
import 'package:http/http.dart' as http;

// my glide utils

// my glide data providers
import 'package:my_glide/data/session.dart';

// my glide own widgets


class Vliegtuigen {
  
  // Haal van de server welke clubkisten we hebben
  static Future<Map> getClubKisten() async {
    try {
      Map parsed;

      if (serverSession.isDemo) 
      {
        String demoJSON = await serverSession.getDemoData("assets/demo/Vliegtuigen/GetClubkistenJSON.json");
        parsed = json.decode(demoJSON);
      }
      else
      {
        String url = await serverSession.getLastUrl();
        String request = '$url/php/main.php?Action=Vliegtuigen.GetClubkistenJSON';

        http.Response response = await serverSession.get(request);
        parsed = json.decode(response.body);
      }
      return parsed;
    }
    catch (e)
    {
      print (e);
    }
    return null;
  }
}