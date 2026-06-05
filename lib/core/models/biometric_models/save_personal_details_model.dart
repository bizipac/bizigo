class SavePersonalDetailsModel {
  final bool? success;
  final String? message;
  final SavePersonalDetailsData? data;

  SavePersonalDetailsModel({
    this.success,
    this.message,
    this.data,
  });

  factory SavePersonalDetailsModel.fromJson(Map<String, dynamic> json) {
    return SavePersonalDetailsModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? SavePersonalDetailsData.fromJson(json['data'])
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

class SavePersonalDetailsData {
  final String? applicationId;
  final String? status;
  final List<dynamic>? validationWarnings;
  final int? fieldsSaved;
  final String? savedAt;

  SavePersonalDetailsData({
    this.applicationId,
    this.status,
    this.validationWarnings,
    this.fieldsSaved,
    this.savedAt,
  });

  factory SavePersonalDetailsData.fromJson(Map<String, dynamic> json) {
    return SavePersonalDetailsData(
      applicationId: json['application_id'],
      status: json['status'],
      validationWarnings: json['validation_warnings'],
      fieldsSaved: json['fields_saved'],
      savedAt: json['saved_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'application_id': applicationId,
      'status': status,
      'validation_warnings': validationWarnings,
      'fields_saved': fieldsSaved,
      'saved_at': savedAt,
    };
  }
}