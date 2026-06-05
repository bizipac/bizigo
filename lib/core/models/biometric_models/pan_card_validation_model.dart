class PanCardValidationModel {
  final bool? success;
  final String? message;
  final PanCardData? data;

  PanCardValidationModel({
    this.success,
    this.message,
    this.data,
  });

  factory PanCardValidationModel.fromJson(Map<String, dynamic> json) {
    return PanCardValidationModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? PanCardData.fromJson(json['data']) : null,
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

class PanCardData {
  final String? applicationId;
  final String? panNumber;
  final String? panName;
  final String? panDob;
  final String? validationStatus;
  final bool? nameMatch;
  final bool? dobMatch;
  final bool? panVerified;
  final bool? fatherNameMatch;
  final PanDetails? panDetails;
  final PanValidationErrors? validationErrors;

  PanCardData({
    this.applicationId,
    this.panNumber,
    this.panName,
    this.panDob,
    this.validationStatus,
    this.nameMatch,
    this.dobMatch,
    this.panVerified,
    this.fatherNameMatch,
    this.panDetails,
    this.validationErrors,
  });

  factory PanCardData.fromJson(Map<String, dynamic> json) {
    return PanCardData(
      applicationId: json['application_id'],
      panNumber: json['pan_number'],
      panName: json['pan_name'],
      panDob: json['pan_dob'],
      validationStatus: json['validation_status'],
      nameMatch: json['name_match'],
      panVerified: json['pan_verified'],
      fatherNameMatch: json['father_name_match'],
      dobMatch: json['dob_match'],
      panDetails: json['pan_details'] != null
          ? PanDetails.fromJson(json['pan_details'])
          : null,
      validationErrors: json['validation_errors'] != null
          ? PanValidationErrors.fromJson(json['validation_errors'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'application_id': applicationId,
      'pan_number': panNumber,
      'pan_name': panName,
      'pan_dob': panDob,
      'validation_status': validationStatus,
      'name_match': nameMatch,
      'dob_match': dobMatch,
      'pan_verified': panVerified,
      'father_name_match': fatherNameMatch,
      'pan_details': panDetails?.toJson(),
      'validation_errors': validationErrors?.toJson(),
    };
  }
}

class PanDetails {
  final String? panNumber;
  final String? name;
  final String? fatherName;
  final String? dob;
  final String? panStatus;
  final String? seedingStatus;

  PanDetails({
    this.panNumber,
    this.name,
    this.fatherName,
    this.dob,
    this.panStatus,
    this.seedingStatus,
  });

  factory PanDetails.fromJson(Map<String, dynamic> json) {
    return PanDetails(
      panNumber: json['pan_number'],
      name: json['name'],
      fatherName: json['father_name'],
      dob: json['dob'],
      panStatus: json['pan_status'],
      seedingStatus: json['seeding_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pan_number': panNumber,
      'name': name,
      'father_name': fatherName,
      'dob': dob,
      'pan_status': panStatus,
      'seeding_status': seedingStatus,
    };
  }
}

class PanValidationErrors {
  final String? name;
  final String? fatherName;
  final String? dob;

  PanValidationErrors({this.name, this.fatherName, this.dob});

  factory PanValidationErrors.fromJson(Map<String, dynamic> json) {
    return PanValidationErrors(
      name: json['name'],
      fatherName: json['father_name'],
      dob: json['dob'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'father_name': fatherName,
      'dob': dob,
    };
  }
}