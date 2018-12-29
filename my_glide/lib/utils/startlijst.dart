import 'package:my_glide/utils/session.dart';
import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';


class Startlijst {

  // Haal de vluchten op van de server
  Future<Map> Logboek() async {
    try {
      if (serverSession.client == null)
        return null;

      String url = serverSession.lastUrl;
      String request = '$url/php/main.php?Action=Startlijst.LogboekJSON';

      http.Response response = await serverSession.client.get(request, headers: serverSession.headers);
      serverSession.updateCookie(response);
      return json.decode(response.body);
    }
    catch (e)
    {
      print (e);
    }
  }
}