
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert';


class Session {
  Map<String, String> _headers = {};
  var _client = new http.Client();

  Session ()
  {
    _getCredentials();
  }
  final _key = 'v3ry_Secret-KeyF0r My_Glide @pp';
  final _iv = '8bytesiv'; 

  String lastUsername;
  String lastPassword;
  String lastUrl;


  Future<String> login (String username, String password, String url) async {
    String request = '$url/php/main.php?Action=Login.heeftToegang';
    String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));

    try {
      http.Response response = await _client.get(
        Uri.encodeFull(request),
        headers: {'authorization': basicAuth}
      );

      switch (response.statusCode) {
        case 200: {
          _storeCredentials(username, password, url);     
          _updateCookie(response);
          return null;
        }
        case 401: return "Gebruiker / wachtwoord onjuist";
        case 404: return "Onjuiste url (404)";
        default: return response.reasonPhrase;
      }
    }
    catch (e) {
      return "Url is onjuist";
    }
  }

  // login with the last know credentials
  Future<String> lastLogin()
  {
    return login(lastUsername, lastPassword, lastUrl);
  }

  // logout, clear headers and remove user info
  void logout()
  {
    _clearCredentials();
    _headers.clear();

  }  

  // Store information, so it can be used when application is restarted
  void _storeCredentials(String username, String password, String url)
  {
    final encrypter = new Encrypter(new Salsa20(_key, _iv));
    final encryptedPassword = encrypter.encrypt(password);

    // opslaan op device
    SharedPreferences.getInstance().then((prefs)
    {
      prefs.setString("username", username);
      prefs.setString("password", encryptedPassword);
      prefs.setString("url", url);

      _getCredentials();
    });
  }

  void _getCredentials()
  {
    final encrypter = new Encrypter(new Salsa20(_key, _iv));

    // ophalen van device
    SharedPreferences.getInstance().then((prefs)
    {
      lastUsername = prefs.getString('username') ?? null;
      final encryptedPassword = prefs.getString('password') ?? null;
      lastUrl = prefs.getString('url') ?? null;

      if (encryptedPassword != null)
        lastPassword = encrypter.decrypt(encryptedPassword);
      else
        lastPassword = null;
    });
  }

  void _clearCredentials()
  {
    SharedPreferences.getInstance().then((prefs)
    {  
      prefs.remove("username");
      prefs.remove("password");
      prefs.remove("url");

      lastUsername = null;
      lastPassword = null;
      lastUrl = null;
    });
  }

  void _updateCookie(http.Response response) {
    String rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      _headers['cookie'] =
          (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }
}