// language packages
import "dart:async";
import "dart:convert";

// language add-ons
import "package:connectivity/connectivity.dart";
import "package:http/http.dart" as http;

// my glide utils
import "package:my_glide/utils/storage.dart";

// my glide data providers
import "package:my_glide/data/session.dart";

// my glide own widgets


class Startlijst 
{  
  // Haal de vluchten op van de server
  static Future<List> getLogboek({force = false}) async {
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
        String request = "$url/php/main.php?Action=Startlijst.LogboekJSON&start=0&limit=$maxItems";

        ConnectivityResult connected = await Connectivity().checkConnectivity();
        if (connected == ConnectivityResult.none) {
          String rawJSON = await Storage.getString("startlijst:getLogboek", defaultValue: """{"total":"0","results":[]}""");
          parsed = json.decode(rawJSON);                                      // geen netwerk gebruik cache
        }
        else {
          http.Response response = await serverSession.get(request);
          parsed = json.decode(response.body);

          Storage.setString("startlijst:getLogboek", response.body);            // stop json in cache
        }
      }

      final List results = (parsed["results"]); 

      // beperk lijst tot ingesteld maximum, gebeurd alleen in demo mode
      if (results.length > maxItems)
        results.removeRange(maxItems-1, results.length-1);

      return results;
    }
    catch (e)
    {
      print (e);
    }
    return null;
  }

  // ophalen van het vliegtuig logboek. vliegtuigID bevat ID van vliegtuig uit ref_vliegtuigen
  static Future<List> getVliegtuigLogboek(String vliegtuigID) async {
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
      return parsed;
    }
    catch (e)
    {
      print (e);
    }
    return null;
  }

  // ophalen van de start van een speciek lid
  static Future<List> getStartsVandaag(String lidID) async {
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
      return results;
    }
    catch (e)
    {
      print (e);
    }
    return null;
  }  

  // ophalen van de start van een speciek lid
  static Future<Map> getRecency(String lidID) async {
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
      return parsed;
    }
    catch (e)
    {
      print (e);
    }
    return null;
  }  

  // Opslaan van de landings tijd. id bevat het ID van de start uit oper_startlijst
  static Future<bool> opslaanLandingsTijd(String id, String landingsTijd) async {
    try {
      if (serverSession.isDemo)  return true;

      String url = await serverSession.getLastUrl();
      String post = "$url/php/main.php?Action=Startlijst.SaveLandingsTijd";
      await serverSession.post(post, {"ID": id, "LANDINGSTIJD": landingsTijd });
      return true;
    }
    catch (e)
    {
      print (e);
    }
    return false;  
  }

  // Verwijderen van een start in het logboek
  static Future<bool> verwijderVlucht(String id) async {
    try {
      if (serverSession.isDemo)  return true;
      
      String url = await serverSession.getLastUrl();
      String post = "$url/php/main.php?Action=Startlijst.VerwijderObject";
      await serverSession.post(post, {"ID": id });
      return true;
    }
    catch (e)
    {
      print (e);
    }
    return false;  
  }                                                   
}