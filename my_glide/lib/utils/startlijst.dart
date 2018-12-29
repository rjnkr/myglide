import 'package:my_glide/utils/session.dart';

import 'package:my_glide/data/Logboek.dart';

import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';

class Startlijst {

  // Haal de vluchten op van de server
  static Future<List> getLogboek() async {
    try {
      if (serverSession.client == null)
        return null;

      String url = serverSession.lastUrl;
      String request = '$url/php/main.php?Action=Startlijst.LogboekJSON';

      http.Response response = await serverSession.client.get(request, headers: serverSession.headers);
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