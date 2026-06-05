import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:icici_bank/core/util/app_preference.dart';
import 'package:provider/provider.dart';

import '../../../providers/product_provider/product_provider.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_product_textField.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    String? type = AppPreference.getKycType();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<ProductProvider>();
      await provider.fetchProductdata(type: 'products', cardType: type!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        return provider.isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  if (provider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (provider.productModel == null || provider.productModel!.data.isEmpty)
                    const Center(
                      child: Text('No products found', style: TextStyle(color: Colors.white)),
                    )
                  else
                    Column(
                      children: [
                        CustomDropdown(
                          label: "Product Category",
                          hint: "Select Product Category",
                          isRequired: true,
                          items: provider.productCategories,
                          value: provider.selectedCategory,
                          errorText: provider.categoryError,
                          onChanged: (val) {
                            if (val == null) return;
                            provider.selectCategory(val);
                            // biometric.productCategory = val;
                          },
                        ),

                        const SizedBox(height: 10),

                        /// PRODUCT CODE
                        CustomDropdown(
                          label: "Product Code",
                          hint: "Select Product Code",
                          isRequired: true,
                          items: provider.filteredProducts.map((e) => "${e.productCode} – ${e.productName}").toList(),
                          value: provider.selectedProduct == null
                              ? null
                              : "${provider.selectedProduct!.productCode} – "
                                    "${provider.selectedProduct!.productName}",
                          errorText: provider.productError,
                          onChanged: provider.selectedCategory == null
                              ? null
                              : (val) async{
                                  final selected = provider.filteredProducts.firstWhere((e) => "${e.productCode} – ${e.productName}" == val);
                                  log('selected Product code: ${selected.productCode}');
                                  await AppPreference.setProductCode(selected.productCode.toString());

                                  provider.selectProduct(selected);
                                  // biometric.productCode = selected.productCode;
                                  // biometric.productCategory = selected.productCategory;
                                },
                        ),
                        const SizedBox(height: 10),

                        // NON-PERSONALIZED FIELDS
                        if (AppPreference.getKycType().toString().toLowerCase() == 'non-personalized')
                          Column(
                            children: [
                              CustomProductTextfield(
                                label: "Enter 16 digit Card Number",
                                isRequired: true,
                                controller: provider.cardNumberController,
                                keyboardType: TextInputType.number,
                                maxLength: 16,
                                digitsOnly: true,
                                errorText: provider.cardError,
                              ),
                              const SizedBox(height: 10),
                              CustomProductTextfield(
                                label: "Proxy Number",
                                isRequired: true,
                                controller: provider.proxyNumberController,
                                keyboardType: TextInputType.number,
                                maxLength: 9,
                                digitsOnly: true,
                                errorText: provider.proxyError,
                              ),
                            ],
                          ),

                        const SizedBox(height: 16),
                      ],
                    ),
                ],
              );
      },
    );
  }
}
