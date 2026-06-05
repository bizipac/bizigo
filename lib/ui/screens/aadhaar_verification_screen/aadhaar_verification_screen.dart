import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icici_bank/config.dart';
import 'package:icici_bank/core/constants/app_strings.dart';
import 'package:icici_bank/core/util/app_routes.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/util/app_preference.dart';
import '../../../providers/aadhaar_verification_provider/aadhaar_kyc_provider.dart';
import '../../widgets/custom_biometric_dialog_box.dart';
import '../../widgets/aadhaar_mask_formatter.dart';
import '../../widgets/common_input_field.dart';
import '../../widgets/custom_checkbox_tile.dart';
import '../../widgets/custom_radio_button.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/device_button.dart';
import '../home_screen/home_screen.dart';

class AadhaarVerificationScreen extends StatefulWidget {
  final String? kycType;
  final int? leadId;

  const AadhaarVerificationScreen({
    super.key,
    required this.kycType,
    this.leadId,
  });

  @override
  State<AadhaarVerificationScreen> createState() =>
      _AadhaarVerificationScreenState();
}

class _AadhaarVerificationScreenState extends State<AadhaarVerificationScreen> {
  final TextEditingController aadhaarController = TextEditingController();
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  void initState() {
    log('AadhaarVerificationScreen: initState: ${widget.kycType}');
    callKycApi();
    super.initState();
  }

  void callKycApi() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AadhaarKycProvider>().createKycApp(
        kycType: widget.kycType!,
        leadId: widget.leadId,
      );
    });
  }

  @override
  void dispose() {
    aadhaarController.dispose();
    super.dispose();
  }

  final List<String> imgList = [
    'assets/images/carousel_1.png',
    'assets/images/carousel_1.png',
    'assets/images/carousel_1.png',
    'assets/images/carousel_1.png',
    'assets/images/carousel_1.png',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AadhaarKycProvider>(context);

    Future<void> onSubmitBtn(BuildContext context) async {
      // showDialog(
      //   context: context,
      //   barrierDismissible: false,
      //   builder: (_) => CustomBiometricDialogBox(),
      // );

      final provider = context.read<AadhaarKycProvider>();
      debugPrint("SUBMIT BUTTON CLICKED");

      final idValue = provider.originalAadhaar.trim();
      final idType = provider.selectedIdType.toLowerCase();
      // final idValue = provider.aadhaarController.text.trim();
      // final idValue = provider.originalAadhaar.trim();

      /// STEP 1: Check Aadhaar number entered or not
      if (idValue.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter Aadhaar number")),
        );
        return;
      }

      /// STEP 2: Aadhaar number length & format validation
      if (!isValidId(idValue, idType)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              idType == "vid"
                  ? "Please enter a valid 16 digit Virtual ID"
                  : "Please enter a valid 12 digit Aadhaar number",
            ),
          ),
        );
        return;
      }

      /// STEP 3: Check RD services device selection
      if (provider.selectedDevice.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select RD services device")),
        );
        return;
      }

      /// STEP 4: Check selected device & connected device
      final connectedDevice = await provider.checkRDServiceDevice();

      if (connectedDevice == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please attach RD service device")),
        );
        return;
      }

      /// Device mismatch validation
      if (provider.selectedDevice != connectedDevice) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Selected ${provider.selectedDevice} but connected $connectedDevice device. Please select correct device.",
            ),
          ),
        );
        return;
      }

      log("REAL AADHAAR : $idValue");
      log("VISIBLE TEXT : ${provider.aadhaarController.text}");

      AppPreference.setAadhaarCardNo(idValue);

      /// STEP 5: FATCA selection check
      if (provider.taxResidency.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select FATCA/CRS declaration")),
        );
        return;
      }

      /// STEP 6: PEP selection check
      if (provider.pepStatus.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select PEP status")),
        );
        return;
      }

      /// STEP 7: Terms & conditions check
      if (!provider.declaration1 ||
          !provider.declaration2 ||
          !provider.termsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please accept all required terms & conditions")),
        );
        return;
      }

      log('Application Status: ${provider.applicationStatus}');
      log("PEP: ${provider.pepStatus}");
      log("FATCA: ${provider.taxResidency}");
      log("TERMS: ${provider.termsAccepted}");
      log("DEVICE: ${provider.selectedDevice}");
      log("ID TYPE: $idType");
      log("ID VALUE: $idValue");

      if (AppConfig.useNewApi &&
          (provider.applicationStatus.toString().toLowerCase() == 'draft' ||
              provider.applicationStatus.toString().toLowerCase() ==
                  'pending_aadhaar_verification')) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => CustomBiometricDialogBox(),
        );
      } else if (provider.applicationStatus.toString().toLowerCase() == 'draft' ||
          provider.applicationStatus.toString().toLowerCase() ==
              'pending_aadhaar_verification') {
        final otpSent = await provider.sendAadhaarOtp();

        log('OTP SENT: $otpSent');

        if (otpSent == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Aadhaar OTP flow is disabled in the new API mode")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("OTP generation failed")),
          );
        }
      } else if (provider.applicationStatus.toString().toLowerCase() ==
          'pending_product_validation') {
        Navigator.pushNamed(context, AppRoutes.biometricKycVerify);
      } else if (provider.applicationStatus.toString().toLowerCase() ==
          'pending_personal_details') {
        Navigator.pushNamed(context, AppRoutes.biometricKycVerify);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Profile is pending.")));
      } else if (provider.applicationStatus.toString().toLowerCase() ==
          'personal_details_completed') {
        Navigator.pushNamed(context, AppRoutes.biometricKycVerify);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile is already completed")),
        );
      } else if (provider.applicationStatus.toString().toLowerCase() ==
          'pan_completed') {
        Navigator.pushNamed(context, AppRoutes.biometricKycVerify);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("PAN verification completed")),
        );
      } else if (provider.applicationStatus.toString().toLowerCase() ==
          'pending_biometric') {
        print("=============");
        print("pending_biometric");
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => CustomBiometricDialogBox(),
        );
      } else if (provider.applicationStatus.toString().toLowerCase() ==
              'corporate_completed' ||
          provider.applicationStatus.toString().toLowerCase() == 'submitted') {
        Navigator.pushNamed(context, AppRoutes.home);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("KYC Already Submitted to Backend")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong please contact admin."),
          ),
        );
      }
    }

    final List<Widget> imageSliders = imgList
        .map(
          (item) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              border: BoxBorder.fromBorderSide(BorderSide(color: Colors.grey)),
            ),
            margin: EdgeInsets.all(5.0),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              child: Stack(
                children: <Widget>[
                  Image.asset(item, fit: BoxFit.cover, width: 1000.0),
                ],
              ),
            ),
          ),
        )
        .toList();

    final devices = [
      // 'Mantra',
      'Mantra L1',
      // 'Morpho',
      'Morpho L1',
      'Precision L1',
      // 'Secugen',
      // 'Startek',
    ];

    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          context.read<AadhaarKycProvider>().clearAadhaarForm();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back, color: Colors.black),
            onPressed: () {
              context.read<AadhaarKycProvider>().clearAadhaarForm();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
          title: Image.asset(AppAssets.iciciLogo, height: 30, width: 80),
          centerTitle: true,
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  // "Non-Personalized Card",
                  widget.kycType.toString().toLowerCase() == 'full_kyc'
                      ? "Personalized Card"
                      : "Non-Personalized Card",

                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF33348F),
                    fontFamily: AppStrings.elMessiri,
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFF33348F),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Column(
                children: [
                  CarouselSlider(
                    items: imageSliders,
                    carouselController: _controller,
                    options: CarouselOptions(
                      autoPlay: true,
                      enlargeCenterPage: true,
                      aspectRatio: 2.0,
                      onPageChanged: (index, reason) {
                        provider.setCurrentIndex(index);
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: imgList.asMap().entries.map((entry) {
                      final isActive = provider.currentIndex == entry.key;
                      return GestureDetector(
                        onTap: () => _controller.animateToPage(entry.key),
                        child: Container(
                          width: 12.0,
                          height: 12.0,
                          margin: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 4.0,
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                (Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.amber)
                                    .withValues(alpha: isActive ? 0.9 : 0.4),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              //radio buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomRadioButton(
                    label: "UID",
                    isSelected: provider.selectedIdType == "UID",
                    onTap: () => provider.selectIdType("UID"),
                  ),
                  const SizedBox(width: 20),
                  CustomRadioButton(
                    label: "VID",
                    isSelected: provider.selectedIdType == "VID",
                    onTap: () => provider.selectIdType("VID"),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // custom text field
              Text(
                "Enter Aadhaar No.",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  fontFamily: AppStrings.poppins,
                  color: Color(0xFF000000),
                ),
              ),
              SizedBox(height: 6),

              CommonInputField(
                hintText:
                    provider.selectedIdType.toString().toLowerCase() == "vid"
                    ? "XXXXXXXXXXXX4896"
                    : "XXXXXXXX9496",

                // controller: aadhaarController,
                // hintText: provider.selectedIdType == "UID"
                //     ? "Enter Aadhaar Number (12 digits)"
                //     : "Enter Virtual ID (16 digits)",
                controller: provider.aadhaarController,
                // maxLength: provider.selectedIdType.toString().toLowerCase() == "vid" ? 16 : 12,
                maxLength: provider.maxLength,

                isNumeric: true,

                inputFormatters: [
                  AadhaarMaskFormatter(
                    isVid: provider.selectedIdType == "VID",
                    onRealValue: (digits) {
                      provider.originalAadhaar = digits;
                    },
                  ),
                ],
                // onChanged: provider.updateAadhaar,
                onChanged: (value) {
                  provider.aadhaarNumber = value;
                },
              ),

              //custom text field for aadhaar no
              // CustomTextField(
              //   hintText: 'Enter Mobile Number / User id',
              //   onChanged: auth.setMobileOrUserId,
              //   fontSize: 10,
              //   textColor: Color(0xFF000000),
              //   hintColor: Color(0xFF8A8A8A),
              //   borderColor: Color(0XFFC1C1C1),
              //   // cursorColor: Colors.indigo,
              // ),
              SizedBox(height: 20),

              // RichText(
              //   text: TextSpan(
              //     style: const TextStyle(
              //       fontSize: 12,
              //       color: Colors.grey,
              //       fontFamily: 'Poppins',
              //     ),
              //     children: <TextSpan>[
              //       // const TextSpan(text: 'Note: '),
              //       TextSpan(
              //         text: "Note: ",
              //         style: TextStyle(
              //           fontWeight: FontWeight.bold,
              //           color: Colors.black,
              //         ), // Bold and blue
              //       ),
              //       const TextSpan(
              //         text:
              //             ' require you to visit an enrolment centre with original '
              //             'Proof of Identity (PoI), Proof of Address (PoA), and other supporting documents for enrolment and updates.',
              //       ),
              //     ],
              //   ),
              // ),

              // const Text(
              //   "Note: require you to visit an enrolment centre with original Proof of Identity (PoI), Proof of Address (PoA), and other supporting documents for enrolment and updates.",
              //   style: TextStyle(
              //     fontSize: 12,
              //     color: Colors.grey,
              //     fontFamily: 'Poppins',
              //   ),
              // ),
              // const SizedBox(height: 25),
              const Text(
                "Select Device for Aadhaar Verification",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),

              // Wrap to make grid-like layout
              Wrap(
                alignment: WrapAlignment.start,
                children: devices.map((device) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width / 2 - 24,
                    child: DeviceButton(
                      label: device,
                      isSelected: provider.selectedDevice == device,
                      onTap: () => provider.selectDevice(device),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: 10),
              if (provider.selectedDevice.isNotEmpty)
                Center(
                  child: Text(
                    "Selected Device: ${provider.selectedDevice}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              // SizedBox(height: 20),

              // text with link
              Row(
                children: [
                  const Text(
                    "FATCA/CRS Declaration",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Text(
                              "FATCA/CRS Terms & Conditions",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                fontSize: 16,
                              ),
                            ),
                            content: SingleChildScrollView(
                              child: const Text(
                                "1. I/we understand that Bank is relying on this information for determining my status in FATCA/CRS compliance and understand that the Bank is unable to offer any tax advice or FATCA/CRS status or its impact.\n\n"
                                "2. I/We agree to submit a new form within 30 days if any certification or information in the FATCA/CRS becomes incorrect.\n\n"
                                "3. I am further aware that as per the Union Budget, 2023, penalty of Rs. 5000 per account holder shall be levied for furnishing inaccurate statement of financial transaction owing to false or inaccurate self-certification submitted by me under FATCA/CRS.",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  height: 1.5,
                                ),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  "OK",
                                  style: TextStyle(
                                    color: Colors.indigo,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text(
                      "Click here for TnC",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.indigoAccent,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.indigoAccent,
                        decorationThickness: 1,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 5),

              // Center(
              //   child:
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomRadioButton(
                      label:
                          "I am a tax resident only of India and not a resident of any other country",
                      isSelected: provider.taxResidency == "INDIA_ONLY",
                      onTap: () => provider.setTaxResidency("INDIA_ONLY"),
                    ),
                    SizedBox(height: 15),
                    CustomRadioButton(
                      label:
                          "I am a tax resident of country outside India or I am a US Person (US citizen or US resident)",
                      isSelected:
                          provider.taxResidency == "OUTSIDE_INDIA_OR_US",
                      onTap: () {
                        provider.setTaxResidency("OUTSIDE_INDIA_OR_US");

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: const Text(
                                "FATCA/CRS Declaration",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              content: const Text(
                                "You are eligible for Physical KYC with FATCA/CRS declaration.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    // CustomRadioButton(
                    //   label:
                    //       "I am a tax resident of country outside India or I am a US Person (US citizen or US resident)",
                    //   isSelected: provider.taxResidency == "OUTSIDE_INDIA_OR_US",
                    //   onTap: () =>
                    //       provider.setTaxResidency("OUTSIDE_INDIA_OR_US"),
                    //
                    //
                    // ),
                  ],
                ),
              ),

              // ),
              const SizedBox(height: 20),

              const Text(
                "Are you a politically exposed person (PEP) "
                "\nor a family member / close associate of PEP?",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 360,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomRadioButton(
                        label: "Yes",
                        isSelected: provider.pepStatus == "Y",
                        onTap: () {
                          provider.setPepStatus("Y");

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: const Text(
                                  "Confirmation",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                content: const Text(
                                  "You selected 'YES' for PEP. Please confirm your selection.",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("OK"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      SizedBox(height: 15),
                      CustomRadioButton(
                        label: "No",
                        isSelected: provider.pepStatus == "N",
                        onTap: () => provider.setPepStatus("N"),
                      ),
                      // CustomRadioButton(
                      //   label: "No",
                      //   isSelected: provider.pepStatus == "N",
                      //   onTap: () => provider.setPepStatus("N"),
                      // ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Center(
                child: const Text(
                  "1. The term family member includes close "
                  "\nfamily members such as spouse, children, "
                  "\nparents and siblings and may also include "
                  "\nother blood relatives and relatives by marriage.\n\n"
                  "2. The term close associates includes "
                  "\ncolleagues, advisors, consultants, "
                  "\nand others who benefit significantly from "
                  "\nbeing close to such a person.",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Declarations
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    CustomCheckboxTile(
                      label:
                          "I hereby state that, I have no objection in "
                          "authenticating myself with Aadhaar/VID "
                          "and give consent to providing Aadhaar"
                          "number/biometric for availing prepaid "
                          "card from ICICI Bank.",
                      value: provider.declaration1,
                      onChanged: provider.toggleDeclaration1,
                    ),
                    CustomCheckboxTile(
                      label:
                          "I have been given to understand that my"
                          "information submitted to the bank shall "
                          "not be used for any purpose other than "
                          "mentioned above, or as per legal requirements.",
                      value: provider.declaration2,
                      onChanged: provider.toggleDeclaration2,
                    ),
                    CustomCheckboxTile(
                      label: "I accept terms & conditions.",
                      value: provider.termsAccepted,
                      onChanged: provider.toggleTerms,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Submit Button
              provider.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        // onPressed: () {
                        //   showDialog(
                        //     context: context,
                        //     barrierDismissible: false,
                        //     builder: (_) =>  CustomBiometricDialogBox(),
                        //   );
                        // },
                        onPressed: () => onSubmitBtn(context),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2B2D9C),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: CustomText(
                          label: "SUBMIT",
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

  bool isValidAadhaar(String aadhaar) {
    final aadhaarRegex = RegExp(r'^[0-9]{12}$');
    return aadhaarRegex.hasMatch(aadhaar);
  }

  bool isValidId(String value, String type) {
    if (type.toLowerCase() == "vid") {
      return RegExp(r'^[0-9]{16}$').hasMatch(value);
    }
    return RegExp(r'^[0-9]{12}$').hasMatch(value);
  }
}
