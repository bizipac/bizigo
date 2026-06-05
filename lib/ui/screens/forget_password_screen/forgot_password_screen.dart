import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icici_bank/core/constants/app_assets.dart';
import 'package:icici_bank/core/constants/app_strings.dart';
import 'package:icici_bank/core/util/app_preference.dart';
import 'package:icici_bank/core/util/app_routes.dart';
import 'package:icici_bank/ui/screens/otp_verify_screen/pinput_theme.dart';
import 'package:icici_bank/ui/widgets/custom_toast_message.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../../../core/models/login_model.dart';
import '../../../providers/login_provider/login_provider.dart';
import '../../../providers/otp_verify_provider/otp_verify_provider.dart';
import '../../widgets/custom_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}


class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController otpController = TextEditingController();
  late OtpVerifyProvider otpProvider;

  @override
  void initState() {
    super.initState();
    otpProvider = context.read<OtpVerifyProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      otpProvider.startTimer();
    });
  }

  @override
  void dispose() {
    otpController.dispose();
    otpProvider.disposeTimer();
    super.dispose();
  }

  Future<void> _newPasswordRequest(BuildContext context) async {
    final provider = context.read<LoginProvider>();

    final userId =
    ModalRoute.of(context)!.settings.arguments as String;

    await provider.verifyOtp(
      userId: userId,
      otp: otpController.text,
    );

    final response = provider.verifyOtpModel;

    if (response!.success) {
      Navigator.pushNamed(
        context,
        AppRoutes.newPassword,
      );
    } else {
      CustomToast.error(context, response.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.06, vertical: size.height * 0.04),
          child: Consumer2<LoginProvider, OtpVerifyProvider>(
            builder: (context, loginProvider, otpProvider, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLogo(size),
                  SizedBox(height: size.height * 0.02),
                  _buildCardImage(size),
                  SizedBox(height: size.height * 0.02),
                  _buildTitle(size),
                  SizedBox(height: size.height * 0.02),
                  _buildOtpInput(context, otpProvider),
                  SizedBox(height: size.height * 0.03),
                  _buildTimerOrResend(context, otpProvider),
                  SizedBox(height: size.height * 0.12),
                  loginProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : CustomCurvedButton(
                          text: AppStrings.verifyOtp,
                          fontSize: size.width * 0.03, // 12 px
                          onPressed: () => 
                          _newPasswordRequest(context),
                        ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(Size size) => Center(child: Image.asset(AppAssets.iciciLogo, width: size.width * 0.3));

  Widget _buildCardImage(Size size) => Center(
    child: Image.asset(AppAssets.otpCardImage, height: size.height * 0.4, width: size.width * 0.5),
  );

  Widget _buildTitle(Size size) => Center(
    child: Text(
      AppStrings.biometricKyc,
      style: TextStyle(
        fontSize: size.width * 0.07,
        fontWeight: FontWeight.bold,
        fontFamily: AppStrings.elMessiri,
        color: const Color(0xFF33348F),
        decoration: TextDecoration.underline,
      ),
    ),
  );

  Widget _buildOtpInput(BuildContext context, OtpVerifyProvider otpProvider) {
    return Center(
      child: Pinput(
        length: 6,
        controller: otpController,
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: focusedPinTheme,
        submittedPinTheme: submittedPinTheme,
        errorPinTheme: errorPinTheme,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        showCursor: true,
        closeKeyboardWhenCompleted: true,
        validator: (pin) {
          if (pin == null || pin.isEmpty) return AppStrings.otpIsRequired;
          if (pin.length < 6) return AppStrings.otpIncomplete;
          return null;
        },
        errorTextStyle: const TextStyle(color: Color(0xffFF3A3A), fontSize: 16, fontWeight: FontWeight.w500),
        onChanged: otpProvider.updateOtp,
        onCompleted: (pin) {
          otpProvider.updateOtp(pin);
          log("Entered OTP: $pin");
        },
      ),
    );
  }

  Widget _buildTimerOrResend(BuildContext context, OtpVerifyProvider otpProvider) {
    return Center(
      child: otpProvider.canResend
          ? GestureDetector(
              onTap: otpProvider.resendOtp,
              child: Text(
                AppStrings.resendOtp,
                style: TextStyle(
                  color: Color(0xFF33348F),
                  fontFamily: AppStrings.poppins,
                  fontSize: MediaQuery.of(context).size.width * 0.025,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            )
          : Text(
              "Resend OTP in ${otpProvider.remainingSeconds}s",
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: MediaQuery.of(context).size.width * 0.025,
                fontFamily: AppStrings.poppins,
                fontWeight: FontWeight.w500,
              ),
            ),
    );
  }
}
