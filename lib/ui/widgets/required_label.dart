import 'package:flutter/material.dart';

class RequiredLabel extends StatelessWidget {
  final String text;
  final bool isRequired;

  const RequiredLabel(this.text, {this.isRequired = true, super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontFamily: 'Poppins',
        ),
        children: isRequired?
        const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ]:[],
      ),
    );
  }
}
