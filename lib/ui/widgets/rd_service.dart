// import 'dart:developer';
//
// import 'package:flutter/services.dart';
//
// class RdService {
//   static const MethodChannel _channel = MethodChannel('rd_service_channel');
//
//   static Future<Map<String, dynamic>?> openRdService(
//       String action,
//       String extras,
//       ) async {
//     try {
//       final result = await _channel.invokeMethod('openRdService', {
//         'action': action,
//         'extras': extras,
//       }).timeout(const Duration(seconds: 30));
//       return result != null ? Map<String, dynamic>.from(result) : null;
//     } on PlatformException catch (e) {
//       log("Error: ${e.message}");
//       return null;
//     }
//   }
// }

import 'dart:async';
import 'dart:developer';
import 'package:flutter/services.dart';

class RdService {
  static const MethodChannel _channel = MethodChannel('rd_service_channel');

  static Future<Map<String, dynamic>> openRdService(
    String action,
    String extras,
  ) async {
    try {
      log("Calling RD Service...");
      log("Action: $action");

      final result = await _channel
          .invokeMethod('openRdService', {'action': action, 'extras': extras})
          .timeout(const Duration(seconds: 50));

      if (result == null) {
        throw Exception("RD Service returned null response");
      }
      log("RD Service response received");

      return Map<String, dynamic>.from(result);
    } on TimeoutException {
      log("RD Service timeout after 30 seconds");
      throw Exception("Fingerprint capture timeout. Please try again.");
    } on PlatformException catch (e) {
      log("PlatformException: ${e.message}");
      throw Exception(e.message ?? "RD Service platform error");
    } catch (e) {
      log("Unexpected RD Service error: $e");
      throw Exception("Unexpected RD Service error");
    }
  }
}
