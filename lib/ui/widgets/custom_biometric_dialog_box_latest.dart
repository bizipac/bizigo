import 'dart:convert';
import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class CustomBiometricDialogBoxLatest extends StatefulWidget {
  const CustomBiometricDialogBoxLatest({super.key});

  @override
  State<CustomBiometricDialogBoxLatest> createState() =>
      _CustomBiometricDialogBoxState();
}

class _CustomBiometricDialogBoxState extends State<CustomBiometricDialogBoxLatest> {
  String? aadhaarCardNo = '';
  final ApiClient _apiClient = ApiClient();

  /// precision device
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


  // ✅ Generate fresh WADH before each capture
  // String buildPrecisionPidXml() {
  //   final wadh = generateWadh();
  //   return '<?xml version="1.0"?>'
  //       '<PidOptions ver="1.0">'
  //       '<Opts fCount="1" fType="2" format="0" pidVer="2.0" '
  //       'timeout="10000" wadh="$wadh" env="PP" posh="UNKNOWN"/>'
  //       '<Demo></Demo>'
  //       '<CustOpts></CustOpts>'
  //       '</PidOptions>';
  // }


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
              _buildLogo(size),
              SizedBox(height: size.height * 0.02),
              Spacer(),

              /// ✅ LOADER REPLACES FINGERPRINT IMAGE HERE
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

  /// below code is developeed for Mantra Scanner device
  String PIDOption = '', Data = '';

  // Future<String> getPidDataMantra() async {
  //   String finalPIDdata = '';
  //   String ver = '';
  //   String Opts = '';
  //   String CustOpts = '';
  //   //Version
  //   ver = "1.0";
  //   // Opts
  //   String fCount = '1';
  //   String fType = '0';
  //   String iCount = '0';
  //   String iType = '0';
  //   String pCount = '0';
  //   String pType = '0';
  //   String format = '0';
  //   String pidVer = '2.0';
  //   String timeout = '10000';
  //   String otp;
  //   String wadh;
  //   String env = 'PP';
  //   String pTimeout = '20000';
  //   String pgCount = '2';
  //   String posh = "UNKNOWN";
  //   Opts =
  //       "<Opts env='$env' fCount='$fCount' fType='$fType' format='$format' iCount='$iCount' iType='$iType' pCount='$pCount' pTimeout='$pTimeout' pType='$pType' pgCount='$pgCount' pidVer='$pidVer' posh='$posh' timeout='$timeout'/>";
  //   //CustOpts
  //   String name = '';
  //   String value = '';
  //   CustOpts = " <CustOpts>" + "<Param/>" + "</CustOpts>";
  //   // CustOpts = '<CustOpts>' +
  //   //     "<Param name='$name' value='$value' /> " +
  //   //     '</CustOpts>';
  //   //PIDData FinalDaat
  //   finalPIDdata =
  //       "<PidOptions ver='$ver'>" + '$CustOpts' + '$Opts' + "</PidOptions>";
  //   print('finalPIDdata  : $finalPIDdata');
  //   // String PIDData="<PidOptions ver=\"1.0\">\n" +
  //   // "       <CustOpts>\n" +
  //   // "          <Param/>\n" +
  //   // "       </CustOpts>\n" +
  //   // "       <Opts env=\"S\" fCount=\"1\" fType=\"0\" format=\"0\" iCount=\"0\" iType=\"0\" pCount=\"0\" pTimeout=\"20000\" pType=\"0\" pgCount=\"2\" pidVer=\"2.0\" posh=\"UNKNOWN\" timeout=\"10000\"/>\n" +
  //   // "    </PidOptions>";
  //   return finalPIDdata;
  // }
  Future<Map<String, String>> getPidDataMantra() async {
    log('🟢 Inside getPidDataMantra()');
    final wadh = generateWadh(); // ✅ generate here
    log('🔴 WADH: $wadh');

    String env = 'PP'; // use P for production
    String fCount = '1';
    String fType = '2'; // ✅ IMPORTANT
    String format = '0';
    String iCount = '0';
    String iType = '0';
    String pCount = '0';
    String pType = '0';
    String pidVer = '2.0';
    String timeout = '10000';
    String posh = "UNKNOWN";

    final pidXml = '''
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

    return {
      "pidXml": pidXml,
      "wadh": wadh, // ✅ return this also
    };
  }
  /// end of developement of mantra scanner device
  // String generateWadh() {
  //   final now = DateTime.now();
  //   log('generateWadh Now: $now ');
  //   final ts = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(now);
  //   log('generateWadh ts: $ts');
  //
  //   final raw = "$ts" "2.5" "$ts" "FYNNN";
  //   log('generateWadh raw: $raw');
  //
  //   final hash = sha256.convert(utf8.encode(raw));
  //   log('generateWadh hash: $hash');
  //   log('generateWadh base64Encode(hash.bytes)): ${base64Encode(hash.bytes).replaceAll('\n', '')}');
  //   return base64Encode(hash.bytes).replaceAll('\n', '');
  // }

  String generateWadh() {
    const rawWadh = "2.5FYNNN";

    final hash = sha256.convert(utf8.encode(rawWadh));

    return base64Encode(hash.bytes).trim();
  }

  Future<void> initiateCapture() async {
    try {
      final selectedDevice = context.read<AadhaarKycProvider>().selectedDevice;

      /// for safe device check
      if (selectedDevice.isEmpty) {
        log("No device selected");
        Navigator.pop(context);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Please select device")));
        return;
      }
      log("Selected Device: $selectedDevice");
      // log("RD Service Name: ${getRdServiceName()}");
      log("Device Mapping Verified");

      log("Starting fingerprint capture... Attempt: ${_retryCount + 1}");

      if (selectedDevice.toString().toLowerCase().startsWith('precision')) {

        final response = await RdService.openRdService(
          "in.gov.uidai.rdservice.fp.CAPTURE",
          captureRequestXML, // static
          // buildPrecisionPidXml(),  // dynamic
        );

        final pidXmlString = response['PID_DATA'];
        log('Fingerprint capture completed PID Data: $pidXmlString');

        if (pidXmlString == null) {
          log("PID_DATA not found");
          return;
        }

        /// Parse XML
        final document = XmlDocument.parse(pidXmlString);
        final respElement = document.findAllElements('Resp').first;

        final errCode = respElement.getAttribute('errCode') ?? '';
        final errInfo = respElement.getAttribute('errInfo') ?? '';

        log("errCode: $errCode");
        log("errInfo: $errInfo");

        /// ❌ SPOOF DETECTED → STOP (NO RETRY, NO NAVIGATION)
        if (errInfo.toLowerCase().contains("spoof")) {
          log("Spoof fingerprint detected. Blocking capture.");

          if (mounted) {
            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Spoof fingerprint detected. Please use a real finger.",
                ),
              ),
            );
          }

          return;
        }

        /// ❌ TIMEOUT → RETRY
        if (errCode == '720') {
          log("Capture timeout detected");

          if (_retryCount < _maxRetries) {
            _retryCount++;
            log("Retrying capture...");
            await initiateCapture();
          } else {
            log("Max retries reached. Stopping capture.");
          }
          return;
        }

        /// ❌ OTHER ERROR
        if (errCode != '0') {
          log("Capture failed: $errCode $errInfo");
          return;
        }

        /// ✅ SUCCESS
        _retryCount = 0;

        /// Extract Data (PID block)
        final dataElement = document
            .findAllElements('Data')
            .firstWhere((e) => e.getAttribute('type') == 'X');

        final data = dataElement.innerText.trim();

        /// Extract Hmac
        final hmacElement = document.findAllElements('Hmac').first;
        final hmac = hmacElement.innerText.trim();

        /// Extract Skey + ci
        final skeyElement = document.findAllElements('Skey').first;
        final skey = skeyElement.innerText.trim();
        final ci = skeyElement.getAttribute('ci') ?? '';

        /// Quality Score
        final qualityScore = respElement.getAttribute('qScore');

        log("Quality Score: $qualityScore");

        /// ❌ Block low quality
        if (qualityScore != null && int.parse(qualityScore) < 40) {
          log("Fingerprint quality too low. Please try again.");
          return;
        }

        /// Aadhaar + Token
        final aadhaarNumber = aadhaarCardNo ?? '';
        final token = AppPreference.getAccessToken();

        /// Build MAS XML
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

          /// PID DATA
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

          /// DEVICE INFO
          final deviceInfoElement = document
              .findAllElements('DeviceInfo')
              .first;

          final dpId = deviceInfoElement.getAttribute('dpId') ?? "";
          final rdsId = deviceInfoElement.getAttribute('rdsId') ?? "";
          final rdsVer = deviceInfoElement.getAttribute('rdsVer') ?? "";
          final dc = deviceInfoElement.getAttribute('dc') ?? "";
          final mi = deviceInfoElement.getAttribute('mi') ?? "";
          final mc = deviceInfoElement.getAttribute('mc') ?? "";

          log("DEVICE INFO");
          log("dpId: $dpId");
          log("rdsId: $rdsId");
          log("rdsVer: $rdsVer");
          log("dc: $dc");
          log("mi: $mi");
          log("mc: $mc");

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
        log('applicationId.toString()');
        log(applicationId.toString());
        log('applicationId.toString()');

        ///actual request body
        ///a
        final Map<String, dynamic> body = buildApiBody(
          aadhaarNumber,
          applicationId,
          pidXmlString,
        );
        log(
          "================================ Fingerprint API Request: ************************************",
        );
        log("Request Data:- ${body.toString()}");

        ///API call
        final responseFingerprint = await _apiClient.post(
          NetworkApi.biometricCapture,
          body,
        );

        log(
          "================================ Fingerprint API Response: ************************************",
        );
        log("Response Data:-${responseFingerprint.toString()}");
        log("Response Data:-${responseFingerprint["success"].toString()}");
        log("Response Data:-${responseFingerprint["message"].toString()}");
        log(
          "Response Data:-${responseFingerprint['data']['ResCode'].toString()}",
        );
        log(
          "Response Data:-${responseFingerprint['data']['ResMsg'].toString()}",
        );
        log(
          "================================ Fingerprint API Response Complete ************************************",
        );

        /// ✅ SUCCESS FLOW - after successful API response
        if (responseFingerprint["success"] == true &&
            responseFingerprint['data']['ResMsg'].toString().toLowerCase() ==
                "success") {
          Navigator.pop(context);
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const CustomDialogSuccess(),
          );
        } else {
          log("Error in response API.");
        }
      }
      // else if (selectedDevice.toString().toLowerCase().startsWith('mantra')) {
      //   log('🟢 Inside Mantra condition');
      //
      //   try {
      //     log('📡 Calling getPidDataMantra()...');
      //     String pidData = await getPidDataMantra();
      //
      //     log('📄 Received PID Data: $pidData');
      //
      //     if (pidData == null) {
      //       log('⚠️ PID Data is null, returning...');
      //       return;
      //     }
      //
      //     setState(() {
      //       PIDOption = pidData;
      //     });
      //     log('✅ PIDOption updated');
      //
      //     log('📲 Calling RdSample.captureData()...');
      //     Data = await RdSample.captureData(pidData);
      //
      //     log('📥 Capture Data Response: $Data');
      //
      //     setState(() {
      //       Data;
      //     });
      //
      //     log('🎉 Mantra process completed successfully');
      //   } on PlatformException catch (e) {
      //     log('❌ PlatformException occurred: ${e.message}');
      //     debugPrint("Error PlatformException : '${e.message}'.");
      //   } catch (e) {
      //     log('🔥 Unexpected Error: $e');
      //   }
      // }
      else if (selectedDevice.toString().toLowerCase().startsWith('mantra')) {
        log('🟢 Inside Mantra condition');

        try {
          // String pidData = await getPidDataMantra();
          //
          // log('📄 PID Request XML: $pidData');
          //
          // Data = await RdSample.captureData(pidData);
          final result = await getPidDataMantra();

          final pidXml = result["pidXml"]!;
          final wadh = result["wadh"]!;

          Data = await RdSample.captureData(pidXml);
          log('📥 Capture Data Response: $Data');

          if (Data.isEmpty) {
            log("❌ No data received from Mantra");
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

          log("================================");
          log("MANTRA API BODY");
          log(body.toString());
          log("================================");

          ///API call
          final responseFingerprint = await _apiClient.post(
            NetworkApi.biometricCapture,
            body,
          );

          log(
            "================================ Fingerprint API Response: ************************************",
          );
          log("Response Data:-${responseFingerprint.toString()}");
          log("Response Data:-${responseFingerprint["success"].toString()}");
          log("Response Data:-${responseFingerprint["message"].toString()}");
          log(
            "Response Data:-${responseFingerprint['data']['ResCode'].toString()}",
          );
          log(
            "Response Data:-${responseFingerprint['data']['ResMsg'].toString()}",
          );
          log(
            "================================ Fingerprint API Response Complete ************************************",
          );

          /// ✅ SUCCESS FLOW - after successful API response
          // if (responseFingerprint["success"] == true && responseFingerprint['data']['ResMsg'].toString().toLowerCase() == "success") {
          //   Navigator.pop(context);
          //   showDialog(context: context, barrierDismissible: false, builder: (_) => const CustomDialogSuccess());
          // }
          if (responseFingerprint["success"] == true &&
              responseFingerprint['data']['ResMsg'].toString().toLowerCase() ==
                  "success") {
            Navigator.pop(context);

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const CustomDialogSuccess(),
            );

            /// ⏳ ADD TIMER HERE
            Future.delayed(const Duration(seconds: 2), () {
              if (context.mounted) {
                Navigator.pop(context);

                Navigator.pushReplacementNamed(context, '/nextScreen');
                // OR
                // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => NextScreen()));
              }
            });
          } else {
            log("Error in response API.");
          }
        } catch (e) {
          log("❌ Mantra Error: $e");
        }
      }
    } catch (e) {
      log("Error in initiateCapture: $e");
    }
  }

  Map<String, dynamic> buildApiBodyForMantra(
    String aadhaar,
    String applicationID,
    String pidXml,
      String wadh
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
      final dataElement = document
          .findAllElements('Data')
          .firstWhere((e) => e.getAttribute('type') == 'X');

      final biometricData = dataElement.innerText.trim();

      // ✅ Extract Hmac
      final hmacElement = document.findAllElements('Hmac').first;
      final hmac = hmacElement.innerText.trim();

      // ✅ Extract Skey + ci attribute
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
