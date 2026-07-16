import 'package:flutter/material.dart';

class Logger {
  static void log(String message) {
    debugPrint("[INK] $message\n+--------------------------------+");
  }
}
