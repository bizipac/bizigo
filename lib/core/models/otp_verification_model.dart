class OtpVerificationModel {
  final bool success;
  final String message;
  final OtpData? data;

  OtpVerificationModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory OtpVerificationModel.fromJson(Map<String, dynamic> json) {
    return OtpVerificationModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? OtpData.fromJson(json['data'])
          : (json['token'] != null || json['access_token'] != null)
              ? OtpData.fromJson(json)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data?.toJson()};
  }
}

class OtpData {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final AgentInfo? agentInfo;

  OtpData({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    this.agentInfo,
  });

  factory OtpData.fromJson(Map<String, dynamic> json) {
    return OtpData(
      accessToken: (json['access_token'] ?? json['token'] ?? '').toString(),
      refreshToken: (json['refresh_token'] ?? '').toString(),
      tokenType: (json['token_type'] ?? 'Bearer').toString(),
      expiresIn: json['expires_in'] is int
          ? json['expires_in']
          : int.tryParse(json['expires_in']?.toString() ?? '0') ?? 0,
      agentInfo: json['agent_info'] != null
          ? AgentInfo.fromJson(json['agent_info'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'agent_info': agentInfo?.toJson(),
    };
  }
}

class AgentInfo {
  final int agentId;
  final String agentName;
  final String email;
  final int mobile;
  final int branchId;
  final String branchName;
  final String deviceCompliance;
  final String deviceType;

  AgentInfo({
    required this.agentId,
    required this.agentName,
    required this.email,
    required this.mobile,
    required this.branchId,
    required this.branchName,
    required this.deviceCompliance,
    required this.deviceType,
  });

  factory AgentInfo.fromJson(Map<String, dynamic> json) {
    return AgentInfo(
      agentId: json['agent_id'] is int
          ? json['agent_id']
          : int.tryParse(json['agent_id']?.toString() ?? '0') ?? 0,
      agentName: json['agent_name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] is int
          ? json['mobile']
          : int.tryParse(json['mobile']?.toString() ?? '0') ?? 0,
      branchId: json['branch_id'] is int
          ? json['branch_id']
          : int.tryParse(json['branch_id']?.toString() ?? '0') ?? 0,
      branchName: json['branch_name'] ?? '',
      deviceCompliance: json['device_compliance'] ?? '',
      deviceType: json['device_type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agent_id': agentId,
      'agent_name': agentName,
      'email': email,
      'mobile': mobile,
      'branch_id': branchId,
      'branch_name': branchName,
      'device_compliance': deviceCompliance,
      'device_type': deviceType,
    };
  }
}
