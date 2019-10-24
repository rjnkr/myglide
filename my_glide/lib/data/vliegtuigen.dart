// language packages
import 'dart:async';
import 'dart:convert';

// language add-ons
import 'package:http/http.dart' as http;

// my glide utils
import "package:my_glide/utils/storage.dart";

// my glide data providers
import 'package:my_glide/data/session.dart';
import 'package:my_glide/utils/debug.dart';

// my glide own widgets

class Vliegtuigen {
  
  // Ophalen van vliegtuigen
  static Future<List> getVliegtuigen(
  { bool alleenClubKisten = true,
    bool alleenFavorieten = false,
    bool alleKisten = false
  }) async {
    String function = "Vliegtuigen.getVliegtuigen";
    MyGlideDebug.info("$function()");

    try {
      List parsed;

      if (serverSession.isDemo) 
      {
        String demoJSON = await serverSession.getDemoData("assets/demo/Vliegtuigen/GetVliegtuigenJSON.json");
        Map p = json.decode(demoJSON);
        parsed = p["results"];

        // We moetn ook in demo mode kunnen filteren. Dus iets meer werk dan alleen de demo json data inlezen
        if (alleKisten)
          return parsed;

        List parsedFiltered = List();
        String favorietenJSON =  await Storage.getString('favorieteKisten', defaultValue: "[]");
        List favorieten = json.decode(favorietenJSON);

        for (int i=0 ; i < parsed.length ; i++)
        {
          // copie clubvliegtuigen naar parsedFilter
          if ((alleenClubKisten) && (parsed[i]['CLUBKIST'] == "true")) 
            parsedFiltered.add(parsed[i]);
          
          // copie favorieten naar parsedFilter
          if (alleenFavorieten)
          {
            if (favorieten.contains(parsed[i]["ID"]))
              parsedFiltered.add(parsed[i]);
          }
        }
        // En dan nu de nieuwe lijst teruggeven
        return parsedFiltered;
      }
      else
      {
        String url = await serverSession.getLastUrl();

        if (url == null)    // URL is nog niet bekend
          return List();  

        String request = '$url/php/main.php?Action=Vliegtuigen.GetObjectsCompleteJSON';

        if (alleenClubKisten) {
          request += "&_:clubkist=true&sort=CLUBKIST DESC, IFNULL(VOLGORDE, 0)&dir=asc";
        }

        if (alleKisten)  
        {
          String userID = serverSession.login.userInfo['ID'];
          String order = """CLUBKIST DESC, IFNULL(VOLGORDE, 0), 
	          (SELECT count(*) 
		          FROM 
			          oper_startlijst 
              WHERE 
			          VLIEGTUIG_ID = vliegtuigenlijst_view.ID AND 
                VLIEGER_ID = $userID AND 
                (STR_TO_DATE(DATUM, '%%Y-%%m-%%d') > DATE_SUB(NOW(), INTERVAL 6 MONTH))) DESC, REGISTRATIE""";

          request += "&sort=$order&dir=ASC";
        }

        if (alleenFavorieten)  
        {
          String favorietenJSON =  await Storage.getString('favorieteKisten');

          if ((favorietenJSON == null) || (favorietenJSON.length < 3))    // Er zijn geen favorieten
          {
            if ((!alleenClubKisten) && (!alleKisten))                     // En ook geen andere opties gekozen
              return List();       // dan maar een leeg opbject teruggeven
          }
          else
          {
            favorietenJSON = favorietenJSON.substring(1, favorietenJSON.length-1);
            request += "&_:in=$favorietenJSON";
          }
        }

        http.Response response = await serverSession.get(request);
        Map p = json.decode(response.body);
        parsed = p["results"];
      }
      MyGlideDebug.trace("$function: return " + parsed.toString());
      return parsed;
    }
    catch (e)
    {
      MyGlideDebug.error("$function:" + e.toString());
    }
    MyGlideDebug.trace("$function: return List()");
    return List();      // exception geeft leeg object terug
  }  
}