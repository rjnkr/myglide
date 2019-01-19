
// language packages
import 'dart:convert';
import 'dart:async';

// language add-ons
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;

// my glide utils
import 'package:my_glide/utils/storage.dart';

// my glide data providers
import 'package:my_glide/data/login.dart';
import 'package:my_glide/data/zonoponder.dart';

// my glide own widgets

// my glide pages

Session serverSession = Session();

class Session {
  Login login = Login();
  bool isIngelogd = false;                                  // Zijn we nog steeds ingelogd

  // private
  Map<String, String> _headers = {};                        // opslaan van header data
  http.Client _client = http.Client();                      // verbinding naar web server
  Timer _endClientSessionTimer;                             // Wanneer _client sessie afgesloten moet worden
  DateTime zonOpkomst;                                      // Hoe laat komt de zon op
  DateTime zonOndergang;                                    // Hoe laat gaat de zon onder
  DateTime _lastZonOpOnder = DateTime.now().subtract(Duration(days: 5));      // wanneer hebben de laaste keer zon opkomst ondergang gelden, default 5 dagen geleden (is lang genoeg)
  
  // Hiermee gaan we inloggen
  void setCredentials(String username, String password)
  {
    String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
    _headers['authorization'] = basicAuth;
  }

  // Gooi alle header informatie weg. We kunnen nu geen web services meer aanroepen omdat
  // zowel de sessie als de credentials hebben verwijderd
  void clearCredentials()
  {
    _headers.clear();
    isIngelogd = false;
  }

  Future<http.Response> get(dynamic url) async
  {
    ConnectivityResult connected = await Connectivity().checkConnectivity();
    if (connected == ConnectivityResult.none)
      throw Exception("Geen data verbinding");

    http.Response response;
    try {
      response = await _client.get(url, headers: _headers); 
    }
    catch (exception) {
      throw Exception("Url incorrect");
    }
    if (response.statusCode == 200)       // 200 = succesful
    {
      isIngelogd = true;
      _updateCookie(response);

      if (_endClientSessionTimer != null)
        _endClientSessionTimer.cancel();   // stop de huidige timer, de sessie wordt verlengd

      _endClientSessionTimer = Timer(Duration(minutes: 2), _endSession);      
    }
    else
    {
      _handleErrorHTTP(response);
    }
    return response;
  }

  Future<http.Response> post(dynamic url, dynamic body) async
  {
    ConnectivityResult connected = await Connectivity().checkConnectivity();
    if (connected == ConnectivityResult.none)
      throw Exception("Geen data verbinding");

    http.Response response;
    try {
      response = await _client.post(url, body: body, headers: _headers);
    }
    catch (exception) {
      throw Exception("Url incorrect");
    }
    if (response.statusCode == 200)       // 200 = succesful
    {
      isIngelogd = true;
      _updateCookie(response);

      if (_endClientSessionTimer != null)
        _endClientSessionTimer .cancel();   // stop de huidige timer, de sessie wordt verlengd

      _endClientSessionTimer = Timer(Duration(minutes: 2), _endSession);
    }
    else
    {
      _handleErrorHTTP(response);
    }
    return response;
  }

  void _handleErrorHTTP(http.Response response)
  {
      isIngelogd = false;

      String exceptionString = response.statusCode.toString() + ": ";

      switch (response.statusCode) {
        case 401: exceptionString += "Gebruiker / wachtwoord onjuist"; break;
        case 404: exceptionString += "Onjuiste url"; break;
        default: exceptionString += response.reasonPhrase; break;
      }
      throw Exception(exceptionString);  
  }

  // De verbinding naar de server wordt verbroken. Zet meteen de volgende sessie klaar
  void _endSession() {
    _client.close(); 
    _client = http.Client();
  }
  
  // opslaan van cookies
  void _updateCookie(http.Response response) {
    String rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      _headers['cookie'] =
          (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }

   // Opslaan van de url zodat het de volgende keer gebruikt kan worden bij opstarten
  void storeUrl(String url)
  {
    Storage.setString("url", url);

    getLastUrl();
  }

  Future<String> getLastUrl() async
  {
    // de gegevens zijn opgeslagen op het device
    return await Storage.getString('url');
  }

  Future<void> ophalenZonOpkomstOndergang() async
  {
    if (DateTime.now().isAfter(_lastZonOpOnder.add(Duration(hours: 24))))
    {
      _lastZonOpOnder = DateTime.now();
      
      ZonOpkomstOndergang.zonOpkomst().then((opkomst) => zonOpkomst = opkomst); 
      ZonOpkomstOndergang.zonOndergang().then((ondergang) => zonOndergang = ondergang); 
    }
  }
}