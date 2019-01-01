import 'package:my_glide/utils/session.dart';

import 'package:my_glide/data/Logboek.dart';

import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';

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
}