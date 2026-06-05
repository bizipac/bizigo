class VerifyOtpModel {
  final bool success;
  final String message;
  final VerifyOtpData? data;

  VerifyOtpModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory VerifyOtpModel.fromJson(Map<String, dynamic> json) {
    return VerifyOtpModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? VerifyOtpData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class VerifyOtpData {
  final String resetToken;
  final int resetTokenExpiry;
  final int expiresIn;

  VerifyOtpData({
    required this.resetToken,
    required this.resetTokenExpiry,
    required this.expiresIn,
  });

  factory VerifyOtpData.fromJson(Map<String, dynamic> json) {
    return VerifyOtpData(
      resetToken: json['reset_token'] ?? '',
      resetTokenExpiry: json['reset_token_expiry'] ?? 0,
      expiresIn: json['expires_in'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reset_token': resetToken,
      'reset_token_expiry': resetTokenExpiry,
      'expires_in': expiresIn,
    };
  }
}