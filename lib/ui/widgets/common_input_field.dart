import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CommonInputField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final int? maxLength;
  final bool isNumeric;

  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  final List<TextInputFormatter>? inputFormatters;

  const CommonInputField({
    super.key,
    required this.hintText,
    required this.controller,
    this.maxLength,
    this.isNumeric = false,
    this.onTap,
    this.onChanged,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onTap: onTap,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey, fontFamily: 'Poppins'),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        counterText: '', // hide counter if needed
      ),
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      inputFormatters: inputFormatters??
      (isNumeric
          ? [
        FilteringTextInputFormatter.digitsOnly,
        if (maxLength != null)
          LengthLimitingTextInputFormatter(maxLength),
      ]
          : []),
      maxLength: maxLength,

    );
  }
}
