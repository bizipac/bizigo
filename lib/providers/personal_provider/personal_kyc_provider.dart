import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:icici_bank/config.dart';

import '../../core/network/api_client.dart';
import '../../core/network/network_api.dart';
import '../../core/util/app_preference.dart';

class PersonalKycProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  PersonalKycProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  String? branchCodeError;
  String? titleError;
  String? firstNameError;
  String? lastNameError;
  String? dobError;
  String? mobileError;
  String? emailError;
  String? nationalityCodeError;
  // String? panStatusError;
  // String? taxAssessesError;
  // String? panNumberError;
  // String? panNameError;
  // String? form60Error;
  // String? wardCircleRangeError;
  // String? reasonNoPanError;
  String? visaTypeError;
  String? visaNumberError;
  String? visaCountryError;
  String? visaExpiryError;
  String? overseasAddress1Error;
  String? overseasAddress2Error;

  bool isLoading = false;
  String? errorMessage;

  String? panStatus;
  String? taxAssess;

  /// 🔹 STORE PERSONAL FORM DATA (LOCAL)
  Map<String, dynamic> _personalFormData = {};

  Map<String, dynamic> get personalFormData => _personalFormData;

  Map<String, dynamic>? aadhaarData;

  void setPanStatus(String value) {
    panStatus = value;
    notifyListeners();
  }

  Future<void> fetchAadhaarData() async {
    isLoading = true;
    notifyListeners();

    aadhaarData = await AppPreference.getAadhaarData();

    if (aadhaarData == null && AppConfig.useNewApi) {
      final applicationId = AppPreference.getApplicationID();
      if (applicationId != null && applicationId.isNotEmpty) {
        try {
          final response = await _apiClient.get(
            "${NetworkApi.getPersonalDetails}?application_id=$applicationId",
          );
          final dynamic data = response is Map<String, dynamic>
              ? response['data'] ?? response['ekyc_data'] ?? response
              : null;
          if (data is Map<String, dynamic>) {
            aadhaarData = data;
          }
        } catch (e, stackTrace) {
          log("Failed to fetch personal details from server", error: e, stackTrace: stackTrace);
        }
      }
    }

    isLoading = false;
    notifyListeners();
  }

  void setTaxAssessStatus(String value) {
    taxAssess = value;
    notifyListeners();
  }

  // void setPersonalFormData(Map<String, dynamic> data) {
  //   _personalFormData = data;
  //   notifyListeners();
  // }
  void setPersonalFormData(Map<String, dynamic> data) {
    _personalFormData.addAll(data);
    notifyListeners();
  }

  ///  SAVE PERSONAL DETAILS
  Future<bool> savePersonalDetails({required String applicationId, required String kycType, required Map<String, dynamic> personalData}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final body = AppConfig.useNewApi
          ? {
              "application_id": applicationId,
              "kyc_data": buildPersonalKycData(personalData),
            }
          : {
              "application_id": applicationId,
              "kyc_type": kycType,
              "kyc_data": personalData, // 🔥 UPPERCASE KEYS ONLY
            };

      debugPrint("📤 Save Personal KYC Body: $body");

      final response = await _apiClient.post(
        AppConfig.useNewApi
            ? NetworkApi.savePersonalDetails
            : NetworkApi.saveClientKycData,
        body,
      );

      debugPrint("📥 Save Personal KYC Response: $response");

      if (response["success"] == true) {
        return true;
      } else {
        errorMessage = response["message"] ?? "Failed to save personal details";
        return false;
      }
    } catch (e) {
      log("❌ Save Personal KYC Error: $e");
      errorMessage = "Something went wrong";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// validate Personal Form
  bool validatePersonalForm() {
    if (personalFormData.isEmpty) {
      errorMessage = "Personal details are missing";
      return false;
    }

    if (personalFormData["FIRST_NAME"] == null || personalFormData["FIRST_NAME"].toString().isEmpty) {
      errorMessage = "First name is required";
      return false;
    }

    if (personalFormData["DOB"] == null) {
      errorMessage = "Date of birth is required";
      return false;
    }

    if (personalFormData["MOBILE_NO"] == null || personalFormData["MOBILE_NO"].toString().isEmpty) {
      errorMessage = "Mobile number is required";
      return false;
    }

    // if (panStatus == null || panStatus!.isEmpty) {
    //   errorMessage = "Please select PAN status";
    //   return false;
    // }
    //
    // if (panStatus == "Y") {
    //   if (personalFormData["PAN_NO"] == null || personalFormData["PAN_NO"].toString().isEmpty) {
    //     errorMessage = "PAN number is required";
    //     return false;
    //   }
    // }
    //
    // if (panStatus == "N") {
    //   if (personalFormData["FORM60_NO"] == null || personalFormData["FORM60_NO"].toString().isEmpty) {
    //     errorMessage = "Form 60 number is required";
    //     return false;
    //   }
    //   if (personalFormData["WARD_CIRCLE_RANGE"] == null || personalFormData["WARD_CIRCLE_RANGE"].toString().isEmpty) {
    //     errorMessage = "Ward/Circle/Range details are required";
    //     return false;
    //   }
    //   if (personalFormData["REASON_NO_PAN"] == null || personalFormData["REASON_NO_PAN"].toString().isEmpty) {
    //     errorMessage = "Reason for not having PAN is required";
    //     return false;
    //   }
    // }

    return true;
  }

  // bool validatePanAndTaxFields({
  //   required String? panStatus,
  //   required String? taxStatus,
  //   required String panNumber,
  //   required String panName,
  //   required String form60Number,
  //   required String wardCircleRange,
  //   required String reasonNoPan,
  // }) {
    //
    // log("---- validatePanAndTaxFields START ----");
    // log("panStatus: $panStatus");
    // log("taxStatus: $taxStatus");
    // log("panNumber: $panNumber");
    // log("panName: $panName");
    // log("form60Number: $form60Number");
    // log("wardCircleRange: $wardCircleRange");
    // log("reasonNoPan: $reasonNoPan");
    //
    // /// Reset Errors
    // panStatusError = null;
    // taxAssessesError = null;
    // panNumberError = null;
    // panNameError = null;
    // form60Error = null;
    // wardCircleRangeError = null;
    // reasonNoPanError = null;
    //
    // bool isValid = true;
    //
    // /// PAN STATUS mandatory
    // if (panStatus == null || panStatus.isEmpty) {
    //   log("❌ PAN STATUS EMPTY");
    //   panStatusError = "Please select PAN status";
    //   isValid = false;
    // }
    //
    // /// PAN = YES
    // if (panStatus == "Y") {
    //
    //   log("PAN STATUS = YES");
    //
    //   if (panNumber.trim().isEmpty) {
    //     log("❌ PAN NUMBER EMPTY");
    //     panNumberError = "PAN number is mandatory";
    //     isValid = false;
    //   }
    //   else if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$')
    //       .hasMatch(panNumber.trim())) {
    //     log("❌ PAN FORMAT INVALID");
    //     panNumberError = "Enter valid PAN number (ABCDE1234F)";
    //     isValid = false;
    //   }
    //
    //   if (panName.trim().isEmpty) {
    //     log("❌ PAN NAME EMPTY");
    //     panNameError = "Name as per PAN is mandatory";
    //     isValid = false;
    //   }
    // }
    //
    // /// PAN = NO
    // if (panStatus == "N") {
    //
    //   log("PAN STATUS = NO");
    //
    //   if (form60Number.trim().isEmpty) {
    //     log("❌ FORM60 EMPTY");
    //     form60Error = "Form 60 number is mandatory";
    //     isValid = false;
    //   }
    //
    //   if (wardCircleRange.trim().isEmpty) {
    //     log("❌ WARD CIRCLE EMPTY");
    //     wardCircleRangeError = "Ward/Circle/Range details are mandatory";
    //     isValid = false;
    //   }
    //
    //   if (reasonNoPan.trim().isEmpty) {
    //     log("❌ REASON NO PAN EMPTY");
    //     reasonNoPanError = "Reason for not having PAN is mandatory";
    //     isValid = false;
    //   }
    //   /// TAX ASSESSEE mandatory
    //   if (taxStatus == null || taxStatus.isEmpty) {
    //     log("❌ TAX STATUS EMPTY");
    //     taxAssessesError = "Please select Tax Assessee option";
    //     isValid = false;
    //   }
    // }
  //
  //
  //
  //   log("FINAL PAN VALIDATION RESULT: $isValid");
  //
  //   notifyListeners();
  //   return isValid;
  // }
  // bool validatePanAndTaxFields({
  //   required String? panStatus,
  //   required String? taxStatus,
  //   required String panNumber,
  //   required String panName,
  //   required String form60Number,
  //   required String wardCircleRange,
  //   required String reasonNoPan,
  // })
  // {
  //   panStatusError = null;
  //   taxAssessesError = null;
  //   panNumberError = null;
  //   form60Error = null;
  //   wardCircleRangeError = null;
  //   reasonNoPanError = null;
  //
  //   bool isValid = true;
  //
  //   /// PAN STATUS mandatory
  //   if (panStatus == null || panStatus.isEmpty) {
  //     panStatusError = "Please select PAN status";
  //     isValid = false;
  //   }
  //
  //   // /// If PAN = YES → PAN number required
  //   // if (panStatus == "Y") {
  //   //   if (panNumber.trim().isEmpty) {
  //   //     panNumberError = "PAN number is mandatory";
  //   //     isValid = false;
  //   //   } else if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$')
  //   //       .hasMatch(panNumber.trim())) {
  //   //     panNumberError = "Enter valid PAN number";
  //   //     isValid = false;
  //   //   }
  //   // }
  //
  //   /// If PAN = YES → PAN number + PAN name required
  //   if (panStatus == "Y") {
  //     ///  PAN Number Validation
  //     if (panNumber.trim().isEmpty) {
  //       panNumberError = "PAN number is mandatory";
  //       isValid = false;
  //     } else if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(panNumber.trim())) {
  //       panNumberError = "Enter valid PAN number (e.g. ABCDE1234F)";
  //       isValid = false;
  //     }
  //
  //     ///  PAN Name Validation
  //     if (panName.trim().isEmpty) {
  //       panNameError = "Name as per PAN is mandatory";
  //       isValid = false;
  //     } else if (!RegExp(r'^[A-Za-z ]+$').hasMatch(panName.trim())) {
  //       panNameError = "Name should contain only alphabets";
  //       isValid = false;
  //     } else if (panName.trim().length < 3) {
  //       panNameError = "Enter valid PAN name";
  //       isValid = false;
  //     }
  //   }
  //
  //   /// If PAN = NO → Form60 required
  //   if (panStatus == "N") {
  //     if (form60Number.trim().isEmpty) {
  //       form60Error = "Form 60 number is mandatory";
  //       isValid = false;
  //     }
  //
  //     /// Ward/Circle/Range required when no PAN
  //     if (wardCircleRange.trim().isEmpty) {
  //       wardCircleRangeError = "Ward/Circle/Range details are mandatory";
  //       isValid = false;
  //     }
  //
  //     /// Reason for no PAN required when no PAN
  //     if (reasonNoPan.trim().isEmpty) {
  //       reasonNoPanError = "Reason for not having PAN is mandatory";
  //       isValid = false;
  //     }
  //   }
  //
  //   /// TAX ASSESSES mandatory
  //   if (taxStatus == null || taxStatus.isEmpty) {
  //     taxAssessesError = "Please select Tax Assesses option";
  //     isValid = false;
  //   }
  //
  //   notifyListeners();
  //   return isValid;
  // }

  /// Validate Mandatory Personal Fields
  bool validateMandatoryPersonalFields({
    // required String branchCode,
    required String? title,
    required String firstName,
    required String lastName,
    required String dob,
    required String mobile,
    required String email,
    // required String nationalityCode,
  }) {
    branchCodeError = null;
    titleError = null;
    firstNameError = null;
    lastNameError = null;
    dobError = null;
    mobileError = null;
    emailError = null;
    // nationalityCodeError = null;

    bool isValid = true;

    // if (branchCode.trim().isEmpty) {
    //   branchCodeError = "Branch code is mandatory";
    //   isValid = false;
    // }

    if (title == null || title.isEmpty) {
      titleError = "Title is mandatory";
      isValid = false;
    }

    if (firstName.trim().isEmpty) {
      firstNameError = "First name is mandatory";
      isValid = false;
    }

    if (lastName.trim().isEmpty) {
      lastNameError = "Last name is mandatory";
      isValid = false;
    }

    if (dob.trim().isEmpty) {
      dobError = "Date of birth is mandatory";
      isValid = false;
    }

    if (mobile.trim().isEmpty) {
      mobileError = "Mobile number is mandatory";
      isValid = false;
    } else if (!RegExp(r'^[0-9]{10}$').hasMatch(mobile.trim())) {
      mobileError = "Enter valid 10 digit mobile number";
      isValid = false;
    }

    if (email.trim().isEmpty) {
      emailError = "Email is mandatory";
      isValid = false;
    } else if (!RegExp(r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$', caseSensitive: false).hasMatch(email.trim())) {
      emailError = "Enter valid email address";
      isValid = false;
    }

    // if (nationalityCode.trim().isEmpty) {
    //   nationalityCodeError = "Nationality code is mandatory";
    //   isValid = false;
    // }

    notifyListeners();
    return isValid;
  }

  /// SAVE ADDRESS DETAILS
  Future<bool> saveAddressDetails({required String applicationId, required String kycType, required Map<String, dynamic> addressData}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final body = AppConfig.useNewApi
          ? {
              "application_id": applicationId,
              "kyc_data": addressData, // 🔥 UPPERCASE KEYS ONLY
            }
          : {
              "application_id": applicationId,
              "kyc_type": kycType,
              "kyc_data": addressData, // 🔥 UPPERCASE KEYS ONLY
            };

      log("📤 Save Address KYC Body: $body");

      final response = await _apiClient.post(
        AppConfig.useNewApi
            ? NetworkApi.saveAddressDetails
            : NetworkApi.saveClientKycData,
        body,
      );

      debugPrint("📥 Save Address KYC Response: $response");

      if (response["success"] == true) {
        return true;
      } else {
        errorMessage = response["message"] ?? "Failed to save address details";
        return false;
      }
    } catch (e) {
      log("❌ Save Address KYC Error: $e");
      errorMessage = "Something went wrong";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> buildPersonalKycData(Map<String, dynamic> personalData) {
    final String nationalityCode =
        personalData['NATIONALITY_CODE']?.toString().split(' - ').first ?? '';
    return {
      "PRODUCT_CODE": personalData['PRODUCT_CODE'],
      "BRANCH_CODE": personalData['BRANCH_CODE'],
      "TITLE": personalData['TITLE'],
      "FIRST_NAME": personalData['FIRST_NAME'],
      "MIDDLE_NAME": personalData['MIDDLE_NAME'],
      "LAST_NAME": personalData['LAST_NAME'],
      "FATHERS_NAME": personalData['FATHER_NAME'],
      "MOTHERS_NAME": personalData['MOTHER_NAME'],
      "MOTHERS_MAIDEN_NAME": personalData['MOTHER_MAIDEN_NAME'],
      "MARITAL_STATUS": personalData['MARITAL_STATUS'],
      "DOB": personalData['DOB'],
      "GENDER": personalData['GENDER'],
      "NATIONALITY_CODE": nationalityCode,
      "MOBILE_NO": personalData['MOBILE_NO'],
      "EMAIL_ID": personalData['EMAIL_ID']?.toString().trim(),
      "STD_CODE_1": personalData['STD_CODE'],
      "PHONE_NO_1": personalData['LANDLINE_NO'],
      "EDUCATION": personalData['EDUCATION'],
      "RESIDENTIAL_STATUS": personalData['RESIDENTIAL_STATUS'],
      "OCCUPATION": personalData['OCCUPATION_TYPE'],
      "SUB_OCCUPATION": personalData['SUB_OCCUPATION_TYPE'],
      "EMPLOYER": personalData['EMPLOYER_NAME'],
      "DESIGNATION": personalData['DESIGNATION'],
      "SOURCE_OF_INCOME": personalData['SOURCE_OF_INCOME'],
      "GROSS_ANNUAL_INCOME": personalData['GROSS_INCOME'],
      "COMMUNICATION_SAME_AS_PERMANENT":
          personalData['COMMUNICATION_SAME_AS_PERMANENT'],
      "DECLARATION_OPTION": personalData['DECLARATION_OPTION'],
      "SELF_DECLARED_COMMUNICATION_ADDRESS":
          personalData['SELF_DECLARED_COMMUNICATION_ADDRESS'],
    };
  }

  Map<String, dynamic> buildAddressKycData(Map<String, dynamic> personalData) {
    final isSameAddress =
        personalData['COMMUNICATION_SAME_AS_PERMANENT']?.toString().toUpperCase() == 'Y';
    return {
      "IDENTIFICATION_PROOF": "ADCRD",
      "IDENTIFICATION_PROOF_NUMBER":
          personalData['IDENTIFICATION_PROOF_NUMBER'] ?? '123456789012',
      "ADDRESS_PROOF": "PANCARD",
      "ADDRESS_PROOF_NUMBER": personalData['PAN_NO'],
      "PERMANENT_ADDRESS_1": personalData['PERMANENT_ADDRESS_1'],
      "PERMANENT_ADDRESS_2": personalData['PERMANENT_ADDRESS_2'],
      "PHYSICAL_LANDMARK": personalData['PHYSICAL_LANDMARK'],
      "PERMANENT_CITY": personalData['PERMANENT_CITY'],
      "PERMANENT_STATE": personalData['PERMANENT_STATE'],
      "PHYSICAL_DISTRICT": personalData['PHYSICAL_DISTRICT'],
      "PERMANENT_ZIP": personalData['PERMANENT_ZIP'],
      "PERMANENT_COUNTRY": personalData['PERMANENT_COUNTRY'],
      "COMMUNICATION_SAME_AS_PERMANENT":
          personalData['COMMUNICATION_SAME_AS_PERMANENT'],
      "COMMUNICATION_ADDRESS_1": isSameAddress
          ? personalData['PERMANENT_ADDRESS_1']
          : personalData['COMMUNICATION_ADDRESS_1'],
      "COMMUNICATION_ADDRESS_2": isSameAddress
          ? personalData['PERMANENT_ADDRESS_2']
          : personalData['COMMUNICATION_ADDRESS_2'],
      "MAILING_LANDMARK": isSameAddress
          ? personalData['PHYSICAL_LANDMARK']
          : personalData['COMMUNICATION_LANDMARK'],
      "COMMUNICATION_CITY": isSameAddress
          ? personalData['PERMANENT_CITY']
          : personalData['COMMUNICATION_CITY'],
      "COMMUNICATION_STATE": isSameAddress
          ? personalData['PERMANENT_STATE']
          : personalData['COMMUNICATION_STATE'],
      "MAILING_DISTRICT": isSameAddress
          ? personalData['PHYSICAL_DISTRICT']
          : personalData['COMMUNICATION_DISTRICT'],
      "COMMUNICATION_ZIP": isSameAddress
          ? personalData['PERMANENT_ZIP']
          : personalData['COMMUNICATION_ZIP'],
      "COMMUNICATION_COUNTRY": isSameAddress
          ? personalData['PERMANENT_COUNTRY']
          : (personalData['COMMUNICATION_COUNTRY'] ?? "INDIA"),
      "SELF_DECLARED_COMMUNICATION_ADDRESS":
          personalData['SELF_DECLARED_COMMUNICATION_ADDRESS'],
    };
  }

  // Future<bool> validatePan({
  //   required String panNumber,
  //   required String name,
  //   required String fatherName,
  // }) async {
  //   isLoading = true;
  //   errorMessage = null;
  //   notifyListeners();
  //
  //   try {
  //     final body = {
  //       "PAN_NO": panNumber,
  //       "PAN_NAME": name,
  //       "PAN_FATHER_NAME": fatherName,
  //     };
  //
  //     debugPrint(" PAN Validate Body: $body");
  //
  //     final response = await _apiClient.post(
  //       NetworkApi.panValidate,
  //       body,
  //     );
  //
  //     debugPrint("📥 PAN Validate Response: $response");
  //
  //     if (response["success"] == true) {
  //       return true;
  //     } else {
  //       errorMessage = response["message"] ?? "PAN validation failed";
  //       return false;
  //     }
  //   } catch (e) {
  //     log("❌ PAN Validate Error: $e");
  //     errorMessage = "Enter valid PAN number";
  //     return false;
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }
}
