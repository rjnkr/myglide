// language packages
import 'dart:convert';
import 'dart:core';

// language add-ons
import "package:connectivity/connectivity.dart";
import 'package:http/http.dart' as http;

// my glide utils
import "package:my_glide/utils/storage.dart";
import 'package:my_glide/utils/debug.dart';

// my glide data providers
import 'package:my_glide/data/session.dart';

// my glide own widgets
class Leden {
  
  // Haal van de server welke clubkisten we hebben
  static Future<List> getLeden() async {
    String function = "Leden.getLeden";
    MyGlideDebug.info("$function()");

    Map parsed;

    try {
      if (serverSession.isDemo)
      {
        String demoJSON = await serverSession.getDemoData("assets/demo/Leden/LedenJSON.json");
        parsed = json.decode(demoJSON);
      }
      else
      {
        String url = await serverSession.getLastUrl();

        if (url == null)    // URL is nog niet bekend
          return List();  

        bool toonDDWV = await Storage.getBool('toonDDWV', defaultValue: false);

        String request = "$url/php/main.php?Action=Leden.getLedenJSON&_:toonDDWV=$toonDDWV";

        ConnectivityResult connected = await Connectivity().checkConnectivity();
        if (connected == ConnectivityResult.none) {
          String rawJSON = await Storage.getString("Leden:getLeden", defaultValue: """{"total":"0","results":[]}""");
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

            String rawJSON = await Storage.getString("Leden:getLeden", defaultValue: """{"total":"0","results":[]}""");
            parsed = json.decode(rawJSON);                                        // netwerk error gebruik cache            
          }
        }
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

}