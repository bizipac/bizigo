import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icici_bank/config.dart';
import 'package:icici_bank/core/constants/app_assets.dart';
import 'package:icici_bank/core/constants/app_strings.dart';
import 'package:icici_bank/core/util/app_preference.dart';
import 'package:icici_bank/core/util/app_routes.dart';
import 'package:icici_bank/ui/screens/otp_verify_screen/pinput_theme.dart';
import 'package:icici_bank/ui/widgets/custom_toast_message.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../../../core/models/login_model.dart';
import '../../../providers/otp_verify_provider/otp_verify_provider.dart';
import '../../widgets/custom_button.dart';

class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({super.key});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final TextEditingController otpController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OtpVerifyProvider>().startTimer();
      if (AppConfig.useNewApi) {
        otpController.text = AppConfig.universalOtp;
        context.read<OtpVerifyProvider>().updateOtp(AppConfig.universalOtp);
      }
    });
  }

  @override
  void dispose() {
    otpController.dispose();
    context.read<OtpVerifyProvider>().disposeTimer();
    super.dispose();
  }

  Future<void> _verifyOtp(BuildContext context, LoginData data) async {
    final otpProvider = context.read<OtpVerifyProvider>();

    if (otpProvider.otp.length != 6) {
      CustomToast.error(context, AppStrings.validatorOtp);
      return;
    }

    //Written by - Shubham Gupta
    print("----Data--------");
    print(data.agentInfo.mobile);
    final mobileNumber = await AppPreference.getMobileNumber();
    await otpProvider.verifyOtp(otpId: data.otpId, mobileNumber: mobileNumber, otp: otpProvider.otp);

    final response = otpProvider.otpVerificationModel;
    if (response == null) return;

    if (response.success) {
      CustomToast.success(context, response.message);
      await AppPreference.setLoginStatus(true);
      await AppPreference.setAccessToken(response.data!.accessToken);
      await AppPreference.setRefreshToken(response.data!.refreshToken);
      if (response.data!.agentInfo != null) {
        await AppPreference.setAgentInfo(response.data!.agentInfo!.toJson());
      }

      Navigator.pushNamed(
        context,
        AppRoutes.home,
        arguments: response.data!.agentInfo?.toJson(),
      );
    } else {
      CustomToast.error(context, response.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final LoginData data = ModalRoute.of(context)!.settings.arguments as LoginData;

    log('OTP ID: ${data.otpId}');
    log('Agent Name: ${data.agentInfo.agentName}');

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.06, vertical: size.height * 0.04),
          child: Consumer<OtpVerifyProvider>(
            builder: (context, otpProvider, _) {
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
                  otpProvider.isVerifying
                      ? const Center(child: CircularProgressIndicator())
                      : CustomCurvedButton(
                          text: AppStrings.verifyOtp,
                          fontSize: size.width * 0.03, // 12 px
                          onPressed: () => _verifyOtp(context, data),
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
