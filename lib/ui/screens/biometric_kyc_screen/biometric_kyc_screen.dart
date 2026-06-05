import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:icici_bank/ui/screens/pan_card_screen/pan_card_detail_screen.dart';
import 'package:icici_bank/ui/screens/product_screen/product_details_screen.dart';
import 'package:icici_bank/ui/widgets/custom_toast_message.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/util/app_preference.dart';
import '../../../providers/aadhaar_verification_provider/aadhaar_kyc_provider.dart';
import '../../../providers/biometric_kyc_provider/biometric_kyc_provider.dart';
import '../../../providers/corporate_provider/corporate_details_provider.dart';
import '../../../providers/pan_card_provider/pan_card_details_provider.dart';
import '../../../providers/personal_provider/personal_kyc_provider.dart';
import '../../../providers/product_provider/product_provider.dart';
import '../../widgets/custom_expansion_tile.dart';
import '../../widgets/custom_text_widget.dart';
import '../corporate_screen/corporate_details_screen.dart';
import '../home_screen/home_screen.dart';
import '../personal_screen/personal_kyc_detail_screen.dart';

class BiometricKYCScreen extends StatefulWidget {
  const BiometricKYCScreen({super.key});

  @override
  State<BiometricKYCScreen> createState() => _BiometricKYCScreenState();
}

class _BiometricKYCScreenState extends State<BiometricKYCScreen> {
  final GlobalKey<PersonalKycDetailScreenState> _personalKey =
      GlobalKey<PersonalKycDetailScreenState>();
  final GlobalKey<PanCardDetailScreenState> _panCardKey =
      GlobalKey<PanCardDetailScreenState>();
  final GlobalKey<CorporateFormScreenState> _corporateKey =
      GlobalKey<CorporateFormScreenState>();

  bool _isProductExpanded = false;
  bool _isPersonalExpanded = false;
  bool _isPanCardExpanded = false;
  bool _isCorporateExpanded = false;

  String? productCodeNew = "";

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    final String applicationId = context
        .read<AadhaarKycProvider>()
        .applicationId
        .toString();
    await context.read<AadhaarKycProvider>().fetchApplicationStatus(
      applicationID: applicationId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // final productProvider = context.watch<ProductProvider>();
    final aadhaarProvider = context.watch<AadhaarKycProvider>();
    log(
      'aadhaarProvider.applicationStatus.toString().toLowerCase(): ${aadhaarProvider.applicationStatus}',
    );
    final aadhaarPro = context.read<AadhaarKycProvider>();
    log(
      'aadhaarPro.applicationStatus.toString().toLowerCase(): ${aadhaarPro.applicationStatus}',
    );
    const List<String> statusFlow = [
      'draft', // 0
      'pending_aadhaar_verification', //1
      'pending_biometric', //2
      'pending_product_validation', //3
      'product_validation_completed', //4
      'pending_personal_details', //5
      'personal_details_completed', //6
      'address_completed', //7
      'pending_pan_details', //8
      'pan_details_completed', //9
      'pending_corporate_details', //10
      'corporate_details_completed', //11
      'submitted', //12
    ];
    final String status = aadhaarProvider.applicationStatus
        .toString()
        .toLowerCase();

    int currentIndex = statusFlow.indexOf(status);
    log('currentIndex.toString()');
    log(currentIndex.toString());

    /// product
    bool showProduct =
        currentIndex > statusFlow.indexOf('pending_biometric') &&
        currentIndex < statusFlow.indexOf('product_validation_completed');
    log('showProduct.toString()');
    log(showProduct.toString());

    /// personal
    bool showPersonal =
        currentIndex >= statusFlow.indexOf('pending_personal_details') &&
        currentIndex < statusFlow.indexOf('pending_pan_details');
    log('showPersonal.toString()');
    log(showPersonal.toString());

    /// pan card
    bool showPanCard =
        currentIndex >= statusFlow.indexOf('pending_pan_details') &&
        currentIndex < statusFlow.indexOf('pending_corporate_details');
    log('showPanCard.toString()');
    log(showPanCard.toString());

    /// corporate
    bool showCorporate =
        currentIndex >= statusFlow.indexOf('pending_corporate_details');
    log('showCorporate.toString()');
    log(showCorporate.toString());

    Future<void> showSuccessDialog(BuildContext context, String ackNumber) {
      return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            insetPadding: const EdgeInsets.symmetric(horizontal: 32),
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Success Circle with Tick
                  Container(
                    height: 160,
                    width: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // color: Colors.green.withValues(alpha: 0.1),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/success.png',
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  /// Success message
                  const CustomText(
                    label:
                        "Your application has been successfully\nsubmitted and verified.",
                    textAlign: TextAlign.center,
                    color: Colors.red,
                    fontSize: 16,
                  ),
                  const SizedBox(height: 16),

                  /// Acknowledgement number
                  CustomText(
                    label: "Application acknowledgement\nNumber is $ackNumber",
                    textAlign: TextAlign.center,
                    fontSize: 14,
                  ),
                  const SizedBox(height: 28),

                  /// Okay Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B2D9C),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const CustomText(
                        label: "OKAY",
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    /// ICICI Logo
                    // Image.asset('assets/icici_logo.png'),
                    _buildLogo(size),
                    SizedBox(height: size.height * 0.02),
                    const SizedBox(height: 12),

                    ///biometric kyc
                    const Text(
                      "Biometric KYC",
                      style: TextStyle(
                        color: Colors.indigo,
                        fontSize: 20,
                        fontFamily: 'El_Messiri',
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),

                    Image.asset(
                      'assets/biometric_kyc.png',
                      height: 360,
                      width: 240,
                    ),

                    const Text(
                      "Fill your details carefully",
                      style: TextStyle(
                        color: Colors.blue,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              Visibility(
                visible: showProduct,
                child: Column(
                  children: [
                    Text(
                      'Product Details',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 5),
                    ExpandableFormSection(
                      title: "Enter Product Details",
                      initiallyExpanded: _isProductExpanded,
                      child: ProductDetailsScreen(),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),

              Visibility(
                visible: showPersonal,
                child: Column(
                  children: [
                    Text(
                      'Personal Details',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 5),
                    // ExpandableFormSection(
                    //   title: "Enter Personal Details",
                    //   initiallyExpanded: _isPersonalExpanded,
                    //   child: PersonalKycDetailScreen(key: _personalKey, status),
                    // ),
                    ExpandableFormSection(
                      title: "Enter Personal Details",
                      initiallyExpanded: _isPersonalExpanded,
                      child: PersonalKycDetailScreen(
                        key: _personalKey,
                        appStatus: status,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),

              Visibility(
                visible: showPanCard,
                child: Column(
                  children: [
                    Text(
                      'Pan Card Details',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 5),
                    ExpandableFormSection(
                      title: "Enter Pan Card Details",
                      initiallyExpanded: _isPanCardExpanded,
                      child: PanCardDetailScreen(key: _panCardKey),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),

              Visibility(
                visible: showCorporate,
                child: Column(
                  children: [
                    Text(
                      'Corporate Details',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 5),
                    ExpandableFormSection(
                      title: "Enter Corporate Details",
                      initiallyExpanded: _isCorporateExpanded,
                      child: CorporateFormScreen(key: _corporateKey),
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              ),

              // Next Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  ///===================  AI code =========================
                  // onPressed: () async {
                  //   log("🚀 KYC FLOW STARTED");
                  //
                  //   final aadhaarProvider = context.read<AadhaarKycProvider>();
                  //   final productProvider = context.read<ProductProvider>();
                  //   final biometricProvider = context.read<BiometricKycProvider>();
                  //   final personalProvider = context.read<PersonalKycProvider>();
                  //   final corporateProvider = context.read<CorporateDetailsProvider>();
                  //
                  //   final String status = aadhaarProvider.applicationStatus.toString().toLowerCase();
                  //   log('On Press Status: $status');
                  //
                  //   final String kycType = aadhaarProvider.kycType.toString().toLowerCase() == "personalized"
                  //       ? "full_kyc"
                  //       : "min_kyc";
                  //
                  //   final String applicationId = aadhaarProvider.applicationId.toString();
                  //   log('On Press Application ID: $applicationId');
                  //
                  //   final productCode = productProvider.selectedProduct?.productCode;
                  //
                  //   log('On Press Product Code: $productCode');
                  //
                  //   log("📊 STATUS → $status");
                  //   log("🆔 APPLICATION ID → $applicationId");
                  //   log("🪪 KYC TYPE → $kycType");
                  //   log("📦 PRODUCT CODE → $productCode");
                  //
                  //   try {
                  //     /// ================= STEP 1 → PRODUCT VALIDATION =================
                  //     if (status == "pending_product_validation") {
                  //       log("📦 STEP 1: PRODUCT VALIDATION STARTED");
                  //
                  //       if (productCode == null || productCode.isEmpty) {
                  //         log("❌ Product not selected");
                  //         CustomToast.error(context, "Product not selected");
                  //         return;
                  //       }
                  //
                  //       final kycTypeLocal = aadhaarProvider.kycType;
                  //
                  //       if (kycTypeLocal == null) {
                  //         log("❌ KYC type missing");
                  //         CustomToast.error(context, "KYC type missing");
                  //         return;
                  //       }
                  //
                  //       if (!productProvider.validateProductForm(kycType: kycTypeLocal)) {
                  //         log("⚠️ Product form validation failed");
                  //
                  //         setState(() => _isProductExpanded = true);
                  //
                  //         ScaffoldMessenger.of(context).showSnackBar(
                  //           const SnackBar(content: Text("Please complete Product section")),
                  //         );
                  //
                  //         return;
                  //       }
                  //
                  //       log("📡 Calling PRODUCT VALIDATION API");
                  //
                  //       await biometricProvider.validateProduct(
                  //         kycType: kycType,
                  //         applicationID: applicationId,
                  //         productCode: productCode,
                  //         cardNumber: productProvider.cardNumberController.text,
                  //         proxyNumber: productProvider.proxyNumberController.text,
                  //       );
                  //
                  //       final response = biometricProvider.productValidationModel;
                  //
                  //       log("📡 PRODUCT API RESPONSE → ${response?.toJson()}");
                  //
                  //       if (response?.success == true) {
                  //         log("✅ PRODUCT VALIDATION SUCCESS");
                  //
                  //         CustomToast.success(context, response!.message ?? "Product validated");
                  //
                  //         log("🔄 Fetching updated application status");
                  //
                  //         await context
                  //             .read<AadhaarKycProvider>()
                  //             .fetchApplicationStatus(applicationID: applicationId);
                  //
                  //         return;
                  //       } else {
                  //         log("❌ PRODUCT VALIDATION FAILED → ${response?.message}");
                  //
                  //         CustomToast.error(context, response?.message ?? "Product validation failed");
                  //         return;
                  //       }
                  //     }
                  //
                  //     /// ================= STEP 2 → PERSONAL SECTION =================
                  //     if (status == "pending_personal_details" ||
                  //         status == "personal_details_completed" ||
                  //         status == "address_completed") {
                  //
                  //       log("👤 STEP 2: PERSONAL DETAILS STARTED");
                  //
                  //       final personalState = _personalKey.currentState;
                  //       log('personalState: $personalState');
                  //
                  //       if (personalState == null || !personalState.validateAndStore(context)) {
                  //         log("⚠️ Personal section validation failed");
                  //
                  //         setState(() => _isPersonalExpanded = true);
                  //
                  //         ScaffoldMessenger.of(context).showSnackBar(
                  //           const SnackBar(content: Text("Please complete Personal section")),
                  //         );
                  //
                  //         return;
                  //       }
                  //
                  //       if (!personalProvider.validatePersonalForm()) {
                  //         log("❌ Personal form error → ${personalProvider.errorMessage}");
                  //
                  //         CustomToast.error(context, personalProvider.errorMessage!);
                  //         return;
                  //       }
                  //
                  //       final storedData = personalProvider.personalFormData;
                  //
                  //       final personalPayload = {
                  //         ...storedData,
                  //         "PRODUCT_CODE": productCode,
                  //         "IDENTIFICATION_PROOF": "ADCRD",
                  //         "IDENTIFICATION_PROOF_NUMBER": aadhaarProvider.aadhaarNumber,
                  //       };
                  //
                  //       log("📡 Saving PERSONAL DETAILS");
                  //
                  //       // log('$kycType');
                  //       // log('$applicationId');
                  //       // log('$productCode');
                  //       // log('${productCode!}');
                  //       // log('$personalPayload');
                  //       // final productCodeNew2 = AppPreference.getProductCode();
                  //       // log('productCodeNew2: $productCodeNew2');
                  //
                  //       // if(productCode!.isEmpty){
                  //         productCodeNew = AppPreference.getProductCode();
                  //         log('productCodeNew: $productCodeNew');
                  //       // }
                  //
                  //       // final productCodeNew1 = AppPreference.getProductCode();
                  //       // log('productCodeNew1: $productCodeNew1');
                  //       // log('$kycType');
                  //       // log('$applicationId');
                  //       // log('${productCode!}');
                  //       // log('${productCodeNew!}');
                  //       // log('$personalPayload');
                  //       await biometricProvider.savePersonalDetails(
                  //         kycType: kycType,
                  //         applicationID: applicationId,
                  //         productCode: productCodeNew!,
                  //         personalData: personalPayload,
                  //       );
                  //
                  //       log("📡 PERSONAL SAVE RESPONSE → ${biometricProvider.savePersonalDetailsModel?.toJson()}");
                  //
                  //       if (biometricProvider.savePersonalDetailsModel?.success != true) {
                  //         log("❌ PERSONAL SAVE FAILED");
                  //
                  //         CustomToast.error(
                  //             context,
                  //             biometricProvider.savePersonalDetailsModel?.message ??
                  //                 "Personal save failed");
                  //         return;
                  //       }
                  //
                  //       log("📡 PAN VALIDATION STARTED");
                  //
                  //       await biometricProvider.kycPanValidate(
                  //         applicationID: applicationId,
                  //         personalData: personalPayload,
                  //       );
                  //
                  //       log("📡 PAN RESPONSE → ${biometricProvider.panCardValidationModel?.toJson()}");
                  //
                  //       if (biometricProvider.panCardValidationModel?.success != true) {
                  //         log("❌ PAN VALIDATION FAILED");
                  //
                  //         CustomToast.error(
                  //             context,
                  //             biometricProvider.panCardValidationModel?.message ??
                  //                 "PAN validation failed");
                  //         return;
                  //       }
                  //
                  //       // log("📡 Saving ADDRESS DETAILS");
                  //       // if(productCode.isEmpty){
                  //       //   productCodeNew = AppPreference.getProductCode();
                  //       //   log('productCodeNew: $productCodeNew');
                  //       // }
                  //       //
                  //       // await biometricProvider.saveAddressDetails(
                  //       //   kycType: kycType,
                  //       //   applicationID: applicationId,
                  //       //   productCode: productCode.isEmpty?productCodeNew!:productCode,
                  //       //   personalData: personalPayload,
                  //       // );
                  //       //
                  //       // if (biometricProvider.savePersonalDetailsModel?.success != true) {
                  //       //   log("❌ ADDRESS SAVE FAILED");
                  //       //
                  //       //   CustomToast.error(
                  //       //       context,
                  //       //       biometricProvider.savePersonalDetailsModel?.message ??
                  //       //           "Address save failed");
                  //       //   return;
                  //       // }
                  //
                  //       log("✅ PERSONAL SECTION COMPLETED");
                  //
                  //       CustomToast.success(context, "Personal section completed");
                  //
                  //       log("🔄 Fetching updated application status");
                  //
                  //       await context
                  //           .read<AadhaarKycProvider>()
                  //           .fetchApplicationStatus(applicationID: applicationId);
                  //
                  //       return;
                  //     }
                  //
                  //     /// ================= STEP 3 → CORPORATE =================
                  //     // if (status == "pan_completed") {
                  //     if (status == "pan_completed") {
                  //       log("🏢 STEP 3: CORPORATE DETAILS STARTED");
                  //
                  //       if (!corporateProvider.validateCorporateForm()) {
                  //         log("⚠️ Corporate validation failed");
                  //
                  //         setState(() => _isCorporateExpanded = true);
                  //
                  //         ScaffoldMessenger.of(context).showSnackBar(
                  //           const SnackBar(content: Text("Please complete Corporate section")),
                  //         );
                  //
                  //         return;
                  //       }
                  //
                  //       log("📡 Saving CORPORATE DETAILS");
                  //
                  //       if(productCode!.isEmpty){
                  //         productCodeNew = AppPreference.getProductCode();
                  //         log('productCodeNew: $productCodeNew');
                  //       }
                  //
                  //
                  //       await biometricProvider.saveCorporateDetails(
                  //         kycType: kycType,
                  //         applicationID: applicationId,
                  //         productCode: productCode.isEmpty?productCodeNew!:productCode,
                  //         corporateData: corporateProvider.buildCorporatePayload(),
                  //       );
                  //
                  //       if (biometricProvider.savePersonalDetailsModel?.success != true) {
                  //         log("❌ CORPORATE SAVE FAILED");
                  //
                  //         CustomToast.error(
                  //             context,
                  //             biometricProvider.savePersonalDetailsModel?.message ??
                  //                 "Corporate save failed");
                  //         return;
                  //       }
                  //
                  //       log("📡 FINAL KYC SUBMISSION");
                  //
                  //       await biometricProvider.submitFinalKyc(
                  //         kycType: kycType,
                  //         applicationID: applicationId,
                  //       );
                  //
                  //       final finalResponse = biometricProvider.applicationSubmitModel;
                  //
                  //       log("📡 FINAL RESPONSE → ${finalResponse?.toJson()}");
                  //
                  //       if (finalResponse?.success == true) {
                  //         log("🎉 KYC SUBMITTED SUCCESSFULLY");
                  //
                  //         showSuccessDialog(
                  //             context, finalResponse!.acknowledgementNumber.toString());
                  //       } else {
                  //         log("❌ FINAL SUBMISSION FAILED");
                  //
                  //         CustomToast.error(context, finalResponse?.message ?? "Submission failed");
                  //       }
                  //     }
                  //   } catch (e) {
                  //     log("💥 KYC ERROR → $e");
                  //     CustomToast.error(context, "Something went wrong");
                  //   }
                  // },
                  onPressed: () async {
                    try {
                      log(
                        "🚀 ================== KYC FLOW STARTED ==================",
                      );

                      final aadhaarProvider = context
                          .read<AadhaarKycProvider>();
                      final productProvider = context.read<ProductProvider>();
                      final biometricProvider = context
                          .read<BiometricKycProvider>();
                      final personalProvider = context
                          .read<PersonalKycProvider>();
                      final panCardProvider = context
                          .read<PanCardDetailsProvider>();
                      final corporateProvider = context
                          .read<CorporateDetailsProvider>();

                      final String status = aadhaarProvider.applicationStatus
                          .toString()
                          .toLowerCase();

                      final String kycType =
                          aadhaarProvider.kycType.toString().toLowerCase() ==
                              "personalized"
                          ? "full_kyc"
                          : "min_kyc";

                      final String applicationId = aadhaarProvider.applicationId
                          .toString();

                      final productCode =
                          productProvider.selectedProduct?.productCode;

                      /// ================= BASIC LOGS =================
                      log("📊 STATUS → $status");
                      log("🆔 APPLICATION ID → $applicationId");
                      log("🪪 KYC TYPE → $kycType");
                      log("📦 PRODUCT CODE → $productCode");

                      /// ================= STEP 1 =================
                      if (status == "pending_product_validation") {
                        log("📦 ===== STEP 1: PRODUCT VALIDATION =====");

                        log("📥 REQUEST DATA ↓");
                        log("   👉 KYC TYPE → $kycType");
                        log("   👉 APP ID → $applicationId");
                        log("   👉 PRODUCT CODE → $productCode");
                        log(
                          "   👉 CARD → ${productProvider.cardNumberController.text}",
                        );
                        log(
                          "   👉 PROXY → ${productProvider.proxyNumberController.text}",
                        );

                        if (productCode == null || productCode.isEmpty) {
                          log("❌ Product not selected");
                          CustomToast.error(context, "Product not selected");
                          return;
                        }

                        if (!productProvider.validateProductForm(
                          kycType: aadhaarProvider.kycType!,
                        )) {
                          log("⚠️ Product validation failed");
                          setState(() => _isProductExpanded = true);
                          return;
                        }

                        log("📡 Calling PRODUCT API...");

                        await biometricProvider.validateProduct(
                          kycType: kycType,
                          applicationID: applicationId,
                          productCode: productCode,
                          cardNumber: productProvider.cardNumberController.text,
                          proxyNumber:
                              productProvider.proxyNumberController.text,
                        );

                        final response =
                            biometricProvider.productValidationModel;

                        log("📡 RESPONSE ↓");
                        log("   👉 FULL → ${response?.toJson()}");

                        if (response?.success == true) {
                          log("✅ PRODUCT SUCCESS 🎉");

                          await aadhaarProvider.fetchApplicationStatus(
                            applicationID: applicationId,
                          );
                          return;
                        } else {
                          log("❌ PRODUCT FAILED → ${response?.message}");
                          return;
                        }
                      }

                      /// ================= STEP 2 =================
                      if (status == "product_validation_completed" ||
                          status == "pending_personal_details" ||
                          status == "personal_details_completed" ||
                          status == "address_completed") {
                        log("👤 ===== STEP 2: PERSONAL DETAILS =====");

                        final personalState = _personalKey.currentState;

                        if (personalState == null ||
                            !personalState.validateAndStore(context)) {
                          log("⚠️ Personal validation failed");
                          setState(() => _isPersonalExpanded = true);
                          return;
                        }

                        if (!personalProvider.validatePersonalForm()) {
                          log(
                            "❌ Personal Error → ${personalProvider.errorMessage}",
                          );
                          return;
                        }

                        final storedData = personalProvider.personalFormData;

                        final personalPayload = {
                          ...storedData,
                          "PRODUCT_CODE": productCode,
                          "IDENTIFICATION_PROOF": "ADCRD",
                          "IDENTIFICATION_PROOF_NUMBER":
                              aadhaarProvider.aadhaarNumber,
                        };

                        final productCodeNew = productCode?.trim().isNotEmpty == true
                            ? productCode!.trim()
                            : AppPreference.getProductCode()?.trim();

                        if (productCodeNew == null || productCodeNew.isEmpty) {
                          CustomToast.error(context, "Product not selected");
                          return;
                        }

                        log("📥 PERSONAL PAYLOAD ↓");
                        log("   👉 DATA → $personalPayload");
                        log("   👉 PRODUCT CODE USED → $productCodeNew");

                        Future<bool> saveAddressOnly({
                          required Map<String, dynamic> addressPayload,
                        }) async {
                          log("📡 Calling SAVE ADDRESS API...");
                          final success = await personalProvider.saveAddressDetails(
                            applicationId: applicationId,
                            kycType: kycType,
                            addressData: addressPayload,
                          );

                          log("📡 ADDRESS RESPONSE ↓");
                          log("   👉 ${personalProvider.errorMessage ?? 'success'}");

                          if (success) {
                            return true;
                          }

                          final retry = await showDialog<bool>(
                            context: context,
                            barrierDismissible: false,
                            builder: (dialogContext) {
                              return AlertDialog(
                                title: const Text("Address save failed"),
                                content: const Text(
                                  "The personal details were saved. Retry the address save?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, true),
                                    child: const Text("Retry"),
                                  ),
                                ],
                              );
                            },
                          );

                          if (retry == true) {
                            return saveAddressOnly(
                              addressPayload: addressPayload,
                            );
                          }

                          return false;
                        }

                        log("📡 Calling SAVE PERSONAL API...");

                        await biometricProvider.savePersonalDetails(
                          kycType: kycType,
                          applicationID: applicationId,
                          productCode: productCodeNew,
                          personalData: personalPayload,
                        );

                        log("📡 PERSONAL RESPONSE ↓");
                        log(
                          "   👉 ${biometricProvider.savePersonalDetailsModel?.toJson()}",
                        );

                        if (biometricProvider
                                .savePersonalDetailsModel
                                ?.success !=
                            true) {
                          log("❌ PERSONAL SAVE FAILED");
                          return;
                        }

                        final addressPayload = personalProvider
                            .buildAddressKycData(personalPayload);
                        final addressSaved = await saveAddressOnly(
                          addressPayload: addressPayload,
                        );

                        if (!addressSaved) {
                          return;
                        }

                        log("✅ PERSONAL + ADDRESS COMPLETED 🎉");

                        await aadhaarProvider.fetchApplicationStatus(
                          applicationID: applicationId,
                        );
                        return;
                      }

                      /// ================= STEP 3 =================
                      if (status == "pending_pan_details") {
                        log("📦 ===== STEP 3: PAN VALIDATION =====");

                        final panCardState = _panCardKey.currentState;

                        if (panCardState == null ||
                            !panCardState.validateAndStore(context)) {
                          log("⚠️ Pan validation failed");
                          setState(() => _isPanCardExpanded = true);
                          return;
                        }

                        log("📡 Calling PAN API...");

                        await biometricProvider.kycPanValidate(
                          applicationID: applicationId,
                          personalData: panCardProvider.panFormData,
                        );

                        log("📡 RESPONSE ↓");
                        log(
                          "   👉 ${biometricProvider.panCardValidationModel?.toJson()}",
                        );

                        if (biometricProvider.panCardValidationModel?.success !=
                            true) {
                          log("❌ PAN FAILED");
                          CustomToast.error(
                            context,
                            biometricProvider.panCardValidationModel?.message ??
                                "PAN validation failed",
                          );
                          return;
                        }

                        /// stop here if pan data mismatch
                        final panData =
                            biometricProvider.panCardValidationModel?.data;
                        if (panData?.panVerified == false) {
                          log("❌ PAN NOT VERIFIED");

                          String errorMsg = "PAN verification failed:\n";
                          if (panData?.dobMatch == false) {
                            errorMsg += "\n Date of birth does not match\n";
                          }
                          if (panData?.nameMatch == false) {
                            errorMsg += "\n Name does not match\n";
                          }

                          CustomToast.error(context, errorMsg);
                          return;
                        }

                        log("✅ PAN COMPLETED");

                        // await aadhaarProvider.fetchApplicationStatus(
                        //   applicationID: applicationId,
                        // );

                        await Future.delayed(const Duration(seconds: 2));

                        await aadhaarProvider.fetchApplicationStatus(
                          applicationID: applicationId,
                        );

                        final updatedStatus = aadhaarProvider.applicationStatus
                            ?.toLowerCase();

                        log("UPDATED STATUS → $updatedStatus");

                        if (updatedStatus == "pan_details_completed" ||
                            updatedStatus == "pending_corporate_details") {
                          setState(() {});
                        } else {
                          CustomToast.error(
                            context,
                            "PAN verification still processing. Please click Next again.",
                          );
                        }

                        return;
                      }

                      /// ================= STEP 4 =================
                      if (status == "pending_corporate_details") {
                        log("🏢 ===== STEP 4: CORPORATE =====");

                        final corporateState = _corporateKey.currentState;

                        if (corporateState == null ||
                            !corporateState.validateCorporateForm()) {
                          log("⚠️ Corporate validation failed");

                          setState(() => _isCorporateExpanded = true);

                          return;
                        }

                        /// provider validation for error text
                        if (!corporateProvider.validateCorporateForm()) {
                          return;
                        }

                        final corporatePayload = corporateProvider
                            .buildCorporatePayload();

                        final productCodeNew = productCode?.trim().isNotEmpty == true
                            ? productCode!.trim()
                            : AppPreference.getProductCode()?.trim();

                        if (productCodeNew == null || productCodeNew.isEmpty) {
                          CustomToast.error(context, "Product not selected");
                          return;
                        }

                        log("📥 CORPORATE PAYLOAD ↓");
                        log("   👉 DATA → $corporatePayload");
                        log(
                          "   👉 PRODUCT CODE → ${productCode ?? productCodeNew}",
                        );

                        log("📡 Calling CORPORATE API...");

                        await biometricProvider.saveCorporateDetails(
                          kycType: kycType,
                          applicationID: applicationId,
                          productCode: productCodeNew,
                          corporateData: corporatePayload,
                        );

                        log("📡 CORPORATE RESPONSE ↓");
                        log(
                          "   👉 ${biometricProvider.savePersonalDetailsModel?.toJson()}",
                        );

                        if (biometricProvider
                                .savePersonalDetailsModel
                                ?.success !=
                            true) {
                          log("❌ CORPORATE FAILED");
                          return;
                        }

                        /// FINAL SUBMIT
                        log("🎯 ===== FINAL SUBMIT =====");

                        await biometricProvider.submitFinalKyc(
                          kycType: kycType,
                          applicationID: applicationId,
                        );

                        final finalResponse =
                            biometricProvider.applicationSubmitModel;

                        log("📡 FINAL RESPONSE ↓");
                        log("   👉 ${finalResponse?.toJson()}");

                        if (finalResponse?.success == true) {
                          showSuccessDialog(
                            context,
                            finalResponse!.acknowledgementNumber.toString(),
                          );
                          log("🎉🎉🎉 KYC SUCCESS 🎉🎉🎉");
                        } else {
                          CustomToast.error(
                            context,
                            finalResponse?.message ?? "Submission failed",
                          );
                          log("❌ FINAL FAILED → ${finalResponse?.message}");
                        }
                      }
                    } catch (e, stackTrace) {
                      log("💥 ERROR OCCURRED");
                      log("❗ ERROR → $e");
                      log("🧵 STACK → $stackTrace");
                    }
                  },

                  // onPressed: () async {
                  //   final aadhaarProvider = context.read<AadhaarKycProvider>();
                  //   final productProvider = context.read<ProductProvider>();
                  //   final biometricProvider = context.read<BiometricKycProvider>();
                  //   final personalProvider = context.read<PersonalKycProvider>();
                  //   final corporateProvider = context.read<CorporateDetailsProvider>();
                  //
                  //   final String status = aadhaarProvider.applicationStatus.toString().toLowerCase();
                  //
                  //   final String kycType = aadhaarProvider.kycType.toString().toLowerCase() == "personalized" ? "full_kyc" : "min_kyc";
                  //
                  //   final String applicationId = aadhaarProvider.applicationId.toString();
                  //
                  //   final productCode = productProvider.selectedProduct?.productCode;
                  //
                  //   try {
                  //     /// ================= STEP 1 → PRODUCT VALIDATION =================
                  //     if (status == "pending_biometric") {
                  //       if (productCode == null || productCode.isEmpty) {
                  //         CustomToast.error(context, "Product not selected");
                  //         return;
                  //       }
                  //       final kycTypeLocal = aadhaarProvider.kycType;
                  //
                  //       if (kycTypeLocal == null) {
                  //         CustomToast.error(context, "KYC type missing");
                  //         return;
                  //       }
                  //
                  //       if (!productProvider.validateProductForm(kycType: kycTypeLocal)) {
                  //         setState(() => _isProductExpanded = true);
                  //
                  //         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please complete Product section")));
                  //
                  //         return;
                  //       }
                  //
                  //       await biometricProvider.validateProduct(
                  //         kycType: kycType,
                  //         applicationID: applicationId,
                  //         productCode: productCode,
                  //         cardNumber: productProvider.cardNumberController.text,
                  //         proxyNumber: productProvider.proxyNumberController.text,
                  //       );
                  //
                  //       final response = biometricProvider.productValidationModel;
                  //
                  //       if (response?.success == true) {
                  //         CustomToast.success(context, response!.message ?? "Product validated");
                  //
                  //         /// Reload screen with updated status
                  //         // await biometricProvider.fetchApplicationStatus(applicationID: applicationId);
                  //         await context.read<AadhaarKycProvider>().fetchApplicationStatus(applicationID: applicationId);
                  //
                  //         return;
                  //       } else {
                  //         CustomToast.error(context, response?.message ?? "Product validation failed");
                  //         return;
                  //       }
                  //     }
                  //
                  //     /// ================= STEP 2 → PERSONAL SECTION =================
                  //     if (status == "pending_product_validation" ||
                  //         status == "personal_details_completed" ||
                  //         status == "address_completed") {
                  //       final personalState = _personalKey.currentState;
                  //
                  //       if (personalState == null || !personalState.validateAndStore(context)) {
                  //         setState(() => _isPersonalExpanded = true);
                  //
                  //         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please complete Personal section")));
                  //
                  //         return;
                  //       }
                  //
                  //       if (!personalProvider.validatePersonalForm()) {
                  //         CustomToast.error(context, personalProvider.errorMessage!);
                  //         return;
                  //       }
                  //
                  //       final storedData = personalProvider.personalFormData;
                  //
                  //       final personalPayload = {
                  //         ...storedData,
                  //         "PRODUCT_CODE": productCode,
                  //         "IDENTIFICATION_PROOF": "ADCRD",
                  //         "IDENTIFICATION_PROOF_NUMBER": aadhaarProvider.aadhaarNumber,
                  //       };
                  //
                  //       /// 1️⃣ Save Personal
                  //       await biometricProvider.savePersonalDetails(
                  //         kycType: kycType,
                  //         applicationID: applicationId,
                  //         productCode: productCode!,
                  //         personalData: personalPayload,
                  //       );
                  //
                  //       if (biometricProvider.savePersonalDetailsModel?.success != true) {
                  //         CustomToast.error(context, biometricProvider.savePersonalDetailsModel?.message ?? "Personal save failed");
                  //         return;
                  //       }
                  //
                  //       /// 2️⃣ PAN Validate
                  //       await biometricProvider.kycPanValidate(applicationID: applicationId, personalData: personalPayload);
                  //
                  //       if (biometricProvider.panCardValidationModel?.success != true) {
                  //         CustomToast.error(context, biometricProvider.panCardValidationModel?.message ?? "PAN validation failed");
                  //         return;
                  //       }
                  //
                  //       /// 3️⃣ Save Address
                  //       await biometricProvider.saveAddressDetails(
                  //         kycType: kycType,
                  //         applicationID: applicationId,
                  //         productCode: productCode,
                  //         personalData: personalPayload,
                  //       );
                  //
                  //       if (biometricProvider.savePersonalDetailsModel?.success != true) {
                  //         CustomToast.error(context, biometricProvider.savePersonalDetailsModel?.message ?? "Address save failed");
                  //         return;
                  //       }
                  //
                  //       CustomToast.success(context, "Personal section completed");
                  //
                  //       // await biometricProvider.fetchApplicationStatus(applicationID: applicationId);
                  //       await context.read<AadhaarKycProvider>().fetchApplicationStatus(applicationID: applicationId);
                  //
                  //       return;
                  //     }
                  //
                  //     /// ================= STEP 3 → CORPORATE =================
                  //     if (status == "pan_completed") {
                  //       if (!corporateProvider.validateCorporateForm()) {
                  //         setState(() => _isCorporateExpanded = true);
                  //
                  //         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please complete Corporate section")));
                  //
                  //         return;
                  //       }
                  //
                  //       await biometricProvider.saveCorporateDetails(
                  //         kycType: kycType,
                  //         applicationID: applicationId,
                  //         productCode: productCode!,
                  //         corporateData: corporateProvider.buildCorporatePayload(),
                  //       );
                  //
                  //       if (biometricProvider.savePersonalDetailsModel?.success != true) {
                  //         CustomToast.error(context, biometricProvider.savePersonalDetailsModel?.message ?? "Corporate save failed");
                  //         return;
                  //       }
                  //
                  //       /// Final Submit
                  //       await biometricProvider.submitFinalKyc(kycType: kycType, applicationID: applicationId);
                  //
                  //       final finalResponse = biometricProvider.applicationSubmitModel;
                  //
                  //       if (finalResponse?.success == true) {
                  //         showSuccessDialog(context, finalResponse!.acknowledgementNumber.toString());
                  //       } else {
                  //         CustomToast.error(context, finalResponse?.message ?? "Submission failed");
                  //       }
                  //     }
                  //   } catch (e) {
                  //     log("KYC ERROR: $e");
                  //     CustomToast.error(context, "Something went wrong");
                  //   }
                  // },

                  ///===================  AI code =========================
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B2D9C),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const CustomText(
                    label: "Next",
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(Size size) =>
      Center(child: Image.asset(AppAssets.iciciLogo, width: size.width * 0.25));
}
