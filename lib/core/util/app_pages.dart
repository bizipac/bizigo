import 'package:flutter/material.dart';
import 'package:icici_bank/ui/screens/aadhaar_verification_screen/aadhaar_verification_screen.dart';
import 'package:icici_bank/ui/screens/biometric_kyc_screen/biometric_kyc_screen.dart';
import 'package:icici_bank/ui/screens/forget_password_screen/forgot_password_screen.dart';
import 'package:icici_bank/ui/screens/forget_password_screen/new_password_screen.dart';
import 'package:icici_bank/ui/screens/forget_password_screen/user_id_screen.dart';
import '../../ui/screens/login_screen/login_screen.dart';
import '../../ui/screens/home_screen/home_screen.dart';
import '../../ui/screens/otp_verify_screen/otp_verify_screen.dart';
import '../../ui/screens/splash_screen/splash_screen.dart';
import 'app_routes.dart';

class AppPages {
  static Map<String, WidgetBuilder> routes = {
    AppRoutes.splash: (context) => const SplashScreen(),
    AppRoutes.login: (context) => const LoginScreen(),
    AppRoutes.otp: (context) => const OtpVerifyScreen(),
    AppRoutes.userId: (context) => const UserIdScreen(),
    AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
    AppRoutes.newPassword: (context) => const NewPasswordScreen(),
    AppRoutes.home: (context) => const HomeScreen(),
    // AppRoutes.aadhaarKycVerify: (context) => const AadhaarVerificationScreen(),
    AppRoutes.aadhaarKycVerify: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map;
      return AadhaarVerificationScreen(
        kycType: args['kycType'],
        leadId: args['leadId'],
      );
    },
    AppRoutes.biometricKycVerify: (context) => const BiometricKYCScreen(),
  };
}
