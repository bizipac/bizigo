import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:icici_bank/core/network/network_api.dart';
import 'package:icici_bank/providers/aadhaar_verification_provider/aadhaar_kyc_provider.dart';
import 'package:icici_bank/providers/biometric_kyc_provider/biometric_kyc_provider.dart';
import 'package:icici_bank/providers/biometric_kyc_provider/dialog_box_provider.dart';
import 'package:icici_bank/providers/corporate_provider/corporate_details_provider.dart';
import 'package:icici_bank/providers/home_preference_provider/preference_provider.dart';
import 'package:icici_bank/providers/login_provider/login_provider.dart';
import 'package:icici_bank/providers/otp_verify_provider/otp_verify_provider.dart';
import 'package:icici_bank/providers/pan_card_provider/pan_card_details_provider.dart';
import 'package:icici_bank/providers/personal_provider/personal_kyc_provider.dart';
import 'package:icici_bank/providers/product_provider/product_provider.dart';
import 'package:provider/provider.dart';

import 'core/util/app_pages.dart';
import 'core/util/app_preference.dart';
import 'core/util/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppPreference.init();
  log('Welcome to the World of Biometric KYC System of ICICI Bank\nCurrent Base URL is: ${NetworkApi.baseUrl}');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => OtpVerifyProvider()),
        ChangeNotifierProvider(create: (_) => PreferenceProvider()),
        ChangeNotifierProvider(create: (_) => AadhaarKycProvider()),
        ChangeNotifierProvider(create: (_) => DialogBoxProvider()),
        ChangeNotifierProvider(create: (_) => BiometricKycProvider()),
        ChangeNotifierProvider(create: (_) => CorporateDetailsProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => PersonalKycProvider()),
        ChangeNotifierProvider(create: (_) => PanCardDetailsProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.indigo),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      routes: AppPages.routes,
    );
  }
}
