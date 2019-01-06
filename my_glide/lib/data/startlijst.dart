// language packages
import 'dart:async';
import 'dart:convert';

// language add-ons
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;

// my glide utils

// my glide data providers
import 'package:my_glide/data/session.dart';

// my glide own widgets



class Startlijst 
{  
  // Haal de vluchten op van de server
  static Future<List> getLogboek({force = false}) async {
    Map parsed;

    try {
      // haal aantal op als opgeslagen in 'nrLogboekItems' anders max 50
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int maxItems = prefs.getInt('nrLogboekItems') ?? 50;

      String url = serverSession.lastUrl;
      String request = '$url/php/main.php?Action=Startlijst.LogboekJSON&start=0&limit=$maxItems';

      ConnectivityResult connected = await Connectivity().checkConnectivity();
      if (connected == ConnectivityResult.none) {
        String rawJSON = prefs.getString("startlijst:getLogboek") ?? "{'total':'0','results':[]}";
        parsed = json.decode(rawJSON);                                      // geen netwerk gebruik cache
      }
      else {
        http.Response response = await serverSession.get(request);
        parsed = json.decode(response.body);

        prefs.setString("startlijst:getLogboek", response.body);            // stop json in cache
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

  // ophalen van het vliegtuig logboek. vliegtuigID bevat ID van vliegtuig uit ref_vliegtuigen
  static Future<List> getVliegtuigLogboek(String vliegtuigID) async {
    try {
      String url = serverSession.lastUrl;
      String request = '$url/php/main.php?Action=Startlijst.VliegtuigLogboekJSON&_:logboekVliegtuigID=$vliegtuigID';

      http.Response response = await serverSession.get(request);
      final List parsed = json.decode(response.body);
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
      String url = serverSession.lastUrl;
      String post = '$url/php/main.php?Action=Startlijst.SaveLandingsTijd';

      await serverSession.post(post, {"ID": id, "LANDINGSTIJD": landingsTijd });

      return true;
    }
    catch (e)
    {
      print (e);
    }
    return false;  
  }

    // Opslaan van de landings tijd. id bevat het ID van de start uit oper_startlijst
  static Future<bool> verwijderVlucht(String id) async {
    try {
      String url = serverSession.lastUrl;
      String post = '$url/php/main.php?Action=Startlijst.VerwijderObject';

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