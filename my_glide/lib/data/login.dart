// language packages
import 'dart:async';
import 'dart:convert';

// language add-ons
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart'; 

// my glide utils

// my glide data providers
import 'package:my_glide/data/session.dart';

// my glide own widgets


class Login 
{
  // nodig voor encryptie / decryptie
  final String _key = 'v3ry_Secret-KeyF0r My_Glide @pp';    // Gebruikt om wachtwoord te versleutelen
  final String _iv = '8bytesiv';                            // Gebruikt om wachtwoord te versleutelen

  String _lastUsername, _lastPassword;                        // variable met laatste gelukte inlog poging
  bool isAangemeld = false;                                 // Is de vlieger aangemeld voor vandaag

  bool magSchrijven =false;
  bool isLocal = false;
  bool isBeheerderDDWV = false;
  bool isBeheerder = false;
  bool isStartleider = false;                               // Vandaag startleider
  bool isInstructeur = false;                               // Vandaag instructeur
  bool isClubVlieger = false;
  
  Map userInfo;                                            // Info over ingelogde gebruiker

  Login ()
  {
    // ophalen van laatst gebruikte credentials (vullen lastUsername, lastPassword, lastUrl)
    _getCredentials();

  }

  Future<bool> login(String username, String password, String url) async
  {
      serverSession.setCredentials(username, password);
      bool succeeded = await getUserInfo(url: url);

      if (succeeded) {
        serverSession.storeUrl(url);            // set url for all new session
        _storeCredentials(username, password);  // save credentials as well
      }
      else
      {
        serverSession.clearCredentials();       // het is mislukt dus alles schoonpoetsen
      }
      return succeeded;
  }

  // login with the last known credentials
  Future<bool> lastLogin() async
  {
    var notused = await _getCredentials();
    if ((_lastUsername == null) || (_lastPassword == null))
      return false;

    return login(_lastUsername, _lastPassword, serverSession.lastUrl);
  }

  void logout()
  {
    serverSession.clearCredentials();
    _clearCredentials();
  }

  // Haal de info van de ingelogde gebruiker op. username is de gebruikte inlognaam
  Future<bool> getUserInfo({String url}) async {
    try {
      if (url == null)  url = serverSession.lastUrl;
      String request = '$url/php/main.php?Action=Login.getUserInfoJSON';

      http.Response response = await serverSession.get(request);
      final Map parsed = json.decode(response.body);
      userInfo = (parsed['UserInfo'])[0]; 
      var userRights = (parsed['UserRights']);  

      magSchrijven    = userRights['magSchrijven'] == '1';
      isLocal         = userRights['isLocal'] == 'true';
      isBeheerderDDWV = userRights['isBeheerderDDWV'] == '1';
      isBeheerder     = userRights['isBeheerder'] == '1';
      isStartleider   = userRights['isStartleider'] == '1';
      isInstructeur   = userRights['isInstructeur'] == '1';                        
      isClubVlieger   = userRights['isClubVlieger'] == '1'; 
      isAangemeld     = userRights['isAangemeld'] == '1'; 
      
      return true;
    }
    catch (e)
    {
      print (e);
    }
    return false;
  }

  // Opslaan van de informatie zodat het de volgende keer gebruikt kan worden bij opstarten
  void _storeCredentials(String username, String password)
  {
    final encrypter = new Encrypter(new Salsa20(_key, _iv));
    final encryptedPassword = encrypter.encrypt(password);

    // opslaan op device
    SharedPreferences.getInstance().then((prefs)
    {
      prefs.setString("username", username);
      prefs.setString("password", encryptedPassword);

      _getCredentials();
    });
  }

  Future _getCredentials()
  {
    final encrypter = new Encrypter(new Salsa20(_key, _iv));

    // de gegevens zijn opgeslagen op het device
    return SharedPreferences.getInstance().then((prefs)
    {
      _lastUsername = prefs.getString('username') ?? null;
      final encryptedPassword = prefs.getString('password') ?? null;

      if (encryptedPassword != null)
        _lastPassword = encrypter.decrypt(encryptedPassword);
      else
        _lastPassword = null;
    });
  }

  // Maak gebruikersnaam ook beschikbaar voor andere classes
  String getLastUsername() {
    return _lastUsername;
  }

    // Maak password ook beschikbaar voor andere classes
  String getLastPassword() {
    return _lastPassword;
  }

  // delete information from device
  void _clearCredentials()
  {
    SharedPreferences.getInstance().then((prefs)
    {  
      prefs.remove("username");
      prefs.remove("password");

      _lastUsername = null;
      _lastPassword = null;
    });
  }

}