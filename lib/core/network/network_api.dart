class NetworkApi {
  static const String appVersion = "1.0.0";

  static const String mainUrl = "https://icicuat.bizipac.com";

  ///Auth endpoints
  static const String baseUrl = "$mainUrl/icici_bizipac/apinew/bizipac_kyc/api/v1";

  ///Login
  static const String agentLogin = "$baseUrl/auth/login.php";
  static const String sendLoginOtp = "$baseUrl/auth/send_login_otp.php";
  static const String verifyLoginOtp = "$baseUrl/auth/verify_login_otp.php";

  ///Forgot Password
  static const String forgotPassword = "$baseUrl/auth/forgot_password.php";
  static const String otpVerify = "$baseUrl/auth/verify_otp.php";
  static const String resetPassword = "$baseUrl/auth/reset_password.php";

  ///Dashboard
  static const String createApplication = "$baseUrl/kyc/create_application.php";
  static const String locationCapture = "$baseUrl/kyc/location_capture.php";
  static const String kycSummaryToday = "$baseUrl/kyc/kyc_summary.php?date=today";

  ///Home Screen
  static const String homeScreen = "$baseUrl/kyc/get_kyc_types.php";

  ///Aadhaar Authentication
  static const String aadhaarEntry = "$baseUrl/kyc/aadhaar_entry.php";
  static const String aadhaarOtpVerify = "$baseUrl/kyc/aadhar_otp_verify.php";

  ///Biometric Capture
  static const String biometricCapture = "$baseUrl/kyc/abkyc_request.php?log=true";
  static const String continueKycDialog = "$baseUrl/kyc/continue_kyc_dialog.php";

  ///Get Master Data (Products)
  static const String getMasterData = "$baseUrl/kyc/get_master_data.php";
  static const String productMaster = "$baseUrl/kyc/product_master.php";

  ///Product Validation
  static const String productValidation = "$baseUrl/kyc/product_validation.php";

  ///PAN Validation
  static const String panValidate = "$baseUrl/kyc/pan_validate.php";

  ///Get Corporate Master
  static const String corporateMaster = "$baseUrl/kyc/corporate_master.php";

  ///Save product & personal section Details
  static const String saveClientKycData = "$baseUrl/kyc/save_client_kyc_data.php";
  static const String savePersonalDetails = "$baseUrl/kyc/save_personal_details.php";
  static const String saveAddressDetails = "$baseUrl/kyc/save_address_details.php";
  static const String getPersonalDetails = "$baseUrl/kyc/get_personal_details.php";

  ///Save corporate section Details
  static const String saveCorporateDetails = "$baseUrl/kyc/save_corporate_details.php";

  /// Final KYC Submit
  static const String submitKycApplication = "$baseUrl/kyc/submit_application.php";

  /// Find Current Status
  static const String fetchApplicationStatus = "$baseUrl/kyc/fetch_application_status.php";
  static const String getStatus = "$baseUrl/kyc/get_status.php";
  static const String cancelApplication = "$baseUrl/kyc/cancel_application.php";


}
