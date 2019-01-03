// language packages
import 'dart:async';
import 'dart:convert';

// language add-ons
import 'package:http/http.dart' as http;

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/session.dart';

// my glide own widgets



class Startlijst {
  
  // Haal de vluchten op van de server
  static Future<List> getLogboek(int maxItems, {force = false}) async {
    try {
      http.Client client = serverSession.getClient();
      if (client == null)
        return null;

      String url = serverSession.lastUrl;
      String request = '$url/php/main.php?Action=Startlijst.LogboekJSON&start=0&limit=$maxItems';

      http.Response response = await client.get(request, headers: serverSession.getHeaders());
      serverSession.updateCookie(response);
      final Map parsed = json.decode(response.body);
      final List results = (parsed['results']); 
      return results;
    }
    catch (e)
    {
      print (e);
    }
    return null;
  }

  static void opslaanLandingsTijd(String id, String landingsTijd) async {
    try {
        http.Client client = serverSession.getClient();
        if (client == null)
          return null;

        String url = serverSession.lastUrl;
        String post = '$url/php/main.php?Action=Startlijst.SaveLandingsTijd';

        http.Response response = await client.post(post, body: {"ID": id, "LANDINGSTIJD": landingsTijd }, headers: serverSession.getHeaders());
        serverSession.updateCookie(response);

        return null;
      }
      catch (e)
      {
        print (e);
      }
    return null;  
  }
}