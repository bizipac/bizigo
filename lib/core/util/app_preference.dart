import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AppPreference {
  static const String loginStatus = "login_status";
  static const String accessToken = "access_token";
  static const String refreshToken = "refresh_token";
  static const String selectedProductCode = "selected_product_code";
  static const String agentInfo = "agent_info";
  static const String keyType = 'kyc_type';
  static const String applicationID = 'application_id';
  static const String leadID = 'lead_id';
  static const String aadhaarCardNo = 'aadhaar_card_no';
  static const String aadhaarResponse = 'aadhaar_response';

  static late final SharedPreferences prefsInstance;

  // call this method from iniState() function of mainApp().
  static Future<SharedPreferences> init() async {
    prefsInstance = await SharedPreferences.getInstance();
    return prefsInstance;
  }

  static Future<void> clearPef() async {
    await prefsInstance.clear();
  }

  static Future<void> clearDraftDataKeepSession() async {
    await prefsInstance.remove(selectedProductCode);
    await prefsInstance.remove(keyType);
    await prefsInstance.remove(applicationID);
    await prefsInstance.remove(leadID);
    await prefsInstance.remove(aadhaarCardNo);
    await prefsInstance.remove(aadhaarResponse);
  }

  // Login status
  static bool getLoginStatus() {
    return prefsInstance.getBool(loginStatus) ?? false;
  }

  static Future<bool> setLoginStatus(bool value) async {
    return prefsInstance.setBool(loginStatus, value);
  }

  // Access token
  static String? getAccessToken() {
    return prefsInstance.getString(accessToken);
  }

  static Future<bool> setAccessToken(String value) async {
    return prefsInstance.setString(accessToken, value);
  }

  // Refresh token
  static String? getRefreshToken() {
    return prefsInstance.getString(refreshToken);
  }

  static Future<bool> setRefreshToken(String value) async {
    return prefsInstance.setString(refreshToken, value);
  }
  // set Product code
  static String? getProductCode() {
    return prefsInstance.getString(selectedProductCode);
  }

  static Future<bool> setProductCode(String value) async {
    return prefsInstance.setString(selectedProductCode, value);
  }

  // Agent info (store as JSON string)
  static Map<String, dynamic>? getAgentInfo() {
    final jsonString = prefsInstance.getString(agentInfo);
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  static Future<bool> setAgentInfo(Map<String, dynamic> agentData) async {
    final jsonString = jsonEncode(agentData);
    return prefsInstance.setString(agentInfo, jsonString);
  }


  // Kyc Type
  static String? getKycType() {
    return prefsInstance.getString(keyType);
  }

  static Future<bool> setKycType(String value) async {
    return prefsInstance.setString(keyType, value);
  }
  // Application ID
  static String? getApplicationID() {
    return prefsInstance.getString(applicationID);
  }

  static Future<bool> setApplicationID(String value) async {
    return prefsInstance.setString(applicationID, value);
  }
  // Lead ID
  static String? getLeadID() {
    return prefsInstance.getString(leadID);
  }

  static Future<bool> setLeadID(String value) async {
    return prefsInstance.setString(leadID, value);
  }
  // Application ID
  static String? getAadhaarCardNo() {
    return prefsInstance.getString(aadhaarCardNo);
  }

  static Future<bool> setAadhaarCardNo(String value) async {
    return prefsInstance.setString(aadhaarCardNo, value);
  }


  /// Storing Addhar data
  static Future<void> saveAadhaarData(Map<String, dynamic> ekycData) async {
    await prefsInstance.setString(
      aadhaarResponse,
      jsonEncode(ekycData),
    );
  }

  ///Retrving Adhaar Data
  static Future<Map<String, dynamic>?> getAadhaarData() async {
    final jsonString = prefsInstance.getString(aadhaarResponse);

    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  //Written by -Shubham Gupta
  static const String mobileNumberKey = "mobile_number";

  static Future<void> setMobileNumber(String mobile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(mobileNumberKey, mobile);
  }

  static Future<String> getMobileNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(mobileNumberKey) ?? "";
  }
}
