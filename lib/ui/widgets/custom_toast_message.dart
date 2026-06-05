import 'package:flutter/material.dart';
import 'package:icici_bank/core/constants/app_strings.dart';

class CustomToast {
  static void show(
      BuildContext context,
      String message, {
        Color backgroundColor = Colors.black87,
        Color textColor = Colors.white,
        Duration duration = const Duration(seconds: 2),
      }) {
    final overlay = Overlay.of(context);

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 80,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontFamily: AppStrings.poppins,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Remove toast after duration
    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }

  static void success(BuildContext context, String message) {
    show(
      context,
      message,
      backgroundColor: Colors.green.shade600,
    );
  }

  static void error(BuildContext context, String message) {
    show(
      context,
      message,
      backgroundColor: Colors.red.shade600,
    );
  }

  static void support(BuildContext context) {
    show(
      context,
      "Please contact the support admin for assistance.",
      backgroundColor: Colors.green.shade600,
    );
  }

}
