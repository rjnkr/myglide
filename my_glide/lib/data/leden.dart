// language packages
import 'dart:async';
import 'dart:convert';

// language add-ons
import 'package:http/http.dart' as http;

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/session.dart';

// my glide own widgets


class Leden {
  
  // Haal de info van de ingelogde gebruiker op
  static Future<Map> getUserDetails(String username) async {
    try {
      http.Client client = serverSession.getClient();
      if (client == null)
        return null;

      String url = serverSession.lastUrl;
      String request = '$url/php/main.php?Action=Leden.GetObjectJSONByLoginNaam&username=$username';

      http.Response response = await client.get(request, headers: serverSession.getHeaders());
      serverSession.updateCookie(response);
      final Map parsed = json.decode(response.body);
      final Map results = (parsed['data']); 
      return results;
    }
    catch (e)
    {
      print (e);
    }
    return null;
  }
}