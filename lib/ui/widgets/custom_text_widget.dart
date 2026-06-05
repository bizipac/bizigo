import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String label;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final TextOverflow overflow;
  final int? maxLines;
  final TextDecoration? decoration;
  final bool isRequired;

  const CustomText({
    super.key,
    required this.label,
    this.fontSize = 12,
    this.color = Colors.black,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.start,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.decoration,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: TextStyle(
              fontSize: fontSize,
              color: color,
              fontWeight: fontWeight,
              decoration: decoration,
              fontFamily: 'Poppins',
            ),
          ),
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
        ],
      ),
    );
  }
}
