import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:icici_bank/config.dart';
import 'package:icici_bank/core/models/otp_verification_model.dart';

import '../../core/network/api_client.dart';
import '../../core/network/network_api.dart';
import '../../core/network/token_manager.dart';

class OtpVerifyProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  String _otp = '';
  int _remainingSeconds = 60;
  bool _canResend = false;
  bool _isVerifying = false;
  Timer? _timer;

  OtpVerificationModel? _otpVerificationModel;

  OtpVerificationModel? get otpVerificationModel => _otpVerificationModel;

  String get otp => _otp;

  int get remainingSeconds => _remainingSeconds;

  bool get canResend => _canResend;

  bool get isVerifying => _isVerifying;

  void updateOtp(String value) {
    _otp = value;
    notifyListeners();
  }

  void startTimer() {
    _remainingSeconds = 60;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
      } else {
        _canResend = true;
        timer.cancel();
      }
      notifyListeners();
    });
  }

  void resendOtp() {
    startTimer();
  }

  Future<void> verifyOtp({
    required String otpId,
    required String mobileNumber,
    required String otp,
  }) async {
    _isVerifying = true;
    notifyListeners();
    log(
      "🔐 Otp request started for user: $mobileNumber its Otp is: $otp and otpId is: $otpId",
    );
    try {
      final Map<String, dynamic> body = AppConfig.useNewApi
          ? {
        "mobile_number": mobileNumber,
        "otp_code": otp,
        "otp_id": otpId,
            }
          : {
              "otp_id": otpId,
              //"agent_id": agentId,
        "mobile_number":mobileNumber,
              "otp": otp,
            };
      log("📤 Otp Request Body: $body");

      final response = await _apiClient.post(
        AppConfig.useNewApi ? NetworkApi.verifyLoginOtp : NetworkApi.otpVerify,
        body,
      );
      log("✅ API Response: $response");

      _otpVerificationModel =
          OtpVerificationModel.fromJson(response);

      if (_otpVerificationModel?.success == true &&
          _otpVerificationModel?.data != null) {

        await TokenManager.saveToken(
          _otpVerificationModel!.data!.accessToken,
        );

        log("🔑 Token saved successfully");
      }
    } catch (e, stackTrace) {
      log(
        "❌ Otp Verification error occurred",
        error: e,
        stackTrace: stackTrace,
      );
      _otpVerificationModel = OtpVerificationModel(
        success: false,
        message: e.toString(),
      );
    }
    _isVerifying = false;
    notifyListeners();
    log("✅ Otp Verification process finished for user: $mobileNumber");
  }

  void disposeTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    disposeTimer();
    super.dispose();
  }
}
