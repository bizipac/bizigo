import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

class WadhHelper {
  static String generateWadh() {
    // Step 1: timestamp
    final now = DateTime.now();
    final formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
    final ts = formatter.format(now);

    // Step 2: raw WADH string
    final rawWadh = "$ts" "2.5" "$ts" "FYNNN";

    // Step 3: SHA256
    final bytes = utf8.encode(rawWadh);
    final digest = sha256.convert(bytes);

    // Step 4: Base64 encode
    final wadh = base64Encode(digest.bytes);

    return wadh.replaceAll('\n', '');
  }
}