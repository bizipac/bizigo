import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icici_bank/core/constants/app_assets.dart';
import 'package:icici_bank/core/util/app_preference.dart';
import 'package:icici_bank/ui/widgets/custom_dialog_success.dart';
import 'package:icici_bank/ui/widgets/rd_service.dart';
import 'package:provider/provider.dart';
import 'package:xml/xml.dart';

import '../../core/network/api_client.dart';
import '../../core/network/network_api.dart';
import '../../providers/aadhaar_verification_provider/aadhaar_kyc_provider.dart';
import '../../providers/biometric_kyc_provider/dialog_box_provider.dart';

class CustomBiometricDialogBoxOld extends StatefulWidget {
  const CustomBiometricDialogBoxOld({super.key});

  @override
  State<CustomBiometricDialogBoxOld> createState() => _CustomBiometricDialogBoxState();
}

class _CustomBiometricDialogBoxState extends State<CustomBiometricDialogBoxOld> {
  String? aadhaarCardNo = '';
  final ApiClient _apiClient = ApiClient();

  /*Example pid options*/
  // final String captureRequestXML =
  //     "<?xml version=\"1.0\"?> "
  //     "<PidOptions ver=\"1.0\"> "
  //     "<Opts fCount=\"1\" fType=\"0\" format=\"0\" pidVer=\"2.0\" "
  //     "timeout=\"10000\" env=\"P\" posh=\"UNKNOWN\" /> </PidOptions>";

  /// While creating Production Developer needs to change env "S" to "P"
  /// While creating Staging Developer needs to change env "S"
  /// While creating Pre-Production Developer needs to change env "PP"
  final String captureRequestXML =
      "<?xml version=\"1.0\"?> "
      "<PidOptions ver=\"1.0\"> "
      "<Opts fCount=\"1\" fType=\"2\" format=\"0\" pidVer=\"2.0\" "
      "timeout=\"10000\" wadh=\"E0jzJ/P8UopUHAieZn8CKqS4WPMi5ZSYXgfnlfkWjrc=\" env=\"PP\" posh=\"UNKNOWN\"/>"
      "<Demo></Demo>"
      "<CustOpts>"
      "</CustOpts>"
      "</PidOptions>";

  /// old
  // final String captureRequestXML =
  //     "<?xml version=\"1.0\"?> "
  //     "<PidOptions ver=\"1.0\"> "
  //     "<Opts fCount=\"1\" fType=\"0\" format=\"0\" pidVer=\"2.0\" "
  //     "timeout=\"15000\" env=\"PP\" posh=\"UNKNOWN\" /> "
  //     "</PidOptions>";

  // final String captureRequestXML =
  //     "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
  //          "<PidOptions ver=\"1.0\">"
  //          "<Opts fCount=\"1\" fType=\"2\" format=\"0\" pidVer=\"2.0\" "
  //          "timeout=\"10000\" env=\"PP\" posh=\"UNKNOWN\" "
  //          "bt=\"FMR\"/>"
  //          "<Demo/>"
  //          "<CustOpts/>"
  //          "</PidOptions>";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    aadhaarCardNo = AppPreference.getAadhaarCardNo();
    log("Aadhaar Card No: $aadhaarCardNo");
    _init();
  }

  void _init() async {
    await initiateCapture();
  }

  @override
  Widget build(BuildContext context) {
    final dialogProvider = Provider.of<DialogBoxProvider>(context);
    final size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: SizedBox(
        height: 350,
        width: 240,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              // Image.asset(AppAssets.iciciLogo,height: 80,width: 30,),
              _buildLogo(size),
              SizedBox(height: size.height * 0.02),
              // SizedBox(height: 60,),
              Spacer(),
              // GestureDetector(
              //   onTap: () {
              //     // dialogProvider.closeDialog();
              //     // Navigator.pop(context); // close dialog
              //     // showDialog(
              //     //   context: context,
              //     //   barrierDismissible: false,
              //     //   builder: (_) => const CustomDialogSuccess(),
              //     // );
              //   },
              //   child: Image.asset(
              //     'assets/finger_print.png',
              //     height: 150,
              //     fit: BoxFit.contain,
              //   ),
              // ),

              /// ✅ LOADER REPLACES FINGERPRINT IMAGE HERE
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFFFF6B00), strokeWidth: 3.0),
                  SizedBox(height: 16),
                  Text(
                    "Scanning fingerprint...",
                    style: TextStyle(fontSize: 13, fontFamily: 'Poppins', color: Colors.grey),
                  ),
                ],
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Please wait for the verification to complete. You will be automatically redirected.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, fontFamily: 'Poppins', fontWeight: FontWeight.w500),
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(Size size) => Center(child: Image.asset(AppAssets.iciciLogo, width: size.width * 0.25));

  // Future<void> initiateCapture() async {
  //   final response = await RdService.openRdService(
  //     "in.gov.uidai.rdservice.fp.CAPTURE",
  //     captureRequestXML,
  //   );
  //
  //   log('Response initiateCapture: ${response.toString()}');
  //
  //
  //   // setState(() {
  //   //   text = response != null ? response.toString() : "No response";
  //   // });
  // }

  // Future<void> initiateCapture() async {
  //   log("Waiting for fingerprint capture before try...");
  //   try {
  //     log("Waiting for fingerprint capture...");
  //
  //     final response = await RdService.openRdService(
  //       "in.gov.uidai.rdservice.fp.CAPTURE",
  //       captureRequestXML,
  //     );
  //
  //     log("Fingerprint capture completed");
  //
  //     final pidXmlString = response['PID_DATA'];
  //
  //     if (pidXmlString == null) {
  //       log("PID_DATA not found");
  //       return;
  //     }
  //
  //     // 🔎 Parse XML manually first to detect spoof
  //     final document = XmlDocument.parse(pidXmlString);
  //     final respElement = document.findAllElements('Resp').first;
  //
  //     final errCode = respElement.getAttribute('errCode');
  //     final errInfo = respElement.getAttribute('errInfo') ?? '';
  //
  //     log("errCode: $errCode");
  //     log("errInfo: $errInfo");
  //
  //     // ❌ STOP if error
  //     if (errCode != '0') {
  //       log("Capture failed: $errCode $errInfo");
  //       return;
  //     }
  //
  //     // ❌ STOP if spoof detected
  //     if (errInfo.toLowerCase().contains("spoof")) {
  //       log("Spoof detected! Navigation blocked.");
  //       return;
  //     }
  //
  //     // ✅ Now safe to parse properly
  //     final parsedData = parseScannerResponse(pidXmlString);
  //
  //     final biometricData = parsedData['biometricData'];
  //     final qualityScore = parsedData['qualityScore'];
  //
  //     log("Biometric Data Length: ${biometricData.length}");
  //     log("Quality Score: $qualityScore");
  //
  //     // ❌ Optional: block if quality low
  //     if (qualityScore != null && int.parse(qualityScore) < 40) {
  //       log("Quality too low. Do not proceed.");
  //       return;
  //     }
  //     log('Biometric Aadhar Data: $aadhaarCardNo');
  //     // ✅ Build MAS request
  //     final masRequestXml = buildMasRequest(
  //       aadhaarCardNo!,
  //       biometricData,
  //     );
  //
  //     log("MAS Request XML Created: $masRequestXml");
  //
  //     // ✅ Only here navigate
  //     // Navigator.push(...);
  //
  //   } catch (e) {
  //     log("Error in initiateCapture: $e");
  //   }
  // }
  int _retryCount = 0;
  final int _maxRetries = 3;

  // Future<void> initiateCapture() async {
  //   try {
  //     log("Starting fingerprint capture... Attempt: ${_retryCount + 1}");
  //
  //     final response = await RdService.openRdService(
  //       "in.gov.uidai.rdservice.fp.CAPTURE",
  //       captureRequestXML,
  //     );
  //     log("Fingerprint capture completed response: $response");
  //     final pidXmlString = response['PID_DATA'];
  //     log("Fingerprint capture completed: $pidXmlString");
  //
  //     if (pidXmlString == null) {
  //       log("PID_DATA not found");
  //       return;
  //     }
  //
  //     final document = XmlDocument.parse(pidXmlString);
  //     final respElement = document.findAllElements('Resp').first;
  //
  //     final errCode = respElement.getAttribute('errCode') ?? '';
  //     final errInfo = respElement.getAttribute('errInfo') ?? '';
  //
  //     log("errCode: $errCode");
  //     log("errInfo: $errInfo");
  //
  //     // ❌ SPOOF DETECTED → STOP COMPLETELY
  //     if (errInfo.toLowerCase().contains("spoof")) {
  //       log("Spoof detected! Capture stopped.");
  //       return;
  //     }
  //
  //     // ❌ TIMEOUT → RETRY
  //     if (errCode == '720') {
  //       log("Capture timeout detected");
  //
  //       if (_retryCount < _maxRetries) {
  //         _retryCount++;
  //         log("Retrying capture...");
  //         await initiateCapture();
  //       } else {
  //         log("Max retries reached. Stopping capture.");
  //       }
  //       return;
  //     }
  //
  //     // ❌ OTHER ERROR
  //     if (errCode != '0') {
  //       log("Capture failed: $errCode $errInfo");
  //       return;
  //     }
  //
  //     // ✅ SUCCESS
  //     _retryCount = 0; // reset retries
  //
  //     final parsedData = parseScannerResponse(pidXmlString);
  //
  //     final biometricData = parsedData['biometricData'];
  //     final qualityScore = parsedData['qualityScore'];
  //
  //     log("Biometric Data Length: ${biometricData.length}");
  //     log("Quality Score: $qualityScore");
  //
  //     // ❌ Block if low quality
  //     if (qualityScore != null && int.parse(qualityScore) < 40) {
  //       log("Quality too low. Please try again.");
  //       return;
  //     }
  //
  //     final masRequestXml = buildMasRequest(aadhaarCardNo!, biometricData);
  //
  //     final token = AppPreference.getAccessToken();
  //
  //     log("MAS Request XML Created Successfully: $masRequestXml");
  //
  //     // ✅ NOW YOU CAN NAVIGATE
  //     // Navigator.push(...);
  //
  //     final responseFingerprint = await _apiClient.postXml(
  //       NetworkApi.biometricCapture,
  //       masRequestXml,
  //       token!,
  //     );
  //     log('responseFingerprint.toString()');
  //     log(responseFingerprint.toString());
  //     log('responseFingerprint.toString()');
  //   } catch (e) {
  //     log("Error in initiateCapture: $e");
  //   }
  // }
  //   Future<void> initiateCapture() async {
  //     try {
  //       log("Starting fingerprint capture... Attempt: ${_retryCount + 1}");
  //
  //       final response = await RdService.openRdService(
  //         "in.gov.uidai.rdservice.fp.CAPTURE",
  //         captureRequestXML,
  //       );
  //
  //       final pidXmlString = response['PID_DATA'];
  //       log('Fingerprint capture completed PID Data: $pidXmlString');
  //
  //       if (pidXmlString == null) {
  //         log("PID_DATA not found");
  //         return;
  //       }
  //
  //       /// Parse XML
  //       final document = XmlDocument.parse(pidXmlString);
  //       final respElement = document.findAllElements('Resp').first;
  //
  //       final errCode = respElement.getAttribute('errCode') ?? '';
  //       final errInfo = respElement.getAttribute('errInfo') ?? '';
  //
  //       log("errCode: $errCode");
  //       log("errInfo: $errInfo");
  //
  //       /// ❌ SPOOF DETECTED → STOP (NO RETRY, NO NAVIGATION)
  //       if (errInfo.toLowerCase().contains("spoof")) {
  //         log("Spoof fingerprint detected. Blocking capture.");
  //
  //         if (mounted) {
  //           Navigator.pop(context);
  //
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(
  //               content: Text(
  //                 "Spoof fingerprint detected. Please use a real finger.",
  //               ),
  //             ),
  //           );
  //         }
  //
  //         return;
  //       }
  //
  //       /// ❌ TIMEOUT → RETRY
  //       if (errCode == '720') {
  //         log("Capture timeout detected");
  //
  //         if (_retryCount < _maxRetries) {
  //           _retryCount++;
  //           log("Retrying capture...");
  //           await initiateCapture();
  //         } else {
  //           log("Max retries reached. Stopping capture.");
  //         }
  //         return;
  //       }
  //
  //       /// ❌ OTHER ERROR
  //       if (errCode != '0') {
  //         log("Capture failed: $errCode $errInfo");
  //         return;
  //       }
  //
  //       /// ✅ SUCCESS
  //       _retryCount = 0;
  //
  //       /// Extract Data (PID block)
  //       final dataElement = document
  //           .findAllElements('Data')
  //           .firstWhere((e) => e.getAttribute('type') == 'X');
  //
  //       final data = dataElement.innerText.trim();
  //
  //       /// Extract Hmac
  //       final hmacElement = document.findAllElements('Hmac').first;
  //       final hmac = hmacElement.innerText.trim();
  //
  //       /// Extract Skey + ci
  //       final skeyElement = document.findAllElements('Skey').first;
  //       final skey = skeyElement.innerText.trim();
  //       final ci = skeyElement.getAttribute('ci') ?? '';
  //
  //       /// Quality Score
  //       final qualityScore = respElement.getAttribute('qScore');
  //
  //       log("Quality Score: $qualityScore");
  //
  //       /// ❌ Block low quality
  //       if (qualityScore != null && int.parse(qualityScore) < 40) {
  //         log("Fingerprint quality too low. Please try again.");
  //         return;
  //       }
  //
  //       /// Aadhaar + Token
  //       final aadhaarNumber = aadhaarCardNo ?? '';
  //       final token = AppPreference.getAccessToken();
  //
  //       /// Build MAS XML
  //       final masRequestXml = buildMasRequest(
  //         aadhaarNumber: aadhaarNumber,
  //         data: data,
  //         hmac: hmac,
  //         skey: skey,
  //         ci: ci,
  //       );
  //
  //       log("MAS Request XML Created Successfully $masRequestXml");
  //
  //       /// API CALL
  //       // final responseFingerprint = await _apiClient.postXml(
  //       //   NetworkApi.biometricCapture,
  //       //   masRequestXml,
  //       //   token!,
  //       // );
  //
  //       /*
  //       * {
  //   "aadhaar": "984485104074",
  //   "pidData": {
  //     "skey": "0Ssuw1fN2J1maoaT6AcOxhccp0lW48Et2QbtiOlyZ6ZK...",
  //     "skeyCI": "20300811",
  //     "hmac": "MSH7MaXBYRBlK5s0fSpGafl5/Owcd3hbn/xr9xysKKlk4hs7a/S7CurmZPC/mKT9",
  //     "data": "MjAyNi0wMy0wNFQxMjo0OTowMclwIUoN61mAx5K2nvAg...",
  //     "dataType": "X"
  //   },
  //   "deviceInfo": {
  //     "dpId": "PRECISION.PB",
  //     "rdsId": "L1.PRECISION.WIN.001",
  //     "rdsVer": "1.2.3",
  //     "dc": "3b8c0425-fdf3-45f7-beab-b6cb8c1f2560",
  //     "mi": "PB1000",
  //     "mc": "MIIEKjCCAxKgAwIBAgII..."
  //   },
  //   "biometricType": "FMR"
  // }
  // * */
  //
  //       /// This is new code to parse the PID data XML
  //       // Map<String, dynamic> buildApiBody(String pidXml, String aadhaar, String applicationID) {
  //       //   final document = XmlDocument.parse(pidXml);
  //       //
  //       //   /// PID DATA
  //       //   final dataElement = document
  //       //       .findAllElements('Data')
  //       //       .firstWhere((e) => e.getAttribute('type') == 'X');
  //       //
  //       //   final skeyElement = document.findAllElements('Skey').first;
  //       //   final hmacElement = document.findAllElements('Hmac').first;
  //       //
  //       //   final data = dataElement.innerText.trim();
  //       //   final dataType = dataElement.getAttribute('type') ?? "X";
  //       //
  //       //   final skey = skeyElement.innerText.trim();
  //       //   final skeyCI = skeyElement.getAttribute('ci') ?? "";
  //       //
  //       //   final hmac = hmacElement.innerText.trim();
  //       //
  //       //   /// DEVICE INFO
  //       //   final deviceInfoElement = document.findAllElements('DeviceInfo').first;
  //       //
  //       //   final dpId = deviceInfoElement.getAttribute('dpId') ?? "";
  //       //   final rdsId = deviceInfoElement.getAttribute('rdsId') ?? "";
  //       //   final rdsVer = deviceInfoElement.getAttribute('rdsVer') ?? "";
  //       //   final dc = deviceInfoElement.getAttribute('dc') ?? "";
  //       //   final mi = deviceInfoElement.getAttribute('mi') ?? "";
  //       //   final mc = deviceInfoElement.getAttribute('mc') ?? "";
  //       //
  //       //   ///this is the request body which will be sendwhile api call
  //       //   return {
  //       //     "aadhaar": aadhaar,
  //       //     "biometricType": "FMR",
  //       //     "application_id":applicationID,
  //       //     "pidData": {
  //       //       "skey": skey,
  //       //       "skeyCI": skeyCI,
  //       //       "hmac": hmac,
  //       //       "data": data,
  //       //       "dataType": dataType,
  //       //     },
  //       //     "deviceInfo": {
  //       //       "dpId": dpId,
  //       //       "rdsId": rdsId,
  //       //       "rdsVer": rdsVer,
  //       //       "dc": dc,
  //       //       "mi": mi,
  //       //       "mc": mc,
  //       //     }
  //       //   };
  //       // }
  //
  //       Map<String, dynamic> buildApiBody(
  //         String aadhaar,
  //         String applicationID,
  //         String pidXml,
  //       ) {
  //         log("PID XML RECEIVED: $pidXml");
  //
  //         final document = XmlDocument.parse(pidXml);
  //
  //         /// PID DATA
  //         final dataElement = document
  //             .findAllElements('Data')
  //             .firstWhere((e) => e.getAttribute('type') == 'X');
  //
  //         final skeyElement = document.findAllElements('Skey').first;
  //         final hmacElement = document.findAllElements('Hmac').first;
  //
  //         final data = dataElement.innerText.trim();
  //         final dataType = dataElement.getAttribute('type') ?? "X";
  //
  //         final skey = skeyElement.innerText.trim();
  //         final skeyCI = skeyElement.getAttribute('ci') ?? "";
  //
  //         final hmac = hmacElement.innerText.trim();
  //
  //         log("PID DATA PARSED");
  //         log("DataType: $dataType");
  //         log("SkeyCI: $skeyCI");
  //         log("Hmac Length: ${hmac.length}");
  //
  //         /// DEVICE INFO
  //         final deviceInfoElement = document.findAllElements('DeviceInfo').first;
  //
  //         final dpId = deviceInfoElement.getAttribute('dpId') ?? "";
  //         final rdsId = deviceInfoElement.getAttribute('rdsId') ?? "";
  //         final rdsVer = deviceInfoElement.getAttribute('rdsVer') ?? "";
  //         final dc = deviceInfoElement.getAttribute('dc') ?? "";
  //         final mi = deviceInfoElement.getAttribute('mi') ?? "";
  //         final mc = deviceInfoElement.getAttribute('mc') ?? "";
  //
  //         log("DEVICE INFO");
  //         log("dpId: $dpId");
  //         log("rdsId: $rdsId");
  //         log("rdsVer: $rdsVer");
  //         log("dc: $dc");
  //         log("mi: $mi");
  //         log("mc: $mc");
  //
  //         final body = {
  //           "aadhaar": aadhaar,
  //           "biometricType": "FMR",
  //           "application_id": applicationID,
  //           "pidData": {
  //             "skey": skey,
  //             "skeyCI": skeyCI,
  //             "hmac": hmac,
  //             "data": data,
  //             "dataType": dataType,
  //           },
  //           "deviceInfo": {
  //             "dpId": dpId,
  //             "rdsId": rdsId,
  //             "rdsVer": rdsVer,
  //             "dc": dc,
  //             "mi": mi,
  //             "mc": mc,
  //           },
  //         };
  //
  //         log("FINAL API BODY: $body");
  //
  //         return body;
  //       }
  //
  //       final aadhaarProvider = context.read<AadhaarKycProvider>();
  //       final String applicationId = aadhaarProvider.applicationId.toString();
  //       log('applicationId.toString()');
  //       log(applicationId.toString());
  //       log('applicationId.toString()');
  //
  //       ///actual request body
  //       ///
  //       final Map<String, dynamic> body = buildApiBody(
  //         aadhaarNumber,
  //         applicationId,
  //         pidXmlString,
  //       );
  //       log(
  //         "================================ Fingerprint API Request: ************************************",
  //       );
  //       log("Request Data:- ${body.toString()}");
  //
  //       ///API call
  //       final responseFingerprint = await _apiClient.post(
  //         NetworkApi.biometricCapture,
  //         body,
  //       );
  //
  //       log(
  //         "================================ Fingerprint API Response: ************************************",
  //       );
  //       log("Response Data:-${responseFingerprint.toString()}");
  //       log("Response Data:-${responseFingerprint["success"].toString()}");
  //       log("Response Data:-${responseFingerprint["message"].toString()}");
  //       log(
  //         "Response Data:-${responseFingerprint['data']['ResCode'].toString()}",
  //       );
  //       log("Response Data:-${responseFingerprint['data']['ResMsg'].toString()}");
  //       log(
  //         "================================ Fingerprint API Response Complete ************************************",
  //       );
  //
  //       /// ✅ SUCCESS FLOW - after successful API response
  //       if (responseFingerprint["success"] == true &&
  //           responseFingerprint['data']['ResMsg'].toString().toLowerCase() ==
  //               "success") {
  //         Navigator.pop(context);
  //         showDialog(
  //           context: context,
  //           barrierDismissible: false,
  //           builder: (_) => const CustomDialogSuccess(),
  //         );
  //       } else {
  //         log("Error in response API.");
  //       }
  //     } catch (e) {
  //       log("Error in initiateCapture: $e");
  //     }
  //   }

  Future<void> initiateCapture() async {
    try {
      log("============= initiateCapture START =============");
      log("Starting fingerprint capture... Attempt: ${_retryCount + 1}");

      final selectedDevice = context.read<AadhaarKycProvider>().selectedDevice;

      log("Selected Device: $selectedDevice");
      log("RD Service Name: ${getRdServiceName()}");
      log("Device Selected: $selectedDevice");
      log("Device Mapping Verified");

      /// for safe device check
      if (selectedDevice.isEmpty) {
        log("No device selected");
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select device")));
        return;
      }

      /// check if rd service not installed or failed
      Map? response;

      try {
        log("Calling startCapture()");
        response = await startCapture(selectedDevice);
        log("startCapture Response: $response");
      } catch (e) {
        log("RD Service Error: $e");

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("RD Service not installed or failed")));
        return;
      }

      /// check if fingerprint capture is failed
      if (response == null || response['PID_DATA'] == null) {
        log("Fingerprint capture failed: PID_DATA null");

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fingerprint capture failed")));
        return;
      }

      final pidXmlString = response['PID_DATA'];

      log("PID_DATA Received Successfully");
      log("PID XML: $pidXmlString");

      if (pidXmlString == null) {
        log("PID_DATA not found");
        return;
      }

      log("Parsing XML...");
      final document = XmlDocument.parse(pidXmlString);

      final respElement = document.findAllElements('Resp').first;

      final errCode = respElement.getAttribute('errCode') ?? '';
      final errInfo = respElement.getAttribute('errInfo') ?? '';

      log("errCode: $errCode");
      log("errInfo: $errInfo");

      /// ❌ SPOOF
      if (errInfo.toLowerCase().contains("spoof")) {
        log("Spoof fingerprint detected");

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Spoof fingerprint detected.")));
        return;
      }

      /// ❌ TIMEOUT
      if (errCode == '720' || errCode == '-2112') {
        if (_retryCount < _maxRetries) {
          _retryCount++;
          log("Retrying capture due to $errCode");
          await Future.delayed(Duration(seconds: 1));
          await initiateCapture();
        } else {
          Navigator.pop(context);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Fingerprint capture failed. Please place finger properly and try again.")));
        }
        return;
      }
      // if (errCode == '720') {
      //   log("Capture Timeout Error");
      //
      //   if (_retryCount < _maxRetries) {
      //     _retryCount++;
      //     log("Retrying capture... Retry Count: $_retryCount");
      //     await initiateCapture();
      //   } else {
      //     log("Max retry limit reached");
      //   }
      //   return;
      // }

      /// ❌ OTHER ERROR
      if (errCode != '0') {
        log("Capture failed with errCode: $errCode");
        log("Capture failed with errInfo: $errInfo");
        return;
      }

      /// ✅ SUCCESS
      log("Fingerprint capture success");
      _retryCount = 0;

      final dataElement = document.findAllElements('Data').firstWhere((e) => e.getAttribute('type') == 'X');

      final data = dataElement.innerText.trim();
      log("Encrypted Data fetched");

      final hmac = document.findAllElements('Hmac').first.innerText.trim();
      log("HMAC fetched");

      final skeyElement = document.findAllElements('Skey').first;

      final skey = skeyElement.innerText.trim();
      final ci = skeyElement.getAttribute('ci') ?? '';

      log("SKEY fetched");
      log("CI: $ci");

      final qualityScore = respElement.getAttribute('qScore');

      log("Quality Score: $qualityScore");

      if (qualityScore != null && int.parse(qualityScore) < 40) {
        log("Low quality fingerprint detected");
        return;
      }

      final aadhaarNumber = aadhaarCardNo ?? '';
      final token = AppPreference.getAccessToken();

      log("Aadhaar Number: $aadhaarNumber");
      log("Access Token: $token");

      final masRequestXml = buildMasRequest(aadhaarNumber: aadhaarNumber, data: data, hmac: hmac, skey: skey, ci: ci);

      log("MAS Request XML Created");

      final aadhaarProvider = context.read<AadhaarKycProvider>();
      final applicationId = aadhaarProvider.applicationId.toString();

      log("Application ID: $applicationId");

      final body = buildApiBody(aadhaarNumber, applicationId, getRdServiceName(), pidXmlString);

      log("API Request Body Created");
      log("Calling biometricCapture API...");

      /// api call
      final responseFingerprint = await _apiClient.post(NetworkApi.biometricCapture, body);

      log("API Response: $responseFingerprint");
      log("================================ Fingerprint API Response: ************************************");
      log("Response Data:-${responseFingerprint.toString()}");
      log("Response Data:-${responseFingerprint["success"].toString()}");
      log("Response Data:-${responseFingerprint["message"].toString()}");
      log("Response Data:-${responseFingerprint['data']['ResCode'].toString()}");
      log("Response Data:-${responseFingerprint['data']['ResMsg'].toString()}");
      log("================================ Fingerprint API Response Complete ************************************");

      if (responseFingerprint["success"] == true) {
        log("Biometric verification SUCCESS");

        Navigator.pop(context);

        showDialog(context: context, barrierDismissible: false, builder: (_) => const CustomDialogSuccess());
      } else {
        log("API Error");
        log("API Failed Response: $responseFingerprint");
      }

      log("============= initiateCapture END =============");
    } catch (e) {
      Navigator.pop(context);

      log("============= EXCEPTION =============");
      log("Error in initiateCapture: $e");

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Something went wrong")));
    }
  }

  // Map<String, dynamic> parseScannerResponse(String scannerXml) {
  //   try {
  //     log("Starting XML parsing...");
  //
  //     // Parse XML
  //     final document = XmlDocument.parse(scannerXml);
  //     log("XML Parsed Successfully");
  //
  //     // Get <Resp> element
  //     final respElements = document.findAllElements('Resp');
  //     if (respElements.isEmpty) {
  //       log("Resp element not found");
  //       throw Exception('Invalid scanner response');
  //     }
  //
  //     final respElement = respElements.first;
  //     log("Resp element found");
  //
  //     // Check errCode
  //     final errCode = respElement.getAttribute('errCode');
  //     log("errCode: $errCode");
  //
  //     if (errCode != '0') {
  //       final errInfo = respElement.getAttribute('errInfo') ?? '';
  //       log("Capture failed: $errCode $errInfo");
  //       throw Exception('Biometric capture failed: $errCode $errInfo');
  //     }
  //
  //     log("Biometric capture successful");
  //
  //     // Extract biometric data from <Data type="X">
  //     XmlElement? dataElement;
  //
  //     final dataElements = document.findAllElements('Data');
  //     log("Total Data elements found: ${dataElements.length}");
  //
  //     for (var element in dataElements) {
  //       if (element.getAttribute('type') == 'X') {
  //         dataElement = element;
  //         break;
  //       }
  //     }
  //
  //     if (dataElement == null) {
  //       log("Biometric data not found with type X");
  //       throw Exception('Biometric data not found');
  //     }
  //
  //     final biometricData = dataElement.innerText.trim();
  //     log("Biometric data extracted");
  //
  //     if (biometricData.isEmpty) {
  //       log("Biometric data is empty");
  //       throw Exception('Biometric data is empty');
  //     }
  //
  //     // Optional: Get quality score
  //     final qScore = respElement.getAttribute('qScore');
  //     log("Quality Score: $qScore");
  //
  //     log("parseScannerResponse completed successfully");
  //
  //     return {
  //       'biometricData': biometricData,
  //       'qualityScore': qScore,
  //       'success': true,
  //     };
  //   } catch (e) {
  //     log("Error while parsing XML: $e");
  //     throw Exception('Failed to parse scanner XML: $e');
  //   }
  // }
  Map<String, dynamic> parseScannerResponse(String scannerXml) {
    try {
      final document = XmlDocument.parse(scannerXml);

      final respElement = document.findAllElements('Resp').first;
      final errCode = respElement.getAttribute('errCode');

      if (errCode != '0') {
        final errInfo = respElement.getAttribute('errInfo') ?? '';
        throw Exception('Biometric capture failed: $errCode $errInfo');
      }

      // ✅ Extract Data
      final dataElement = document.findAllElements('Data').firstWhere((e) => e.getAttribute('type') == 'X');

      final biometricData = dataElement.innerText.trim();

      // ✅ Extract Hmac
      final hmacElement = document.findAllElements('Hmac').first;
      final hmac = hmacElement.innerText.trim();

      // ✅ Extract Skey + ci attribute
      final skeyElement = document.findAllElements('Skey').first;
      final skey = skeyElement.innerText.trim();
      final ci = skeyElement.getAttribute('ci') ?? '';

      final qScore = respElement.getAttribute('qScore');

      return {'data': biometricData, 'hmac': hmac, 'skey': skey, 'ci': ci, 'qualityScore': qScore, 'success': true};
    } catch (e) {
      throw Exception('Failed to parse scanner XML: $e');
    }
  }

  //   String buildMasRequest(String aadhaarNumber, String biometricData) {
  //     return '''<?xml version="1.0" encoding="UTF-8"?>
  // <MAS_Request>
  //   <AadhaarNumber>$aadhaarNumber</AadhaarNumber>
  //   <BiometricData>$biometricData</BiometricData>
  //   <BiometricType>FMR</BiometricType>
  // </MAS_Request>''';
  //   }
  String buildMasRequest({required String aadhaarNumber, required String data, required String hmac, required String skey, required String ci}) {
    return '''<?xml version="1.0" encoding="UTF-8"?>
<MAS_Request>

  <AadhaarNumber>$aadhaarNumber</AadhaarNumber>

  <Skey ci="$ci">
    $skey
  </Skey>

  <Hmac>
    $hmac
  </Hmac>

  <Data type="X">
    $data
  </Data>

  <BiometricType>FMR</BiometricType>

</MAS_Request>''';
  }

  Map<String, dynamic> buildApiBody(String aadhaar, String applicationID, String rdService, String pidXml) {
    final document = XmlDocument.parse(pidXml);

    /// PID DATA
    final dataElement = document.findAllElements('Data').firstWhere((e) => e.getAttribute('type') == 'X');

    final skeyElement = document.findAllElements('Skey').first;
    final hmacElement = document.findAllElements('Hmac').first;

    final data = dataElement.innerText.trim();
    final dataType = dataElement.getAttribute('type') ?? "X";

    final skey = skeyElement.innerText.trim();
    final skeyCI = skeyElement.getAttribute('ci') ?? "";

    final hmac = hmacElement.innerText.trim();

    /// DEVICE INFO
    final deviceInfoElement = document.findAllElements('DeviceInfo').first;

    final dpId = deviceInfoElement.getAttribute('dpId') ?? "";
    final rdsId = deviceInfoElement.getAttribute('rdsId') ?? "";
    final rdsVer = deviceInfoElement.getAttribute('rdsVer') ?? "";
    final dc = deviceInfoElement.getAttribute('dc') ?? "";
    final mi = deviceInfoElement.getAttribute('mi') ?? "";
    final mc = deviceInfoElement.getAttribute('mc') ?? "";

    return {
      "aadhaar": aadhaar,
      "biometricType": "FMR",
      "application_id": applicationID,
      "rd_service": rdService,

      "pidData": {"skey": skey, "skeyCI": skeyCI, "hmac": hmac, "data": data, "dataType": dataType},
      "deviceInfo": {"dpId": dpId, "rdsId": rdsId, "rdsVer": rdsVer, "dc": dc, "mi": mi, "mc": mc},
    };
  }

  Future<Map?> startCapture(String selectedDevice) async {
    const channel = MethodChannel("rd_service_channel");

    String action = "in.gov.uidai.rdservice.fp.CAPTURE";
    String packageName = "";
    String xml = captureRequestXML;

    if (selectedDevice == "Precision L1") {
      // packageName = "com.precision.pb510.rdservice";
      packageName = "";

      /// keep your existing precision xml
      xml = captureRequestXML;
    } else if (selectedDevice == "Mantra L1") {
      packageName = "";

      /// separate mantra xml
      xml =
          "<?xml version=\"1.0\"?>"
          "<PidOptions ver=\"1.0\">"
          "<Opts fCount=\"1\" fType=\"0\" format=\"0\" "
          "pidVer=\"2.0\" timeout=\"15000\" "
          "env=\"PP\" posh=\"UNKNOWN\"/>"
          "</PidOptions>";
    } else if (selectedDevice == "Morpho L1") {
      packageName = "";

      /// later morpho support
      xml = captureRequestXML;
    } else {
      throw Exception("Please select device");
    }

    final response = await channel.invokeMethod("openRdService", {"action": action, "extras": xml, "package": packageName});

    return response;
  }

  String getRdServiceName() {
    final selectedDevice = context.read<AadhaarKycProvider>().selectedDevice;

    if (selectedDevice == "Mantra L1") {
      return "mantra";
    } else if (selectedDevice == "Precision L1") {
      return "precision";
    }

    return "mantra";
  }
}

// import 'dart:developer';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:icici_bank/core/constants/app_assets.dart';
// import 'package:icici_bank/core/util/app_preference.dart';
// import 'package:icici_bank/ui/widgets/custom_dialog_success.dart';
// import 'package:icici_bank/ui/widgets/rd_service.dart';
// import 'package:provider/provider.dart';
// import 'package:xml/xml.dart';
//
// import '../../core/network/api_client.dart';
// import '../../core/network/network_api.dart';
// import '../../providers/aadhaar_verification_provider/aadhaar_kyc_provider.dart';
// import '../../providers/biometric_kyc_provider/dialog_box_provider.dart';
//
// class CustomBiometricDialogBox extends StatefulWidget {
//   const CustomBiometricDialogBox({super.key});
//
//   @override
//   State<CustomBiometricDialogBox> createState() =>
//       _CustomBiometricDialogBoxState();
// }
//
// class _CustomBiometricDialogBoxState extends State<CustomBiometricDialogBox> {
//   String? aadhaarCardNo = '';
//   final ApiClient _apiClient = ApiClient();
//
//   /*Example pid options*/
//   // final String captureRequestXML =
//   //     "<?xml version=\"1.0\"?> "
//   //     "<PidOptions ver=\"1.0\"> "
//   //     "<Opts fCount=\"1\" fType=\"0\" format=\"0\" pidVer=\"2.0\" "
//   //     "timeout=\"10000\" env=\"P\" posh=\"UNKNOWN\" /> </PidOptions>";
//
//   /// While creating Production Developer needs to change env "S" to "P"
//   /// While creating Staging Developer needs to change env "S"
//   /// While creating Pre-Production Developer needs to change env "PP"
//   final String captureRequestXML =
//       "<?xml version=\"1.0\"?> "
//       "<PidOptions ver=\"1.0\"> "
//       "<Opts fCount=\"1\" fType=\"2\" format=\"0\" pidVer=\"2.0\" "
//       "timeout=\"10000\" wadh=\"E0jzJ/P8UopUHAieZn8CKqS4WPMi5ZSYXgfnlfkWjrc=\" env=\"PP\" posh=\"UNKNOWN\"/>"
//       "<Demo></Demo>"
//       "<CustOpts>"
//       "</CustOpts>"
//       "</PidOptions>";
//
//   /// old
//   // final String captureRequestXML =
//   //     "<?xml version=\"1.0\"?> "
//   //     "<PidOptions ver=\"1.0\"> "
//   //     "<Opts fCount=\"1\" fType=\"0\" format=\"0\" pidVer=\"2.0\" "
//   //     "timeout=\"15000\" env=\"PP\" posh=\"UNKNOWN\" /> "
//   //     "</PidOptions>";
//
//   // final String captureRequestXML =
//   //     "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
//   //          "<PidOptions ver=\"1.0\">"
//   //          "<Opts fCount=\"1\" fType=\"2\" format=\"0\" pidVer=\"2.0\" "
//   //          "timeout=\"10000\" env=\"PP\" posh=\"UNKNOWN\" "
//   //          "bt=\"FMR\"/>"
//   //          "<Demo/>"
//   //          "<CustOpts/>"
//   //          "</PidOptions>";
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     aadhaarCardNo = AppPreference.getAadhaarCardNo();
//     log("Aadhaar Card No: $aadhaarCardNo");
//     _init();
//   }
//
//   void _init() async {
//     await initiateCapture();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final dialogProvider = Provider.of<DialogBoxProvider>(context);
//     final size = MediaQuery.of(context).size;
//
//     return Dialog(
//       backgroundColor: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
//       child: SizedBox(
//         height: 350,
//         width: 240,
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Spacer(),
//               // Image.asset(AppAssets.iciciLogo,height: 80,width: 30,),
//               _buildLogo(size),
//               SizedBox(height: size.height * 0.02),
//               // SizedBox(height: 60,),
//               Spacer(),
//               // GestureDetector(
//               //   onTap: () {
//               //     // dialogProvider.closeDialog();
//               //     // Navigator.pop(context); // close dialog
//               //     // showDialog(
//               //     //   context: context,
//               //     //   barrierDismissible: false,
//               //     //   builder: (_) => const CustomDialogSuccess(),
//               //     // );
//               //   },
//               //   child: Image.asset(
//               //     'assets/finger_print.png',
//               //     height: 150,
//               //     fit: BoxFit.contain,
//               //   ),
//               // ),
//
//               /// ✅ LOADER REPLACES FINGERPRINT IMAGE HERE
//               Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   CircularProgressIndicator(
//                     color: Color(0xFFFF6B00),
//                     strokeWidth: 3.0,
//                   ),
//                   SizedBox(height: 16),
//                   Text(
//                     "Scanning fingerprint...",
//                     style: TextStyle(
//                       fontSize: 13,
//                       fontFamily: 'Poppins',
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ],
//               ),
//               Spacer(),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   "Please wait for the verification to complete. You will be automatically redirected.",
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontFamily: 'Poppins',
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//               Spacer(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLogo(Size size) =>
//       Center(child: Image.asset(AppAssets.iciciLogo, width: size.width * 0.25));
//
//   // Future<void> initiateCapture() async {
//   //   final response = await RdService.openRdService(
//   //     "in.gov.uidai.rdservice.fp.CAPTURE",
//   //     captureRequestXML,
//   //   );
//   //
//   //   log('Response initiateCapture: ${response.toString()}');
//   //
//   //
//   //   // setState(() {
//   //   //   text = response != null ? response.toString() : "No response";
//   //   // });
//   // }
//
//   // Future<void> initiateCapture() async {
//   //   log("Waiting for fingerprint capture before try...");
//   //   try {
//   //     log("Waiting for fingerprint capture...");
//   //
//   //     final response = await RdService.openRdService(
//   //       "in.gov.uidai.rdservice.fp.CAPTURE",
//   //       captureRequestXML,
//   //     );
//   //
//   //     log("Fingerprint capture completed");
//   //
//   //     final pidXmlString = response['PID_DATA'];
//   //
//   //     if (pidXmlString == null) {
//   //       log("PID_DATA not found");
//   //       return;
//   //     }
//   //
//   //     // 🔎 Parse XML manually first to detect spoof
//   //     final document = XmlDocument.parse(pidXmlString);
//   //     final respElement = document.findAllElements('Resp').first;
//   //
//   //     final errCode = respElement.getAttribute('errCode');
//   //     final errInfo = respElement.getAttribute('errInfo') ?? '';
//   //
//   //     log("errCode: $errCode");
//   //     log("errInfo: $errInfo");
//   //
//   //     // ❌ STOP if error
//   //     if (errCode != '0') {
//   //       log("Capture failed: $errCode $errInfo");
//   //       return;
//   //     }
//   //
//   //     // ❌ STOP if spoof detected
//   //     if (errInfo.toLowerCase().contains("spoof")) {
//   //       log("Spoof detected! Navigation blocked.");
//   //       return;
//   //     }
//   //
//   //     // ✅ Now safe to parse properly
//   //     final parsedData = parseScannerResponse(pidXmlString);
//   //
//   //     final biometricData = parsedData['biometricData'];
//   //     final qualityScore = parsedData['qualityScore'];
//   //
//   //     log("Biometric Data Length: ${biometricData.length}");
//   //     log("Quality Score: $qualityScore");
//   //
//   //     // ❌ Optional: block if quality low
//   //     if (qualityScore != null && int.parse(qualityScore) < 40) {
//   //       log("Quality too low. Do not proceed.");
//   //       return;
//   //     }
//   //     log('Biometric Aadhar Data: $aadhaarCardNo');
//   //     // ✅ Build MAS request
//   //     final masRequestXml = buildMasRequest(
//   //       aadhaarCardNo!,
//   //       biometricData,
//   //     );
//   //
//   //     log("MAS Request XML Created: $masRequestXml");
//   //
//   //     // ✅ Only here navigate
//   //     // Navigator.push(...);
//   //
//   //   } catch (e) {
//   //     log("Error in initiateCapture: $e");
//   //   }
//   // }
//   int _retryCount = 0;
//   final int _maxRetries = 3;
//
//   // Future<void> initiateCapture() async {
//   //   try {
//   //     log("Starting fingerprint capture... Attempt: ${_retryCount + 1}");
//   //
//   //     final response = await RdService.openRdService(
//   //       "in.gov.uidai.rdservice.fp.CAPTURE",
//   //       captureRequestXML,
//   //     );
//   //     log("Fingerprint capture completed response: $response");
//   //     final pidXmlString = response['PID_DATA'];
//   //     log("Fingerprint capture completed: $pidXmlString");
//   //
//   //     if (pidXmlString == null) {
//   //       log("PID_DATA not found");
//   //       return;
//   //     }
//   //
//   //     final document = XmlDocument.parse(pidXmlString);
//   //     final respElement = document.findAllElements('Resp').first;
//   //
//   //     final errCode = respElement.getAttribute('errCode') ?? '';
//   //     final errInfo = respElement.getAttribute('errInfo') ?? '';
//   //
//   //     log("errCode: $errCode");
//   //     log("errInfo: $errInfo");
//   //
//   //     // ❌ SPOOF DETECTED → STOP COMPLETELY
//   //     if (errInfo.toLowerCase().contains("spoof")) {
//   //       log("Spoof detected! Capture stopped.");
//   //       return;
//   //     }
//   //
//   //     // ❌ TIMEOUT → RETRY
//   //     if (errCode == '720') {
//   //       log("Capture timeout detected");
//   //
//   //       if (_retryCount < _maxRetries) {
//   //         _retryCount++;
//   //         log("Retrying capture...");
//   //         await initiateCapture();
//   //       } else {
//   //         log("Max retries reached. Stopping capture.");
//   //       }
//   //       return;
//   //     }
//   //
//   //     // ❌ OTHER ERROR
//   //     if (errCode != '0') {
//   //       log("Capture failed: $errCode $errInfo");
//   //       return;
//   //     }
//   //
//   //     // ✅ SUCCESS
//   //     _retryCount = 0; // reset retries
//   //
//   //     final parsedData = parseScannerResponse(pidXmlString);
//   //
//   //     final biometricData = parsedData['biometricData'];
//   //     final qualityScore = parsedData['qualityScore'];
//   //
//   //     log("Biometric Data Length: ${biometricData.length}");
//   //     log("Quality Score: $qualityScore");
//   //
//   //     // ❌ Block if low quality
//   //     if (qualityScore != null && int.parse(qualityScore) < 40) {
//   //       log("Quality too low. Please try again.");
//   //       return;
//   //     }
//   //
//   //     final masRequestXml = buildMasRequest(aadhaarCardNo!, biometricData);
//   //
//   //     final token = AppPreference.getAccessToken();
//   //
//   //     log("MAS Request XML Created Successfully: $masRequestXml");
//   //
//   //     // ✅ NOW YOU CAN NAVIGATE
//   //     // Navigator.push(...);
//   //
//   //     final responseFingerprint = await _apiClient.postXml(
//   //       NetworkApi.biometricCapture,
//   //       masRequestXml,
//   //       token!,
//   //     );
//   //     log('responseFingerprint.toString()');
//   //     log(responseFingerprint.toString());
//   //     log('responseFingerprint.toString()');
//   //   } catch (e) {
//   //     log("Error in initiateCapture: $e");
//   //   }
//   // }
//   Future<void> initiateCapture() async {
//     try {
//       log("Starting fingerprint capture... Attempt: ${_retryCount + 1}");
//
//       final response = await RdService.openRdService(
//         "in.gov.uidai.rdservice.fp.CAPTURE",
//         captureRequestXML,
//       );
//
//       final pidXmlString = response['PID_DATA'];
//       log('Fingerprint capture completed PID Data: $pidXmlString');
//
//       if (pidXmlString == null) {
//         log("PID_DATA not found");
//         return;
//       }
//
//       /// Parse XML
//       final document = XmlDocument.parse(pidXmlString);
//       final respElement = document.findAllElements('Resp').first;
//
//       final errCode = respElement.getAttribute('errCode') ?? '';
//       final errInfo = respElement.getAttribute('errInfo') ?? '';
//
//       log("errCode: $errCode");
//       log("errInfo: $errInfo");
//
//       /// ❌ SPOOF DETECTED → STOP (NO RETRY, NO NAVIGATION)
//       if (errInfo.toLowerCase().contains("spoof")) {
//         log("Spoof fingerprint detected. Blocking capture.");
//
//         if (mounted) {
//           Navigator.pop(context);
//
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text(
//                 "Spoof fingerprint detected. Please use a real finger.",
//               ),
//             ),
//           );
//         }
//
//         return;
//       }
//
//       /// ❌ TIMEOUT → RETRY
//       if (errCode == '720') {
//         log("Capture timeout detected");
//
//         if (_retryCount < _maxRetries) {
//           _retryCount++;
//           log("Retrying capture...");
//           await initiateCapture();
//         } else {
//           log("Max retries reached. Stopping capture.");
//         }
//         return;
//       }
//
//       /// ❌ OTHER ERROR
//       if (errCode != '0') {
//         log("Capture failed: $errCode $errInfo");
//         return;
//       }
//
//       /// ✅ SUCCESS
//       _retryCount = 0;
//
//       /// Extract Data (PID block)
//       final dataElement = document
//           .findAllElements('Data')
//           .firstWhere((e) => e.getAttribute('type') == 'X');
//
//       final data = dataElement.innerText.trim();
//
//       /// Extract Hmac
//       final hmacElement = document.findAllElements('Hmac').first;
//       final hmac = hmacElement.innerText.trim();
//
//       /// Extract Skey + ci
//       final skeyElement = document.findAllElements('Skey').first;
//       final skey = skeyElement.innerText.trim();
//       final ci = skeyElement.getAttribute('ci') ?? '';
//
//       /// Quality Score
//       final qualityScore = respElement.getAttribute('qScore');
//
//       log("Quality Score: $qualityScore");
//
//       /// ❌ Block low quality
//       if (qualityScore != null && int.parse(qualityScore) < 40) {
//         log("Fingerprint quality too low. Please try again.");
//         return;
//       }
//
//       /// Aadhaar + Token
//       final aadhaarNumber = aadhaarCardNo ?? '';
//       final token = AppPreference.getAccessToken();
//
//       /// Build MAS XML
//       final masRequestXml = buildMasRequest(
//         aadhaarNumber: aadhaarNumber,
//         data: data,
//         hmac: hmac,
//         skey: skey,
//         ci: ci,
//       );
//
//       log("MAS Request XML Created Successfully $masRequestXml");
//
//       /// API CALL
//       // final responseFingerprint = await _apiClient.postXml(
//       //   NetworkApi.biometricCapture,
//       //   masRequestXml,
//       //   token!,
//       // );
//
//       /*
//       * {
//   "aadhaar": "984485104074",
//   "pidData": {
//     "skey": "0Ssuw1fN2J1maoaT6AcOxhccp0lW48Et2QbtiOlyZ6ZK...",
//     "skeyCI": "20300811",
//     "hmac": "MSH7MaXBYRBlK5s0fSpGafl5/Owcd3hbn/xr9xysKKlk4hs7a/S7CurmZPC/mKT9",
//     "data": "MjAyNi0wMy0wNFQxMjo0OTowMclwIUoN61mAx5K2nvAg...",
//     "dataType": "X"
//   },
//   "deviceInfo": {
//     "dpId": "PRECISION.PB",
//     "rdsId": "L1.PRECISION.WIN.001",
//     "rdsVer": "1.2.3",
//     "dc": "3b8c0425-fdf3-45f7-beab-b6cb8c1f2560",
//     "mi": "PB1000",
//     "mc": "MIIEKjCCAxKgAwIBAgII..."
//   },
//   "biometricType": "FMR"
// }
// * */
//
//       /// This is new code to parse the PID data XML
//       // Map<String, dynamic> buildApiBody(String pidXml, String aadhaar, String applicationID) {
//       //   final document = XmlDocument.parse(pidXml);
//       //
//       //   /// PID DATA
//       //   final dataElement = document
//       //       .findAllElements('Data')
//       //       .firstWhere((e) => e.getAttribute('type') == 'X');
//       //
//       //   final skeyElement = document.findAllElements('Skey').first;
//       //   final hmacElement = document.findAllElements('Hmac').first;
//       //
//       //   final data = dataElement.innerText.trim();
//       //   final dataType = dataElement.getAttribute('type') ?? "X";
//       //
//       //   final skey = skeyElement.innerText.trim();
//       //   final skeyCI = skeyElement.getAttribute('ci') ?? "";
//       //
//       //   final hmac = hmacElement.innerText.trim();
//       //
//       //   /// DEVICE INFO
//       //   final deviceInfoElement = document.findAllElements('DeviceInfo').first;
//       //
//       //   final dpId = deviceInfoElement.getAttribute('dpId') ?? "";
//       //   final rdsId = deviceInfoElement.getAttribute('rdsId') ?? "";
//       //   final rdsVer = deviceInfoElement.getAttribute('rdsVer') ?? "";
//       //   final dc = deviceInfoElement.getAttribute('dc') ?? "";
//       //   final mi = deviceInfoElement.getAttribute('mi') ?? "";
//       //   final mc = deviceInfoElement.getAttribute('mc') ?? "";
//       //
//       //   ///this is the request body which will be sendwhile api call
//       //   return {
//       //     "aadhaar": aadhaar,
//       //     "biometricType": "FMR",
//       //     "application_id":applicationID,
//       //     "pidData": {
//       //       "skey": skey,
//       //       "skeyCI": skeyCI,
//       //       "hmac": hmac,
//       //       "data": data,
//       //       "dataType": dataType,
//       //     },
//       //     "deviceInfo": {
//       //       "dpId": dpId,
//       //       "rdsId": rdsId,
//       //       "rdsVer": rdsVer,
//       //       "dc": dc,
//       //       "mi": mi,
//       //       "mc": mc,
//       //     }
//       //   };
//       // }
//
//       Map<String, dynamic> buildApiBody(
//         String aadhaar,
//         String applicationID,
//         String pidXml,
//       ) {
//         log("PID XML RECEIVED: $pidXml");
//
//         final document = XmlDocument.parse(pidXml);
//
//         /// PID DATA
//         final dataElement = document
//             .findAllElements('Data')
//             .firstWhere((e) => e.getAttribute('type') == 'X');
//
//         final skeyElement = document.findAllElements('Skey').first;
//         final hmacElement = document.findAllElements('Hmac').first;
//
//         final data = dataElement.innerText.trim();
//         final dataType = dataElement.getAttribute('type') ?? "X";
//
//         final skey = skeyElement.innerText.trim();
//         final skeyCI = skeyElement.getAttribute('ci') ?? "";
//
//         final hmac = hmacElement.innerText.trim();
//
//         log("PID DATA PARSED");
//         log("DataType: $dataType");
//         log("SkeyCI: $skeyCI");
//         log("Hmac Length: ${hmac.length}");
//
//         /// DEVICE INFO
//         final deviceInfoElement = document.findAllElements('DeviceInfo').first;
//
//         final dpId = deviceInfoElement.getAttribute('dpId') ?? "";
//         final rdsId = deviceInfoElement.getAttribute('rdsId') ?? "";
//         final rdsVer = deviceInfoElement.getAttribute('rdsVer') ?? "";
//         final dc = deviceInfoElement.getAttribute('dc') ?? "";
//         final mi = deviceInfoElement.getAttribute('mi') ?? "";
//         final mc = deviceInfoElement.getAttribute('mc') ?? "";
//
//         log("DEVICE INFO");
//         log("dpId: $dpId");
//         log("rdsId: $rdsId");
//         log("rdsVer: $rdsVer");
//         log("dc: $dc");
//         log("mi: $mi");
//         log("mc: $mc");
//
//         final body = {
//           "aadhaar": aadhaar,
//           "biometricType": "FMR",
//           "application_id": applicationID,
//           "pidData": {
//             "skey": skey,
//             "skeyCI": skeyCI,
//             "hmac": hmac,
//             "data": data,
//             "dataType": dataType,
//           },
//           "deviceInfo": {
//             "dpId": dpId,
//             "rdsId": rdsId,
//             "rdsVer": rdsVer,
//             "dc": dc,
//             "mi": mi,
//             "mc": mc,
//           },
//         };
//
//         log("FINAL API BODY: $body");
//
//         return body;
//       }
//
//       final aadhaarProvider = context.read<AadhaarKycProvider>();
//       final String applicationId = aadhaarProvider.applicationId.toString();
//       log('applicationId.toString()');
//       log(applicationId.toString());
//       log('applicationId.toString()');
//
//       ///actual request body
//       ///
//       final Map<String, dynamic> body = buildApiBody(
//         aadhaarNumber,
//         applicationId,
//         pidXmlString,
//       );
//       log(
//         "================================ Fingerprint API Request: ************************************",
//       );
//       log("Request Data:- ${body.toString()}");
//
//       ///API call
//       final responseFingerprint = await _apiClient.post(
//         NetworkApi.biometricCapture,
//         body,
//       );
//
//       log(
//         "================================ Fingerprint API Response: ************************************",
//       );
//       log("Response Data:-${responseFingerprint.toString()}");
//       log("Response Data:-${responseFingerprint["success"].toString()}");
//       log("Response Data:-${responseFingerprint["message"].toString()}");
//       log(
//         "Response Data:-${responseFingerprint['data']['ResCode'].toString()}",
//       );
//       log("Response Data:-${responseFingerprint['data']['ResMsg'].toString()}");
//       log(
//         "================================ Fingerprint API Response Complete ************************************",
//       );
//
//       /// ✅ SUCCESS FLOW - after successful API response
//       if (responseFingerprint["success"] == true &&
//           responseFingerprint['data']['ResMsg'].toString().toLowerCase() ==
//               "success") {
//         Navigator.pop(context);
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (_) => const CustomDialogSuccess(),
//         );
//       } else {
//         log("Error in response API.");
//       }
//     } catch (e) {
//       log("Error in initiateCapture: $e");
//     }
//   }
//
//   // Map<String, dynamic> parseScannerResponse(String scannerXml) {
//   //   try {
//   //     log("Starting XML parsing...");
//   //
//   //     // Parse XML
//   //     final document = XmlDocument.parse(scannerXml);
//   //     log("XML Parsed Successfully");
//   //
//   //     // Get <Resp> element
//   //     final respElements = document.findAllElements('Resp');
//   //     if (respElements.isEmpty) {
//   //       log("Resp element not found");
//   //       throw Exception('Invalid scanner response');
//   //     }
//   //
//   //     final respElement = respElements.first;
//   //     log("Resp element found");
//   //
//   //     // Check errCode
//   //     final errCode = respElement.getAttribute('errCode');
//   //     log("errCode: $errCode");
//   //
//   //     if (errCode != '0') {
//   //       final errInfo = respElement.getAttribute('errInfo') ?? '';
//   //       log("Capture failed: $errCode $errInfo");
//   //       throw Exception('Biometric capture failed: $errCode $errInfo');
//   //     }
//   //
//   //     log("Biometric capture successful");
//   //
//   //     // Extract biometric data from <Data type="X">
//   //     XmlElement? dataElement;
//   //
//   //     final dataElements = document.findAllElements('Data');
//   //     log("Total Data elements found: ${dataElements.length}");
//   //
//   //     for (var element in dataElements) {
//   //       if (element.getAttribute('type') == 'X') {
//   //         dataElement = element;
//   //         break;
//   //       }
//   //     }
//   //
//   //     if (dataElement == null) {
//   //       log("Biometric data not found with type X");
//   //       throw Exception('Biometric data not found');
//   //     }
//   //
//   //     final biometricData = dataElement.innerText.trim();
//   //     log("Biometric data extracted");
//   //
//   //     if (biometricData.isEmpty) {
//   //       log("Biometric data is empty");
//   //       throw Exception('Biometric data is empty');
//   //     }
//   //
//   //     // Optional: Get quality score
//   //     final qScore = respElement.getAttribute('qScore');
//   //     log("Quality Score: $qScore");
//   //
//   //     log("parseScannerResponse completed successfully");
//   //
//   //     return {
//   //       'biometricData': biometricData,
//   //       'qualityScore': qScore,
//   //       'success': true,
//   //     };
//   //   } catch (e) {
//   //     log("Error while parsing XML: $e");
//   //     throw Exception('Failed to parse scanner XML: $e');
//   //   }
//   // }
//   Map<String, dynamic> parseScannerResponse(String scannerXml) {
//     try {
//       final document = XmlDocument.parse(scannerXml);
//
//       final respElement = document.findAllElements('Resp').first;
//       final errCode = respElement.getAttribute('errCode');
//
//       if (errCode != '0') {
//         final errInfo = respElement.getAttribute('errInfo') ?? '';
//         throw Exception('Biometric capture failed: $errCode $errInfo');
//       }
//
//       // ✅ Extract Data
//       final dataElement = document
//           .findAllElements('Data')
//           .firstWhere((e) => e.getAttribute('type') == 'X');
//
//       final biometricData = dataElement.innerText.trim();
//
//       // ✅ Extract Hmac
//       final hmacElement = document.findAllElements('Hmac').first;
//       final hmac = hmacElement.innerText.trim();
//
//       // ✅ Extract Skey + ci attribute
//       final skeyElement = document.findAllElements('Skey').first;
//       final skey = skeyElement.innerText.trim();
//       final ci = skeyElement.getAttribute('ci') ?? '';
//
//       final qScore = respElement.getAttribute('qScore');
//
//       return {
//         'data': biometricData,
//         'hmac': hmac,
//         'skey': skey,
//         'ci': ci,
//         'qualityScore': qScore,
//         'success': true,
//       };
//     } catch (e) {
//       throw Exception('Failed to parse scanner XML: $e');
//     }
//   }
//
//   //   String buildMasRequest(String aadhaarNumber, String biometricData) {
//   //     return '''<?xml version="1.0" encoding="UTF-8"?>
//   // <MAS_Request>
//   //   <AadhaarNumber>$aadhaarNumber</AadhaarNumber>
//   //   <BiometricData>$biometricData</BiometricData>
//   //   <BiometricType>FMR</BiometricType>
//   // </MAS_Request>''';
//   //   }
//   String buildMasRequest({
//     required String aadhaarNumber,
//     required String data,
//     required String hmac,
//     required String skey,
//     required String ci,
//   }) {
//     return '''<?xml version="1.0" encoding="UTF-8"?>
// <MAS_Request>
//
//   <AadhaarNumber>$aadhaarNumber</AadhaarNumber>
//
//   <Skey ci="$ci">
//     $skey
//   </Skey>
//
//   <Hmac>
//     $hmac
//   </Hmac>
//
//   <Data type="X">
//     $data
//   </Data>
//
//   <BiometricType>FMR</BiometricType>
//
// </MAS_Request>''';
//   }
// }
