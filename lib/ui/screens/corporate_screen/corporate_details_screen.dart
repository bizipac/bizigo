import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../providers/corporate_provider/corporate_details_provider.dart';
import '../../widgets/corporate_custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_text_widget.dart';

class CorporateFormScreen extends StatefulWidget {
  const CorporateFormScreen({super.key});

  @override
  State<CorporateFormScreen> createState() => CorporateFormScreenState();
}

class CorporateFormScreenState extends State<CorporateFormScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _autoValidate = false;

  String? _accountType;
  final List<String> _accountTypeList = [
    'Savings Account',
    'Current Account',
    'Debit Card',
    'Other',
  ];

  final ScrollController _scrollController = ScrollController();

  final _corporateNameKey = GlobalKey();

  final _corporateIdKey = GlobalKey();

  final _address1Key = GlobalKey();

  final _address2Key = GlobalKey();

  final _cityKey = GlobalKey();

  final _stateKey = GlobalKey();

  final _districtKey = GlobalKey();

  final _pincodeKey = GlobalKey();

  final _countryKey = GlobalKey();

  final _landmarkKey = GlobalKey();

  final _bankAccountKey = GlobalKey();

  final _ifscKey = GlobalKey();

  final _iciciAccountKey = GlobalKey();

  final _accountTypeKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<CorporateDetailsProvider>();
      await provider.fetchCorporateData();
    });
  }

  String? _requiredValidator(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'This field is required';
    }

    return null;
  }

  String? _pinCodeValidator(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'This field is required';
    }

    if (!RegExp(r'^[0-9]{6}$').hasMatch(val.trim())) {
      return 'Pincode must be exactly 6 digits';
    }

    return null;
  }

  bool validateCorporateForm() {
    final provider = context.read<CorporateDetailsProvider>();
    setState(() {
      _autoValidate = true;
    });

    /// Corporate Name
    if (provider.selectedName == null) {
      _scrollToField(_corporateNameKey, "Please select corporate name");
      return false;
    }

    /// Corporate ID
    if (provider.corporateId.text.trim().isEmpty) {
      _scrollToField(_corporateIdKey, "Corporate ID required");
      return false;
    }

    /// Address 1
    if (provider.officeAddress.text.trim().isEmpty) {
      _scrollToField(_address1Key, "Corporate address 1 required");
      return false;
    }

    /// Address 2
    if (provider.officeAddress2.text.trim().isEmpty) {
      _scrollToField(_address2Key, "Corporate address 2 required");
      return false;
    }

    /// City
    if (provider.city.text.trim().isEmpty) {
      _scrollToField(_cityKey, "City required");
      return false;
    }

    /// District
    if (provider.district.text.trim().isEmpty) {
      _scrollToField(_districtKey, "District required");
      return false;
    }

    /// State
    if (provider.state.text.trim().isEmpty) {
      _scrollToField(_stateKey, "State required");
      return false;
    }

    /// Pincode
    if (provider.pincode.text.trim().isEmpty ||
        !RegExp(r'^[0-9]{6}$').hasMatch(provider.pincode.text.trim())) {
      _scrollToField(_pincodeKey, "Enter valid 6 digit pincode");
      return false;
    }

    // /// Country
    // if (provider.country.text.trim().isEmpty) {
    //   _scrollToField(_countryKey, "Country required");
    //   return false;
    // }

    /// Landmark
    if (provider.landmark.text.trim().isEmpty) {
      _scrollToField(_landmarkKey, "Landmark required");
      return false;
    }

    /// ICICI customer validation
    if (provider.isICICCustomer) {
      if (provider.bankAccountNumber.text.trim().isEmpty) {
        _scrollToField(_bankAccountKey, "Bank account number required");
        return false;
      }

      if (provider.ifscCode.text.trim().isEmpty) {
        _scrollToField(_ifscKey, "IFSC code required");
        return false;
      }

      if (provider.iciciAccountNumber.text.trim().isEmpty) {
        _scrollToField(_iciciAccountKey, "ICICI account number required");
        return false;
      }

      if (provider.accountType.text.trim().isEmpty) {
        _scrollToField(_accountTypeKey, "Please select account type");
        return false;
      }
    }

    /// validator text
    if (!_formKey.currentState!
        .validate()) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    // final provider = Provider.of<CorporateDetailsProvider>(context);

    return Consumer<CorporateDetailsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Form(
            key: _formKey,
            autovalidateMode: _autoValidate
                ? AutovalidateMode.always
                : AutovalidateMode.disabled,

            child: Column(
              children: [
                if (provider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (provider.corporateMasterModel == null ||
                    provider.corporateMasterModel!.data.isEmpty)
                  const Center(
                    child: Text(
                      'No Corporate Data found',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Employer / Corporate Name
                        // CustomText(label: 'Corporate Name', fontSize: 12, isRequired: true),
                        Container(
                          key: _corporateNameKey,
                          child: CustomDropdown(
                            label: "Corporate Name",
                            hint: "Select corporate name",
                            isRequired: true,
                            items: provider.corporateDataList,
                            value: provider.selectedName,
                            errorText: provider.nameError,
                            validator: _requiredValidator,
                            onChanged: (val) {
                              if (val == null) return;
                              provider.selectName(val);
                              log('Selected Name: $val');
                            },
                          ),
                        ),
                        const SizedBox(height: 5),

                        /// corporate ID
                        CustomText(
                          label: 'Corporate ID',
                          fontSize: 12,
                          isRequired: true,
                        ),
                        const SizedBox(height: 5),

                        Container(
                          key: _corporateIdKey,
                          child: CustomTextField(
                            label: 'Corporate ID',
                            controller: provider.corporateId,
                            isEnabled: false,
                            isRequired: true,
                            errorText: provider.corporateIdError,
                            validator: _requiredValidator,
                          ),
                        ),
                        const SizedBox(height: 5),

                        /// Employer Address 1
                        CustomText(
                          label: 'Corporate Address 1',
                          fontSize: 12,
                          isRequired: true,
                        ),
                        const SizedBox(height: 5),

                        Container(
                          key: _address1Key,
                          child: CustomTextField(
                            label: 'Enter Corporate address 1',
                            controller: provider.officeAddress,
                            isRequired: true,
                            errorText: provider.officeAddressError,
                            validator: _requiredValidator,
                          ),
                        ),
                        const SizedBox(height: 5),

                        /// Employer Address 2
                        CustomText(
                          label: 'Corporate Address 2',
                          fontSize: 12,
                          isRequired: true,
                        ),
                        const SizedBox(height: 5),

                        Container(
                          key: _address2Key,
                          child: CustomTextField(
                            label: 'Enter corporate address 2 ',
                            controller: provider.officeAddress2,
                            isRequired: true,
                            errorText: provider.officeAddressError2,
                            validator: _requiredValidator,
                          ),
                        ),
                        const SizedBox(height: 5),

                        /// City / Town / Village
                        CustomText(
                          label: 'Corporate City/Town/Village',
                          fontSize: 12,
                          isRequired: true,
                        ),
                        const SizedBox(height: 5),

                        Container(
                          key: _cityKey,
                          child: CustomTextField(
                            label: 'Enter corporate city/town/village',
                            controller: provider.city,
                            isRequired: true,
                            errorText: provider.cityError,
                            validator: _requiredValidator,
                          ),
                        ),
                        const SizedBox(height: 5),

                        /// District
                        CustomText(
                          label: 'Corporate District',
                          fontSize: 12,
                          isRequired: true,
                        ),
                        const SizedBox(height: 5),

                        Container(
                          key: _districtKey,
                          child: CustomTextField(
                            label: 'Enter corporate district',
                            controller: provider.district,
                            isRequired: true,
                            errorText: provider.districtError,
                            validator: _requiredValidator,
                          ),
                        ),
                        const SizedBox(height: 5),

                        /// State
                        CustomText(
                          label: 'Corporate State',
                          fontSize: 12,
                          isRequired: true,
                        ),
                        const SizedBox(height: 5),

                        Container(
                          key: _stateKey,
                          child: CustomTextField(
                            label: 'Enter corporate state',
                            controller: provider.state,
                            isRequired: true,
                            errorText: provider.stateError,
                            validator: _requiredValidator,
                          ),
                        ),
                        const SizedBox(height: 5),

                        /// zip / pincode
                        CustomText(
                          label: 'Corporate Zip/Pincode',
                          fontSize: 12,
                          isRequired: true,
                        ),
                        const SizedBox(height: 5),

                        Container(
                          key: _pincodeKey,
                          child: CustomTextField(
                            label: 'Enter corporate zip/pincode',
                            controller: provider.pincode,
                            keyboardType: TextInputType.number,
                            isRequired: true,
                            errorText: provider.pincodeError,
                            validator: _requiredValidator,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),

                        /// country
                        CustomText(
                          label: 'Corporate Country',
                          fontSize: 12,
                          isRequired: false,
                        ),
                        const SizedBox(height: 5),

                        Container(
                          // key: _countryKey,
                          child: CustomTextField(
                            label: 'Enter corporate country',
                            controller: provider.country,
                            isRequired: true,
                            errorText: provider.countryError,
                            // validator: _requiredValidator,
                          ),
                        ),
                        const SizedBox(height: 5),

                        /// landmark
                        CustomText(
                          label: 'Corporate Landmark',
                          fontSize: 12,
                          isRequired: true,
                        ),
                        const SizedBox(height: 5),

                        Container(
                          key: _landmarkKey,
                          child: CustomTextField(
                            label: 'Enter corporate landmark',
                            controller: provider.landmark,
                            isRequired: true,
                            errorText: provider.landmarkError,
                            validator: _requiredValidator,
                          ),
                        ),
                        const SizedBox(height: 5),

                        // /// phone
                        // CustomText(
                        //   label: 'Corporate Phone',
                        //   fontSize: 12,
                        //   isRequired: true,
                        // ),
                        // const SizedBox(height: 5),
                        //
                        // CustomTextField(
                        //   label: 'Enter corporate phone (with STD code)',
                        //   controller: provider.phone,
                        //   isRequired: true,
                        //   keyboardType: TextInputType.phone,
                        //   inputFormatters: [
                        //     FilteringTextInputFormatter.digitsOnly,
                        //     LengthLimitingTextInputFormatter(15),
                        //   ],
                        //   errorText: provider.phoneError,
                        // ),
                        // const SizedBox(height: 5),
                        //
                        // /// mobile
                        // CustomText(
                        //   label: 'Corporate Mobile',
                        //   fontSize: 12,
                        //   isRequired: true,
                        // ),
                        // const SizedBox(height: 5),
                        //
                        // CustomTextField(
                        //   label: 'Enter corporate mobile',
                        //   controller: provider.mobile,
                        //   keyboardType: TextInputType.phone,
                        //   inputFormatters: [
                        //     FilteringTextInputFormatter.digitsOnly,
                        //     LengthLimitingTextInputFormatter(10),
                        //   ],
                        //   isRequired: true,
                        //   errorText: provider.mobileError,
                        // ),
                        // const SizedBox(height: 5),

                        // /// icici relationship number
                        // CustomText(
                        //   label: 'ICICI Relationship Number',
                        //   fontSize: 12,
                        //   isRequired: true,
                        // ),
                        // const SizedBox(height: 5),
                        //
                        // CustomTextField(
                        //   label: 'Enter icici relationship number',
                        //   controller: provider.relationshipNumber,
                        //   isRequired: true,
                        //   errorText: provider.relationshipNumberError,
                        // ),
                        // const SizedBox(height: 5),

                        /// For ICICI Bank Customers
                        CustomText(
                          label: 'For ICICI Bank Customers',
                          fontSize: 14,
                          isRequired: false,
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(height: 10),

                        /// icici relationship type
                        CustomText(
                          label: 'ICICI Relationship Type',
                          fontSize: 12,
                          isRequired: true,
                        ),
                        const SizedBox(height: 5),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: provider.isICICCustomer,
                              onChanged: (val) =>
                                  provider.toggleICICCustomer(val ?? false),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Are you an existing ICICI bank customer?",
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),

                        // CustomTextField(
                        //   label: 'Enter icici relationship type',
                        //   controller: provider.relationshipType,
                        //   isRequired: true,
                        //   errorText: provider.relationshipTypeError,
                        // ),
                        // CustomDropdown(
                        //   label: "ICICI Relationship Type",
                        //   hint: "Select relationship type",
                        //   isRequired: true,
                        //   value: provider.relationshipType.text.isEmpty
                        //       ? null
                        //       : provider.relationshipType.text,
                        //   items: const ["EXISTING_CUSTOMER", "NEW_CUSTOMER"],
                        //   errorText: provider.relationshipTypeError,
                        //   onChanged: (val) {
                        //     provider.relationshipType.text = val ?? "";
                        //     provider.notifyListeners();
                        //   },
                        // ),
                        const SizedBox(height: 5),

                        if (provider.isICICCustomer) ...[
                          /// bank account number
                          CustomText(
                            label: 'Bank Account Number',
                            fontSize: 12,
                            isRequired: provider.isICICCustomer,
                          ),
                          const SizedBox(height: 5),

                          Container(
                            key: _bankAccountKey,
                            child: CustomTextField(
                              label: 'Enter bank account number',
                              controller: provider.bankAccountNumber,
                              isRequired: provider.isICICCustomer,
                              errorText: provider.isICICCustomer
                                  ? provider.bankAccountNumberError
                                  : null,
                              validator: _requiredValidator,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(18),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),

                          /// IFSC code
                          CustomText(
                            label: 'IFSC Code',
                            fontSize: 12,
                            isRequired: provider.isICICCustomer,
                          ),
                          const SizedBox(height: 5),

                          Container(
                            key: _ifscKey,
                            child: CustomTextField(
                              label: 'Enter IFSC Code',
                              controller: provider.ifscCode,
                              isRequired: provider.isICICCustomer,
                              errorText: provider.isICICCustomer
                                  ? provider.ifscCodeError
                                  : null,
                              validator: _requiredValidator,
                              textCapitalization: TextCapitalization.characters,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[A-Za-z0-9]'),
                                ),
                                LengthLimitingTextInputFormatter(11),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),

                          /// icici account number
                          CustomText(
                            label: 'ICICI Account Number',
                            fontSize: 12,
                            isRequired: provider.isICICCustomer,
                          ),
                          const SizedBox(height: 5),

                          Container(
                            key: _iciciAccountKey,
                            child: CustomTextField(
                              label: 'Enter ICICI account number',
                              controller: provider.iciciAccountNumber,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(12),
                              ],
                              isRequired: provider.isICICCustomer,
                              validator: _requiredValidator,
                              errorText: provider.isICICCustomer
                                  ? provider.iciciAccountNumberError
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 5),

                          /// icici relationship number
                          CustomText(
                            label: 'ICICI Relationship Type',
                            fontSize: 12,
                            isRequired: true,
                          ),
                          const SizedBox(height: 5),

                          Container(
                            key: _accountTypeKey,
                            child: DropdownButtonFormField<String>(
                              validator: (value) {
                                if (provider.isICICCustomer &&
                                    (value == null || value.isEmpty)) {
                                  return 'This field is required';
                                }

                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'Select icici relationship type',
                                errorText: provider.accountTypeError,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  // Circular border
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.blue,
                                    width: 2,
                                  ),
                                ),
                              ),
                              items: _accountTypeList
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s),
                                    ),
                                  )
                                  .toList(),
                              value: provider.accountType.text.isEmpty
                                  ? null
                                  : provider.accountType.text,
                              onChanged: (val) {
                                provider.accountType.text = val ?? '';
                                provider.accountTypeError = null;
                                provider.notifyListeners();
                              },
                            ),
                          ),
                          const SizedBox(height: 5),
                        ],

                        // CustomText(label: 'Preferred Mailing Address', fontSize: 12, isRequired: true),
                        // const SizedBox(height: 5),
                        //
                        // CustomTextField(label: 'Select Preferred Mailing Address', controller: TextEditingController(), isRequired: true),
                        //
                        // CustomText(label: 'Additional Details', fontSize: 12, isRequired: true),
                        // const SizedBox(height: 5),
                        //
                        // CustomTextField(label: 'Select Additional details', controller: provider.additionalDetails, isRequired: true),
                        // Column(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     // Checkbox
                        //     Row(
                        //       children: [
                        //         Checkbox(
                        //           value: provider.payWithQR,
                        //           onChanged: (val) => provider.togglePayWithQR(val ?? false),
                        //           activeColor: Colors.blue,
                        //         ),
                        //         const Text(
                        //           "Pay with QR",
                        //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'Poppins'),
                        //         ),
                        //       ],
                        //     ),
                        //
                        //     // Show QR code and form if checked
                        //     if (provider.payWithQR) ...[
                        //       const SizedBox(height: 8),
                        //
                        //       // QR Code display
                        //       Center(
                        //         child: QrImageView(
                        //           data: "upi://pay?pa=your@upiid&pn=Company&am=199.00",
                        //           version: QrVersions.auto,
                        //           size: 180.0,
                        //           gapless: true,
                        //         ),
                        //       ),
                        //
                        //       const SizedBox(height: 12),
                        //
                        //       // Transaction number field
                        //       CustomText(label: 'Enter transaction number', fontSize: 14, isRequired: true),
                        //       const SizedBox(height: 6),
                        //
                        //       CustomTextField(label: 'Enter transaction number', controller: provider.transactionController, isRequired: true),
                        //       if (provider.transactionError != null)
                        //         Padding(
                        //           padding: const EdgeInsets.only(top: 4),
                        //           child: Text(provider.transactionError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                        //         ),
                        //       const SizedBox(height: 16),
                        //
                        //       // Camera + Upload Buttons
                        //       Row(
                        //         children: [
                        //           Expanded(
                        //             child: OutlinedButton.icon(
                        //               onPressed: () {},
                        //               icon: const Icon(Icons.camera_alt_outlined),
                        //               label: const Text("Camera"),
                        //               style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                        //             ),
                        //           ),
                        //           const SizedBox(width: 12),
                        //           Expanded(
                        //             child: OutlinedButton.icon(
                        //               onPressed: () {},
                        //               icon: const Icon(Icons.upload_outlined),
                        //               label: const Text("Upload documents"),
                        //               style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     ],
                        //   ],
                        // ),
                        // const SizedBox(height: 15),
                        //
                        // CustomText(label: 'Student Details', fontSize: 14, isRequired: true),
                        // const SizedBox(height: 5),
                        //
                        // Container(
                        //   height: 100,
                        //   width: double.infinity,
                        //   decoration: BoxDecoration(
                        //     border: Border.all(color: Colors.grey),
                        //     borderRadius: BorderRadius.circular(8),
                        //   ),
                        //   child: const Center(
                        //     child: Column(
                        //       children: [
                        //         SizedBox(height: 10),
                        //         Icon(Icons.account_circle_outlined, size: 40.0, color: Colors.black),
                        //         CustomText(label: "Upload Student Image", fontSize: 16, fontWeight: FontWeight.bold),
                        //         CustomText(label: "Click to browse (2 MB max)", fontSize: 12, color: Colors.grey),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        // const SizedBox(height: 15),
                        //
                        // CustomText(label: 'For ICICI Bank Customers', fontSize: 14, isRequired: true, fontWeight: FontWeight.bold),
                        // Row(
                        //   children: [
                        //     Checkbox(value: provider.isICICCustomer, onChanged: (val) => provider.toggleICICCustomer(val ?? false)),
                        //     const CustomText(label: "Are you an existing ICIC bank customer?", fontSize: 14),
                        //   ],
                        // ),
                        // Container(
                        //   padding: const EdgeInsets.all(8),
                        //   decoration: BoxDecoration(color: Colors.greenAccent, borderRadius: BorderRadius.circular(20)),
                        //   child: Column(
                        //     children: [
                        //       Row(
                        //         children: [
                        //           Checkbox(value: provider.greenPinChecked, onChanged: (val) => provider.toggleGreenPin(val ?? false)),
                        //           const CustomText(label: "Green pin", fontSize: 14, fontWeight: FontWeight.bold),
                        //           const Spacer(),
                        //           TextButton(
                        //             onPressed: () {},
                        //             child: const CustomText(label: "Resend", fontSize: 14),
                        //           ),
                        //         ],
                        //       ),
                        //       Row(
                        //         children: List.generate(
                        //           4,
                        //           (index) => Expanded(
                        //             child: Container(
                        //               margin: const EdgeInsets.all(4),
                        //               height: 40,
                        //               decoration: BoxDecoration(
                        //                 border: Border.all(color: Colors.black54),
                        //                 borderRadius: BorderRadius.circular(6),
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //       const SizedBox(height: 8),
                        //       ElevatedButton(
                        //         onPressed: provider.generateOtp,
                        //         child: const CustomText(label: "Generate OTP", fontSize: 14, fontWeight: FontWeight.bold),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        //
                        // CustomCheckboxTile(
                        //   label:
                        //       "In compliance with the rule 98 of the prevention of money laundering (maintenance of records) rules. you are required to intimate us if there is any change in your KYC details along with updated documents (i.e. address, contact details, profile ect) within a period of 30 days from the date the change was made. Once you intimate us, we will make necessary changes in our records. any update can be intimated to the bank by physical mode.",
                        //   value: provider.declaration,
                        //   onChanged: provider.toggleDeclaration,
                        // ),
                        // if (provider.declarationError != null)
                        //   Padding(
                        //     padding: const EdgeInsets.only(left: 8, top: 4),
                        //     child: Text(provider.declarationError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                        //   ),
                        // const SizedBox(height: 15),
                        //
                        // Container(
                        //   padding: const EdgeInsets.all(16),
                        //   decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(10)),
                        //   child: Column(
                        //     children: [
                        //       Row(
                        //         children: List.generate(
                        //           6,
                        //           (index) => Expanded(
                        //             child: Container(
                        //               margin: const EdgeInsets.all(4),
                        //               height: 40,
                        //               decoration: BoxDecoration(
                        //                 border: Border.all(color: Colors.black54),
                        //                 borderRadius: BorderRadius.circular(6),
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //       const SizedBox(height: 8),
                        //       ElevatedButton(
                        //         onPressed: provider.submitForm,
                        //         child: const CustomText(label: "Resend", fontSize: 14, fontWeight: FontWeight.bold),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        }
      },
    );
  }

  void _scrollToField(GlobalKey key, String message) {
    final contextField = key.currentContext;

    if (contextField != null) {
      Future.delayed(const Duration(milliseconds: 100), () {
        Scrollable.ensureVisible(
          contextField,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
          alignment: 0.25,
        );
      });
    } else {
      log("❌ Context null for key: $key");
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
