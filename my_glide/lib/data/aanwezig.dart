// language packages

// language add-ons

// my glide utils

// my glide data providers
import 'package:my_glide/data/session.dart';

// my glide own widgets

class Aanwezig 
{  
  // Onszelf aanmelden voor de vliegdag
  // voorkeurVliegtuigType is een CSV string met de ID uit de type tabel
  static Future<bool> aanmeldenLidVandaag(String voorkeurVliegtuigType) async {
    try {
        String url = serverSession.lastUrl;
        String post = '$url/php/main.php?Action=Aanwezig.AanmeldenLidJSON';

        String lidID = serverSession.login.userInfo['ID'];      
        await serverSession.post(post, {"LID_ID": lidID, "VOORKEUR_VLIEGTUIG_TYPE": voorkeurVliegtuigType });
  
        return true;
      }
      catch (e)
      {
        print (e);
        return false;
      }
  }
}