import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:icici_bank/core/network/api_client.dart';

import '../../core/models/biometric_models/corporate_master_model.dart';
import '../../core/network/network_api.dart';

class CorporateDetailsProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  // Text fields
  final TextEditingController corporateName = TextEditingController();
  final TextEditingController corporateId = TextEditingController();
  final TextEditingController officeAddress = TextEditingController();
  final TextEditingController officeAddress2 = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController state = TextEditingController();
  final TextEditingController district = TextEditingController();
  final TextEditingController landmark = TextEditingController();
  // final TextEditingController phone = TextEditingController();
  // final TextEditingController mobile = TextEditingController();
  final TextEditingController relationshipNumber = TextEditingController();
  final TextEditingController accountType = TextEditingController();
  final TextEditingController relationshipType = TextEditingController();
  final TextEditingController bankAccountNumber = TextEditingController();
  final TextEditingController ifscCode = TextEditingController();
  final TextEditingController iciciAccountNumber = TextEditingController();
  final TextEditingController country = TextEditingController();
  final TextEditingController pincode = TextEditingController();
  final TextEditingController additionalDetails = TextEditingController();
  final TextEditingController transactionController = TextEditingController();

  bool payWithQR = false;
  bool isICICCustomer = false;
  bool declaration = false;
  bool greenPinChecked = false;

  String otp = "";

  bool _isLoading = false;

  bool get isLoading => _isLoading;
  String? errorMessage;

  // Field Errors
  String? corporateNameError;
  String? corporateIdError;
  String? officeAddressError;
  String? officeAddressError2;
  String? cityError;
  String? stateError;
  String? districtError;
  String? landmarkError;
  // String? phoneError;
  // String? mobileError;
  String? relationshipNumberError;
  String? relationshipTypeError;
  String? bankAccountNumberError;
  String? ifscCodeError;
  String? iciciAccountNumberError;
  String? accountTypeError;
  String? countryError;
  String? pincodeError;
  String? transactionError;
  String? declarationError;
  String? selectedName;
  String? nameError;

  CorporateMasterModel? _corporateMasterModel;

  CorporateMasterModel? get corporateMasterModel => _corporateMasterModel;

  /// corporate data fetch
  Future<CorporateMasterModel> fetchCorporateData() async {
    _setLoading(true);
    try {
      final response = await _apiClient.get(NetworkApi.corporateMaster);
      log('Response 82:: $response');

      final corporateModel = CorporateMasterModel.fromJson(response);
      log('Response 85:: $corporateModel');
      _corporateMasterModel = corporateModel;
      notifyListeners();
      return corporateModel;
    } catch (e, stackTrace) {
      log(e.toString(), error: stackTrace);

      _corporateMasterModel = CorporateMasterModel(success: false, data: []);

      notifyListeners();
      return _corporateMasterModel!;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  /// 🔹 Get unique corporate Name
  List<String> get corporateDataList {
    if (_corporateMasterModel == null) return [];
    return _corporateMasterModel!.data.map((e) => e.name).toSet().toList();
  }

  void toggleICICCustomer(bool value) {
    isICICCustomer = value;

    if (!value) {
      bankAccountNumber.clear();
      ifscCode.clear();
      iciciAccountNumber.clear();

      bankAccountNumberError = null;
      ifscCodeError = null;
      iciciAccountNumberError = null;
      accountTypeError = null;
    }

    notifyListeners();
  }

  void toggleDeclaration(bool? value) {
    declaration = value ?? false;
    notifyListeners();
  }

  void togglePayWithQR(bool value) {
    payWithQR = value;
    notifyListeners();
  }

  void toggleGreenPin(bool value) {
    greenPinChecked = value;
    notifyListeners();
  }

  void generateOtp() {
    otp = "1234"; // mock OTP
    notifyListeners();
  }

  bool isCorporateFormFilled() {
    return corporateName.text.trim().isNotEmpty &&
        corporateId.text.trim().isNotEmpty &&
        officeAddress.text.trim().isNotEmpty &&
        officeAddress2.text.trim().isNotEmpty &&
        city.text.trim().isNotEmpty &&
        state.text.trim().isNotEmpty &&
        pincode.text.trim().isNotEmpty;
  }

  /// validate form
  // bool validateCorporateForm() {
  //   // reset all errors
  //   corporateNameError = null;
  //   corporateIdError = null;
  //   officeAddressError = null;
  //   officeAddressError2 = null;
  //   cityError = null;
  //   stateError = null;
  //   districtError = null;
  //   landmarkError = null;
  //   countryError = null;
  //   phoneError = null;
  //   mobileError = null;
  //   relationshipNumberError = null;
  //   relationshipTypeError = null;
  //   bankAccountNumberError = null;
  //   ifscCodeError = null;
  //   iciciAccountNumberError = null;
  //   pincodeError = null;
  //   transactionError = null;
  //   declarationError = null;
  //   nameError = null;
  //
  //   bool isValid = true;
  //   // bool isICICCustomer = this.isICICCustomer ;
  //
  //   if (corporateName.text.trim().isEmpty) {
  //     corporateNameError = "Corporate name is required";
  //     isValid = false;
  //   }
  //
  //   if (selectedName == null || selectedName!.isEmpty) {
  //     nameError = "Please select corporate name";
  //     isValid = false;
  //   }
  //
  //   if (corporateId.text.trim().isEmpty) {
  //     corporateIdError = "Corporate ID is required";
  //     isValid = false;
  //   }
  //
  //   if (officeAddress.text.trim().isEmpty) {
  //     officeAddressError = "Office address is required";
  //     isValid = false;
  //   }
  //
  //   if (officeAddress2.text.trim().isEmpty) {
  //     officeAddressError2 = "Office address is required";
  //     isValid = false;
  //   }
  //
  //   if (city.text.trim().isEmpty) {
  //     cityError = "City is required";
  //     isValid = false;
  //   }
  //
  //   if (state.text.trim().isEmpty) {
  //     stateError = "State is required";
  //     isValid = false;
  //   }
  //
  //   if (country.text.trim().isEmpty) {
  //     countryError = "Country is required";
  //     isValid = false;
  //   }
  //
  //   if (district.text.trim().isEmpty) {
  //     districtError = "District is required";
  //     isValid = false;
  //   }
  //
  //   if (landmark.text.trim().isEmpty) {
  //     landmarkError = "Landmark is required";
  //     isValid = false;
  //   }
  //
  //   if (phone.text.trim().isEmpty) {
  //     phoneError = "Phone is required";
  //     isValid = false;
  //   }
  //
  //   if (mobile.text.trim().isEmpty) {
  //     mobileError = "Mobile is required";
  //     isValid = false;
  //   }
  //
  //   if (relationshipNumber.text.trim().isEmpty) {
  //     relationshipNumberError = "Relationship number is required";
  //     isValid = false;
  //   }
  //
  //   // final relation = relationshipType.text.trim().toUpperCase();
  //   //
  //   // if (relation.isEmpty) {
  //   //   relationshipTypeError = "Relationship type is required";
  //   //   isValid = false;
  //   // } else if (relation != "EXISTING_CUSTOMER" &&
  //   //     relation != "NEW_CUSTOMER") {
  //   //   relationshipTypeError =
  //   //   "Relationship type must be EXISTING_CUSTOMER or NEW_CUSTOMER";
  //   //   isValid = false;
  //   // }
  //   //
  //   // if (relation == "EXISTING_CUSTOMER") {
  //   //   final accNo = bankAccountNumber.text.trim();
  //   //
  //   //   if (accNo.isEmpty) {
  //   //     bankAccountNumberError =
  //   //     "Bank account number required for existing customer";
  //   //     isValid = false;
  //   //   } else if (!RegExp(r'^[0-9]{9,18}$').hasMatch(accNo)) {
  //   //     bankAccountNumberError =
  //   //     "Enter valid bank account number (9-18 digits)";
  //   //     isValid = false;
  //   //   }
  //   // }
  //
  //   // 🔹 Validate only if checkbox is selected
  //   if (isICICCustomer) {
  //     final accNo = bankAccountNumber.text.trim();
  //
  //     if (accNo.isEmpty) {
  //       bankAccountNumberError = "Bank account number is required";
  //       isValid = false;
  //     } else if (!RegExp(r'^[0-9]{9,18}$').hasMatch(accNo)) {
  //       bankAccountNumberError = "Enter valid bank account number (9-18 digits)";
  //       isValid = false;
  //     }
  //
  //     final ifsc = ifscCode.text.trim().toUpperCase();
  //
  //     if (ifsc.isEmpty) {
  //       ifscCodeError = "IFSC code is required";
  //       isValid = false;
  //     } else if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(ifsc)) {
  //       ifscCodeError = "Enter valid IFSC code (e.g. ICIC0001234)";
  //       isValid = false;
  //     }
  //
  //     if (iciciAccountNumber.text.trim().isEmpty) {
  //       iciciAccountNumberError = "ICICI account number is required";
  //       isValid = false;
  //     }
  //   }
  //
  //   // final ifsc = ifscCode.text.trim().toUpperCase();
  //   //
  //   // if (ifsc.isEmpty) {
  //   //   ifscCodeError = "IFSC code is required";
  //   //   isValid = false;
  //   // } else if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(ifsc)) {
  //   //   ifscCodeError = "Enter valid IFSC code (e.g. ICIC0001234)";
  //   //   isValid = false;
  //   // }
  //   //
  //   // if(iciciAccountNumber.text.trim().isEmpty) {
  //   //   iciciAccountNumberError = "ICICI account number is required";
  //   //   isValid = false;
  //   // }
  //
  //   final pin = pincode.text.trim();
  //
  //   if (pin.isEmpty) {
  //     pincodeError = "Pincode is required";
  //     isValid = false;
  //   } else if (!RegExp(r'^[0-9]{6}$').hasMatch(pin)) {
  //     pincodeError = "Enter valid 6 digit pincode";
  //     isValid = false;
  //   }
  //
  //   if (payWithQR && transactionController.text.trim().isEmpty) {
  //     transactionError = "Transaction number required";
  //     isValid = false;
  //   }
  //
  //   if (!declaration) {
  //     declarationError = "Please accept declaration";
  //     isValid = false;
  //   }
  //
  //   notifyListeners();
  //   return isValid;
  // }
  bool validateCorporateForm() {
    log("🏢 ================= CORPORATE VALIDATION START =================");

    corporateIdError = null;
    officeAddressError = null;
    officeAddressError2 = null;
    cityError = null;
    stateError = null;
    districtError = null;
    landmarkError = null;
    // phoneError = null;
    // mobileError = null;
    relationshipNumberError = null;
    bankAccountNumberError = null;
    ifscCodeError = null;
    iciciAccountNumberError = null;
    accountTypeError = null;
    pincodeError = null;
    nameError = null;

    bool isValid = true;

    /// 🔍 PRINT ALL INPUT VALUES
    log("📥 INPUT DATA ↓↓↓");
    log("👤 Name → $selectedName");
    log("🆔 Corporate ID → ${corporateId.text}");
    log("🏢 Address1 → ${officeAddress.text}");
    log("🏢 Address2 → ${officeAddress2.text}");
    log("🌆 City → ${city.text}");
    log("🗺 State → ${state.text}");
    log("📍 District → ${district.text}");
    log("📌 Landmark → ${landmark.text}");
    // log("☎️ Phone → ${phone.text}");
    // log("📱 Mobile → ${mobile.text}");
    log("📮 Pincode → ${pincode.text}");
    log("🏦 Bank Acc → ${bankAccountNumber.text}");
    log("🔢 IFSC → ${ifscCode.text}");
    log("🏧 ICICI Acc → ${iciciAccountNumber.text}");
    log("📂 Acc Type → ${accountType.text}");
    log("🏦 Is ICICI Customer → $isICICCustomer");

    /// Employer
    if (selectedName == null || selectedName!.trim().isEmpty) {
      log("❌ Name validation failed");
      nameError = "Please select corporate name";
      isValid = false;
    }

    /// Corporate ID
    if (corporateId.text.trim().isEmpty) {
      log("❌ Corporate ID missing");
      corporateIdError = "Corporate ID is required";
      isValid = false;
    }

    /// Address
    if (officeAddress.text.trim().isEmpty) {
      log("❌ Address1 missing");
      officeAddressError = "Office address is required";
      isValid = false;
    }

    if (officeAddress2.text.trim().isEmpty) {
      log("❌ Address2 missing");
      officeAddressError2 = "Office address is required";
      isValid = false;
    }

    /// City
    if (city.text.trim().isEmpty) {
      log("❌ City missing");
      cityError = "City is required";
      isValid = false;
    }

    /// State
    if (state.text.trim().isEmpty) {
      log("❌ State missing");
      stateError = "State is required";
      isValid = false;
    }

    /// District
    if (district.text.trim().isEmpty) {
      log("❌ District missing");
      districtError = "District is required";
      isValid = false;
    }

    /// Landmark
    if (landmark.text.trim().isEmpty) {
      log("❌ Landmark missing");
      landmarkError = "Landmark is required";
      isValid = false;
    }

    /// Phone
    // final phoneValue = phone.text.trim();
    // if (phoneValue.isEmpty) {
    //   log("❌ Phone missing");
    //   phoneError = "Employer phone is required";
    //   isValid = false;
    // } else if (!RegExp(r'^[0-9]+$').hasMatch(phoneValue)) {
    //   log("❌ Phone invalid format");
    //   phoneError = "Only digits allowed";
    //   isValid = false;
    // } else if (phoneValue.length < 11 || phoneValue.length > 15) {
    //   log("❌ Phone invalid length");
    //   phoneError = "Enter valid phone with STD code (11–15 digits)";
    //   isValid = false;
    // }

    /// Mobile
    // if (!RegExp(r'^[0-9]{10}$').hasMatch(mobile.text.trim())) {
    //   log("❌ Mobile invalid");
    //   mobileError = "Enter valid mobile number";
    //   isValid = false;
    // }

    /// Pincode
    if (!RegExp(r'^[0-9]{6}$').hasMatch(pincode.text.trim())) {
      log("❌ Pincode invalid");
      pincodeError = "Enter valid 6 digit pincode";
      isValid = false;
    }

    /// ================= ICICI VALIDATION =================
    final accNo = bankAccountNumber.text.trim();
    final ifsc = ifscCode.text.trim().toUpperCase();
    final iciciAcc = iciciAccountNumber.text.trim();
    final iciciAccType = accountType.text.trim();

    if (isICICCustomer) {
      log("🏦 ICICI CUSTOMER FLOW START");

      /// Account Number
      if (accNo.isEmpty) {
        log("❌ Bank Account missing");
        bankAccountNumberError = "Bank account number required";
        isValid = false;
      } else if (!RegExp(r'^[0-9]{9,18}$').hasMatch(accNo)) {
        log("❌ Bank Account invalid");
        bankAccountNumberError =
        "Enter valid account number (9–18 digits)";
        isValid = false;
      }

      /// IFSC
      if (ifsc.isEmpty) {
        log("❌ IFSC missing");
        ifscCodeError = "IFSC code required";
        isValid = false;
      } else if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(ifsc)) {
        log("❌ IFSC invalid");
        ifscCodeError = "Enter valid IFSC (e.g. ICIC0001234)";
        isValid = false;
      }

      /// ICICI Account
      if (iciciAcc.isEmpty) {
        log("❌ ICICI Account missing");
        iciciAccountNumberError = "ICICI account number required";
        isValid = false;
      } else if (!RegExp(r'^[0-9]{10,12}$').hasMatch(iciciAcc)) {
        log("❌ ICICI Account invalid");
        iciciAccountNumberError =
        "Enter valid ICICI account number (10–12 digits)";
        isValid = false;
      }

      /// Account Type
      if (iciciAccType.isEmpty) {
        log("❌ Account type missing");
        accountTypeError = "Account type required";
        isValid = false;
      }
    } else {
      log("ℹ️ Non-ICICI Customer → Skipping ICICI validation");
    }

    /// FINAL RESULT
    log("📊 FINAL VALIDATION RESULT → $isValid");

    if (!isValid) {
      log("❌ ================= VALIDATION FAILED =================");
    } else {
      log("✅ ================= VALIDATION SUCCESS =================");
    }

    notifyListeners();
    return isValid;
  }
  // bool validateCorporateForm() {
  //   corporateIdError = null;
  //   officeAddressError = null;
  //   officeAddressError2 = null;
  //   cityError = null;
  //   stateError = null;
  //   districtError = null;
  //   landmarkError = null;
  //   phoneError = null;
  //   mobileError = null;
  //   relationshipNumberError = null;
  //   bankAccountNumberError = null;
  //   ifscCodeError = null;
  //   iciciAccountNumberError = null;
  //   accountTypeError=null;
  //   pincodeError = null;
  //   nameError = null;
  //
  //   bool isValid = true;
  //
  //   /// Employer
  //   if (selectedName == null || selectedName!.trim().isEmpty) {
  //     nameError = "Please select corporate name";
  //     isValid = false;
  //   }
  //
  //   /// Corporate ID
  //   if (corporateId.text.trim().isEmpty) {
  //     corporateIdError = "Corporate ID is required";
  //     isValid = false;
  //   }
  //
  //   /// Address
  //   if (officeAddress.text.trim().isEmpty) {
  //     officeAddressError = "Office address is required";
  //     isValid = false;
  //   }
  //
  //   if (officeAddress2.text.trim().isEmpty) {
  //     officeAddressError2 = "Office address is required";
  //     isValid = false;
  //   }
  //
  //   /// City
  //   if (city.text.trim().isEmpty) {
  //     cityError = "City is required";
  //     isValid = false;
  //   }
  //
  //   /// State
  //   if (state.text.trim().isEmpty) {
  //     stateError = "State is required";
  //     isValid = false;
  //   }
  //
  //   /// District
  //   if (district.text.trim().isEmpty) {
  //     districtError = "District is required";
  //     isValid = false;
  //   }
  //
  //   /// Landmark
  //   if (landmark.text.trim().isEmpty) {
  //     landmarkError = "Landmark is required";
  //     isValid = false;
  //   }
  //
  //   /// Employer Phone (STD + number, 11–15 digits)
  //   final phoneValue = phone.text.trim();
  //   if (phoneValue.isEmpty) {
  //     phoneError = "Employer phone is required";
  //     isValid = false;
  //   } else if (!RegExp(r'^[0-9]+$').hasMatch(phoneValue)) {
  //     phoneError = "Only digits allowed";
  //     isValid = false;
  //   } else if (phoneValue.length < 11 || phoneValue.length > 15) {
  //     phoneError = "Enter valid phone with STD code (11–15 digits)";
  //     isValid = false;
  //   }
  //
  //   /// Mobile
  //   if (!RegExp(r'^[0-9]{10}$').hasMatch(mobile.text.trim())) {
  //     mobileError = "Enter valid mobile number";
  //     isValid = false;
  //   }
  //
  //   // /// Relationship number
  //   // if (relationshipNumber.text.trim().isEmpty) {
  //   //   relationshipNumberError = "Relationship number required";
  //   //   isValid = false;
  //   // }
  //
  //   /// Pincode
  //   if (!RegExp(r'^[0-9]{6}$').hasMatch(pincode.text.trim())) {
  //     pincodeError = "Enter valid 6 digit pincode";
  //     isValid = false;
  //   }
  //
  //   /// ICICI customer validation
  //   final accNo = bankAccountNumber.text.trim();
  //   final ifsc = ifscCode.text.trim().toUpperCase();
  //   final iciciAcc = iciciAccountNumber.text.trim();
  //   final iciciAccType = accountType.text.trim();
  //
  //   if (isICICCustomer) {
  //     ///bank account number
  //     // if (bankAccountNumber.text.trim().isEmpty) {
  //     //   bankAccountNumberError = "Bank account number required";
  //     //   isValid = false;
  //     // }
  //     if (accNo.isEmpty) {
  //       bankAccountNumberError = "Bank account number required";
  //       isValid = false;
  //     } else if (!RegExp(r'^[0-9]{9,18}$').hasMatch(accNo)) {
  //       bankAccountNumberError = "Enter valid account number (9–18 digits)";
  //       isValid = false;
  //     }
  //
  //     ///ifsc code
  //       if (ifsc.isEmpty) {
  //         ifscCodeError = "IFSC code required";
  //         isValid = false;
  //       } else if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(ifsc)) {
  //         ifscCodeError = "Enter valid IFSC (e.g. ICIC0001234)";
  //         isValid = false;
  //       }
  //
  //     ///icici account number
  //     // if (iciciAccountNumber.text.trim().isEmpty) {
  //     //   iciciAccountNumberError = "ICICI account number required";
  //     //   isValid = false;
  //     // }
  //     if (iciciAcc.isEmpty) {
  //       iciciAccountNumberError = "ICICI account number required";
  //       isValid = false;
  //     } else if (!RegExp(r'^[0-9]{10,12}$').hasMatch(iciciAcc)) {
  //       iciciAccountNumberError =
  //       "Enter valid ICICI account number (10–12 digits)";
  //       isValid = false;
  //     }
  //
  //     /// Relationship account type
  //     if (iciciAccType.isEmpty) {
  //       accountTypeError = "Account type required";
  //       isValid = false;
  //     }
  //
  //
  //   }
  //
  //   notifyListeners();
  //   return isValid;
  // }

  void submitForm() {
    debugPrint("Corporate Name: ${corporateName.text}");
    debugPrint("Corporate ID: ${corporateId.text}");
    debugPrint("Office Address: ${officeAddress.text}");
    debugPrint("Office Address2: ${officeAddress2.text}");
    debugPrint("City: ${city.text}");
    debugPrint("State: ${state.text}");
    debugPrint("District: ${district.text}");
    // debugPrint("Phone: ${phone.text}");
    // debugPrint("Mobile: ${mobile.text}");
    debugPrint("Landmark: ${landmark.text}");
    debugPrint("Country: ${country.text}");
    debugPrint("Relationship Number: ${relationshipNumber.text}");
    debugPrint("Account Type: ${accountType.text}");
    debugPrint("Relationship Type: ${relationshipType.text}");
    debugPrint("Bank Account Number: ${bankAccountNumber.text}");
    debugPrint("IFSC Code: ${ifscCode.text}");
    debugPrint("ICICI Account Number: ${iciciAccountNumber.text}");
    debugPrint("Pincode: ${pincode.text}");
    debugPrint("Additional Details: ${additionalDetails.text}");
    debugPrint("ICIC Customer: $isICICCustomer");
    debugPrint("Green Pin Checked: $greenPinChecked");
    debugPrint("OTP: $otp");
  }

  // Map<String, dynamic> buildCorporatePayload() {
  //   return {
  //     "EMPLOYER": corporateName.text.trim(),
  //     "CORPRATE_ID": corporateId.text.trim(),
  //     "EMPL_ADDRESS1": officeAddress.text.trim(),
  //     "EMPL_ADDRESS2": officeAddress2.text.trim(),
  //     "EMPL_CITY": city.text.trim(),
  //     "EMPL_STATE": state.text.trim(),
  //     "EMPLOYER_DISTRICT": district.text.trim(),
  //     "EMPLOYER_LANDMARK": landmark.text.trim(),
  //     "EMPLOYER_COUNTRY": country.text.trim(),
  //     "EMPL_PHONE_1": phone.text.trim(),
  //     "EMPL_MOBILE": mobile.text.trim(),
  //     "ICICI_RELATIONSHIP_NUMBER": relationshipNumber.text.trim(),
  //     "ICICI_RELATIONSHIP_TYPE": isICICCustomer ? "EXISTING_CUSTOMER" : "NEW_CUSTOMER",
  //     "BANK_ACCOUNT_NUMBER": bankAccountNumber.text.trim(),
  //     "IFSC_CODE": ifscCode.text.trim(),
  //     "ICICI_ACCOUNT_NUMBER": iciciAccountNumber.text.trim(),
  //     "EMPL_ZIP": pincode.text.trim(),
  //     "EMPL_COUNTRY": "INDIA",
  //   };
  // }
  Map<String, dynamic> buildCorporatePayload() {
    final isExisting = isICICCustomer;

    return {
      "EMPLOYER": selectedName ?? corporateName.text.trim(),
      "CORPRATE_ID": corporateId.text.trim(),

      "EMPL_ADDRESS1": officeAddress.text.trim(),
      "EMPL_ADDRESS2": officeAddress2.text.trim(),
      "EMPL_CITY": city.text.trim(),
      "EMPL_STATE": state.text.trim(),
      "EMPL_ZIP": pincode.text.trim(),

      "EMPLOYER_DISTRICT": district.text.trim(),
      "EMPLOYER_LANDMARK": landmark.text.trim(),

      "EMPL_COUNTRY": country.text.trim().isEmpty
          ? "INDIA"
          : country.text.trim(),

      // "EMPL_PHONE_1": phone.text.trim(),
      // "EMPL_MOBILE": mobile.text.trim(),

      /// ⭐ BOTH VALUES
      "existing_icici_customer": isExisting ? "Y" : "N",
      "ICICI_RELATIONSHIP_TYPE": isExisting
          ? "EXISTING_CUSTOMER"
          : "NEW_CUSTOMER",

      "ICICI_RELATIONSHIP_NUMBER": relationshipNumber.text.trim(),

      /// Bank details
      "BANK_ACCOUNT_NUMBER": isExisting ? bankAccountNumber.text.trim() : "",
      "IFSC_CODE": isExisting ? ifscCode.text.trim().toUpperCase() : "",
      "ICICI_ACCOUNT_NUMBER": isExisting ? iciciAccountNumber.text.trim() : "",
    };
  }

  // SUBMIT CORPORATE KYC
  Future<bool> submitCorporateKyc(String applicationId) async {
    _isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final payload = {
        "application_id": applicationId,
        "kyc_type": "corporate",
        "corporate_data": buildCorporatePayload(),
      };

      debugPrint("📤 Corporate KYC Payload: $payload");

      final response = await _apiClient.post(
        NetworkApi.saveClientKycData,
        payload,
      );

      debugPrint("📥 Corporate KYC Response: $response");

      if (response["success"] == true) {
        return true;
      } else {
        errorMessage = response["message"] ?? "Corporate KYC submission failed";
        return false;
      }
    } catch (e) {
      debugPrint("❌ Corporate KYC Error: $e");
      errorMessage = "Something went wrong";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectName(String name) {
    selectedName = name;
    nameError = null;
    if (_corporateMasterModel != null) {
      final selectedCorp = _corporateMasterModel!.data.firstWhere(
        (e) => e.name == name,
        orElse: () => _corporateMasterModel!.data.first,
      );
      corporateId.text = selectedCorp.corpId ?? "";
    }
    notifyListeners();
  }

  @override
  void dispose() {
    corporateName.dispose();
    corporateId.dispose();
    officeAddress.dispose();
    officeAddress2.dispose();
    city.dispose();
    state.dispose();
    district.dispose();
    // phone.dispose();
    // mobile.dispose();
    relationshipNumber.dispose();
    accountType.dispose();
    relationshipType.dispose();
    bankAccountNumber.dispose();
    ifscCode.dispose();
    iciciAccountNumber.dispose();
    landmark.dispose();
    country.dispose();
    pincode.dispose();
    additionalDetails.dispose();
    transactionController.dispose();
    super.dispose();
  }
}
