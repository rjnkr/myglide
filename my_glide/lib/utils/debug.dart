// language packages

// language add-ons

// my glide utils

// my glide data providers

// my glide own widgets

// my glide pages

enum MyGlideErrorLevel {
  trace,
  info,
  warning,
  error,
  fatal,
  off
}

class MyGlideDebug {
  static const MyGlideErrorLevel _errorLevel = MyGlideErrorLevel.off;
  static const bool _logLocalFunctions = true;
  static const String _include = "";

   static void trace(String msg) {

    if (_errorLevel.index >= MyGlideErrorLevel.info.index) {
      _logMe (_now() + "#Trace# $msg");
    }
  }

  static void info(String msg) {
    if (_errorLevel.index >= MyGlideErrorLevel.info.index) {
      _logMe (_now() + "#Info# $msg");
    }
  }

  static void warning (String msg) {
    if (_errorLevel.index >= MyGlideErrorLevel.warning.index) {
      _logMe (_now() + "#Warning# $msg");
    }
  }

  static void error(String msg) {
    if (_errorLevel.index >= MyGlideErrorLevel.error.index) {
      _logMe (_now() + "#Error# $msg");
    }
  }

  static void fatal (String msg) {
    if (_errorLevel.index >= MyGlideErrorLevel.error.index) {
      _logMe (_now() + "#Fatal# $msg");
    }
  }

  static String _now() {
    DateTime now = DateTime.now();
    return "${now.minute}:${now.second}.${now.millisecond}";
  }

  static void _logMe (String message) {
    if (_include != null)
    {
      if (!message.contains(_include))
        return;
    }

    if (_logLocalFunctions) {
      print (message);
    }
    else {
      if (!message.contains("._"))
        print (message);
    }
  }

}
