
// language packages
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';

// language add-ons
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart'; 
import 'package:http/http.dart' as http;

// my glide utils

// my glide data providers

// my glide own widgets

// my glide pages

Session serverSession = Session();

class Session {
  // nodig voor encryptie / decryptie
  final String _key = 'v3ry_Secret-KeyF0r My_Glide @pp';
  final String _iv = '8bytesiv'; 

  Map<String, String> _headers = {};
  http.Client _client = http.Client();
  Timer _endClientSessionTimer;     // Wanneer _client sessie afgesloten moet worden
  DateTime _nextogin;               // Bijhouden wanneer we opnieuw moeten inloggen 
  
  // variable met laatste gelukte inlog poging
  String lastUsername, lastPassword, lastUrl;

  Session ()
  {
    // ophalen van laatst gebruikte credentials (vullen lastUsername, lastPassword, lastUrl)
    _getCredentials();
  }
  
  // inloggen op de server. Als het gelukt is wordt er een PHP_SESSION cookie opgeslagen
  // we slaan ook credentials op om later te hergebruiken
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
          updateCookie(response);

          _storeCredentials(username, password, url);  
          _setNextLogin();   
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

  // login with the last known credentials
  Future<String> lastLogin() async
  {
    var notused = await _getCredentials();
    return login(lastUsername, lastPassword, lastUrl);
  }

  // logout, clear headers and remove user info
  void logout()
  {
    _clearCredentials();
    _headers.clear();

  }  

  void _endSession() {
    _client.close(); 
    _client = http.Client();
  }
  
  http.Client getClient() {
    if (_nextogin.isBefore(DateTime.now()))
      lastLogin();

    _endClientSessionTimer = Timer(Duration(minutes: 2), _endSession);
    _setNextLogin();
    return _client;
  }

  // maak cookie ook buiten deze class beschikbaar
  Map<String, String> getHeaders() {
    return _headers;
  }

  // opslaan van cookies
  void updateCookie(http.Response response) {
    String rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      _headers['cookie'] =
          (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }

  // Zet de datetime dat we opnieuw moeten inloggen
  void _setNextLogin() {
    _nextogin = DateTime.now().add(Duration(minutes: 15));
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

  Future _getCredentials()
  {
    final encrypter = new Encrypter(new Salsa20(_key, _iv));

    // ophalen van device
    return SharedPreferences.getInstance().then((prefs)
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

  // delete information from device
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

}