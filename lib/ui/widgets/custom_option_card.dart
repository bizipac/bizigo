import 'package:flutter/material.dart';

class CustomOptionCard extends StatelessWidget {
  final String title;
  final String imageAsset;
  final VoidCallback onTap;

  const CustomOptionCard({
    super.key,
    required this.title,
    required this.imageAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 🔹 Dynamic scaling factor (works across devices)
    double fontSize = screenWidth * 0.035; // ~14px on 400px width screen
    if (fontSize < 12) fontSize = 12; // minimum for readability
    if (fontSize > 18) fontSize = 18; // cap on very large screens

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenWidth * 0.4,
        // ~40% of screen width
        height: screenWidth * 0.4,
        // keep square shape
        padding: EdgeInsets.all(screenWidth * 0.03),
        // responsive padding
        margin: EdgeInsets.all(screenWidth * 0.02),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.5),
              blurRadius: 8,
              spreadRadius: 4,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ Responsive image
            Image.asset(
              imageAsset,
              height: screenWidth * 0.18, // scales with width
              width: screenWidth * 0.18,
              fit: BoxFit.contain,
            ),

            SizedBox(height: screenHeight * 0.012),

            // ✅ Responsive text
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
                color: const Color(0xFF33348F),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
