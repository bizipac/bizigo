import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:icici_bank/config.dart';
import '../../core/network/api_client.dart';
import '../../core/network/network_api.dart';
import '../../core/models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  bool isProductValidated = false;
  String? categoryError;
  String? productError;
  String? cardError;
  String? proxyError;

  // List<ProductItem> _allProducts = [];
  // List<ProductItem> filteredProducts = [];

  // ProductItem? selectedProduct;

  void resetValidation() {
    isProductValidated = false;
    notifyListeners();
  }

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  ProductModel? _productModel;

  ProductModel? get productModel => _productModel;

  String? selectedCategory;
  Product? selectedProduct;

  final cardNumberController = TextEditingController();
  final proxyNumberController = TextEditingController();

  /// 🔹 PRODUCT VALIDATION
  // bool validateProductForm({required String kycType}) {
  //   categoryError = null;
  //   productError = null;
  //   cardError = null;
  //   proxyError = null;
  //
  //   bool isValid = true;
  //
  //   // 🔹 CASE 1 → All empty
  //   if (selectedCategory == null &&
  //       selectedProduct == null &&
  //       (kycType.toLowerCase() != 'non-personalized' || (cardNumberController.text.isEmpty && proxyNumberController.text.isEmpty))) {
  //     categoryError = "Please select product category";
  //     productError = "Please select product code";
  //     isValid = false;
  //
  //     notifyListeners();
  //     return false;
  //   }
  //
  //   // 🔹 Category validation
  //   if (selectedCategory == null) {
  //     categoryError = "Product category is mandatory";
  //     isValid = false;
  //   }
  //
  //   // 🔹 Product validation
  //   if (selectedProduct == null) {
  //     productError = "Product code selection is mandatory";
  //     isValid = false;
  //   }
  //
  //   // 🔹 Non-personalized fields
  //   if (kycType.toLowerCase() == 'non-personalized') {
  //     final cardNo = cardNumberController.text.trim();
  //     final proxyNo = proxyNumberController.text.trim();
  //
  //     if (cardNo.isEmpty) {
  //       cardError = "Card number is required";
  //       isValid = false;
  //     } else if (!RegExp(r'^[0-9]{16}$').hasMatch(cardNo)) {
  //       cardError = "Enter valid 16 digit card number";
  //       isValid = false;
  //     }
  //
  //     if (proxyNo.isEmpty) {
  //       proxyError = "Proxy number is required";
  //       isValid = false;
  //     } else if (!RegExp(r'^[0-9]{10}$').hasMatch(proxyNo)) {
  //       proxyError = "Enter valid 10 digit proxy number";
  //       isValid = false;
  //     }
  //   }
  //
  //   notifyListeners();
  //   return isValid;
  // }
  bool validateProductForm({required String kycType}) {
    categoryError = null;
    productError = null;
    cardError = null;
    proxyError = null;

    bool isValid = true;

    if (selectedCategory == null || selectedCategory!.isEmpty) {
      categoryError = "Please select product category";
      isValid = false;
    }

    if (selectedProduct == null) {
      productError = "Please select product code";
      isValid = false;
    }

    if (kycType.toLowerCase() == 'non-personalized') {
      final cardNo = cardNumberController.text.trim();
      final proxyNo = proxyNumberController.text.trim();

      if (cardNo.isEmpty) {
        cardError = "Card number is required";
        isValid = false;
      } else if (!RegExp(r'^[0-9]{16}$').hasMatch(cardNo)) {
        cardError = "Enter valid 16 digit card number";
        isValid = false;
      }

      if (proxyNo.isEmpty) {
        proxyError = "Proxy number is required";
        isValid = false;
      } else if (!RegExp(r'^[0-9]{9}$').hasMatch(proxyNo)) {
        proxyError = "Enter valid 9 digit proxy number";
        isValid = false;
      }
    }

    notifyListeners();
    return isValid;
  }

  /// 🔹 Get unique product categories
  List<String> get productCategories {
    if (_productModel == null) return [];
    return _productModel!.data.map((e) => e.productCategory).toSet().toList();
  }

  /// 🔹 Filter products by selected category
  List<Product> get filteredProducts {
    if (selectedCategory == null) return [];
    return _productModel!.data.where((e) => e.productCategory == selectedCategory).toList();
  }

  void selectCategory(String category) {
    selectedCategory = category;
    selectedProduct = null;
    categoryError = null;
    productError = null;
    notifyListeners();
  }

  void selectProduct(Product product) {
    selectedProduct = product;
    productError = null;
    notifyListeners();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  /// Product data fetch
  Future<ProductModel> fetchProductdata({required String type, required String cardType}) async {
    _setLoading(true);
    try {
      final Map<String, dynamic> body = {"type": "products", "card_type": cardType};
      final response = AppConfig.useNewApi
          ? await _apiClient.get(NetworkApi.productMaster)
          : await _apiClient.post(NetworkApi.getMasterData, body);
      log('Response 82:: $response');

      final productModel = ProductModel.fromJson(response);
      log('Response 85:: $productModel');
      _productModel = productModel;
      notifyListeners();
      return productModel;
    } catch (e, stackTrace) {
      log(e.toString(), error: stackTrace);

      _productModel = ProductModel(success: false, message: 'Something went wrong', data: []);

      notifyListeners();
      return _productModel!;
    } finally {
      _setLoading(false);
    }
  }

  /// Product Validation
  // Future<ProductModel> validateProduct() async {
  //   _setLoading(true);
  //   try {
  //     final Map<String, dynamic> body = {
  //       ///for Non-Personalized
  //       "application_id": "KYC202512122591",
  //       "product_code": "VISA001",
  //       "card_number": "1234567890123456",
  //       "proxy_number": "9876543210",
  //
  //       ///for Personalized
  //       "application_id": "KYC202512122591",
  //       "product_code": "VISA001",
  //     };
  //     final response = await _apiClient.post(NetworkApi.getMasterData, body);
  //     log('test 1:: $response');
  //
  //     final productModel = ProductModel.fromJson(response);
  //     log('test 2:: $productModel');
  //     _productModel = productModel;
  //     notifyListeners();
  //     return productModel;
  //   } catch (e, stackTrace) {
  //     log(e.toString(), error: stackTrace);
  //
  //     _productModel = ProductModel(success: false, message: 'Something went wrong', data: []);
  //
  //     notifyListeners();
  //     return _productModel!;
  //   } finally {
  //     _setLoading(false);
  //   }
  // }
}
