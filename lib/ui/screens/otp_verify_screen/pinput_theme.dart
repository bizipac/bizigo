import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../../../core/constants/app_strings.dart';

final defaultPinTheme = PinTheme(
  width: 50,
  height: 50,
  textStyle: const TextStyle(
    fontSize: 20,
    color: Color.fromRGBO(30, 60, 87, 1),
    fontWeight: FontWeight.w600,
    fontFamily: AppStrings.poppins,
  ),
  decoration: BoxDecoration(
    border: Border.all(color: Color(0xff707070)),
    borderRadius: BorderRadius.circular(8),
  ),
);

final focusedPinTheme = defaultPinTheme.copyDecorationWith(
  border: Border.all(color: Color(0xff33348F)),
  borderRadius: BorderRadius.circular(8),
);

final errorPinTheme = defaultPinTheme.copyWith(
  textStyle: defaultPinTheme.textStyle!.copyWith(color: Color(0xffFF3A3A)),
);

final submittedPinTheme = defaultPinTheme.copyWith(
  decoration: defaultPinTheme.decoration!.copyWith(color: Colors.white),
);
