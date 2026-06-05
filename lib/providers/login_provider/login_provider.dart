import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:icici_bank/config.dart';
import 'package:icici_bank/core/models/forgot_password_model.dart';

import '../../core/models/login_model.dart';
import '../../core/models/reset_password_model.dart';
import '../../core/models/verify_otp_model.dart';
import '../../core/network/api_client.dart';
import '../../core/network/network_api.dart';
import '../../ui/widgets/rd_service.dart';

class LoginProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  String resetToken = "";

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  LoginModel? _loginResponse;

  LoginModel? get loginResponse => _loginResponse;

  ForgotPasswordModel? _forgotPasswordModel;
  VerifyOtpModel? _verifyOtpModel;
  ResetPasswordModel? _resetPasswordModel;

  ForgotPasswordModel? get forgotPasswordModel => _forgotPasswordModel;
  VerifyOtpModel? get verifyOtpModel => _verifyOtpModel;
  ResetPasswordModel? get resetPasswordModel => _resetPasswordModel;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  bool get isPasswordVisible => _isPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        final info = {
          "device_platform": "android",
          "device_brand": androidInfo.brand,
          "device_model": androidInfo.model,
          "device_manufacturer": androidInfo.manufacturer,
          "current_app_version": NetworkApi.appVersion,
        };
        log("📱 Android Device Info: $info");
        return info;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        final info = {
          "device_platform": "iOS",
          "device_brand": "Apple",
          "device_model": iosInfo.utsname.machine,
          "device_manufacturer": "Apple",
          "current_app_version": NetworkApi.appVersion,
        };
        log("🍎 iOS Device Info: $info");
        return info;
      } else {
        log("⚠️ Unknown device platform detected");
        return {
          "device_platform": "unknown",
          "device_brand": "",
          "device_model": "",
          "device_manufacturer": "",
          "current_app_version": NetworkApi.appVersion,
        };
      }
    } catch (e, stackTrace) {
      log(
        "❌ Error while fetching device info",
        error: e,
        stackTrace: stackTrace,
      );
      return {
        "device_platform": "error",
        "device_brand": "",
        "device_model": "",
        "device_manufacturer": "",
        "current_app_version": NetworkApi.appVersion,
      };
    }
  }

  Future<Map<String, dynamic>> _getBiometricInfo() async {
    try {
      final info = {
        "device_make": "Mantra",
        "device_model": "MFS100",
        "device_serial": "12345678",
      };
      log(" Biometric Device Info: $info");
      return info;
    } catch (e, stackTrace) {
      log(
        "❌ Error while fetching Biometric device info",
        error: e,
        stackTrace: stackTrace,
      );
      return {
        "device_make": "Mantra",
        "device_model": "MFS100",
        "device_serial": "12345678",
      };
    }
  }

  Future<void> loginAgent({
    required String mobile,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    log("🔐 Login request started for user: $mobile");

    try {
      final deviceInfo = await _getDeviceInfo();
      final biometricInfo = await _getBiometricInfo();

      final Map<String, dynamic> body = AppConfig.useNewApi
          ? {
              "mobile_number": mobile,
              //"password": "dummy_password", //comment by Shubham Gupta
             "password": password,
              "device_info":deviceInfo,   //Written By - Shubham Gupta
              }
          : {
              "mobile_number": mobile,
              "password": password,
              "device_info": deviceInfo,
              "device_type": "Mantra",
              "biometric_device_info": biometricInfo,
            };

      log("📤 Login Request Body: $body");

      final response = await _apiClient.post(
        AppConfig.useNewApi ? NetworkApi.sendLoginOtp : NetworkApi.agentLogin,
        body,
      );

      log("✅ API Response: $response");

      _loginResponse = LoginModel.fromJson(response);
      log("✅ API Response model: $_loginResponse");
    } catch (e, stackTrace) {
      log("❌ Login error occurred", error: e, stackTrace: stackTrace);
      _loginResponse = LoginModel(success: false, message: e.toString());
    }

    _isLoading = false;
    notifyListeners();
    log("✅ Login process finished for user: $mobile");
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }


  Future<void> getRDInfo() async {
    final response = await RdService.openRdService(
      "in.gov.uidai.rdservice.fp.INFO",
      "",
    );
    print(response);
  }


  Future<void> sendUserID({
    required String userId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final body = {
        "user_id": userId,
      };

      final response = await _apiClient.post(
        NetworkApi.forgotPassword,
        body,
      );

      _forgotPasswordModel =
          ForgotPasswordModel.fromJson(response);

    } catch (e) {
      _forgotPasswordModel =
          ForgotPasswordModel(
            success: false,
            message: e.toString(),
            data: ForgotPasswordData(
              userId: 0,
              mobileMasked: "",
              otpExpiry: 0,
              expiresIn: 0,
            ),
          );
    }

    _isLoading = false;
    notifyListeners();
  }


  Future<void> verifyOtp({
    required String userId,
    required String otp,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final body = {
        "user_id": userId,
        "otp": otp,
      };

      final response = await _apiClient.post(
        NetworkApi.otpVerify,
        body,
      );

      if (response["success"]) {
        resetToken = response["data"]["reset_token"];
      }

      _verifyOtpModel =
          VerifyOtpModel.fromJson(response);
    } catch (e) {
      _verifyOtpModel =
          VerifyOtpModel(success: false, message: e.toString());
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> resetPassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final body = {
        "reset_token": resetToken,
        "new_password": newPassword,
        "confirm_password": confirmPassword,
      };

      final response = await _apiClient.post(
        NetworkApi.resetPassword,
        body,
      );

      _resetPasswordModel =
          ResetPasswordModel.fromJson(response);
    } catch (e) {
      _resetPasswordModel =
          ResetPasswordModel(success: false, message: e.toString());
    }

    _isLoading = false;
    notifyListeners();
  }
}
