// language packages
import "dart:async";
import "dart:convert";

// language add-ons
import "package:connectivity/connectivity.dart";
import "package:http/http.dart" as http;
import 'package:intl/intl.dart';

// my glide utils
import "package:my_glide/utils/storage.dart";
import 'package:my_glide/utils/debug.dart';

// my glide data providers
import "package:my_glide/data/session.dart";

// my glide own widgets


class Startlijst 
{ 
  static DateTime _lastLogboekGeladen;

  // Haal de vluchten op van de server
  static Future<List> getLogboek() async {
    String function = "Startlijst.getLogboek";
    MyGlideDebug.info("$function()");

    Map parsed;

    try {
      // haal aantal op als opgeslagen in "nrLogboekItems" anders max 50
      int maxItems = await Storage.getInt("nrLogboekItems", defaultValue: 50);

      if (serverSession.isDemo)
      {
        String demoJSON = await serverSession.getDemoData("assets/demo/Startlijst/LogboekJSON.json");
        parsed = json.decode(demoJSON);
      }
      else
      {
        String url = await serverSession.getLastUrl();

        if (url == null)    // URL is nog niet bekend
          return List();  

        String request = "$url/php/main.php?Action=Startlijst.LogboekJSON&start=0&limit=$maxItems";

        ConnectivityResult connected = await Connectivity().checkConnectivity();
        if (connected == ConnectivityResult.none) {
          String rawJSON = await Storage.getString("startlijst:getLogboek", defaultValue: """{"total":"0","results":[]}""");
          parsed = json.decode(rawJSON);                                        // geen netwerk gebruik cache
        }
        else {
          try {
            http.Response response = await serverSession.get(request);
            parsed = json.decode(response.body);

            Storage.setString("startlijst:getLogboek", response.body);            // stop json in cache
          }
          catch(e) {
            MyGlideDebug.error("$function:" + e.toString());

            String rawJSON = await Storage.getString("startlijst:getLogboek", defaultValue: """{"total":"0","results":[]}""");
            parsed = json.decode(rawJSON);                                        // netwerk error gebruik cache            
          }
        }
      }

      final List results = (parsed["results"]); 

      // beperk lijst tot ingesteld maximum, gebeurd alleen in demo mode
      if (results.length > maxItems)
        results.removeRange(maxItems-1, results.length-1);

      _lastLogboekGeladen = DateTime.now();
      MyGlideDebug.trace("$function: return " + results.toString());
      return results;
    }
    catch (e)
    {
      MyGlideDebug.error("$function:" + e.toString());
    }

    MyGlideDebug.trace("$function: return List()");
    return List();          // exception geeft leeg object terug
  }

  // Wanneer is logboek voor de laatste keer geladen
  static DateTime lastLogboekGeladen()
  {
    return _lastLogboekGeladen;
  }

  // ophalen van het vliegtuig logboek. vliegtuigID bevat ID van vliegtuig uit ref_vliegtuigen
  static Future<List> getVliegtuigLogboek(String vliegtuigID) async {
    String function = "Startlijst.getVliegtuigLogboek";
    MyGlideDebug.info("$function($vliegtuigID)");

    try {
      List parsed;

      if (serverSession.isDemo)
      {
        String demoJSON = await serverSession.getDemoData("assets/demo/Startlijst/VliegtuigLogboekJSON_$vliegtuigID.json");
        parsed = json.decode(demoJSON);
      }
      else
      {
        String url = await serverSession.getLastUrl();
        String request = "$url/php/main.php?Action=Startlijst.VliegtuigLogboekJSON&_:logboekVliegtuigID=$vliegtuigID";

        http.Response response = await serverSession.get(request);
        parsed = json.decode(response.body);
      }
      MyGlideDebug.trace("$function: return " + parsed.toString());
      return parsed;
    }
    catch (e)
    {
      MyGlideDebug.error("$function:" + e.toString());
    }
    MyGlideDebug.trace("$function: return List()");
    return List();          // exception geeft leeg object terug
  }

  // ophalen van de start van een speciek lid
  static Future<List> getStartsVandaag(String lidID) async {
    String function = "Startlijst.getStartsVandaag";
    MyGlideDebug.info("$function($lidID)");

    try {
      Map parsed;

      if (serverSession.isDemo)
      {
        String demoJSON = await serverSession.getDemoData("assets/demo/Startlijst/StartlijstVandaagJSON_$lidID.json");
        parsed = json.decode(demoJSON);
      }
      else
      {
        String url = await serverSession.getLastUrl();
        String request = "$url/php/main.php?Action=Startlijst.StartlijstVandaagJSON&_:id=$lidID";

        http.Response response = await serverSession.get(request);
        parsed = json.decode(response.body);
      }
      final List results = (parsed["results"]);
      MyGlideDebug.trace("$function: return " + results.toString());
      return results;
    }
    catch (e)
    {
      MyGlideDebug.error("$function:" + e.toString());
    }
    MyGlideDebug.trace("$function: return List()");
    return List();          // exception geeft leeg object terug
  }  

  // ophalen van de start van een speciek lid
  static Future<Map> getRecency(String lidID) async {
    String function = "Startlijst.getRecency";
    MyGlideDebug.info("$function($lidID)");

    try {
      Map parsed;

      if (serverSession.isDemo)
      {
        String demoJSON = await serverSession.getDemoData("assets/demo/Startlijst/VliegerRecencyJSON_$lidID.json");
        parsed = json.decode(demoJSON);
      }
      else
      {
        String url = await serverSession.getLastUrl();

        String request = "$url/php/main.php?Action=Startlijst.VliegerRecencyJSON&_:id=$lidID";

        http.Response response = await serverSession.get(request);
        parsed = json.decode(response.body);
      }
      MyGlideDebug.trace("$function: return " + parsed.toString());
      return parsed;
    }
    catch (e)
    {
      MyGlideDebug.error("$function:" + e.toString());
    }
    MyGlideDebug.trace("$function: return List()");
    return Map();          // exception geeft leeg object terug
  }  

  // Opslaan van de landings tijd. id bevat het ID van de start uit oper_startlijst
  static Future<bool> opslaanLandingsTijd(String id, String landingsTijd) async {
    String function = "Startlijst.opslaanLandingsTijd";
    MyGlideDebug.info("$function($id, $landingsTijd)");

    try {
      if (serverSession.isDemo)  return true;

      String url = await serverSession.getLastUrl();
      String post = "$url/php/main.php?Action=Startlijst.SaveLandingsTijd";
      await serverSession.post(post, {"ID": id, "LANDINGSTIJD": landingsTijd });
      _lastLogboekGeladen = null;                                                 // Indicatie dat logboek verandert is

      MyGlideDebug.trace("$function: return true");
      return true;
    }
    catch (e)
    {
      MyGlideDebug.error("$function:" + e.toString());
    }
    MyGlideDebug.trace("$function: return false");
    return false;  
  }

  // Opslaan van de start tijd. id bevat het ID van de start uit oper_startlijst
  static Future<bool> opslaanStartTijd(String id, String startTijd) async {
    String function = "Startlijst.opslaanStartTijd";
    MyGlideDebug.info("$function($id, $startTijd)");

    try {
      if (serverSession.isDemo)  return true;

      String url = await serverSession.getLastUrl();
      String post = "$url/php/main.php?Action=Startlijst.SaveStartTijd";
      await serverSession.post(post, {"ID": id, "STARTTIJD": startTijd });
      _lastLogboekGeladen = null;                                                 // Indicatie dat logboek verandert is

      MyGlideDebug.trace("$function: return true");
      return true;
    }
    catch (e)
    {
      MyGlideDebug.error("$function:" + e.toString());
    }
    MyGlideDebug.trace("$function: return false");
    return false;  
  }  

  // Verwijderen van een start in het logboek
  static Future<bool> verwijderVlucht(String id) async {
    String function = "Startlijst.verwijderVlucht";
    MyGlideDebug.info("$function($id)");

    try {
      if (serverSession.isDemo)  return true;
      
      String url = await serverSession.getLastUrl();
      String post = "$url/php/main.php?Action=Startlijst.VerwijderObject";
      await serverSession.post(post, {"ID": id });
      MyGlideDebug.trace("$function: return true");
      return true;
    }
    catch (e)
    {
      MyGlideDebug.error("$function:" + e.toString());
    }
    MyGlideDebug.trace("$function: return false");
    return false;  
  }                                                   
}