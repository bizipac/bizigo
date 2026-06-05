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

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  String text = "";

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSubmitClick(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<LoginProvider>();

    await provider.resetPassword(
      newPassword: passwordController.text.trim(),
      confirmPassword: confirmPasswordController.text.trim(),
    );

    if (!mounted) return;

    final response = provider.resetPasswordModel;

    if (response == null) {
      CustomToast.error(context, "Something went wrong");
      return;
    }

    if (response.success) {
      CustomToast.success(context, response.message);

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
            (route) => false,
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
                    _buildLabel(AppStrings.newPassword, size),
                    SizedBox(height: size.height * 0.005),
                    CustomTextField(
                      controller: passwordController,
                      hintText: AppStrings.enterNewPassword,
                      obscureText: !loginProvider.isPasswordVisible,
                      fontSize: size.width * 0.03,
                      textColor: Colors.black,
                      hintColor: const Color(0xFF8A8A8A),
                      borderColor: const Color(0xFFC1C1C1),
                      textInputAction: TextInputAction.next,
                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return AppStrings.passwordIsRequired;
                      //   } else if (value.length < 8) {
                      //     return AppStrings.passwordMinLength;
                      //   }
                      //   return null;
                      // },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password required";
                        } else if (value.length < 8) {
                          return "Minimum 8 characters";
                        } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
                          return "Add one uppercase letter";
                        } else if (!RegExp(r'[a-z]').hasMatch(value)) {
                          return "Add one lowercase letter";
                        } else if (!RegExp(r'[0-9]').hasMatch(value)) {
                          return "Add one number";
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(loginProvider.isPasswordVisible ? Icons.visibility_off : Icons.visibility, color: const Color(0xFFFB0000)),
                        onPressed: loginProvider.togglePasswordVisibility,
                      ),
                      onChanged: (String value) {},
                    ),
                    SizedBox(height: size.height * 0.02),
                    _buildLabel(AppStrings.password, size),
                    SizedBox(height: size.height * 0.005),
                    CustomTextField(
                      controller: confirmPasswordController,
                      hintText: AppStrings.enterConfirmNewPassword,
                      obscureText: !loginProvider.isConfirmPasswordVisible,
                      fontSize: size.width * 0.03,
                      textColor: Colors.black,
                      hintColor: const Color(0xFF8A8A8A),
                      borderColor: const Color(0xFFC1C1C1),
                      textInputAction: TextInputAction.done,
                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return AppStrings.passwordIsRequired;
                      //   } else if (value.length < 6) {
                      //     return AppStrings.passwordMinLength;
                      //   }
                      //   return null;
                      // },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Confirm password required";
                        } else if (value.length < 8) {
                          return "Minimum 8 characters";
                        } else if (value != passwordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(loginProvider.isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility, color: const Color(0xFFFB0000)),
                        onPressed: loginProvider.togglePasswordVisibility,
                      ),
                      onChanged: (String value) {},
                    ),
                    SizedBox(height: size.height * 0.08),
                    loginProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomCurvedButton(text: AppStrings.submit, fontSize: size.width * 0.03, onPressed: () => _onSubmitClick(context)),
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
