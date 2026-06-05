class ApplicationSubmitModel {
  final bool? success;
  final String? message;
  final String? acknowledgementNumber;

  ApplicationSubmitModel({
    this.success,
    this.message,
    this.acknowledgementNumber,
  });

  factory ApplicationSubmitModel.fromJson(Map<String, dynamic> json) {
    return ApplicationSubmitModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      acknowledgementNumber: json['acknowledgement_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'acknowledgement_number': acknowledgementNumber,
    };
  }
}