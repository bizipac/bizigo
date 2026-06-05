class CorporateMasterModel {
  final bool success;
  final List<CorporateData> data;

  CorporateMasterModel({
    required this.success,
    required this.data,
  });

  factory CorporateMasterModel.fromJson(Map<String, dynamic> json) {
    return CorporateMasterModel(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => CorporateData.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class CorporateData {
  final String corpId;
  final String name;

  CorporateData({
    required this.corpId,
    required this.name,
  });

  factory CorporateData.fromJson(Map<String, dynamic> json) {
    return CorporateData(
      corpId: json['corp_id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'corp_id': corpId,
      'name': name,
    };
  }
}