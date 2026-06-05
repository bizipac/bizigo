class LoginModel {
  final bool success;
  final String message;
  final LoginData? data;

  LoginModel({required this.success, required this.message, this.data});

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data?.toJson()};
  }
}

class LoginData {
  final String otpId;
  //Written By - Shubham Gupta
  final String mobile_number;
  final int otpExpiry;
  final bool testMode;
  final String testOtp;
  final AgentInfo agentInfo;

  LoginData({
    required this.otpId,
    //Written By - Shubham Gupta
    required this.mobile_number,
    required this.otpExpiry,
    required this.testMode,
    required this.testOtp,
    required this.agentInfo,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      otpId: json['otp_id']?.toString() ?? '',
      //Written By - Shubham Gupta
      mobile_number: json['mobile_number']?.toString() ?? '',
      otpExpiry: json['otp_expiry'] is int
          ? json['otp_expiry']
          : int.tryParse(json['otp_expiry']?.toString() ?? '0') ?? 0,
      testMode: json['test_mode'] == true,
      testOtp: json['test_otp']?.toString() ?? '',
      agentInfo: AgentInfo.fromJson(json['agent_info'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'otp_id': otpId,
      //Written By - Shubham Gupta
      'mobile_number': mobile_number,
      'otp_expiry': otpExpiry,
      'test_mode': testMode,
      'test_otp': testOtp,
      'agent_info': agentInfo.toJson(),
    };
  }
}

class AgentInfo {
  final String agentId;
  final String agentName;
  final String mobile;
  final String deviceCompliance;
  final String devicePlatform;
  final String appVersion;

  AgentInfo({
    required this.agentId,
    required this.agentName,
    required this.mobile,
    required this.deviceCompliance,
    required this.devicePlatform,
    required this.appVersion,
  });

  factory AgentInfo.fromJson(Map<String, dynamic> json) {
    return AgentInfo(
      agentId: json['agent_id']?.toString() ?? '',
      agentName: json['agent_name']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      deviceCompliance: json['device_compliance']?.toString() ?? '',
      devicePlatform: json['device_platform']?.toString() ?? '',
      appVersion: json['app_version']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agent_id': agentId,
      'agent_name': agentName,
      'mobile': mobile,
      'device_compliance': deviceCompliance,
      "device_platform": devicePlatform,
      "app_version": appVersion,
    };
  }
}
