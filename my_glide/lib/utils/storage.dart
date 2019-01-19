// language packages


// language add-ons
import 'package:encrypt/encrypt.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

// my glide utils

// my glide data providers

// my glide own widgets

class Storage 
{
  // nodig voor encryptie / decryptie
  static final String _key = 'v3ry_Secret-KeyF0r My_Glide @pp';    // Gebruikt om te versleutelen
  static final String _iv = '8bytesiv';                            // Gebruikt om te versleutelen
  static final encrypter = new Encrypter(new Salsa20(_key, _iv));

  static String _encrypt(var object) {
    if (object == null) return null;
    return encrypter.encrypt(object.toString());
  }

  static String _decrypt(String encrypted) {
    if (encrypted == null) return null;
    return encrypter.decrypt(encrypted);
  }

  // set functies
  static Future<bool> setBool(String key, bool value) async {
    SharedPreferences.getInstance().then((prefs) {
      return prefs.setString(key, _encrypt(value.toString()));
    });
    return null;
  }

  static Future<bool> setInt(String key, int value) async {
    SharedPreferences.getInstance().then((prefs) {
      return prefs.setString(key, _encrypt(value.toString()));
    });
    return null;    
  }

  static Future<bool> setString(String key, String value) async {
    SharedPreferences.getInstance().then((prefs) {
      return prefs.setString(key, _encrypt(value));
    });
    return null;    
  }

  static Future<bool> setDouble(String key, double value) async {
    SharedPreferences.getInstance().then((prefs) {
      return prefs.setString(key, _encrypt(value.toString()));
    });
    return null;
  }    

  // get fucties
  static Future<bool> getBool(String key, { bool defaultValue = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var availableKeys = prefs.getKeys();
    if (!availableKeys.contains(key)) return defaultValue;

    try {
      return _decrypt(prefs.getString(key)) == "true";
    }
    catch(e) { return defaultValue; }
  }

 static Future<int> getInt(String key, { int defaultValue = 0}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var availableKeys = prefs.getKeys();
    if (!availableKeys.contains(key)) return defaultValue;

    try {
      return int.parse(_decrypt(prefs.getString(key)));
    }
    catch(e) { return defaultValue; }          
  }

 static Future<String> getString(String key, { String defaultValue}) async  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var availableKeys = prefs.getKeys();
    if (!availableKeys.contains(key)) return defaultValue;

    return _decrypt(prefs.getString(key));  
  }

  static Future<double> getDouble(String key, { double defaultValue = 0.0}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var availableKeys = prefs.getKeys();
    if (!availableKeys.contains(key)) return defaultValue;

    try {
      return double.parse(_decrypt(prefs.getString(key)));
    }
    catch(e) { return defaultValue; }        
  }   

  // Verwijderen key
  static Future<bool> remove(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var availableKeys = prefs.getKeys();
    if (!availableKeys.contains(key)) return false;   

    return prefs.remove(key); 
  }

  // Alle keys weggooien
   static Future<bool> clear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); 

    return prefs.clear(); 
  } 
}
