class ResetPasswordModel {
  final bool success;
  final String message;
  final ResetPasswordData? data;

  ResetPasswordModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory ResetPasswordModel.fromJson(Map<String, dynamic> json) {
    return ResetPasswordModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? ResetPasswordData.fromJson(json['data'])
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

class ResetPasswordData {
  final String resetAt;

  ResetPasswordData({
    required this.resetAt,
  });

  factory ResetPasswordData.fromJson(Map<String, dynamic> json) {
    return ResetPasswordData(
      resetAt: json['reset_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reset_at': resetAt,
    };
  }
}