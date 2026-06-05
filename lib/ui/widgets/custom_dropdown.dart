import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final String hint;
  final bool isRequired;
  final List<String> items;
  final String? value;
  final ValueChanged<String?>? onChanged;
  final String? errorText;
  final String? Function(String?)? validator;

  const CustomDropdown({
    super.key,
    required this.label,
    this.hint = '',
    required this.items,
    this.value,
    this.onChanged,
    this.isRequired = false,
    this.errorText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        DropdownButtonFormField<String>(
          isExpanded: true,
          value: items.contains(value) ? value : null,
          // ✅ SAFE
          items: items
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e,
                  // child: Text(e),
                  child: Text(e, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onChanged,
          validator: validator,
          hint: Text(hint),
          decoration: InputDecoration(
            errorText: errorText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}
