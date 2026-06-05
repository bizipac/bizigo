class AadhaarOtpModel {
  final bool success;
  final String message;
  final AadhaarOtpData? data;

  AadhaarOtpModel({required this.success, required this.message, this.data});

  factory AadhaarOtpModel.fromJson(Map<String, dynamic> json) {
    return AadhaarOtpModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? AadhaarOtpData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data?.toJson()};
  }
}

class AadhaarOtpData {
  final String applicationId;
  final String aadhaarSessionId;
  final String transactionId;
  final String aadhaarType;
  final String aadhaarNumberMasked;
  final String status;
  final String taxResidentStatus;
  final String fatcaCrs;
  final dynamic taxCertificationDetails;
  final String pepStatus;
  final dynamic pepType;
  final bool termsAccepted;
  final bool otpSent;

  AadhaarOtpData({
    required this.applicationId,
    required this.aadhaarSessionId,
    required this.transactionId,
    required this.aadhaarType,
    required this.aadhaarNumberMasked,
    required this.status,
    required this.taxResidentStatus,
    required this.fatcaCrs,
    this.taxCertificationDetails,
    required this.pepStatus,
    this.pepType,
    required this.termsAccepted,
    required this.otpSent,
  });

  factory AadhaarOtpData.fromJson(Map<String, dynamic> json) {
    return AadhaarOtpData(
      applicationId: json['application_id'] ?? '',
      aadhaarSessionId: json['aadhaar_session_id'] ?? '',
      transactionId: json['transaction_id'] ?? '',
      aadhaarType: json['aadhaar_type'] ?? '',
      aadhaarNumberMasked: json['aadhaar_number_masked'] ?? '',
      status: json['status'] ?? '',
      taxResidentStatus: json['tax_resident_status'] ?? '',
      fatcaCrs: json['fatca_crs'] ?? '',
      taxCertificationDetails: json['tax_certification_details'],
      pepStatus: json['pep_status'] ?? '',
      pepType: json['pep_type'],
      termsAccepted: json['terms_accepted'] ?? false,
      otpSent: json['otp_sent'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'application_id': applicationId,
      'aadhaar_session_id': aadhaarSessionId,
      'transaction_id': transactionId,
      'aadhaar_type': aadhaarType,
      'aadhaar_number_masked': aadhaarNumberMasked,
      'status': status,
      'tax_resident_status': taxResidentStatus,
      'fatca_crs': fatcaCrs,
      'tax_certification_details': taxCertificationDetails,
      'pep_status': pepStatus,
      'pep_type': pepType,
      'terms_accepted': termsAccepted,
      'otp_sent': otpSent,
    };
  }
}
