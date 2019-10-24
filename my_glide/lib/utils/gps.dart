// language packages
import 'dart:math' as math;
import 'dart:async';

// language add-ons
import 'package:connectivity/connectivity.dart';
import 'package:geolocator/geolocator.dart';

// my glide utils
import 'package:my_glide/utils/my_glide_const.dart';
import 'package:my_glide/utils/storage.dart';
import 'package:my_glide/utils/debug.dart';

// my glide data providers
import 'package:my_glide/data/session.dart';
import 'package:my_glide/data/aanwezig.dart';

// my glide own widgets

// my glide pages

Gps gpsData = Gps();

class Point 
{
  double latitude;
  double longitude;
}

class Gps
{
  DateTime startTijd;
  DateTime landingsTijd;
  double _lastAltitude = 0;
  Position _currentLocation;
  Timer _positionTimer;                   // Timer om positie te verwerken

  void start()
  {
    MyGlideDebug.info("Gps.start()");
     _positionTimer = Timer.periodic(Duration(seconds: 30), (Timer t) {
      this.gpsLocatie();
    }); 
  }

  void stop()
  {
    MyGlideDebug.info("Gps.stop()");

    if (_positionTimer != null) {
      _positionTimer.cancel();
      _positionTimer = null;
    }
  }
  
  void gpsLocatie() async
  {
    MyGlideDebug.info("Gps.gpsLocatie()");

    // Voorkom dat start / landingstijd van vorige dag gebruikt kan worden
    if (startTijd != null)
    {
      if (startTijd.day != DateTime.now().day)
        startTijd = null;
    }

    if (landingsTijd != null)
    {
      if (landingsTijd.day != DateTime.now().day)
        landingsTijd = null;
    }

    _currentLocation = await Geolocator().getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);

    if (_currentLocation == null) {
      MyGlideDebug.error("Gps.gpsLocatie(), currentLocation == null");
      return;
    }

    try {
      if ((_currentLocation.speed > MyGlideConst.takeOffSpeed) && 
          (_currentLocation.altitude > MyGlideConst.noStallAltitude) && 
          (_lastAltitude < MyGlideConst.noStallAltitude)) {
        startTijd = DateTime.now();
        landingsTijd = null;
      }

      if ((_currentLocation.speed < MyGlideConst.takeOffSpeed) && 
          (_currentLocation.altitude < MyGlideConst.noStallAltitude) && 
          (landingsTijd == null) && (startTijd != null)) {
        landingsTijd = DateTime.now();
      }

      if (!serverSession.login.isAangemeld) {
        ConnectivityResult connected = await  Connectivity().checkConnectivity();
        bool autoAanmelden = await Storage.getBool('autoAanmelden', defaultValue: true);

        // Autmatisch aanmelden als gebruiker data verbinding heeft en de optie aan heeft staan
        // Maar natuurlijk alleen binnen het gedefineerde gebied en maar 1 keer
        if (autoAanmelden && connected !=ConnectivityResult.none) 
        {
          bool isInside = insideArea(serverSession.vliegveld); 

          if (isInside) {        // Aanmelden van het lid
            Storage.getString("aanmelden", defaultValue: "").then((lastCSV) // Vliegtuig types die gebruikt is bij laatste keer aanmelden
            {
              Aanwezig.aanmeldenLidVandaagTypes(lastCSV, "");
              serverSession.login.isAangemeld = true;
            });
          }
        }
      }
    }
    catch (e)
    {
      MyGlideDebug.error("Gps.gpsLocatie:" + e.toString());
    }

    _lastAltitude = _currentLocation.altitude;

    // Tussen zonsondergang en zonsopgang doen we niets. Hopelijk besparen we energie
    DateTime zonOpkomst = serverSession.zonOpkomst.subtract(Duration(minutes: 1));
    DateTime zonOndergang = serverSession.zonOndergang.add(Duration(minutes: 1));

    if ((DateTime.now().isAfter(zonOpkomst)) && (DateTime.now().isBefore(zonOndergang)))
    {
      return;
    }

    stop();
    Duration wachtOpZonsOpkomst;
    
    if (DateTime.now().isBefore(serverSession.zonOpkomst))
      wachtOpZonsOpkomst = serverSession.zonOpkomst.difference(DateTime.now());
    else
      wachtOpZonsOpkomst = serverSession.zonOpkomst.add(Duration(hours: 24)).difference(DateTime.now());

    Timer(wachtOpZonsOpkomst, start);
  }

  bool insideArea(List polygon)
  {
    String function = "Gps.insideArea";
    MyGlideDebug.info("$function(polygon)");

    if ((polygon == null) || (_currentLocation == null)) {
      MyGlideDebug.trace("$function: return false (=null)");
      return false;
    }

    if (polygon.length == 0) {
      MyGlideDebug.trace("$function: return false (polygon == 0)");
      return false;
    }
    
    double minLon = polygon[0].latitude;
    double maxLon = polygon[0].latitude;
    double minLat = polygon[0].longitude;
    double maxLat = polygon[0].longitude;

    for (Point q in polygon)
    {
        minLon = math.min(q.latitude, minLon);
        maxLon = math.max(q.latitude, maxLon);
        minLat = math.min(q.longitude, minLat);
        maxLat = math.max(q.longitude, maxLat);
    }

    if (_currentLocation.latitude < minLon || _currentLocation.latitude > maxLon || _currentLocation.longitude < minLat || _currentLocation.longitude > maxLat )
    {
        MyGlideDebug.trace("$function: return false (outside max)");
        return false;
    }

    bool inside = false;
    for ( int i = 0, j = polygon.length - 1 ; i < polygon.length ; j = i++ )
    {
        if ((polygon[i].longitude > _currentLocation.longitude) != (polygon[j].longitude > _currentLocation.longitude ) &&
             _currentLocation.latitude < ( polygon[j].latitude - polygon[i].latitude) * (_currentLocation.longitude - polygon[i].longitude) / (polygon[j].longitude - polygon[i].longitude ) + polygon[i].latitude)
        {
            inside = !inside;
        }
    }
    MyGlideDebug.trace("$function: return $inside");
    return inside;      
  }
}