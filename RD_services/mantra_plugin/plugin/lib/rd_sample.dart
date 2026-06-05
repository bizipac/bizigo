import 'dart:async';
import 'dart:collection';
import 'package:flutter/services.dart';
import 'dart:core';

class RdSample {
  static const MethodChannel _channel = const MethodChannel('rd_sample');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<HashMap<String, String>> get fingerDeviceInfo async {
    try {
      final result = await _channel.invokeMethod('finger_device_info');
      final Finger_DEVICE_INFO = result['DEVICE_INFO'] as String;
      final Finger_RD_SERVICE_INFO = result['RD_SERVICE_INFO'] as String;

      // Initialize a HashMap explicitly
      HashMap<String, String> fingerHashMap = HashMap();
      fingerHashMap['DEVICE_INFO'] = Finger_DEVICE_INFO;
      fingerHashMap['RD_SERVICE_INFO'] = Finger_RD_SERVICE_INFO;

      return fingerHashMap; // Returning HashMap<String, String>
    } catch (Exp) {
      print("fingerDeviceInfo Exception: $Exp");
      // Return an empty HashMap in case of an error to maintain type consistency
      return HashMap();
    }
  }

  static Future<HashMap<String, String>> get irisDeviceInfo async {
    try {
      final result = await _channel.invokeMethod('iris_device_info');
      final IrisDEVICEINFO = result['DEVICE_INFO'] as String;
      final IrisRDSERVICEINFO = result['RD_SERVICE_INFO'] as String;

      // Use HashMap explicitly
      HashMap<String, String> IrisHashMap = HashMap();
      IrisHashMap['DEVICE_INFO'] = IrisDEVICEINFO;
      IrisHashMap['RD_SERVICE_INFO'] = IrisRDSERVICEINFO;

      return IrisHashMap; // Return HashMap explicitly
    } catch (Exp) {
      print("Exception: $Exp");
      // Return an empty HashMap in case of an error
      return HashMap();
    }
  }

  static Future<String> captureData(String text) async {
    try {
      final result = await _channel.invokeMethod('capture', {"text": text});
      return result as String; // Ensure the result is treated as String
    } catch (Exp) {
      print("Exception: $Exp");
      return "Error occurred"; // Provide a non-null fallback value
    }
  }

  static Future<String> iriscaptureData(text) async {
    try {
      final result = await _channel.invokeMethod('iriscapture', {"text": text});
      return result as String;
    } catch (Exp) {
      print("Exception: $Exp");
      return "Error occurred";
    }
  }

}
