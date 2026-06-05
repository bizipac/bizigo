/* -------------------- MAIN RESPONSE -------------------- */

class HomeScreenCardTypesModel {
  final bool success;
  final String message;
  final KycData? data;

  HomeScreenCardTypesModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory HomeScreenCardTypesModel.fromJson(Map<String, dynamic> json) {
    return HomeScreenCardTypesModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? KycData.fromJson(json['data']) : null,
    );
  }
}

/* -------------------- DATA OBJECT -------------------- */

class KycData {
  final List<KycType> kycTypes;
  final int count;
  final String agentId;
  final String retrievedAt;

  KycData({
    required this.kycTypes,
    required this.count,
    required this.agentId,
    required this.retrievedAt,
  });

  factory KycData.fromJson(Map<String, dynamic> json) {
    return KycData(
      kycTypes: (json['kyc_types'] as List<dynamic>? ?? [])
          .map((e) => KycType.fromJson(e))
          .toList(),
      count: json['count'] ?? 0,
      agentId: json['agent_id']?.toString() ?? '',
      retrievedAt: json['retrieved_at'] ?? '',
    );
  }
}

/* -------------------- KYC TYPE -------------------- */

class KycType {
  final String type;
  final String displayName;
  final String description;
  final bool requiresCardNumber;
  final bool cardNumberRequired;
  final bool cardNumberEditable;
  final bool available;
  final List<String> features;

  KycType({
    required this.type,
    required this.displayName,
    required this.description,
    required this.requiresCardNumber,
    required this.cardNumberRequired,
    required this.cardNumberEditable,
    required this.available,
    required this.features,
  });

  factory KycType.fromJson(Map<String, dynamic> json) {
    return KycType(
      type: json['type'] ?? '',
      displayName: json['display_name'] ?? '',
      description: json['description'] ?? '',
      requiresCardNumber: json['requires_card_number'] ?? false,
      cardNumberRequired: json['card_number_required'] ?? false,
      cardNumberEditable: json['card_number_editable'] ?? false,
      available: json['available'] ?? false,
      features: List<String>.from(json['features'] ?? []),
    );
  }
}
