import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomProductTextfield extends StatelessWidget {
  final String label;
  final bool isRequired;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  final int? maxLength;
  final bool digitsOnly;
  final String? errorText;

  const CustomProductTextfield({
    super.key,
    required this.label,
    this.isRequired = false,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.enabled = true,
    this.onChanged,
    this.maxLength,
    this.digitsOnly = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: label,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontFamily: 'Poppins',
              ),
              children: [
                if (isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red, fontFamily: 'Poppins'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            style: const TextStyle(fontFamily: 'Poppins'),
            keyboardType: keyboardType,
            enabled: enabled,
            onChanged: onChanged,

            maxLength: maxLength,
            inputFormatters: digitsOnly
                ? [
                    FilteringTextInputFormatter.digitsOnly,
                    if (maxLength != null)
                      LengthLimitingTextInputFormatter(maxLength),
                  ]
                : null,
            decoration: InputDecoration(
              errorText: errorText,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: errorText != null ? Colors.red : Colors.grey,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: errorText != null ? Colors.red : Colors.blue,
                  width: 1.5,
                ),
              ),
            ),
            // decoration: InputDecoration(
            //   errorText: errorText,
            //   suffixIcon: suffixIcon,
            //   contentPadding: const EdgeInsets.symmetric(
            //     horizontal: 12,
            //     vertical: 14,
            //   ),
            //   counterText: "", // hides default counter if you don't want it
            //   border: OutlineInputBorder(
            //     borderRadius: BorderRadius.circular(8),
            //     borderSide: BorderSide(color: Colors.grey),
            //   ),
            // ),
          ),
        ],
      ),
    );
  }
}
