// class ProductMasterModel {
//   final bool success;
//   final String message;
//   final ProductMasterData? data;
//
//   ProductMasterModel({required this.success, required this.message, this.data});
//
//   factory ProductMasterModel.fromJson(Map<String, dynamic> json) {
//     return ProductMasterModel(
//       success: json['success'] ?? false,
//       message: json['message'] ?? '',
//       data: json['data'] != null
//           ? ProductMasterData.fromJson(json['data'])
//           : null,
//     );
//   }
// }
//
// class ProductMasterData {
//   final String type;
//   final List<ProductItem> masterData;
//   final int count;
//   final String retrievedAt;
//
//   ProductMasterData({
//     required this.type,
//     required this.masterData,
//     required this.count,
//     required this.retrievedAt,
//   });
//
//   factory ProductMasterData.fromJson(Map<String, dynamic> json) {
//     return ProductMasterData(
//       type: json['type'] ?? '',
//       masterData: (json['master_data'] as List? ?? [])
//           .map((e) => ProductItem.fromJson(e))
//           .toList(),
//       count: json['count'] ?? 0,
//       retrievedAt: json['retrieved_at'] ?? '',
//     );
//   }
// }
//
// class ProductItem {
//   final String id;
//   final String productCode;
//   final String productName;
//   final String productCategory;
//   final String cardType;
//   final String status;
//   final String createdAt;
//
//   ProductItem({
//     required this.id,
//     required this.productCode,
//     required this.productName,
//     required this.productCategory,
//     required this.cardType,
//     required this.status,
//     required this.createdAt,
//   });
//
//   factory ProductItem.fromJson(Map<String, dynamic> json) {
//     return ProductItem(
//       id: json['id'] ?? '',
//       productCode: json['product_code'] ?? '',
//       productName: json['product_name'] ?? '',
//       productCategory: json['product_category'] ?? '',
//       cardType: json['card_type'] ?? '',
//       status: json['status'] ?? '',
//       createdAt: json['created_at'] ?? '',
//     );
//   }
// }
class ProductModel {
  final bool success;
  final String message;
  final List<Product> data;

  ProductModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class Product {
  final String id;
  final String productCode;
  final String productName;
  final String productCategory;
  final String cardType;
  final String status;

  Product({
    required this.id,
    required this.productCode,
    required this.productName,
    required this.productCategory,
    required this.cardType,
    required this.status,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      productCode: json['product_code'] ?? '',
      productName: json['product_name'] ?? '',
      productCategory: json['product_category'] ?? '',
      cardType: json['card_type'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_code': productCode,
      'product_name': productName,
      'product_category': productCategory,
      'card_type': cardType,
      'status': status,
    };
  }
}
