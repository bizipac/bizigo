class ForgotPasswordModel {
  final bool success;
  final String message;
  final ForgotPasswordData data;

  ForgotPasswordModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ForgotPasswordModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ForgotPasswordData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class ForgotPasswordData {
  final int userId;
  final String mobileMasked;
  final int otpExpiry;
  final int expiresIn;

  ForgotPasswordData({
    required this.userId,
    required this.mobileMasked,
    required this.otpExpiry,
    required this.expiresIn,
  });

  factory ForgotPasswordData.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordData(
      userId: json['user_id'] ?? 0,
      mobileMasked: json['mobile_masked'] ?? '',
      otpExpiry: json['otp_expiry'] ?? 0,
      expiresIn: json['expires_in'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'mobile_masked': mobileMasked,
      'otp_expiry': otpExpiry,
      'expires_in': expiresIn,
    };
  }
}