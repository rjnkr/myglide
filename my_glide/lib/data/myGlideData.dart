
// language add-ons

// my glide utils
import 'package:my_glide/utils/debug.dart';

// my glide data providers
import 'package:my_glide/data/session.dart';
import 'package:my_glide/utils/my_glide_const.dart';

// my glide own widgets

class MyGlideData 
{
  static Future<bool> incidentPostMelding(String rapport, String naamlMelder, String emailMelder, bool annoniem) async {
    String function = "myGlide.incidentPostMelding";
    MyGlideDebug.info("$function($rapport, $emailMelder, $annoniem)");

    if (serverSession.login.userInfo == null) {      // we weten niet wie het is
      MyGlideDebug.trace("$function: return false");
      return false;
    }

    try {
      if (serverSession.isDemo)
      {
        MyGlideDebug.trace("$function: return true");
        return true;
      }

      String url = await serverSession.getLastUrl();
      String post = '$url/php/main.php?Action=MyGlide.incidentMelding';   
      await serverSession.post(post, {"RAPPORT": rapport,  "NAAM_MELDER": naamlMelder, "EMAIL_MELDER": emailMelder, "ANNONIEM": annoniem.toString(), "EMAIL_VM": MyGlideConst.emailVeiligheidsManager });
      
      MyGlideDebug.trace("$function: return true");
      return true;
    }
    catch (e)
    {
      MyGlideDebug.error("$function:" + e.toString());
      return false;
    }
  }  
}