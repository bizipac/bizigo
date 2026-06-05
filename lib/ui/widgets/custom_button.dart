import 'package:flutter/material.dart';

class CustomCurvedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double? fontSize;

  const CustomCurvedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF33348F),
    this.textColor = Colors.white,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CurvedButtonClipper(),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 65,
          width: double.infinity,
          color: backgroundColor,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              fontSize: fontSize,
            ),
          ),
        ),
      ),
    );
  }
}

class CurvedButtonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    // Left rounded edge
    path.moveTo(size.width * 0.0, size.height * 0.5);
    // Top curve
    path.quadraticBezierTo(size.width * 0.0, 0, size.width * 0.15, 0);
    // Right sharp taper
    path.lineTo(size.width * 0.85, size.height * 0.40);
    path.quadraticBezierTo(
      size.width,
      size.height * 0.5,
      size.width * 0.85,
      size.height * 0.65,
    );
    path.lineTo(size.width * 0.15, size.height);
    path.quadraticBezierTo(
      size.width * 0.0,
      size.height,
      size.width * 0.0,
      size.height * 0.5,
    );
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
