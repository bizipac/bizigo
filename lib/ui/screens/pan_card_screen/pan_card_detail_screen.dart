import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icici_bank/core/util/app_preference.dart';
import 'package:icici_bank/providers/aadhaar_verification_provider/aadhaar_kyc_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../providers/pan_card_provider/pan_card_details_provider.dart';
import '../../widgets/custom_radio_button.dart';
import '../../widgets/required_label.dart';

class PanCardDetailScreen extends StatefulWidget {
  const PanCardDetailScreen({super.key});

  @override
  State<PanCardDetailScreen> createState() => PanCardDetailScreenState();
}

class PanCardDetailScreenState extends State<PanCardDetailScreen> {
  final TextEditingController _panNumberController = TextEditingController();
  final TextEditingController _panNameController = TextEditingController();
  final TextEditingController _panDOBController = TextEditingController();
  final TextEditingController _form60Controller = TextEditingController();
  final TextEditingController _wardCircleRangeController =
      TextEditingController();
  final TextEditingController _reasonNoPanController = TextEditingController();

  bool _autoValidate = false;

  final _formKey = GlobalKey<FormState>();

  bool get showPanSection => true;

  final _panStatusKey = GlobalKey();

  final _panNumberKey = GlobalKey();
  final _panNameKey = GlobalKey();
  final _panDobKey = GlobalKey();

  final _form60Key = GlobalKey();
  final _taxAssessKey = GlobalKey();
  final _wardCircleKey = GlobalKey();
  final _reasonNoPanKey = GlobalKey();

  @override
  void dispose() {
    _panNumberController.dispose();
    _panNameController.dispose();
    _panDOBController.dispose();
    _form60Controller.dispose();
    _wardCircleRangeController.dispose();
    _reasonNoPanController.dispose();
    super.dispose();
  }

  Future<void> _pickPANDob() async {
    final now = DateTime.now();
    final initial = DateTime(now.year - 25, now.month, now.day);
    final first = DateTime(1900);
    final last = DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) {
      _panDOBController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  String? _requiredValidator(String? val) {
    if (val == null || val.trim().isEmpty) return 'This field is required';
    return null;
  }

  bool validatePanTaxFields(BuildContext context) {
    final provider = context.read<PanCardDetailsProvider>();

    setState(() => _autoValidate = true);

    /// PAN selection
    if (provider.panStatus ==
        null) {
      _scrollToField(
        _panStatusKey,
        "Please select PAN status",
      );
      return false;
    }

    /// PAN = YES
    if (provider.panStatus ==
        "Y") {

      if (_panNumberController
          .text
          .trim()
          .isEmpty) {
        _scrollToField(
          _panNumberKey,
          "PAN number is required",
        );
        return false;
      }

      if (_panNameController
          .text
          .trim()
          .isEmpty) {
        _scrollToField(
          _panNameKey,
          "PAN name is required",
        );
        return false;
      }

      if (_panDOBController
          .text
          .trim()
          .isEmpty) {
        _scrollToField(
          _panDobKey,
          "PAN DOB required",
        );
        return false;
      }
    }

    /// PAN = NO
    if (provider.panStatus ==
        "N") {

      if (_form60Controller
          .text
          .trim()
          .isEmpty) {
        _scrollToField(
          _form60Key,
          "Form 60 required",
        );
        return false;
      }

      if (provider.taxAssess ==
          null) {
        _scrollToField(
          _taxAssessKey,
          "Please select tax assesses",
        );
        return false;
      }

      if (provider.taxAssess ==
          "Y") {

        if (_wardCircleRangeController
            .text
            .trim()
            .isEmpty) {
          _scrollToField(
            _wardCircleKey,
            "Ward/Circle/Range required",
          );
          return false;
        }

        if (_reasonNoPanController
            .text
            .trim()
            .isEmpty) {
          _scrollToField(
            _reasonNoPanKey,
            "Reason for no PAN required",
          );
          return false;
        }
      }
    }

    if (!_formKey.currentState!
        .validate()) {
      return false;
    }

    final bool isPanTaxValid = provider.validatePanAndTaxFields(
      panStatus: provider.panStatus,
      taxStatus: provider.taxAssess,
      panNumber: _panNumberController.text,
      panName: _panNameController.text,
      form60Number: _form60Controller.text,
      wardCircleRange: _wardCircleRangeController.text,
      reasonNoPan: _reasonNoPanController.text,
    );

    if (!isPanTaxValid) return false;

    provider.setPanFormData({
      "PAN_STATUS": provider.panStatus,
      "PAN_NO": _panNumberController.text.trim(),
      "PAN_NAME": _panNameController.text.trim(),
      "PAN_DOB": _panDOBController.text.trim(),
      "FORM60_NO": _form60Controller.text.trim(),
      "WARD_CIRCLE_RANGE": _wardCircleRangeController.text.trim(),
      "REASON_NO_PAN": _reasonNoPanController.text.trim(),
      // "TAX_ASSESSEE": provider.taxAssess,
      // "IS_TAX_ASSESSE": provider.taxAssess == "Y",
      "TAX_ASSESSEE": provider.taxAssess ?? "Y", // ✅ default to "Y"
      "IS_TAX_ASSESSE": (provider.taxAssess ?? "Y") == "Y",
    });

    return true;
  }

  bool validateAndStore(BuildContext context) {
    return validatePanTaxFields(context);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: _autoValidate
          ? AutovalidateMode.always
          : AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RequiredLabel("Do you have a Pan Card?"),
          const SizedBox(height: 5),
          Consumer<PanCardDetailsProvider>(
            builder: (context, provider, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Radio Buttons
                  Container(
                    key: _panStatusKey,
                    child: Center(
                      child: Container(
                        width: 360,
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomRadioButton(
                              label: "Yes",
                              isSelected: provider.panStatus == "Y",
                              onTap: () {
                                provider.setPanStatus("Y");
                                _form60Controller.clear();
                                _wardCircleRangeController.clear();
                                _reasonNoPanController.clear();
                              },
                            ),

                            const SizedBox(height: 15),

                            CustomRadioButton(
                              label: "No",
                              isSelected: provider.panStatus == "N",
                              onTap: () {
                                provider.setPanStatus("N");
                                _panNumberController.clear();
                                _panNameController.clear();
                                _panDOBController.clear();
                                // if pan is no - assess must be yes
                                provider.setTaxAssessStatus("Y");
                              },
                            ),

                            /// 🔴 PAN STATUS ERROR HERE
                            if (provider.panStatusError != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0, top: 4),
                                child: Text(
                                  provider.panStatusError!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),

                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// ✅ IF PAN = YES → SHOW 3 FIELDS
                  if (provider.panStatus == "Y") ...[
                    RequiredLabel("PAN Number"),
                    const SizedBox(height: 5),

                    Container(
                      key: _panNumberKey,
                      child: TextFormField(
                        controller: _panNumberController,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          _PanInputFormatter(),
                          LengthLimitingTextInputFormatter(10),
                        ],
                        onChanged: (val) => setState(() {}),
                        // context.read<PanCardProvider>().panNumber = val;
                        decoration: InputDecoration(
                          hintText: 'e.g. ABCDE1234F',
                          errorText: provider.panNumberError,
                          // live helper text below field
                          helperText: _buildPanHelper(_panNumberController.text),
                          helperStyle: TextStyle(
                            color: _isPanComplete(_panNumberController.text)
                                ? Colors.green
                                : Colors.grey[600],
                            fontSize: 12,
                          ),
                          // green tick / red cross when 10 chars entered
                          suffixIcon: _panNumberController.text.length == 10
                              ? Icon(
                                  _isPanComplete(_panNumberController.text)
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: _isPanComplete(_panNumberController.text)
                                      ? Colors.green
                                      : Colors.red,
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: _isPanComplete(_panNumberController.text)
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: _isPanComplete(_panNumberController.text)
                                  ? Colors.green
                                  : Colors.blue,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'PAN number is required';
                          }
                          if (!RegExp(
                            r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$',
                          ).hasMatch(val.trim())) {
                            return 'Invalid PAN: 5 letters + 4 digits + 1 letter (e.g. ABCDE1234F)';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    RequiredLabel("Name as on Card"),
                    const SizedBox(height: 5),

                    Container(
                      key: _panNameKey,
                      child: TextFormField(
                        controller: _panNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter Name as on PAN Card',
                          errorText: provider.panNameError,
                          helperText: 'Name matching is case-insensitive',
                          helperStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: _requiredValidator,
                      ),
                    ),

                    const SizedBox(height: 10),

                    RequiredLabel("Pan DOB"),
                    const SizedBox(height: 5),
                    Container(
                      key: _panDobKey,
                      child: TextFormField(
                        controller: _panDOBController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Select Pan date of birth',
                          errorText: provider.dobError,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_month),
                            onPressed: _pickPANDob,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            // Circular border
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "This field is required";
                          }

                          final dob = DateFormat('dd/MM/yyyy').parse(val);
                          final today = DateTime.now();
                          int age = today.year - dob.year;

                          if (today.month < dob.month ||
                              (today.month == dob.month && today.day < dob.day)) {
                            age--;
                          }

                          if (age < 18) return "Minimum age must be 18";

                          return null;
                        },
                      ),
                    ),
                  ],

                  ///  if pan - no then show form 60 + ward/circle/range + reason
                  if (provider.panStatus == "N") ...[
                    RequiredLabel(
                      "To Be Filled by those who do not have PAN or GIR",
                    ),
                    const SizedBox(height: 5),

                    /// Form 60 number
                    Container(
                      key: _form60Key,
                      child: TextFormField(
                        controller: _form60Controller,
                        decoration: InputDecoration(
                          hintText: 'Enter Form 60 / Form 49A Application Number',
                          errorText: provider.form60Error,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: _requiredValidator,
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// --------------- Tax Assesses Section -----------------
                    Consumer<PanCardDetailsProvider>(
                      builder: (context, provider, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            RequiredLabel("Are you a Tax Assesses"),
                            const SizedBox(height: 5),
                            Container(
                              key: _taxAssessKey,
                              child: Center(
                                child: Container(
                                  width: 360,
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    4,
                                    12,
                                    4,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomRadioButton(
                                        label: "Yes",
                                        isSelected: provider.taxAssess == "Y",
                                        onTap: () =>
                                            provider.setTaxAssessStatus("Y"),
                                      ),

                                      SizedBox(height: 15),

                                      Opacity(
                                        opacity: provider.panStatus == "N"
                                            ? 0.4
                                            : 1.0,
                                        child: IgnorePointer(
                                          ignoring: provider.panStatus == "N",
                                          child: CustomRadioButton(
                                            label: "No",
                                            isSelected: provider.taxAssess == "N",
                                            onTap: () =>
                                                provider.setTaxAssessStatus("N"),
                                          ),
                                        ),
                                      ),

                                      //  msg if PAN - no
                                      if (provider.panStatus == "N")
                                        const Padding(
                                          padding: EdgeInsets.only(
                                            left: 8.0,
                                            top: 6,
                                          ),
                                          child: Text(
                                            'Tax Assessee must be Yes when PAN is not available',
                                            style: TextStyle(
                                              color: Colors.orange,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),

                                      /// 🔴 TAX ASSESSES ERROR
                                      if (provider.taxAssessesError != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8.0,
                                            top: 4,
                                          ),
                                          child: Text(
                                            provider.taxAssessesError!,
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            /// show only if yes, then open below
                            if (provider.taxAssess == "Y") ...[
                              const SizedBox(height: 10),

                              /// Ward/Circle/Range field — now rendered and connected
                              RequiredLabel(
                                '(a) Details of ward/circle/range where the last return of income was filed',
                              ),
                              const SizedBox(height: 5),

                              Container(
                                key: _wardCircleKey,
                                child: TextFormField(
                                  enabled: true,
                                  controller: _wardCircleRangeController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter ward/circle/range details',
                                    errorText: provider.wardCircleRangeError,
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
                                  validator: (val) {
                                    if (provider.panStatus == "N" &&
                                        provider.taxAssess == "Y") {
                                      return _requiredValidator(val);
                                    }
                                    return null;
                                  },
                                ),
                              ),

                              const SizedBox(height: 10),

                              /// Reason for no PAN field — now rendered and connected
                              RequiredLabel('(b) Reason for not having PAN No'),

                              const SizedBox(height: 5),
                              Container(
                                key: _reasonNoPanKey,
                                child: TextFormField(
                                  enabled: provider.panStatus == "N",
                                  controller: _reasonNoPanController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter reason for not having PAN',
                                    errorText: provider.reasonNoPanError,
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
                                  validator: (val) {
                                    if (provider.panStatus == "N" &&
                                        provider.taxAssess == "Y") {
                                      return _requiredValidator(val);
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  bool _isPanComplete(String val) =>
      RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(val.toUpperCase());

  String _buildPanHelper(String val) {
    final v = val.toUpperCase();
    if (v.isEmpty) return 'Format: 5 letters · 4 digits · 1 letter';
    if (_isPanComplete(v)) return '✓ Valid PAN format';
    const pattern = 'LLLLLDDDDL';
    final buf = StringBuffer();
    for (int i = 0; i < 10; i++) {
      if (i > 0) buf.write(' ');
      buf.write(i < v.length ? v[i] : (pattern[i] == 'L' ? 'A' : '0'));
    }
    return 'Entered: $buf';
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

/// Enforces PAN format AAAAA9999A position by position:
///   pos 0-4 → letters only
///   pos 5-8 → digits only
///   pos 9   → letter only
class _PanInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.toUpperCase();
    final buffer = StringBuffer();

    for (int i = 0; i < raw.length && i < 10; i++) {
      final ch = raw[i];
      if (i < 5) {
        if (RegExp(r'[A-Z]').hasMatch(ch)) buffer.write(ch);
      } else if (i < 9) {
        if (RegExp(r'[0-9]').hasMatch(ch)) buffer.write(ch);
      } else {
        if (RegExp(r'[A-Z]').hasMatch(ch)) buffer.write(ch);
      }
    }

    final result = buffer.toString();
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}
