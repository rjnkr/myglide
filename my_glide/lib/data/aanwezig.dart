// language packages
import 'dart:convert';

// language add-ons
import 'package:http/http.dart' as http;

// my glide utils

// my glide data providers
import 'package:my_glide/data/session.dart';

// my glide own widgets

class Aanwezig 
{  
  // Onszelf aanmelden voor de vliegdag
  // voorkeurVliegtuigType is een CSV string met de ID uit de type tabel
  static Future<bool> aanmeldenLidVandaag(String voorkeurVliegtuigType, String opmerking) async {
    try {
        if (serverSession.isDemo)
        {
          serverSession.login.isAangemeld = true;
          return true;
        }

        String url = await serverSession.getLastUrl();
        String post = '$url/php/main.php?Action=Aanwezig.AanmeldenLidJSON';
        String lidID = serverSession.login.userInfo['ID'];      
        await serverSession.post(post, {"OPMERKING": opmerking,  "LID_ID": lidID, "VOORKEUR_VLIEGTUIG_TYPE": voorkeurVliegtuigType });
        return true;
      }
      catch (e)
      {
        print (e);
        return false;
      }
  }

  // Haal van de server welke leden zich aangemeld hebben
  static Future<List> ledenAanwezig({force = false}) async {
    try {
      Map parsed;

      if (serverSession.isDemo)
      {
        String demoJSON = await serverSession.getDemoData("assets/demo/Aanwezig/LedenAanwezigJSON.json");
        parsed = json.decode(demoJSON);
      }
      else
      {
        String url = await serverSession.getLastUrl();
        String request = '$url/php/main.php?Action=Aanwezig.LedenAanwezigJSON';

        http.Response response = await serverSession.get(request);
        parsed = json.decode(response.body);
      }

      final List results = (parsed['results']); 
      return results;
    }
    catch (e)
    {
      print (e);
    }
    return null;
  }  
}