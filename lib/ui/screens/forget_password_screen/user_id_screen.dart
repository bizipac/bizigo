import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:icici_bank/core/constants/app_assets.dart';
import 'package:icici_bank/core/constants/app_strings.dart';
import 'package:icici_bank/core/util/app_routes.dart';
import 'package:icici_bank/providers/login_provider/login_provider.dart';
import 'package:provider/provider.dart';

import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_toast_message.dart';

class UserIdScreen extends StatefulWidget {
  const UserIdScreen({super.key});

  @override
  State<UserIdScreen> createState() => _UserIdScreenState();
}

class _UserIdScreenState extends State<UserIdScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController userController = TextEditingController();
  String text = "";

  @override
  void dispose() {
    userController.dispose();
    super.dispose();
  }

  Future<void> _sendUserIdDetails(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<LoginProvider>();

    await provider.sendUserID(
      userId: userController.text.trim(),
    );

    if (!mounted) return;

    final response = provider.forgotPasswordModel;

    if (response == null) {
      CustomToast.error(context, "Something went wrong");
      return;
    }

    if (response.success) {
      CustomToast.success(context, response.message);

      Navigator.pushNamed(
        context,
        AppRoutes.forgotPassword,
        arguments: userController.text.trim(),
      );
    } else {
      if (response.message.toLowerCase().contains("user not found")) {
        CustomToast.error(context, "User not found");
      } else {
        CustomToast.error(context, response.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.06,
            vertical: size.height * 0.03,
          ),
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
                      validator: (value) => (value == null || value.isEmpty)
                          ? AppStrings.validatorMobileNumberUserId
                          : null,
                      onChanged: (String value) {},
                    ),
                    SizedBox(height: size.height * 0.18),
                    loginProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomCurvedButton(
                            text: AppStrings.submit,
                            fontSize: size.width * 0.03,
                            onPressed: () =>
                                _sendUserIdDetails(context),
                          ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(Size size) =>
      Center(child: Image.asset(AppAssets.iciciLogo, width: size.width * 0.25));

  Widget _buildCardImage(Size size) => Center(
    child: Image.asset(
      AppAssets.loginCardImage,
      height: size.height * 0.35,
      width: size.width * 0.5,
    ),
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
    style: TextStyle(
      fontSize: size.width * 0.035,
      fontWeight: FontWeight.w500,
      fontFamily: AppStrings.poppins,
      color: Colors.black,
    ),
  );
}
