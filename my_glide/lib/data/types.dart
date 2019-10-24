// language packages
import 'dart:async';
import 'dart:convert';

// language add-ons
import 'package:http/http.dart' as http;

// my glide utils

// my glide data providers
import 'package:my_glide/data/session.dart';
import 'package:my_glide/utils/debug.dart';

// my glide own widgets

class Types {
  
  // Haal van de server welke clubkisten we hebben
  static Future<List> getTypeGroep(int groupID) async {
    String function = "Types.getTypeGroep";
    MyGlideDebug.info("$function($groupID)");

    try {
      List parsed;

      if (serverSession.isDemo) 
      {
        String demoJSON = await serverSession.getDemoData("assets/demo/Types/TypesJSON_$groupID.json");
        parsed = json.decode(demoJSON);
      }
      else
      {
        String url = await serverSession.getLastUrl();
        String request = '$url/php/main.php?Action=Types.GetObjectsJSON&_:TYPEGROUP_ID=$groupID';

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
    MyGlideDebug.trace("$function: return Map()");
    return List();       // exception geeft leeg object terug
  }
}