// language packages
import 'dart:async';
import 'dart:convert';

// language add-ons
import 'package:http/http.dart' as http;

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/session.dart';

// my glide own widgets



class Aanwezig {
  
    static Future<bool> isAangemeld(String lidID) async {
    try {
      http.Client client = serverSession.getClient();
      if (client == null)
        return null;

      String url = serverSession.lastUrl;
      String request = '$url/php/main.php?Action=Aanwezig.LedenAanwezigJSON&_:lid_id=$lidID';

      http.Response response = await client.get(request, headers: serverSession.getHeaders());
      serverSession.updateCookie(response);
      final Map parsed = json.decode(response.body);
      
      if (parsed['total'] == '1')
        return true;
    }
    catch (e)
    {
      print (e);
    }
    return false;
  }

  static void aanmeldenLidVandaag(String voorkeurVliegtuigType) async {
    try {
        http.Client client = serverSession.getClient();
        if (client == null)
          return null;

        String url = serverSession.lastUrl;
        String post = '$url/php/main.php?Action=Aanwezig.AanmeldenLidJSON';

        http.Response response = await client.post(post, body: {"LID_ID": serverSession.userInfo['ID'], "VOORKEUR_VLIEGTUIG_TYPE": voorkeurVliegtuigType }, headers: serverSession.getHeaders());
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