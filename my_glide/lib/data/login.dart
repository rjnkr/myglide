// language packages
import 'dart:async';
import 'dart:convert';

// language add-ons
import 'package:http/http.dart' as http;

// my glide utils
import 'package:my_glide/utils/storage.dart';
import 'package:my_glide/utils/debug.dart';

// my glide data providers
import 'package:my_glide/data/session.dart';

// my glide own widgets


class Login 
{
  String _lastUsername, _lastPassword;                      // variable met laatste gelukte inlog poging
  Timer _userInfoRefreshTimer;                              // Timer om regelmatig UserInfo te verversen
  DateTime _lastUserInfoOpgehaald;                          // Wanneer is de laatste keer de UserInfo opgehaald

  bool isAangemeld = false;                                 // Is de vlieger aangemeld voor vandaag

  bool magSchrijven =false;
  bool isLocal = false;
  bool isBeheerderDDWV = false;
  bool isBeheerder = false;
  bool isStartleider = false;                               // Vandaag startleider
  bool isInstructeur = false;                               // Vandaag instructeur
  bool isClubVlieger = false;
  bool isDDWV = false;
  
  Map userInfo;                                            // Info over ingelogde gebruiker

  Login ()
  {
    MyGlideDebug.info("Login()");

    // ophalen van laatst gebruikte credentials (vullen lastUsername, lastPassword, lastUrl)
    _getCredentials();
  }

  Future<bool> login(String username, String password, String url) async
  {
    String function = "Login.login";
    MyGlideDebug.info("$function($username, $password, $url)");

    serverSession.setCredentials(username, password);
    bool succeeded = await getUserInfo(url: url);

    if (succeeded) {
      serverSession.storeUrl(url);      // set url for all new session
      _storeCredentials(username, password);  // save credentials as well
    }
    else
    {
      serverSession.clearCredentials();       // het is mislukt dus alles schoonpoetsen
    }
    MyGlideDebug.trace("$function: return $succeeded");
    return succeeded;
  }

  // login with the last known credentials
  Future<bool> lastLogin() async
  {
    String function = "Login.lastLogin";
    MyGlideDebug.info("$function()");

    await _getCredentials();
    if ((_lastUsername == null) || (_lastPassword == null))
      return false;

    String url = await serverSession.getLastUrl();  
    bool succeeded = await login(_lastUsername, _lastPassword, url);
    MyGlideDebug.trace("$function: return $succeeded");
    return succeeded;
  }

  void logout()
  {
    MyGlideDebug.info("Login.logout()");

    // uitgelogd dus UserInfo niet meer verversen
    if (_userInfoRefreshTimer != null)  _userInfoRefreshTimer.cancel();       
                 
    _clearCredentials();
    serverSession = new Session();    // Gooi alles uit het geheugen weg
  }

  // Haal de info van de ingelogde gebruiker op. username is de gebruikte inlognaam
  Future<bool> getUserInfo({String url}) async {
    String function = "Login.getUserInfo";
    MyGlideDebug.info("$function($url)");

    try {
      Map parsed;

      if (serverSession.isDemo)
      {
        String demoJSON = await serverSession.getDemoData("assets/demo/Login/getUserInfoJSON.json");
        parsed = json.decode(demoJSON);
      }
      else 
      {
        if (url == null)  url = await serverSession.getLastUrl();
        
        String request = '$url/php/main.php?Action=Login.getUserInfoJSON';
        http.Response response = await serverSession.get(request);
        parsed = json.decode(response.body);
      }

      if (parsed['UserInfo'] == null) return false;       // Geen user info aanwezig
      if (parsed['UserInfo'].length == 0) return false;   // Geen user info aanwezig
      userInfo = (parsed['UserInfo'])[0]; 
      var userRights = (parsed['UserRights']);  

      magSchrijven    = userRights['magSchrijven'] == '1';
      isLocal         = userRights['isLocal'] == 'true';
      isBeheerderDDWV = userRights['isBeheerderDDWV'] == '1';
      isBeheerder     = userRights['isBeheerder'] == '1';
      isStartleider   = userRights['isStartleider'] == '1';
      isInstructeur   = userRights['isInstructeur'] == '1';                        
      isClubVlieger   = userRights['isClubVlieger'] == '1'; 
      isDDWV          = userRights['DDWV'] == '1'; 
      isAangemeld     = userRights['isAangemeld'] == '1'; 
      
      _lastUserInfoOpgehaald = DateTime.now();
      _setTimerForNextUserInfo();

      serverSession.ophalenZonOpkomstOndergang(url);

      MyGlideDebug.trace("$function: return true");
      return true;
    }
    catch (e)
    {
      MyGlideDebug.error("$function:" + e.toString());
    }
    return false;
  }

  // UserInfo bevat dynamische informatie, moet dus regelmatig geupdate worden
  void _setTimerForNextUserInfo() {
    MyGlideDebug.info("Login._setTimerForNextUserInfo()");

    if (_userInfoRefreshTimer != null)  _userInfoRefreshTimer.cancel();

    _userInfoRefreshTimer = Timer.periodic(Duration(hours: 1), (Timer t) {
      final now = DateTime.now();

      if (_lastUserInfoOpgehaald.day != now.day)
        getUserInfo();
      else if ((serverSession.zonOpkomst == null) || (serverSession.zonOndergang == null))
        getUserInfo();
      else {
        if (now.isAfter(serverSession.zonOpkomst) && now.isBefore(serverSession.zonOndergang))
          getUserInfo();
      }
    });
  }

  // Opslaan van de informatie zodat het de volgende keer gebruikt kan worden bij opstarten
  void _storeCredentials(String username, String password)
  {
    MyGlideDebug.info("Login._storeCredentials($username, $password)");

    Storage.setString ("username", username);
    Storage.setString ("password", password);

    _getCredentials();
  }

  Future<void> _getCredentials() async
  {
    MyGlideDebug.info("Login._getCredentials()");

    // de gegevens zijn opgeslagen op het device
    _lastUsername = await Storage.getString('username');
    _lastPassword = await Storage.getString('password'); 
  }

  // Maak gebruikersnaam ook beschikbaar voor andere classes
  String getLastUsername() {
    String function = "Login.getLastUsername";
    MyGlideDebug.info("$function()");
    MyGlideDebug.trace("$function: return $_lastUsername");

    return _lastUsername;
  }

    // Maak password ook beschikbaar voor andere classes
  String getLastPassword() {
    String function = "Login.getLastPassword";
    MyGlideDebug.info("$function()");
    MyGlideDebug.trace("$function: return $_lastPassword");

    return _lastPassword;
  }

  // delete information from device
  void _clearCredentials()
  {
    MyGlideDebug.info("Login._clearCredentials()");

    Storage.remove("username");
    Storage.remove("password");

    _lastUsername = null;
    _lastPassword = null;
  }

  // We are in demo mode
  Future<void> demo({bool ddwv = false, bool lid = false, bool startleider = false, bool instructeur = false}) async
  {
    MyGlideDebug.info("Login.demo($ddwv, $lid, $startleider, $instructeur)");

    serverSession.isDemo = true;
    await serverSession.storeUrl("demo");    
    await getUserInfo();

    magSchrijven    = (startleider || instructeur);
    isStartleider   = startleider;
    isInstructeur   = instructeur;                      
    isClubVlieger   = lid;
    isDDWV          = ddwv;
  }
}