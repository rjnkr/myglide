// language packages
import 'dart:async';
import 'dart:convert';

// language add-ons
import 'package:http/http.dart' as http;

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/session.dart';

// my glide own widgets



class Vliegtuigen {
  
  // Haal de vluchten op van de server
  static Future<Map> getClubKisten() async {
    try {
      http.Client client = serverSession.getClient();
      if (client == null)
        return null;

      String url = serverSession.lastUrl;
      String request = '$url/php/main.php?Action=Vliegtuigen.GetClubkistenJSON';

      http.Response response = await client.get(request, headers: serverSession.getHeaders());
      serverSession.updateCookie(response);
      final Map parsed = json.decode(response.body);
      return parsed;
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