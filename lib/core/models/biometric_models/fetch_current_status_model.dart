class FetchCurrentStatusModel {
  final bool? status;
  final String? message;
  final String? currentStatus;

  FetchCurrentStatusModel({
    this.status,
    this.message,
    this.currentStatus,
  });

  factory FetchCurrentStatusModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return FetchCurrentStatusModel(
      status: json['success'] ?? json['status'],
      message: json['message'],
      currentStatus: data['current_status']?.toString() ?? data['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'current_status': currentStatus,
    };
  }
}
