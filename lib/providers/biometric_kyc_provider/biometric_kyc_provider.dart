import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icici_bank/config.dart';
import 'package:icici_bank/core/models/biometric_models/fetch_current_status_model.dart';
import 'package:icici_bank/core/models/biometric_models/product_validation_model.dart';
import 'package:icici_bank/core/models/biometric_models/save_personal_details_model.dart';
import 'package:intl/intl.dart';

import '../../core/models/biometric_models/application_submit_model.dart';
import '../../core/models/biometric_models/pan_card_validation_model.dart';
import '../../core/network/api_client.dart';
import '../../core/network/network_api.dart';
import '../../core/util/app_preference.dart';

class BiometricKycProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  static const _channel = MethodChannel('biometric_channel');

  bool _isVerifying = false;

  String _productDetails = '';
  String _personalDetails = '';
  String _corporateDetails = '';
  bool _isProductExpanded = false;

  String? _pidXml;

  String? get pidXml => _pidXml;

  String get productDetails => _productDetails;

  String get personalDetails => _personalDetails;

  String get corporateDetails => _corporateDetails;

  bool get isProductExpanded => _isProductExpanded;

  ProductValidationModel? _productValidationModel;

  ProductValidationModel? get productValidationModel => _productValidationModel;

  SavePersonalDetailsModel? _savePersonalDetailsModel;

  SavePersonalDetailsModel? get savePersonalDetailsModel =>
      _savePersonalDetailsModel;

  PanCardValidationModel? _panCardValidationModel;

  PanCardValidationModel? get panCardValidationModel => _panCardValidationModel;

  ApplicationSubmitModel? _applicationSubmitModel;

  ApplicationSubmitModel? get applicationSubmitModel => _applicationSubmitModel;

  FetchCurrentStatusModel? _fetchCurrentStatusModel;

  FetchCurrentStatusModel? get fetchCurrentStatusModel =>
      _fetchCurrentStatusModel;

  Future<void> fetchApplicationStatus({required String applicationID}) async {
    _isVerifying = true;
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
    _isVerifying = false;
    notifyListeners();
  }

  Future<void> validateProduct({
    required String kycType,
    required String applicationID,
    required String productCode,
    required String cardNumber,
    required String proxyNumber,
  }) async {
    _isVerifying = true;
    notifyListeners();

    try {
      final Map<String, dynamic> body = {
        "application_id": applicationID,
        "product_code": productCode,
        if (kycType == "min_kyc") ...{
          "card_number": cardNumber,
          // "proxy_number": proxyNumber,
          "card_proxy_number": proxyNumber,
        },
      };
      log('========== Body Param API Data validateProduct ==========');
      log(body.toString());
      log('========== Body Param API Data validateProduct ==========');

      final response = await _apiClient.post(
        NetworkApi.productValidation,
        body,
      );
      _productValidationModel = ProductValidationModel.fromJson(response);
    } catch (e, stackTrace) {
      log(
        "❌ Product Validation error occurred",
        error: e,
        stackTrace: stackTrace,
      );
      _productValidationModel = ProductValidationModel(
        success: false,
        message: e.toString(),
      );
    }
    _isVerifying = false;
    notifyListeners();
  }

  DateTime parseDobFlexible(String val) {
    try {
      return DateFormat('dd/MM/yyyy').parseStrict(val);
    } catch (_) {
      return DateFormat('dd-MM-yyyy').parseStrict(val);
    }
  }

  Future<void> savePersonalDetails({
    required String kycType,
    required String applicationID,
    required String productCode,
    required Map<String, dynamic> personalData,
  }) async {
    _isVerifying = true;
    notifyListeners();
    log('========== Personal API Data new ==========');
    log('Hello This is Data: \n${personalData.toString()}');

    try {
      final Map<String, dynamic> kycData = {
        "PRODUCT_CODE": productCode,
        "BRANCH_CODE": personalData['BRANCH_CODE'],
        "TITLE": personalData['TITLE'],
        "FIRST_NAME": personalData['FIRST_NAME'],
        "MIDDLE_NAME": personalData['MIDDLE_NAME'],
        "LAST_NAME": personalData['LAST_NAME'],
        "FATHERS_NAME": personalData['FATHER_NAME'],
        "MOTHERS_NAME": personalData['MOTHER_NAME'],
        "MOTHERS_MAIDEN_NAME": personalData['MOTHER_MAIDEN_NAME'],
        "MARITAL_STATUS": personalData['MARITAL_STATUS'],
        "DOB": DateFormat('yyyy-MM-dd').format(
          parseDobFlexible(personalData['DOB']),
        ),
        "GENDER": personalData['GENDER'],
        "NATIONALITY_CODE":
            personalData['NATIONALITY_CODE']?.toString().split(' - ').first ??
                '',
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

      log('========== KYCDATABODY savePersonalDetails ==========');
      log(kycData.toString());
      log('========== KYCDATABODY savePersonalDetails ==========');
      final Map<String, dynamic> body = AppConfig.useNewApi
          ? {
              "application_id": applicationID,
              "kyc_data": kycData,
            }
          : {
              "application_id": applicationID,
              "kyc_type": kycType,
              "kyc_data": kycData,
            };

      log('========== Body Param API Data savePersonalDetails ==========');
      log(body.toString());
      log('========== Body Param API Data savePersonalDetails ==========');

      final response = await _apiClient.post(
        AppConfig.useNewApi
            ? NetworkApi.savePersonalDetails
            : NetworkApi.saveClientKycData,
        body,
      );

      _savePersonalDetailsModel = SavePersonalDetailsModel.fromJson(response);
    } catch (e, stackTrace) {
      log(
        "❌ Save Personal Details error occurred",
        error: e,
        stackTrace: stackTrace,
      );
      _savePersonalDetailsModel = SavePersonalDetailsModel(
        success: false,
        message: e.toString(),
      );
    }
    _isVerifying = false;
    notifyListeners();
  }

  // Future<void> saveAddressDetails({
  //   required String kycType,
  //   required String applicationID,
  //   required String productCode,
  //   required Map<String, dynamic> personalData,
  // }) async
  // {
  //   _isVerifying = true;
  //   notifyListeners();
  //   log('========== Personal API Data ==========');
  //   log(personalData.toString());
  //
  //   try {
  //     final Map<String, dynamic> kycData = {
  //       "PERMANENT_ADDRESS_1": personalData['PERMANENT_ADDRESS_1'],
  //       "PERMANENT_ADDRESS_2": personalData['PERMANENT_ADDRESS_2'],
  //       "PHYSICAL_LANDMARK": personalData['PHYSICAL_LANDMARK'],
  //       "PERMANENT_CITY": personalData['PERMANENT_CITY'],
  //       "PERMANENT_STATE": personalData['PERMANENT_STATE'],
  //       "PHYSICAL_DISTRICT": personalData['PHYSICAL_DISTRICT'],
  //       "PERMANENT_ZIP": personalData['PERMANENT_ZIP'],
  //       "PERMANENT_COUNTRY": personalData['PERMANENT_COUNTRY'],
  //       "COMMUNICATION_SAME_AS_PERMANENT": personalData['COMMUNICATION_SAME_AS_PERMANENT'],
  //       "COMMUNICATION_ADDRESS_1": personalData['COMMUNICATION_ADDRESS_1'],
  //       "COMMUNICATION_ADDRESS_2": personalData['COMMUNICATION_ADDRESS_2'],
  //       "MAILING_LANDMARK": personalData['COMMUNICATION_LANDMARK'],
  //       "COMMUNICATION_CITY": personalData['COMMUNICATION_CITY'],
  //       "COMMUNICATION_STATE": personalData['COMMUNICATION_STATE'],
  //       "MAILING_DISTRICT": personalData['COMMUNICATION_DISTRICT'],
  //       "COMMUNICATION_ZIP": personalData['COMMUNICATION_ZIP'],
  //       "COMMUNICATION_COUNTRY": personalData['COMMUNICATION_COUNTRY'] ?? "INDIA",
  //       "SELF_DECLARED_COMMUNICATION_ADDRESS": personalData['SELF_DECLARED_COMMUNICATION_ADDRESS'],
  //     };
  //
  //     final Map<String, dynamic> body = {"application_id": applicationID, "kyc_type": kycType, "kyc_data": kycData};
  //
  //     log('========== Body Param API Data savePersonalDetails ==========');
  //     log(body.toString());
  //     log('========== Body Param API Data savePersonalDetails ==========');
  //
  //     final response = await _apiClient.post(NetworkApi.saveClientKycData, body);
  //     _savePersonalDetailsModel = SavePersonalDetailsModel.fromJson(response);
  //   } catch (e, stackTrace) {
  //     log("❌ Save Personal Details error occurred", error: e, stackTrace: stackTrace);
  //     _savePersonalDetailsModel = SavePersonalDetailsModel(success: false, message: e.toString());
  //   }
  //   _isVerifying = false;
  //   notifyListeners();
  // }

  Future<void> kycPanValidate({
    required String applicationID,
    required Map<String, dynamic> personalData,
  }) async {
    _isVerifying = true;
    notifyListeners();
    log('========== Personal API Data ==========');
    log(personalData.toString());

    try {
      final bool hasPan = personalData['PAN_STATUS'] == 'Y';
      final bool isTaxAssesse = personalData['TAX_ASSESSEE'] == 'Y';

      final Map<String, dynamic> panData = {
        // "has_pan": personalData['PAN_STATUS'] == 'Y' ? true : false,
        "has_pan": hasPan,

        if (hasPan) ...{
          "pan": personalData['PAN_NO'],
          "name": personalData['PAN_NAME'],
          /// father name is optional
          if (personalData['PAN_FATHER_NAME'] != null &&
              personalData['PAN_FATHER_NAME'].toString().isNotEmpty)
            "father_name": personalData['PAN_FATHER_NAME'],
          "dob": personalData['PAN_DOB'],
        },

        if (!hasPan) ...{
          "form_60_number": personalData['FORM60_NO'],
          "is_tax_assesse": isTaxAssesse,
          "ward_circle_range": personalData['WARD_CIRCLE_RANGE'],
          "reason_no_pan": personalData['REASON_NO_PAN'],
        },
      };
      final Map<String, dynamic> body = AppConfig.useNewApi
          ? {
              "application_id": applicationID,
              "kyc_data": panData,
            }
          : panData;

      log('========== Body Param API Data pan validation ==========');
      log(body.toString());
      log('========== Body Param API Data pan validation ==========');

      final response = await _apiClient.post(NetworkApi.panValidate, body);
      _panCardValidationModel = PanCardValidationModel.fromJson(response);
    } catch (e, stackTrace) {
      log(
        "❌ Save Personal Details error occurred",
        error: e,
        stackTrace: stackTrace,
      );
      _panCardValidationModel = PanCardValidationModel(
        success: false,
        message: e.toString(),
      );
    }
    _isVerifying = false;
    notifyListeners();
  }

  Future<void> saveCorporateDetails({
    required String kycType,
    required String applicationID,
    required String productCode,
    required Map<String, dynamic> corporateData,
  }) async {
    _isVerifying = true;
    notifyListeners();
    log('========== Corporate API Data ==========');
    log(corporateData.toString());

    try {
      final Map<String, dynamic> kycData = {
        "EMPLOYER": corporateData['EMPLOYER'],
        "CORPRATE_ID": corporateData['CORPRATE_ID'],
        "EMPL_ADDRESS1": corporateData['EMPL_ADDRESS1'],
        "EMPL_ADDRESS2": corporateData['EMPL_ADDRESS2'],
        "EMPL_CITY": corporateData['EMPL_CITY'],
        "EMPL_STATE": corporateData['EMPL_STATE'],
        "EMPL_ZIP": corporateData['EMPL_ZIP'],
        "EMPL_COUNTRY": corporateData['EMPL_COUNTRY'],
        "EMPL_DISTRICT": corporateData['EMPLOYER_DISTRICT'],
        "EMPL_LANDMARK": corporateData['EMPLOYER_LANDMARK'],
        "EMPL_PHONE_1": corporateData['EMPL_PHONE_1'],
        "EMPL_MOBILE": corporateData['EMPL_MOBILE'],
        "ICICI_RELATIONSHIP_NO": corporateData['ICICI_RELATIONSHIP_NUMBER'],
        "ICICI_RELATIONSHIP_TYPE": corporateData['ICICI_RELATIONSHIP_TYPE'],
        "existing_icici_customer":
            corporateData['existing_icici_customer'] ??
                corporateData['EXISTING_ICICI_CUSTOMER'] ??
                (corporateData['ICICI_RELATIONSHIP_TYPE'] == 'EXISTING_CUSTOMER'
                    ? 'Y'
                    : 'N'),
      };

      /// Add bank details only if EXISTING_CUSTOMER
      if (corporateData['ICICI_RELATIONSHIP_TYPE'] == 'EXISTING_CUSTOMER') {
        kycData.addAll({
          "BANK_ACCOUNT_NUMBER": corporateData['BANK_ACCOUNT_NUMBER'],
          "IFSC_CODE": corporateData['IFSC_CODE'],
          "ICICI_ACCOUNT_NUMBER": corporateData['ICICI_ACCOUNT_NUMBER'],
        });
      }

      final Map<String, dynamic> body = AppConfig.useNewApi
          ? {
              "application_id": applicationID,
              "kyc_data": kycData,
            }
          : {
              "application_id": applicationID,
              "kyc_type": kycType,
              "kyc_data": kycData,
            };

      log('========== Body Param API Data corporate ==========');
      log(body.toString());
      log('========== Body Param API Data corporate ==========');

      final response = await _apiClient.post(
        NetworkApi.saveCorporateDetails,
        body,
      );
      log('========== API Response Corporate ==========');
      log(response.toString());
      log('========== API Response Corporate Complete ==========');
      _savePersonalDetailsModel = SavePersonalDetailsModel.fromJson(response);
    } catch (e, stackTrace) {
      log(
        "❌ Save Personal Details error occurred",
        error: e,
        stackTrace: stackTrace,
      );
      _savePersonalDetailsModel = SavePersonalDetailsModel(
        success: false,
        message: e.toString(),
      );
    }
    _isVerifying = false;
    notifyListeners();
  }

  Future<void> submitFinalKyc({
    required String applicationID,
    required String kycType,
  }) async {
    _isVerifying = true;
    notifyListeners();
    try {
      final Map<String, dynamic> body = AppConfig.useNewApi
          ? {
              "application_id": applicationID,
            }
          : {
              "application_id": applicationID,
              "kyc_type": kycType,
            };

      log('========== Body Param API Data savePersonalDetails ==========');
      log(body.toString());
      log('========== Body Param API Data savePersonalDetails ==========');

      final response = await _apiClient.post(
        NetworkApi.submitKycApplication,
        body,
      );
      _applicationSubmitModel = ApplicationSubmitModel.fromJson(response);
      if (_applicationSubmitModel?.success == true) {
        await AppPreference.clearDraftDataKeepSession();
      }
    } catch (e, stackTrace) {
      log(
        "❌ Save Personal Details error occurred",
        error: e,
        stackTrace: stackTrace,
      );
      _applicationSubmitModel = ApplicationSubmitModel(
        success: false,
        message: e.toString(),
      );
    }
    _isVerifying = false;
    notifyListeners();
  }

  void updateProductDetails(String value) {
    _productDetails = value;
    notifyListeners();
  }

  void updatePersonalDetails(String value) {
    _personalDetails = value;
    notifyListeners();
  }

  void updateCorporateDetails(String value) {
    _corporateDetails = value;
    notifyListeners();
  }

  void toggleProductSection() {
    _isProductExpanded = !_isProductExpanded;
    notifyListeners();
  }

  // Form values
  String productCode = '';
  String productCategory = '';
  String cardNumber = '';
  String proxyNumber = '';
}
