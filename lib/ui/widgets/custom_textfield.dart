import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;

  // NEW customizable params
  final double fontSize;
  final Color textColor;
  final Color hintColor;
  final Color borderColor;
  final Color cursorColor;

  const CustomTextField({super.key,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    required this.onChanged,
    this.suffixIcon,
    this.fontSize = 16,
    this.textColor = Colors.black,
    this.hintColor = Colors.grey,
    this.borderColor = Colors.grey,
    this.cursorColor = Colors.indigo,
    this.controller,
    this.validator, required this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      cursorColor: cursorColor,
      validator: validator,
      textInputAction: textInputAction,
      style: TextStyle(
        fontSize: fontSize,
        color: textColor,
        fontFamily: AppStrings.poppins,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: fontSize - 2,
          color: hintColor,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cursorColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
