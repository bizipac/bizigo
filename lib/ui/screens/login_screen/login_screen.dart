import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icici_bank/core/constants/app_assets.dart';
import 'package:icici_bank/core/constants/app_strings.dart';
import 'package:icici_bank/config.dart';
import 'package:icici_bank/core/util/app_routes.dart';
import 'package:icici_bank/providers/login_provider/login_provider.dart';
import 'package:provider/provider.dart';
import 'package:rd_sample/rd_sample.dart';

import '../../../core/util/app_preference.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_toast_message.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String text = "";
  String DEVICE_INFO = '', RD_SERVICE_INFO = '', capturePID = '';
  String PIDOption = '', Data = '';

  @override
  void dispose() {
    userController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(BuildContext context) async {
    final loginProvider = context.read<LoginProvider>();

    if (!_formKey.currentState!.validate()) {
      log('Validation failed');
      return;
    }
    //Written By - Shubham Gupta
    await AppPreference.setMobileNumber(
      userController.text.trim(),
    );
    await loginProvider.loginAgent(mobile: userController.text.trim(), password: passwordController.text.trim());

    final response = loginProvider.loginResponse;
    if (response == null) return;

    if (response.success) {
      CustomToast.success(context, response.message);

      /// in future we need to handle here which device is connected and according to that we need to fetch device information
      _startFingerDevicesInfo();
      loginProvider.getRDInfo();

      //Written By - Shubham Gupta
      print("================================");
      print(response.data?.mobile_number);
      print(response.data?.otpId);
      print("================================");
      Navigator.pushNamed(context, AppRoutes.otp, arguments: response.data);
    } else {
      CustomToast.error(context, response.message);
    }
  }

  Future<void> _startFingerDevicesInfo() async {
    log('🟢 Starting Finger Device Info Process...');

    try {
      log('📡 Fetching fingerDeviceInfo...');
      final info = await RdSample.fingerDeviceInfo;

      log('📄 Raw Device Info Response: $info');

      setState(() {
        DEVICE_INFO = info['DEVICE_INFO'] as String;
        RD_SERVICE_INFO = info['RD_SERVICE_INFO'] as String;
        Data = DEVICE_INFO + "\n\n" + RD_SERVICE_INFO;
        PIDOption = '';
      });

      log('✅ DEVICE_INFO Updated');
      log('✅ RD_SERVICE_INFO Updated');
      log('🧹 PIDOption Cleared');

      log('📱 DEVICE_INFO: $DEVICE_INFO');
      log('🛠️ RD_SERVICE_INFO: $RD_SERVICE_INFO');
      log('🎉 Finger Device Info Process Completed Successfully');
    } on PlatformException catch (e) {
      log('❌ PlatformException occurred: ${e.message}');
      debugPrint("Error PlatformException : '${e.message}'.");
    } catch (e) {
      log('🔥 Unexpected Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.06, vertical: size.height * 0.03),
          child: Form(
            key: _formKey,
            child: Consumer<LoginProvider>(
              builder: (context, loginProvider, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLogo(size),
                    SizedBox(height: size.height * 0.02),
                    _buildCardImage(size),
                    SizedBox(height: size.height * 0.02),
                    _buildTitle(size),
                    SizedBox(height: size.height * 0.03),
                    _buildLabel(AppStrings.mobileNumberUserId, size),
                    SizedBox(height: size.height * 0.005),
                    CustomTextField(
                      controller: userController,
                      hintText: AppStrings.enterMobileNumberUserId,
                      fontSize: size.width * 0.03,
                      textColor: Colors.black,
                      hintColor: const Color(0xFF8A8A8A),
                      borderColor: const Color(0xFFC1C1C1),
                      textInputAction: TextInputAction.next,
                      validator: (value) => (value == null || value.isEmpty) ? AppStrings.validatorMobileNumberUserId : null,
                      onChanged: (String value) {},
                    ),
                    SizedBox(height: size.height * 0.02),
                    _buildLabel(AppStrings.password, size),
                    SizedBox(height: size.height * 0.005),
                    CustomTextField(
                      controller: passwordController,
                      hintText: AppStrings.enterPassword,
                      obscureText: !loginProvider.isPasswordVisible,
                      fontSize: size.width * 0.03,
                      textColor: Colors.black,
                      hintColor: const Color(0xFF8A8A8A),
                      borderColor: const Color(0xFFC1C1C1),
                      textInputAction: TextInputAction.done,
                      validator: AppConfig.useNewApi
                          ? null
                          : (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.passwordIsRequired;
                              } else if (value.length < 6) {
                                return AppStrings.passwordMinLength;
                              }
                              return null;
                            },
                      suffixIcon: IconButton(
                        icon: Icon(loginProvider.isPasswordVisible ? Icons.visibility_off : Icons.visibility, color: const Color(0xFFFB0000)),
                        onPressed: loginProvider.togglePasswordVisibility,
                      ),
                      onChanged: (String value) {},
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          CustomToast.support(context);
                          // Navigator.pushNamed(context, AppRoutes.userId);
                        },
                        child: Text(
                          AppStrings.forgotPassword,
                          style: TextStyle(
                            fontSize: size.width * 0.03,
                            fontWeight: FontWeight.w500,
                            fontFamily: AppStrings.poppins,
                            color: const Color(0xFF33348F),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    loginProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomCurvedButton(text: AppStrings.sendOtp, fontSize: size.width * 0.03, onPressed: () => _handleLogin(context)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(Size size) => Center(child: Image.asset(AppAssets.iciciLogo, width: size.width * 0.25));

  Widget _buildCardImage(Size size) => Center(
    child: Image.asset(AppAssets.loginCardImage, height: size.height * 0.35, width: size.width * 0.5),
  );

  Widget _buildTitle(Size size) => Center(
    child: Text(
      AppStrings.biometricKyc,
      style: TextStyle(
        fontSize: size.width * 0.075,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF33348F),
        fontFamily: AppStrings.elMessiri,
        decoration: TextDecoration.underline,
      ),
    ),
  );

  Widget _buildLabel(String text, Size size) => Text(
    text,
    style: TextStyle(fontSize: size.width * 0.035, fontWeight: FontWeight.w500, fontFamily: AppStrings.poppins, color: Colors.black),
  );
}
