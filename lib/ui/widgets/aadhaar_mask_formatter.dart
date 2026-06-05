import 'dart:developer';

import 'package:flutter/services.dart';

class AadhaarMaskFormatter extends TextInputFormatter {
  final bool isVid;
  final Function(String digits)? onRealValue;

  AadhaarMaskFormatter({
    required this.isVid,
    this.onRealValue,
  });

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    log("------------ INPUT FORMATTER START ------------");
    log("Old Value Text: ${oldValue.text}");
    log("New Value Text: ${newValue.text}");

    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    log("Only Digits Extracted: $digits");

    int max = isVid ? 16 : 12;
    log("isVid: $isVid");
    log("Max Allowed Length: $max");

    if (digits.length > max) {
      log("Input exceeded max length. Trimming...");
      digits = digits.substring(0, max);
    }

    log("Final Digits After Trim: $digits");

    /// ✅ Save real value here
    onRealValue?.call(digits);
    log("Real Value Saved: $digits");

    String masked = digits;

    if (!isVid && digits.length == 12) {
      masked = "XXXXXXXX${digits.substring(8)}";
      log("Aadhaar Fully Entered -> Masked Value: $masked");
    }

    if (isVid && digits.length == 16) {
      masked = "XXXXXXXXXXXX${digits.substring(12)}";
      log("VID Fully Entered -> Masked Value: $masked");
    }

    log("Final Display Value: $masked");
    log("------------ INPUT FORMATTER END ------------");

    return TextEditingValue(
      text: masked,
      selection: TextSelection.collapsed(offset: masked.length),
    );
  }
}