import 'dart:convert';
import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icici_bank/config.dart';
import 'package:icici_bank/core/constants/app_assets.dart';
import 'package:icici_bank/core/util/app_preference.dart';
import 'package:icici_bank/ui/widgets/custom_dialog_success.dart';
import 'package:icici_bank/ui/widgets/rd_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rd_sample/rd_sample.dart';
import 'package:xml/xml.dart';

import '../../core/network/api_client.dart';
import '../../core/network/network_api.dart';
import '../../providers/aadhaar_verification_provider/aadhaar_kyc_provider.dart';
import '../../providers/biometric_kyc_provider/dialog_box_provider.dart';

class CustomBiometricDialogBox extends StatefulWidget {
  const CustomBiometricDialogBox({super.key});

  @override
  State<CustomBiometricDialogBox> createState() =>
      _CustomBiometricDialogBoxState();
}

class _CustomBiometricDialogBoxState extends State<CustomBiometricDialogBox> {
  String? aadhaarCardNo = '';
  final ApiClient _apiClient = ApiClient();

  final String captureRequestXML =
      "<?xml version=\"1.0\"?> "
      "<PidOptions ver=\"1.0\"> "
      "<Opts fCount=\"1\" fType=\"2\" format=\"0\" pidVer=\"2.0\" "
      "timeout=\"10000\" wadh=\"E0jzJ/P8UopUHAieZn8CKqS4WPMi5ZSYXgfnlfkWjrc=\" env=\"PP\" posh=\"UNKNOWN\"/>"
      "<Demo></Demo>"
      "<CustOpts>"
      "</CustOpts>"
      "</PidOptions>";

  @override
  void initState() {
    super.initState();
    aadhaarCardNo = AppPreference.getAadhaarCardNo();
    log("Aadhaar Card No: $aadhaarCardNo");
    _init();
  }

  void _init() async {
    await initiateCapture();
  }

  // ✅ Show red error toast AND close the biometric dialog
  void _showErrorAndPop(String message) {
    if (!mounted) return;
    Navigator.pop(context); // close biometric scanning dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ✅ Show green success toast (dialog stays open until redirect)
  void _showSuccessToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
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
              _buildLogo(size),
              SizedBox(height: size.height * 0.02),
              Spacer(),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFFFF6B00),
                    strokeWidth: 3.0,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Scanning fingerprint...",
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Please wait for the verification to complete. You will be automatically redirected.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(Size size) =>
      Center(child: Image.asset(AppAssets.iciciLogo, width: size.width * 0.25));

  int _retryCount = 0;
  final int _maxRetries = 3;

  String PIDOption = '', Data = '';

  Future<Map<String, String>> getPidDataMantra() async {
    log('🟢 Inside getPidDataMantra()');
    final wadh = generateWadh();
    log('🔴 WADH: $wadh');

    String env = 'PP';
    String fCount = '1';
    String fType = '2';
    String format = '0';
    String iCount = '0';
    String iType = '0';
    String pCount = '0';
    String pType = '0';
    String pidVer = '2.0';
    String timeout = '10000';
    String posh = "UNKNOWN";

    final pidXml =
        '''
<PidOptions ver="2.0">
   <Opts 
     env="$env"
     fCount="$fCount"
     fType="$fType"
     format="$format"
     iCount="$iCount"
     iType="$iType"
     pCount="$pCount"
     pType="$pType"
     pidVer="$pidVer"
     posh="$posh"
     timeout="$timeout"
     wadh="$wadh"/>
</PidOptions>
''';

    log("PID XML with WADH: $pidXml");

    return {"pidXml": pidXml, "wadh": wadh};
  }

  String generateWadh() {
    const rawWadh = "2.5FYNNN";
    final hash = sha256.convert(utf8.encode(rawWadh));
    return base64Encode(hash.bytes).trim();
  }

  Future<void> initiateCapture() async {
    try {
      final selectedDevice = context.read<AadhaarKycProvider>().selectedDevice;

      // ✅ VALIDATION 1: No device selected
      if (selectedDevice.isEmpty) {
        log("No device selected");
        _showErrorAndPop(
          "No device selected. Please go back and select a device.",
        );
        return;
      }

      log("Selected Device: $selectedDevice");
      log("Starting fingerprint capture... Attempt: ${_retryCount + 1}");

      // ─────────────────────────────────────────────
      // PRECISION DEVICE FLOW
      // ─────────────────────────────────────────────
      if (selectedDevice.toString().toLowerCase().startsWith('precision')) {
        final response = await RdService.openRdService(
          "in.gov.uidai.rdservice.fp.CAPTURE",
          captureRequestXML,
        );

        final pidXmlString = response['PID_DATA'];
        log('Fingerprint capture completed PID Data: $pidXmlString');

        // ✅ VALIDATION 2: No PID data received from device
        if (pidXmlString == null) {
          log("PID_DATA not found");
          _showErrorAndPop(
            "Fingerprint scan failed. No data received from device. Please try again.",
          );
          return;
        }

        // Parse XML
        final document = XmlDocument.parse(pidXmlString);
        final respElement = document.findAllElements('Resp').first;

        final errCode = respElement.getAttribute('errCode') ?? '';
        final errInfo = respElement.getAttribute('errInfo') ?? '';

        log("errCode: $errCode");
        log("errInfo: $errInfo");

        // ✅ VALIDATION 3: Spoof fingerprint detected
        if (errInfo.toLowerCase().contains("spoof")) {
          log("Spoof fingerprint detected. Blocking capture.");
          _showErrorAndPop(
            "Spoof fingerprint detected. Please use a real finger and try again.",
          );
          return;
        }

        // ✅ VALIDATION 4: Timeout — retry or show error
        if (errCode == '720') {
          log("Capture timeout detected");
          if (_retryCount < _maxRetries) {
            _retryCount++;
            log("Retrying capture... attempt $_retryCount of $_maxRetries");
            await initiateCapture();
          } else {
            log("Max retries reached. Stopping capture.");
            _showErrorAndPop(
              "Fingerprint scan timed out after $_maxRetries attempts. Please reconnect the device and try again.",
            );
          }
          return;
        }

        // ✅ VALIDATION 5: Other device error codes
        if (errCode != '0') {
          log("Capture failed: $errCode $errInfo");
          _showErrorAndPop(
            "Fingerprint scan failed (Error $errCode: $errInfo). Please try again.",
          );
          return;
        }

        // ✅ SUCCESS — reset retry count
        _retryCount = 0;

        // Extract Data (PID block)
        final dataElement = document
            .findAllElements('Data')
            .firstWhere((e) => e.getAttribute('type') == 'X');

        final data = dataElement.innerText.trim();

        // Extract Hmac
        final hmacElement = document.findAllElements('Hmac').first;
        final hmac = hmacElement.innerText.trim();

        // Extract Skey + ci
        final skeyElement = document.findAllElements('Skey').first;
        final skey = skeyElement.innerText.trim();
        final ci = skeyElement.getAttribute('ci') ?? '';

        // Quality Score
        final qualityScore = respElement.getAttribute('qScore');
        log("Quality Score: $qualityScore");

        // ✅ VALIDATION 6: Low quality fingerprint
        if (qualityScore != null && int.parse(qualityScore) < 40) {
          log("Fingerprint quality too low: $qualityScore");
          _showErrorAndPop(
            "Fingerprint quality too low ($qualityScore/100). Please clean your finger and place it firmly on the scanner.",
          );
          return;
        }

        final aadhaarNumber = aadhaarCardNo ?? '';

        // Build MAS XML
        final masRequestXml = buildMasRequest(
          aadhaarNumber: aadhaarNumber,
          data: data,
          hmac: hmac,
          skey: skey,
          ci: ci,
        );

        log("MAS Request XML Created Successfully $masRequestXml");

        Map<String, dynamic> buildApiBody(
          String aadhaar,
          String applicationID,
          String pidXml,
        ) {
          log("PID XML RECEIVED: $pidXml");

          final document = XmlDocument.parse(pidXml);

          final dataElement = document
              .findAllElements('Data')
              .firstWhere((e) => e.getAttribute('type') == 'X');

          final skeyElement = document.findAllElements('Skey').first;
          final hmacElement = document.findAllElements('Hmac').first;

          final data = dataElement.innerText.trim();
          final dataType = dataElement.getAttribute('type') ?? "X";

          final skey = skeyElement.innerText.trim();
          final skeyCI = skeyElement.getAttribute('ci') ?? "";

          final hmac = hmacElement.innerText.trim();

          log("PID DATA PARSED");
          log("DataType: $dataType");
          log("SkeyCI: $skeyCI");
          log("Hmac Length: ${hmac.length}");

          final deviceInfoElement = document
              .findAllElements('DeviceInfo')
              .first;

          final dpId = deviceInfoElement.getAttribute('dpId') ?? "";
          final rdsId = deviceInfoElement.getAttribute('rdsId') ?? "";
          final rdsVer = deviceInfoElement.getAttribute('rdsVer') ?? "";
          final dc = deviceInfoElement.getAttribute('dc') ?? "";
          final mi = deviceInfoElement.getAttribute('mi') ?? "";
          final mc = deviceInfoElement.getAttribute('mc') ?? "";

          log("DEVICE INFO: dpId=$dpId, rdsId=$rdsId, rdsVer=$rdsVer");

          final body = {
            "aadhaar": aadhaar,
            "biometricType": "FMR",
            "application_id": applicationID,
            "pidData": {
              "skey": skey,
              "skeyCI": skeyCI,
              "hmac": hmac,
              "data": data,
              "dataType": dataType,
            },
            "deviceInfo": {
              "dpId": dpId,
              "rdsId": rdsId,
              "rdsVer": rdsVer,
              "dc": dc,
              "mi": mi,
              "mc": mc,
            },
          };

          log("FINAL API BODY: $body");
          return body;
        }

        final aadhaarProvider = context.read<AadhaarKycProvider>();
        final String applicationId = aadhaarProvider.applicationId.toString();
        log('applicationId: $applicationId');

          final Map<String, dynamic> body = buildApiBody(
            aadhaarNumber,
            applicationId,
            pidXmlString,
          );
          final Map<String, dynamic> requestBody = AppConfig.useNewApi
              ? buildContinueKycBody(
                  aadhaarNumber,
                  applicationId,
                  selectedDevice,
                  pidXmlString,
                )
              : body;

        log(
          "================================ Fingerprint API Request ================================",
        );
          log("Request Data: ${requestBody.toString()}");

          final responseFingerprint = await _apiClient.post(
            AppConfig.useNewApi
                ? NetworkApi.continueKycDialog
                : NetworkApi.biometricCapture,
            requestBody,
          );

        log(
          "================================ Fingerprint API Response ================================",
        );
        log("Response: ${responseFingerprint.toString()}");

        // ✅ VALIDATION 7: Precision API success
        if (AppConfig.useNewApi
            ? responseFingerprint["success"] == true
            : responseFingerprint["success"] == true &&
                responseFingerprint['data']['ResMsg']
                        .toString()
                        .toLowerCase() ==
                    "success") {
          Navigator.pop(context);
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const CustomDialogSuccess(),
          );
        } else {
          // ✅ VALIDATION 8: Precision API returned failure
          log("API returned failure for Precision.");
          final apiMsg = responseFingerprint["message"]?.toString() ?? "";
          _showErrorAndPop(
            apiMsg.isNotEmpty
                ? apiMsg
                : "Biometric verification failed. Please try again.",
          );
        }
      }
      // ─────────────────────────────────────────────
      // MANTRA DEVICE FLOW
      // ─────────────────────────────────────────────
      else if (selectedDevice.toString().toLowerCase().startsWith('mantra')) {
        log('🟢 Inside Mantra condition');

        try {
          final result = await getPidDataMantra();
          final pidXml = result["pidXml"]!;
          final wadh = result["wadh"]!;

          Data = await RdSample.captureData(pidXml);
          log('📥 Capture Data Response: $Data');

          // ✅ VALIDATION 9: No data received from Mantra
          if (Data.isEmpty) {
            log("❌ No data received from Mantra");
            _showErrorAndPop(
              "Fingerprint scan failed. No data received from Mantra device. Please try again.",
            );
            return;
          }

          final aadhaarProvider = context.read<AadhaarKycProvider>();
          final String applicationId = aadhaarProvider.applicationId.toString();
          final aadhaarNumber = aadhaarCardNo ?? '';

          final Map<String, dynamic> body = buildApiBodyForMantra(
            aadhaarNumber,
            applicationId,
            Data,
            wadh,
          );
          final Map<String, dynamic> requestBody = AppConfig.useNewApi
              ? buildContinueKycBody(
                  aadhaarNumber,
                  applicationId,
                  selectedDevice,
                  Data,
                )
              : body;

          log(
            "================================ MANTRA API BODY ================================",
          );
          log(requestBody.toString());

          final responseFingerprint = await _apiClient.post(
            AppConfig.useNewApi
                ? NetworkApi.continueKycDialog
                : NetworkApi.biometricCapture,
            requestBody,
          );

          log(
            "================================ Fingerprint API Response ================================",
          );
          log("Response: ${responseFingerprint.toString()}");

          // ✅ VALIDATION 10: Mantra API success
          if (AppConfig.useNewApi
              ? responseFingerprint["success"] == true
              : responseFingerprint["success"] == true &&
                  responseFingerprint['data']['ResMsg']
                          .toString()
                          .toLowerCase() ==
                      "success") {
            Navigator.pop(context);
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const CustomDialogSuccess(),
            );
          } else {
            // ✅ VALIDATION 11: Mantra API returned failure
            log("API returned failure for Mantra.");
            final apiMsg = responseFingerprint["message"]?.toString() ?? "";
            _showErrorAndPop(
              apiMsg.isNotEmpty
                  ? apiMsg
                  : "Biometric verification failed. Please try again.",
            );
          }
        } catch (e) {
          // ✅ VALIDATION 12: Mantra device/capture exception
          log("❌ Mantra Error: $e");
          _showErrorAndPop(
            "Fingerprint scan error. Please reconnect the Mantra device and try again.",
          );
        }
      }
      // ─────────────────────────────────────────────
      // MORPHO DEVICE FLOW (placeholder)
      // ─────────────────────────────────────────────
      else {
        // ✅ VALIDATION 13: Unknown/unsupported device
        log("Unknown device selected: $selectedDevice");
        _showErrorAndPop(
          "Device '$selectedDevice' is not supported. Please select a valid device.",
        );
      }
    } catch (e) {
      // ✅ VALIDATION 14: Outer unexpected exception
      log("Error in initiateCapture: $e");
      _showErrorAndPop(
        "An unexpected error occurred during fingerprint scan. Please try again.",
      );
    }
  }

  Map<String, dynamic> buildApiBodyForMantra(
    String aadhaar,
    String applicationID,
    String pidXml,
    String wadh,
  ) {
    final document = XmlDocument.parse(pidXml);

    final dataElement = document
        .findAllElements('Data')
        .firstWhere((e) => e.getAttribute('type') == 'X');

    final skeyElement = document.findAllElements('Skey').first;
    final hmacElement = document.findAllElements('Hmac').first;
    final deviceInfoElement = document.findAllElements('DeviceInfo').first;

    final body = {
      "aadhaar": aadhaar,
      "biometricType": "FMR",
      "application_id": applicationID,
      "wadh": wadh,
      "pidData": {
        "skey": skeyElement.innerText.trim(),
        "skeyCI": skeyElement.getAttribute('ci') ?? "",
        "hmac": hmacElement.innerText.trim(),
        "data": dataElement.innerText.trim(),
        "dataType": dataElement.getAttribute('type') ?? "X",
      },
      "deviceInfo": {
        "dpId": deviceInfoElement.getAttribute('dpId') ?? "",
        "rdsId": deviceInfoElement.getAttribute('rdsId') ?? "",
        "rdsVer": deviceInfoElement.getAttribute('rdsVer') ?? "",
        "dc": deviceInfoElement.getAttribute('dc') ?? "",
        "mi": deviceInfoElement.getAttribute('mi') ?? "",
        "mc": deviceInfoElement.getAttribute('mc') ?? "",
      },
    };

    return body;
  }

  Map<String, dynamic> buildContinueKycBody(
    String aadhaar,
    String applicationID,
    String selectedDevice,
    String biometricXml,
  ) {
    final brand = selectedDevice.split(' ').first;

    return {
      "application_id": applicationID,
      "aadhaar_number": aadhaar,
      "device_info": {
        "brand": brand,
        "model": selectedDevice,
      },
      "biometric_data": base64Encode(utf8.encode(biometricXml)),
    };
  }

  Map<String, dynamic> parseScannerResponse(String scannerXml) {
    try {
      final document = XmlDocument.parse(scannerXml);

      final respElement = document.findAllElements('Resp').first;
      final errCode = respElement.getAttribute('errCode');

      if (errCode != '0') {
        final errInfo = respElement.getAttribute('errInfo') ?? '';
        throw Exception('Biometric capture failed: $errCode $errInfo');
      }

      final dataElement = document
          .findAllElements('Data')
          .firstWhere((e) => e.getAttribute('type') == 'X');

      final biometricData = dataElement.innerText.trim();

      final hmacElement = document.findAllElements('Hmac').first;
      final hmac = hmacElement.innerText.trim();

      final skeyElement = document.findAllElements('Skey').first;
      final skey = skeyElement.innerText.trim();
      final ci = skeyElement.getAttribute('ci') ?? '';

      final qScore = respElement.getAttribute('qScore');

      return {
        'data': biometricData,
        'hmac': hmac,
        'skey': skey,
        'ci': ci,
        'qualityScore': qScore,
        'success': true,
      };
    } catch (e) {
      throw Exception('Failed to parse scanner XML: $e');
    }
  }

  String buildMasRequest({
    required String aadhaarNumber,
    required String data,
    required String hmac,
    required String skey,
    required String ci,
  }) {
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
}
