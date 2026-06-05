import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:icici_bank/config.dart';
import 'package:icici_bank/core/models/Aadhaar_otp_model.dart';

import '../../core/models/biometric_models/fetch_current_status_model.dart';
import '../../core/models/login_model.dart';
import '../../core/network/api_client.dart';
import '../../core/network/network_api.dart';
import '../../core/util/app_preference.dart';
import '../../ui/widgets/rd_service.dart';

class AadhaarKycProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController aadhaarController = TextEditingController();

  String selectedIdType = "UID";
  // int maxLength = 12;
  int get maxLength => selectedIdType == "VID" ? 16 : 12;

  String selectedDevice = "";

  String originalAadhaar = "";
  String aadhaarNumber = '';

  String taxResidency = '';
  String pepStatus = '';
  bool declaration1 = false;
  bool declaration2 = false;
  bool termsAccepted = false;

  String? _kycType;

  String? get kycType => _kycType;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // 🔁 OTP Resend Timer
  int _remainingSeconds = 60;
  bool _canResendOtp = false;

  int get remainingSeconds => _remainingSeconds;

  bool get canResendOtp => _canResendOtp;

  Timer? _otpTimer;

  AgentInfo? _agentInfo;

  AgentInfo? get agentInfo => _agentInfo;

  String? _applicationId;

  String? get applicationId => _applicationId;

  String? _leadId;

  String? get leadId => _leadId;

  String? _applicationStatus;

  String? get applicationStatus => _applicationStatus;

  String? _transactionId;

  String? get transactionId => _transactionId;

  AadhaarOtpModel? _aadhaarOtpModel;

  AadhaarOtpModel? get aadhaarOtpModel => _aadhaarOtpModel;

  FetchCurrentStatusModel? _fetchCurrentStatusModel;

  FetchCurrentStatusModel? get fetchCurrentStatusModel =>
      _fetchCurrentStatusModel;

  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void selectIdType(String type) {
    selectedIdType = type;

    aadhaarController.clear();
    originalAadhaar = "";
    aadhaarNumber = "";

    // maxLength = (type == "UID") ? 12 : 16;
    // aadhaarController.clear();
    notifyListeners();
  }

  void selectDevice(String device) {
    selectedDevice = device;
    notifyListeners();
  }

  // void updateAadhaar(String value) {
  //   aadhaarNumber = value;
  //   notifyListeners();
  // }

  void updateAadhaar(String realValue, String maskedValue) {
    originalAadhaar = realValue;
    aadhaarNumber = maskedValue;
    notifyListeners();
  }

  void setTaxResidency(String value) {
    taxResidency = value;
    notifyListeners();
  }

  void setPepStatus(String value) {
    pepStatus = value;
    notifyListeners();
  }

  void toggleDeclaration1(bool? value) {
    declaration1 = value ?? false;
    notifyListeners();
  }

  void toggleDeclaration2(bool? value) {
    declaration2 = value ?? false;
    notifyListeners();
  }

  void toggleTerms(bool? value) {
    termsAccepted = value ?? false;
    notifyListeners();
  }

  void clearAadhaarForm() {
    aadhaarController.clear();

    selectedIdType = "UID";
    selectedDevice = "";

    originalAadhaar = "";
    aadhaarNumber = "";

    taxResidency = '';
    pepStatus = '';

    declaration1 = false;
    declaration2 = false;
    termsAccepted = false;

    notifyListeners();
  }

    Future<void> fetchApplicationStatus({required String applicationID}) async {
    _applicationId = applicationID;
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> body = {"application_id": applicationID};

      log('========== Body Param API Data fetchApplicationStatus ==========');
      log(body.toString());
      log('========== Body Param API Data fetchApplicationStatus ==========');

      final response = AppConfig.useNewApi
          ? await _apiClient.get("${NetworkApi.getStatus}?application_id=$applicationID")
          : await _apiClient.post(
              NetworkApi.fetchApplicationStatus,
              body,
            );
      log('========== Body Param API Data fetchApplicationStatus ==========');
      log(response.toString());
      _fetchCurrentStatusModel = FetchCurrentStatusModel.fromJson(response);

      /// IMPORTANT: update status used by UI
      _applicationStatus = _fetchCurrentStatusModel?.currentStatus;
    } catch (e, stackTrace) {
      log(
        "❌ Fetch Current Status error occurred",
        error: e,
        stackTrace: stackTrace,
      );
      _fetchCurrentStatusModel = FetchCurrentStatusModel(
        status: false,
        message: e.toString(),
      );
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> cancelApplication({required String applicationID}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        NetworkApi.cancelApplication,
        {"application_id": applicationID},
      );
      if (response['success'] == true) {
        await AppPreference.clearDraftDataKeepSession();
        clearAadhaarForm();
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      log("Cancel application failed", error: e, stackTrace: stackTrace);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> captureLocation({
    required String applicationID,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _apiClient.post(
        NetworkApi.locationCapture,
        {
          "application_id": applicationID,
          "latitude": latitude.toString(),
          "longitude": longitude.toString(),
        },
      );
      return response['success'] == true;
    } catch (e, stackTrace) {
      log("Location capture failed", error: e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<void> createKycApp({
    required String kycType,
    int? leadId,
  }) async {
    // ✅ SAVE KYC TYPE IN PROVIDER
    _kycType = kycType;

    final agentInfoMap = AppPreference.getAgentInfo();
    if (agentInfoMap != null) {
      _agentInfo = AgentInfo.fromJson(agentInfoMap);
    }
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> body = AppConfig.useNewApi
          ? {"kyc_type": kycType}
          : {
              "kyc_type": kycType,
              "lead_id": leadId,
            };

      final response = await _apiClient.post(
        NetworkApi.createApplication,
        body,
      );

      log('application id :- $body');
      log('Application creation failed: ${response['message']}');

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        _applicationId = data['application_id']?.toString();
        if (_applicationId != null && _applicationId!.isNotEmpty) {
          AppPreference.setApplicationID(_applicationId!);
        }
        _leadId = data['lead_id']?.toString();
        if (_leadId != null && _leadId!.isNotEmpty) {
          AppPreference.setLeadID(_leadId!);
        }
        _applicationStatus = data['status']?.toString();
      } else {
        log('Application creation failed: ${response['message']}');
      }
    } catch (e) {
      log("❌ Invalid application ", error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendAadhaarOtp() async {
    _isLoading = true;
    notifyListeners();
    log(
      "🧪 sendAadhaarOtp | appId=$_applicationId | status=$_applicationStatus",
    );

    void startOtpTimer() {
      _otpTimer?.cancel();

      _remainingSeconds = 60;
      _canResendOtp = false;
      notifyListeners();

      _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds == 0) {
          timer.cancel();
          _canResendOtp = true;
          notifyListeners();
        } else {
          _remainingSeconds--;
          notifyListeners();
        }
      });
    }

    // if (_applicationStatus != 'draft') {
    //   logger.e("⛔ Aadhaar entry blocked. Application status: $_applicationStatus");
    //   return false;
    // }

    // ❌ No application → no Aadhaar
    if (_applicationId == null) {
      log("❌ Application ID missing");
      return false;
    }

    // ❌ Aadhaar form incomplete
    if (aadhaarNumber.isEmpty ||
        taxResidency.isEmpty ||
        pepStatus.isEmpty ||
        !termsAccepted) {
      log("❌ Aadhaar data incomplete");
      return false;
    }

    try {
      final body = {
        "application_id": _applicationId,

        "aadhaar_number": originalAadhaar,
        "tax_resident_status": taxResidency,
        "pep_status": pepStatus,
        "terms_accepted": termsAccepted,
        "pep_type": pepStatus == "Y" ? "Domestic" : null,
      };

      log("📤 Aadhaar Entry Body: $body");

      final response = await _apiClient.post(NetworkApi.aadhaarEntry, body);
      log("✅ Aadhaar Entry Response: $response");

      if (response['success'] == true) {
        _aadhaarOtpModel = AadhaarOtpModel.fromJson(response);
        _transactionId = _aadhaarOtpModel?.data?.transactionId;

        log("✅ Aadhaar OTP sent");
        log("✅ Transaction ID: $_transactionId");

        // ⏱ START OTP TIMER HERE
        startOtpTimer();

        log("⏱ OTP timer started");

        return true;
      }

      log("❌ Aadhaar entry failed: $response");
      return false;
    } catch (e, s) {
      log("❌ Aadhaar OTP failed", error: e, stackTrace: s);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendOtp() async {
    if (!_canResendOtp) return;

    log("🔁 Resending Aadhaar OTP");

    final success = await sendAadhaarOtp();

    if (!success) {
      log("❌ Resend OTP failed");
    }
  }

  Future<bool> verifyAadhaarOtp(String enteredOtp) async {
    if (_applicationId == null || _transactionId == null) {
      log("❌ Missing applicationId or transactionId");
      return false;
    }

    try {
      final body = {
        "application_id": _applicationId,
        "aadhaar_number": originalAadhaar,
        "otp": enteredOtp,
        "transaction_id": _transactionId,
      };

      log("📤 Aadhaar Verify OTP Body: $body");

      final response = await _apiClient.post(NetworkApi.aadhaarOtpVerify, body);

      log("✅ Aadhaar OTP Verify Response: $response");

      // return response['success'] == true;
      if (response['success'] == true) {
        final ekycData = response['data']['ekyc_data'];
        await AppPreference.saveAadhaarData(ekycData);
        _otpTimer?.cancel();
        _canResendOtp = false;
        notifyListeners();

        return true;
      }

      return false;
    } catch (e, s) {
      log("❌ Aadhaar OTP verify failed", error: e, stackTrace: s);
      return false;
    }
  }

  Future<String?> checkRDServiceDevice() async {
    try {
      String action = "in.gov.uidai.rdservice.fp.INFO";

      final response = await RdService.openRdService(
        action,
        "",
      );

      log("RD INFO RESPONSE: $response");

      if (response == null || response.isEmpty) {
        return null;
      }

      final responseString =
      response.toString().toLowerCase();

      /// Detect connected device
      if (responseString.contains("mantra")) {
        return "Mantra L1";
      } else if (responseString.contains("precision")) {
        return "Precision L1";
      } else if (responseString.contains("morpho")) {
        return "Morpho L1";
      }

      return "UNKNOWN";
    } catch (e) {
      log("RD Service check failed: $e");
      return null;
    }
  }

}
