// language packages
import 'package:flutter/material.dart';

// language add-ons

// my glide utils

// my glide data providers

// my glide own widgets

// my glide pages

class MyNavigator {
  static void goMijnLogboek(BuildContext context) {
    Navigator.popAndPushNamed(context, "/mijnlogboek");
  }

  static void goToLogin(BuildContext context) {
    Navigator.popAndPushNamed(context, "/login");
  }
  
  static void goToSettings(BuildContext context) {
    Navigator.popAndPushNamed(context, "/settings");
  }

  static void goToVliegtuigen(BuildContext context) {
    Navigator.popAndPushNamed(context, "/vliegtuigen");
  } 
}