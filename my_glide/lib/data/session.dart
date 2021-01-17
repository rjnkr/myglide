
// language packages
import 'dart:convert';
import 'dart:async';

// language add-ons
import 'package:flutter/services.dart' show rootBundle;
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;

// my glide utils
import 'package:my_glide/utils/storage.dart';
import 'package:my_glide/utils/debug.dart';

// my glide data providers
import 'package:my_glide/data/login.dart';
import 'package:my_glide/data/zonoponder.dart';

// my glide own widgets

// my glide pages

Session serverSession = Session();

class Session {
  Login login = Login();
  bool isIngelogd = false;                                  // Zijn we nog steeds ingelogd
  bool isDemo = false;

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
    MyGlideDebug.info("Session.setCredentials($username, $password)");

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

  // Ophalen data
  Future<http.Response> get(dynamic url) async
  {
    String function = "Session.get";
    MyGlideDebug.info("$function($url)");

    ConnectivityResult connected = await Connectivity().checkConnectivity();
    if (connected == ConnectivityResult.none)
      throw Exception("Geen data verbinding");

    if (url == null)
      throw Exception("Url onbekend");

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
    MyGlideDebug.trace("$function: return response");
    return response;
  }

  // Het versturen van data naar de server
  Future<http.Response> post(dynamic url, dynamic body) async
  {
    String function = "Session.post";
    MyGlideDebug.info("$function($url)");

    ConnectivityResult connected = await Connectivity().checkConnectivity();
    if (connected == ConnectivityResult.none)
      throw Exception("Geen data verbinding");

    if (url == null)
      throw Exception("Url onbekend");
      
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
    MyGlideDebug.trace("$function: return response");
    return response;
  }

  // Afhandelen als een http error hebben
  void _handleErrorHTTP(http.Response response)
  {
    String function = "Session._handleErrorHTTP";
    MyGlideDebug.info("$function()");

    isIngelogd = false;

    String exceptionString = response.request.url.toString() + "\n";
    exceptionString += response.statusCode.toString() + ": ";

    switch (response.statusCode) {
      case 401: exceptionString += "Gebruiker / wachtwoord onjuist"; break;
      case 404: exceptionString += "Onjuiste url"; break;
      default: exceptionString += response.reasonPhrase; break;
    }
    MyGlideDebug.error("$function = $exceptionString");
    throw Exception(exceptionString);  
  }

  // De verbinding naar de server wordt verbroken. Zet meteen de volgende sessie klaar
  void _endSession() {
    MyGlideDebug.info("Session._endSession()");

    _client.close(); 
    _client = http.Client();
  }
  
  // opslaan van cookies
  void _updateCookie(http.Response response) {
    MyGlideDebug.info("Session._updateCookie()");

    String rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      _headers['cookie'] =
          (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }

   // Opslaan van de url zodat het de volgende keer gebruikt kan worden bij opstarten
  Future<void> storeUrl(String url) async
  {
    MyGlideDebug.info("Session.storeUrl($url)");

    await Storage.setString("url", url);
    getLastUrl();
  }

  // Wat is de url waarop we aan het werk zijn, wordt gezet bij inloggen
  Future<String> getLastUrl() async
  {
    String function = "Session.getLastUrl";
    MyGlideDebug.info("$function()");

    // de gegevens zijn opgeslagen op het device
    String lastUrl = await Storage.getString('url');
    
    // indien url "demo" is zitten we in demo mode, anders niet
    // in demo mode halen we json data op uit strings ipv webservice
    isDemo = (lastUrl == "demo");     
    MyGlideDebug.trace("$function: return $lastUrl");    
    return lastUrl;
  }

  // Ophalen van zon opkomst/ondergang. Wordt opgelagen in sessie
  // We halen bijvoorbeeld geen data op tijdens de nacht
  Future<void> ophalenZonOpkomstOndergang(String url) async
  {
    MyGlideDebug.info("Session.ophalenZonOpkomstOndergang($url)");

    if (DateTime.now().isAfter(_lastZonOpOnder.add(Duration(hours: 24))))
    {
      _lastZonOpOnder = DateTime.now();
      
      ZonOpkomstOndergang.zonOpkomst(url).then((opkomst) => zonOpkomst = opkomst); 
      ZonOpkomstOndergang.zonOndergang(url).then((ondergang) => zonOndergang = ondergang); 
    }
  }

  Future<String> getDemoData(String file) async {
    String function = "Session.getDemoData";
    MyGlideDebug.info("$function($file)");

    String retVal = await rootBundle.loadString(file);
    MyGlideDebug.trace("$function: return $retVal");
    return retVal;
  }
}