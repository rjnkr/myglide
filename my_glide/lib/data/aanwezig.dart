// language packages
import 'dart:convert';

// language add-ons
import 'package:http/http.dart' as http;

// my glide utils
import 'package:my_glide/utils/debug.dart';

// my glide data providers
import 'package:my_glide/data/session.dart';

// my glide own widgets

class Aanwezig 
{  
  // Onszelf aanmelden voor de vliegdag
  // voorkeurVliegtuigType is een CSV string met de ID uit de type tabel
  static Future<bool> aanmeldenLidVandaagTypes(String voorkeurVliegtuigType, String opmerking, {String id}) async {
    String function = "Aanwezig.aanmeldenLidVandaagTypes";
    MyGlideDebug.info("$function($voorkeurVliegtuigType, $opmerking)");

    if (serverSession.login.userInfo == null) {      // we weten niet wie het is
      MyGlideDebug.trace("$function: return false");
      return false;
    }

    try {
      if (serverSession.isDemo)
      {
        serverSession.login.isAangemeld = true;
        MyGlideDebug.trace("$function: return true");
        return true;
      }

      String url = await serverSession.getLastUrl();
      String post = '$url/php/main.php?Action=Aanwezig.AanmeldenLidJSON';
      String lidID = (id != null) ? id : serverSession.login.userInfo['ID'];    // Als id niet meegegeven is, melden we onszelf aan     
      await serverSession.post(post, {"OPMERKING": opmerking,  "LID_ID": lidID, "VOORKEUR_VLIEGTUIG_TYPE": voorkeurVliegtuigType });
      
      MyGlideDebug.trace("$function: return true");
      return true;
    }
    catch (e)
    {
      MyGlideDebug.error("$function:" + e.toString());
      return false;
    }
  }

  // Onszelf aanmelden voor de vliegdag
  // voorkeurVliegtuig is een vliegtuig ID
  static Future<bool> aanmeldenLidVandaagVliegtuig(String vliegtuigID, String opmerking, String startMethode, {String id}) async {
    String function = "Aanwezig.aanmeldenLidVandaagVliegtuig";
    MyGlideDebug.info("$function($vliegtuigID, $opmerking)");

    if (serverSession.login.userInfo == null) {      // we weten niet wie het is
      MyGlideDebug.trace("$function: return false");
      return false;
    }

    try {
      if (serverSession.isDemo)
      {
        serverSession.login.isAangemeld = true;
        MyGlideDebug.trace("$function: return true");
        return true;
      }

      String url = await serverSession.getLastUrl();
      String post = '$url/php/main.php?Action=Aanwezig.AanmeldenLidJSON';
      String lidID = (id != null) ? id : serverSession.login.userInfo['ID'];    // Als id niet meegegeven is, melden we onszelf aan     
      await serverSession.post(post, {"OPMERKING": opmerking,  "LID_ID": lidID, "VOORKEUR_VLIEGTUIG_ID": vliegtuigID, "STARTMETHODE": startMethode });
      
      MyGlideDebug.trace("$function: return true");
      return true;
    }
    catch (e)
    {
      MyGlideDebug.error("$function:" + e.toString());
      return false;
    }
  }

  // Haal van de server welke leden zich aangemeld hebben
  static Future<List> ledenAanwezig({force = false}) async {
    String function = "Aanwezig.ledenAanwezig";
    MyGlideDebug.info("$function($force)");

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
      MyGlideDebug.trace("$function:" + results.toString());

      return results;
    }
    catch (e)
    {
      MyGlideDebug.error("$function:" + e.toString());
    }
    MyGlideDebug.trace("$function: List()");
    return List();          // exception geeft leeg object terug
  }  
}