class ProductValidationModel {
  final bool? success;
  final String? message;
  final ProductData? data;

  ProductValidationModel({
    this.success,
    this.message,
    this.data,
  });

  factory ProductValidationModel.fromJson(Map<String, dynamic> json) {
    return ProductValidationModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? ProductData.fromJson(json['data']) : null,
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

class ProductData {
  final String? applicationId;
  final String? productCode;
  final String? cardNumber;
  final String? cardStatus;
  final String? validationStatus;

  ProductData({
    this.applicationId,
    this.productCode,
    this.cardNumber,
    this.cardStatus,
    this.validationStatus,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      applicationId: json['application_id'],
      productCode: json['product_code'],
      cardNumber: json['card_number'],
      cardStatus: json['card_status'],
      validationStatus: json['validation_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'application_id': applicationId,
      'product_code': productCode,
      'card_number': cardNumber,
      'card_status': cardStatus,
      'validation_status': validationStatus,
    };
  }
}