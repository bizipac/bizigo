import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icici_bank/core/util/app_preference.dart';
import 'package:icici_bank/providers/aadhaar_verification_provider/aadhaar_kyc_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../providers/personal_provider/personal_kyc_provider.dart';
import '../../widgets/custom_radio_button.dart';
import '../../widgets/required_label.dart';

class PersonalKycDetailScreen extends StatefulWidget {
  final String? appStatus;

  const PersonalKycDetailScreen({super.key, required this.appStatus});

  @override
  State<PersonalKycDetailScreen> createState() =>
      PersonalKycDetailScreenState();
}

class PersonalKycDetailScreenState extends State<PersonalKycDetailScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final provider = context.read<PersonalKycProvider>();
      await provider.fetchAadhaarData();
      loadData();
    });
  }

  String get _status => widget.appStatus?.toLowerCase() ?? "";

  bool get isPendingPersonalValidation => _status == "pending_personal_details";

  bool get isPersonalCompleted => _status == "personal_details_completed";

  bool get isAddressCompleted => _status == "address_completed";

  /// Section visibility
  // bool get showPersonalSection => isPendingPersonalValidation;

  bool get showPersonalSection =>
      isPendingPersonalValidation || isPersonalCompleted || isAddressCompleted;

  // bool get showPanSection => isPendingProductValidation || isPersonalCompleted || isAddressCompleted;
  // bool get showPanSection => isPendingPersonalValidation || isPersonalCompleted;

  @override
  bool get wantKeepAlive => true;

  final _formKey = GlobalKey<FormState>();

  final ScrollController _scrollController = ScrollController();

  final _titleKey = GlobalKey();
  final _firstNameKey = GlobalKey();
  final _lastNameKey = GlobalKey();
  final _fatherNameKey = GlobalKey();
  final _motherNameKey = GlobalKey();
  final _dobKey = GlobalKey();
  final _mobileKey = GlobalKey();
  final _emailKey = GlobalKey();
  final _maritalKey = GlobalKey();
  final _educationKey = GlobalKey();
  final _residentialKey = GlobalKey();
  final _occupationKey = GlobalKey();
  final _annualIncomeKey = GlobalKey();

  final _permFlatKey = GlobalKey();
  final _permRoadKey = GlobalKey();
  final _permLandmarkKey = GlobalKey();
  final _permCityKey = GlobalKey();
  final _permStateKey = GlobalKey();
  final _permDistrictKey = GlobalKey();
  final _permPinKey = GlobalKey();

  final _comFlatKey = GlobalKey();
  final _comRoadKey = GlobalKey();
  final _comLandmarkKey = GlobalKey();
  final _comCityKey = GlobalKey();
  final _comDistrictKey = GlobalKey();
  final _comStateKey = GlobalKey();
  final _comPinKey = GlobalKey();

  // Controllers
  final TextEditingController _branchCodeController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _spouseNameController = TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _motherMaidenController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _stdController = TextEditingController();
  final TextEditingController _landlineController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();

  // final TextEditingController _nationalityCodeController = TextEditingController();
  final TextEditingController _typeOfVisaController = TextEditingController();
  final TextEditingController _visaNumberController = TextEditingController();
  final TextEditingController _visaCountryController = TextEditingController();
  final TextEditingController _visaExpiryController = TextEditingController();
  final TextEditingController _overseasAddress1Controller =
      TextEditingController();
  final TextEditingController _overseasAddress2Controller =
      TextEditingController();

  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _panNumberController = TextEditingController();
  final TextEditingController _panNameController = TextEditingController();
  final TextEditingController _panDOBController = TextEditingController();
  final TextEditingController _form60Controller = TextEditingController();
  final TextEditingController _wardCircleRangeController =
      TextEditingController();
  final TextEditingController _reasonNoPanController = TextEditingController();

  final TextEditingController _employerController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();

  // Permanent address controllers
  final TextEditingController _permFlatController = TextEditingController();
  final TextEditingController _permRoadController = TextEditingController();
  final TextEditingController _permLandmarkController = TextEditingController();
  final TextEditingController _permCityController = TextEditingController();
  final TextEditingController _permStateController = TextEditingController();
  final TextEditingController _permDistrictController = TextEditingController();
  final TextEditingController _permPincodeController = TextEditingController();
  final TextEditingController _permForm60Controller = TextEditingController();

  // Communication address controllers
  final TextEditingController _comFlatController = TextEditingController();
  final TextEditingController _comRoadController = TextEditingController();
  final TextEditingController _comLandmarkController = TextEditingController();
  final TextEditingController _comCityController = TextEditingController();
  final TextEditingController _comStateController = TextEditingController();
  final TextEditingController _comDistrictController = TextEditingController();
  final TextEditingController _comPincodeController = TextEditingController();
  final TextEditingController _comForm60Controller = TextEditingController();

  // Other fields
  String? _productSelected;
  String? _maritalStatus;
  String? _title;
  String? _gender;
  String? _education;
  String? _residentialStatus;
  String? _occupationType;
  String? _subOccupationType;
  String? _sourceOfIncome;
  String? _annualIncome;
  String? _nationalityCode;

  bool _commSameAsPerm = false;
  int _addressDeclarationChoice = 0;

  bool _autoValidate = false;

  bool get _isNonIndian =>
      _nationalityCode != null && !_nationalityCode!.startsWith('IN -');

  final List<String> _maritalOptions = ['Single', 'Married', 'Others'];
  final List<String> _titleOptions = ['MR.', 'MRS.', 'MISS.', 'MS.'];
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _educationOptions = [
    'Below High School',
    'High School',
    'Diploma',
    'Graduate',
    'Post Graduate',
    'Other',
  ];
  final List<String> _residentialOptions = [
    'Resident Indian',
    'Non-Resident Indian (NRI)',
    'Others',
  ];
  final List<String> _occupationOptions = [
    'Private Sector (Salaried)',
    'Government Sector (Salaried)',
    'Self-Employed',
    'Business',
    'Other',
  ];
  final List<String> _subOccupationOptions = [
    'Software Engineer',
    'Doctor',
    'Nurse',
    'Teacher',
    'Professor',
    'Bank Employee',
    'Government Employee',
    'Private Company Employee',
    'Chartered Accountant',
    'Lawyer',
    'Architect',
    'Engineer (Non-IT)',
    'Marketing Executive',
    'Sales Executive',
    'HR Executive',
    'Police Personnel',
    'Defense Personnel',
    'Public Sector Employee',
    'Clerk',
    'Manager',
  ];
  final List<String> _sourceIncomeOptions = [
    'Salary',
    'Business Income',
    'Professional Income',
    'Agriculture',
    'Investments',
    'Rental Income',
    'Pension',
    'Other',
  ];
  final List<String> _annualIncomeList = [
    'Nil',
    'Upto 5 lakhs',
    '5 to 10 lakhs',
    '10 to 20 lakhs',
    '20 to 35 lakhs',
    '35 to 50 lakhs',
    'Above 50 lakhs',
  ];
  final List<String> _nationalityCodeOptions = [
    'AF - Afghanistan',
    'AX - Åland Islands',
    'AL - Albania',
    'DZ - Algeria',
    'AS - American Samoa',
    'AD - Andorra',
    'AO - Angola',
    'AI - Anguilla',
    'AQ - Antarctica',
    'AG - Antigua and Barbuda',
    'AR - Argentina',
    'AM - Armenia',
    'AW - Aruba',
    'AU - Australia',
    'AT - Austria',
    'AZ - Azerbaijan',
    'BS - Bahamas',
    'BH - Bahrain',
    'BD - Bangladesh',
    'BB - Barbados',
    'BY - Belarus',
    'BE - Belgium',
    'BZ - Belize',
    'BJ - Benin',
    'BM - Bermuda',
    'BT - Bhutan',
    'BO - Bolivia',
    'BQ - Bonaire, Sint Eustatius and Saba',
    'BA - Bosnia and Herzegovina',
    'BW - Botswana',
    'BR - Brazil',
    'IO - British Indian Ocean Territory',
    'BN - Brunei Darussalam',
    'BG - Bulgaria',
    'BF - Burkina Faso',
    'BI - Burundi',
    'KH - Cambodia',
    'CM - Cameroon',
    'CA - Canada',
    'CV - Cape Verde',
    'KY - Cayman Islands',
    'CF - Central African Republic',
    'TD - Chad',
    'CL - Chile',
    'CN - China',
    'CX - Christmas Island',
    'CC - Cocos (Keeling) Islands',
    'CO - Colombia',
    'KM - Comoros',
    'CG - Congo',
    'CD - Congo (Democratic Republic)',
    'CR - Costa Rica',
    'CI - Côte d’Ivoire',
    'HR - Croatia',
    'CU - Cuba',
    'CW - Curaçao',
    'CY - Cyprus',
    'CZ - Czech Republic',
    'DK - Denmark',
    'DJ - Djibouti',
    'DM - Dominica',
    'DO - Dominican Republic',
    'EC - Ecuador',
    'EG - Egypt',
    'SV - El Salvador',
    'GQ - Equatorial Guinea',
    'ER - Eritrea',
    'EE - Estonia',
    'ET - Ethiopia',
    'FK - Falkland Islands',
    'FO - Faroe Islands',
    'FJ - Fiji',
    'FI - Finland',
    'FR - France',
    'GF - French Guiana',
    'PF - French Polynesia',
    'GA - Gabon',
    'GM - Gambia',
    'GE - Georgia',
    'DE - Germany',
    'GH - Ghana',
    'GI - Gibraltar',
    'GR - Greece',
    'GL - Greenland',
    'GD - Grenada',
    'GP - Guadeloupe',
    'GU - Guam',
    'GT - Guatemala',
    'GG - Guernsey',
    'GN - Guinea',
    'GW - Guinea-Bissau',
    'GY - Guyana',
    'HT - Haiti',
    'HN - Honduras',
    'HK - Hong Kong',
    'HU - Hungary',
    'IS - Iceland',
    'IN - India',
    'ID - Indonesia',
    'IR - Iran',
    'IQ - Iraq',
    'IE - Ireland',
    'IM - Isle of Man',
    'IL - Israel',
    'IT - Italy',
    'JM - Jamaica',
    'JP - Japan',
    'JE - Jersey',
    'JO - Jordan',
    'KZ - Kazakhstan',
    'KE - Kenya',
    'KI - Kiribati',
    'KP - North Korea',
    'KR - South Korea',
    'KW - Kuwait',
    'KG - Kyrgyzstan',
    'LA - Laos',
    'LV - Latvia',
    'LB - Lebanon',
    'LS - Lesotho',
    'LR - Liberia',
    'LY - Libya',
    'LI - Liechtenstein',
    'LT - Lithuania',
    'LU - Luxembourg',
    'MO - Macau',
    'MK - North Macedonia',
    'MG - Madagascar',
    'MW - Malawi',
    'MY - Malaysia',
    'MV - Maldives',
    'ML - Mali',
    'MT - Malta',
    'MH - Marshall Islands',
    'MQ - Martinique',
    'MR - Mauritania',
    'MU - Mauritius',
    'YT - Mayotte',
    'MX - Mexico',
    'FM - Micronesia',
    'MD - Moldova',
    'MC - Monaco',
    'MN - Mongolia',
    'ME - Montenegro',
    'MS - Montserrat',
    'MA - Morocco',
    'MZ - Mozambique',
    'MM - Myanmar',
    'NA - Namibia',
    'NR - Nauru',
    'NP - Nepal',
    'NL - Netherlands',
    'NC - New Caledonia',
    'NZ - New Zealand',
    'NI - Nicaragua',
    'NE - Niger',
    'NG - Nigeria',
    'NU - Niue',
    'NF - Norfolk Island',
    'MP - Northern Mariana Islands',
    'NO - Norway',
    'OM - Oman',
    'PK - Pakistan',
    'PW - Palau',
    'PS - Palestine',
    'PA - Panama',
    'PG - Papua New Guinea',
    'PY - Paraguay',
    'PE - Peru',
    'PH - Philippines',
    'PN - Pitcairn',
    'PL - Poland',
    'PT - Portugal',
    'PR - Puerto Rico',
    'QA - Qatar',
    'RE - Réunion',
    'RO - Romania',
    'RU - Russia',
    'RW - Rwanda',
    'BL - Saint Barthélemy',
    'SH - Saint Helena',
    'KN - Saint Kitts and Nevis',
    'LC - Saint Lucia',
    'MF - Saint Martin',
    'VC - Saint Vincent and the Grenadines',
    'WS - Samoa',
    'SM - San Marino',
    'ST - São Tomé and Príncipe',
    'SA - Saudi Arabia',
    'SN - Senegal',
    'RS - Serbia',
    'SC - Seychelles',
    'SL - Sierra Leone',
    'SG - Singapore',
    'SX - Sint Maarten',
    'SK - Slovakia',
    'SI - Slovenia',
    'SB - Solomon Islands',
    'SO - Somalia',
    'ZA - South Africa',
    'SS - South Sudan',
    'ES - Spain',
    'LK - Sri Lanka',
    'SD - Sudan',
    'SR - Suriname',
    'SE - Sweden',
    'CH - Switzerland',
    'SY - Syria',
    'TW - Taiwan',
    'TJ - Tajikistan',
    'TZ - Tanzania',
    'TH - Thailand',
    'TL - Timor-Leste',
    'TG - Togo',
    'TK - Tokelau',
    'TO - Tonga',
    'TT - Trinidad and Tobago',
    'TN - Tunisia',
    'TR - Turkey',
    'TM - Turkmenistan',
    'TC - Turks and Caicos Islands',
    'TV - Tuvalu',
    'UG - Uganda',
    'UA - Ukraine',
    'AE - United Arab Emirates',
    'GB - United Kingdom',
    'US - United States',
    'UM - United States Minor Outlying Islands',
    'UY - Uruguay',
    'UZ - Uzbekistan',
    'VU - Vanuatu',
    'VA - Vatican City',
    'VE - Venezuela',
    'VN - Vietnam',
    'VG - British Virgin Islands',
    'VI - U.S. Virgin Islands',
    'WF - Wallis and Futuna',
    'EH - Western Sahara',
    'YE - Yemen',
    'ZM - Zambia',
    'ZW - Zimbabwe',
  ];

  Future<void> loadData() async {
    final provider = context.read<PersonalKycProvider>();
    final data = provider.aadhaarData;
    if (data != null) {
      /// name
      final fullName = data['name'] ?? '';
      final parts = fullName.trim().split(' ');
      if (parts.isNotEmpty) {
        _firstNameController.text = parts.first;
        _middleNameController.text = parts.length > 2
            ? parts.sublist(1, parts.length - 1).join(' ')
            : '';
        _lastNameController.text = parts.length > 1 ? parts.last : '';
      }

      log('Father name From Aadhaar Name: ${data['father_name']}');
      _fatherNameController.text = data['father_name'].toString() ?? '';

      /// dob
      _dobController.text = data['dob'] ?? '';

      ///gender
      final genderCode = data['gender'];

      _genderController.text = genderCode == 'M'
          ? 'Male'
          : genderCode == 'F'
          ? 'Female'
          : 'Other';

      log('gender from aadhaar: $genderCode');

      /// address
      _permFlatController.text = data['house_number'] ?? '';
      _permRoadController.text = data['street'] ?? '';
      _permLandmarkController.text = data['landmark'] ?? '';
      _permCityController.text =
          data['village_town_city'] ?? data['location'] ?? '';
      _permDistrictController.text = data['district'] ?? '';
      _permStateController.text = data['state'] ?? '';
      _permPincodeController.text = data['pincode'] ?? '';
    }
  }

  List<String> getNationalityList() {
    final sorted = List<String>.from(_nationalityCodeOptions)..sort();
    sorted.removeWhere((e) => e.startsWith('IN -'));
    return ['IN - India', ...sorted];
  }

  DateTime? parseDob(String val) {
    try {
      return DateFormat('dd/MM/yyyy').parseStrict(val);
    } catch (_) {
      try {
        return DateFormat('dd-MM-yyyy').parseStrict(val);
      } catch (_) {
        return null;
      }
    }
  }

  /// Always convert to one format (recommended: dd-MM-yyyy)
  String formatDob(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  // Utility validators
  String? _requiredValidator(String? val) {
    if (val == null || val.trim().isEmpty) return 'This field is required';
    return null;
  }

  String? _emailValidator(String? val) {
    if (val == null || val.trim().isEmpty) return 'This field is required';
    final regexp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regexp.hasMatch(val.trim())) return 'Enter valid email';
    return null;
  }

  String? _mobileValidator(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'This field is required';
    }

    final digitsOnly = val.trim();

    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(digitsOnly)) {
      return 'Enter valid Indian mobile number';
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

  Future<void> _pickDob() async {
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
      _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
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

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _fatherNameController.dispose();
    _spouseNameController.dispose();
    _motherNameController.dispose();
    _motherMaidenController.dispose();
    _dobController.dispose();
    _genderController.dispose();
    _stdController.dispose();
    _landlineController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _branchCodeController.dispose();
    _panNumberController.dispose();
    _panNameController.dispose();
    _panDOBController.dispose();
    _form60Controller.dispose();
    _wardCircleRangeController.dispose();
    _reasonNoPanController.dispose();
    _employerController.dispose();
    _designationController.dispose();
    _incomeController.dispose();
    _permFlatController.dispose();
    _permRoadController.dispose();
    _permLandmarkController.dispose();
    _permCityController.dispose();
    _permStateController.dispose();
    _permDistrictController.dispose();
    _permPincodeController.dispose();
    _comFlatController.dispose();
    _comRoadController.dispose();
    _comLandmarkController.dispose();
    _comCityController.dispose();
    _comStateController.dispose();
    _comDistrictController.dispose();
    _comPincodeController.dispose();
    _comForm60Controller.dispose();
    _typeOfVisaController.dispose();
    _visaNumberController.dispose();
    _visaCountryController.dispose();
    _visaExpiryController.dispose();
    _overseasAddress1Controller.dispose();
    _overseasAddress2Controller.dispose();
    _permForm60Controller.dispose();
    // _nationalityCodeController.dispose();
    super.dispose();
  }

  void _copyPermToCommIfNeeded() {
    if (_commSameAsPerm) {
      _comFlatController.text = _permFlatController.text;
      _comRoadController.text = _permRoadController.text;
      _comLandmarkController.text = _permLandmarkController.text;
      _comCityController.text = _permCityController.text;
      _comStateController.text = _permStateController.text;
      _comDistrictController.text = _permDistrictController.text;
      _comPincodeController.text = _permPincodeController.text;
      _comForm60Controller.text = _permForm60Controller.text;
    } else {
      _comFlatController.clear();
      _comRoadController.clear();
      _comLandmarkController.clear();
      _comCityController.clear();
      _comStateController.clear();
      _comDistrictController.clear();
      _comPincodeController.clear();
      _comForm60Controller.clear();
    }
  }

  // bool validateAndStore(BuildContext context) {
  //   final provider = context.read<PersonalKycProvider>();
  //
  //   setState(() {
  //     _autoValidate = true;
  //   });
  //
  //   if (!_formKey.currentState!.validate()) {
  //     return false;
  //   }
  //
  //   final isBasicValid = provider.validateMandatoryPersonalFields(
  //     branchCode: _branchCodeController.text,
  //     title: _title,
  //     firstName: _firstNameController.text,
  //     lastName: _lastNameController.text,
  //     dob: _dobController.text,
  //     mobile: _mobileController.text,
  //     email: _emailController.text,
  //     // nationalityCode: _nationalityCodeController.text,
  //   );
  //
  //   bool isPanTaxValid = true;
  //   if (showPanSection) {
  //     isPanTaxValid = provider.validatePanAndTaxFields(
  //       panStatus: provider.panStatus,
  //       taxStatus: provider.taxAssess,
  //       panNumber: _panNumberController.text,
  //       panName: _panNameController.text,
  //       form60Number: _form60Controller.text,
  //       wardCircleRange: _wardCircleRangeController.text,
  //       reasonNoPan: _reasonNoPanController.text,
  //     );
  //   }
  //
  //   if (!isBasicValid || !isPanTaxValid) {
  //     return false;
  //   }
  //
  //   /// ✅ CREATE MAP FIRST
  //   final Map<String, dynamic> dataToStore = {
  //     "BRANCH_CODE": _branchCodeController.text.trim(),
  //     "TITLE": _title,
  //     "FIRST_NAME": _firstNameController.text.trim(),
  //     "MIDDLE_NAME": _middleNameController.text.trim(),
  //     "LAST_NAME": _lastNameController.text.trim(),
  //     "FATHER_NAME": _fatherNameController.text.trim(),
  //     "MOTHER_NAME": _motherNameController.text.trim(),
  //     "MOTHER_MAIDEN_NAME": _motherMaidenController.text.trim(),
  //     "MARITAL_STATUS": _maritalStatus,
  //     "DOB": _dobController.text.trim(),
  //     "STD_CODE": _stdController.text.trim(),
  //     "LANDLINE_NO": _landlineController.text.trim(),
  //     "MOBILE_NO": _mobileController.text.trim(),
  //     "EMAIL_ID": _emailController.text.trim(),
  //     "GENDER": _gender == "Male"
  //         ? "M"
  //         : _gender == "Female"
  //         ? "F"
  //         : "O",
  //     "EDUCATION": _education,
  //     "RESIDENTIAL_STATUS": _residentialStatus,
  //     "OCCUPATION_TYPE": _occupationType,
  //     "SUB_OCCUPATION_TYPE": _subOccupationType,
  //     "EMPLOYER_NAME": _employerController.text.trim(),
  //     "SOURCE_OF_INCOME": _sourceOfIncome,
  //     "DESIGNATION": _designationController.text.trim(),
  //     "GROSS_INCOME": _incomeController.text.trim(),
  //
  //     "PAN_STATUS": provider.panStatus,
  //     "PAN_NO": _panNumberController.text.trim(),
  //     "PAN_NAME": _panNameController.text.trim(),
  //     "PAN_FATHER_NAME": _panFatherController.text.trim(),
  //     "FORM60_NO": _form60Controller.text.trim(),
  //     "WARD_CIRCLE_RANGE": _wardCircleRangeController.text.trim(),
  //     "REASON_NO_PAN": _reasonNoPanController.text.trim(),
  //     "TAX_ASSESSEE": provider.taxAssess,
  //     "IS_TAX_ASSESSE": provider.taxAssess == "Y",
  //
  //     /// Permanent
  //     "PERMANENT_ADDRESS_1": _permFlatController.text.trim(),
  //     "PERMANENT_ADDRESS_2": _permRoadController.text.trim(),
  //     "PHYSICAL_LANDMARK": _permLandmarkController.text.trim(),
  //     "PERMANENT_CITY": _permCityController.text.trim(),
  //     "PERMANENT_STATE": _permStateController.text.trim(),
  //     "PHYSICAL_DISTRICT": _permDistrictController.text.trim(),
  //     "PERMANENT_ZIP": _permPincodeController.text.trim(),
  //     "PERMANENT_COUNTRY": "INDIA",
  //
  //     /// Flag
  //     "COMMUNICATION_SAME_AS_PERMANENT": _commSameAsPerm ? "Y" : "N",
  //
  //     "NATIONALITY_CODE": _nationalityCode,
  //     "SELF_DECLARED_COMMUNICATION_ADDRESS": _addressDeclarationChoice == 0 ? "Y" : "N",
  //   };
  //
  //   /// ✅ ADD COMMUNICATION ADDRESS IF NOT SAME
  //   if (!_commSameAsPerm) {
  //     dataToStore.addAll({
  //       "COMMUNICATION_ADDRESS_1": _comFlatController.text.trim(),
  //       "COMMUNICATION_ADDRESS_2": _comRoadController.text.trim(),
  //       "COMMUNICATION_LANDMARK": _comLandmarkController.text.trim(),
  //       "COMMUNICATION_CITY": _comCityController.text.trim(),
  //       "COMMUNICATION_STATE": _comStateController.text.trim(),
  //       "COMMUNICATION_DISTRICT": _comDistrictController.text.trim(),
  //       "COMMUNICATION_ZIP": _comPincodeController.text.trim(),
  //       "COMMUNICATION_COUNTRY": "INDIA",
  //     });
  //   }
  //
  //   /// ✅ ADD VISA FIELDS ONLY IF NON-INDIAN
  //   if (_isNonIndian) {
  //     dataToStore["TYPE_OF_VISA"] = _typeOfVisaController.text.trim();
  //     dataToStore["VISA_NUMBER"] = _visaNumberController.text.trim();
  //     dataToStore["VISA_COUNTRY_OF_ISSUE"] = _visaCountryController.text.trim();
  //     dataToStore["VISA_EXPIRY_DATE"] = _visaExpiryController.text.trim();
  //     dataToStore["OVERSEAS_ADDRESS_ONE"] = _overseasAddress1Controller.text.trim();
  //     dataToStore["OVERSEAS_ADDRESS_LINE_TWO"] = _overseasAddress2Controller.text.trim();
  //   }
  //
  //   /// ✅ STORE ONCE
  //   provider.setPersonalFormData(dataToStore);
  //
  //   return true;
  // }
  bool validateAndStore(BuildContext context) {
    final provider = context.read<PersonalKycProvider>();

    log("🚀 validateAndStore() called");

    setState(() {
      _autoValidate = true;
    });

    if (_title == null) {
      _scrollToField(_titleKey, "Please select title");
      return false;
    }

    if (_firstNameController.text.trim().isEmpty) {
      _scrollToField(_firstNameKey, "First name is required");
      return false;
    }

    if (_lastNameController.text.trim().isEmpty) {
      _scrollToField(_lastNameKey, "Last name is required");
      return false;
    }

    if (_motherNameController.text.trim().isEmpty) {
      _scrollToField(_motherNameKey, "Mother name is required");
      return false;
    }

    if (_maritalStatus == null) {
      _scrollToField(_maritalKey, "Please select marital status");
      return false;
    }

    if (_maritalStatus == "Married" &&
        _spouseNameController.text.trim().isEmpty) {
      _scrollToField(_maritalKey, "Spouse name is required");
      return false;
    }

    if (_dobController.text.trim().isEmpty) {
      _scrollToField(_dobKey, "Date of birth required");
      return false;
    }

    if (_mobileController.text.trim().isEmpty) {
      _scrollToField(_mobileKey, "Mobile number required");
      return false;
    }

    if (_emailController.text.trim().isEmpty) {
      _scrollToField(_emailKey, "Email required");
      return false;
    }

    if (_education == null) {
      _scrollToField(_educationKey, "Please select education");
      return false;
    }

    if (_residentialStatus == null) {
      _scrollToField(_residentialKey, "Please select residential status");
      return false;
    }

    if (_occupationType == null) {
      _scrollToField(_occupationKey, "Please select occupation type");
      return false;
    }

    if (_annualIncome == null) {
      _scrollToField(_annualIncomeKey, "Please select annual income");
      return false;
    }

    /// Permanent Address
    if (_permFlatController.text.trim().isEmpty) {
      _scrollToField(_permFlatKey, "Flat/House No is required");
      return false;
    }

    if (_permRoadController.text.trim().isEmpty) {
      _scrollToField(_permRoadKey, "Road/Street is required");
      return false;
    }

    if (_permLandmarkController.text.trim().isEmpty) {
      _scrollToField(_permLandmarkKey, "Nearby Landby is required");
      return false;
    }

    if (_permCityController.text.trim().isEmpty) {
      _scrollToField(_permCityKey, "City is required");
      return false;
    }

    if (_permDistrictController.text.trim().isEmpty) {
      _scrollToField(_permDistrictKey, "District is required");
      return false;
    }

    if (_permStateController.text.trim().isEmpty) {
      _scrollToField(_permStateKey, "State is required");
      return false;
    }

    if (_permPincodeController.text.trim().isEmpty) {
      _scrollToField(_permPinKey, "Pincode required");
      return false;
    }

    log("PERM FLAT: ${_permFlatController.text}");
    log("PERM ROAD: ${_permRoadController.text}");
    log("PERM LANDMARK: ${_permLandmarkController.text}");
    log("PERM CITY: ${_permCityController.text}");
    log("PERM DISTRICT: ${_permDistrictController.text}");
    log("PERM STATE: ${_permStateController.text}");
    log("PERM PIN: ${_permPincodeController.text}");

    /// Communication Address
    if (!_commSameAsPerm) {

      if (_comFlatController
          .text
          .trim()
          .isEmpty) {
        _scrollToField(
          _comFlatKey,
          "Communication Flat/House No is required",
        );
        return false;
      }

      if (_comRoadController
          .text
          .trim()
          .isEmpty) {
        _scrollToField(
          _comRoadKey,
          "Communication Road/Street is required",
        );
        return false;
      }

      if (_comLandmarkController
          .text
          .trim()
          .isEmpty) {
        _scrollToField(
          _comLandmarkKey,
          "Communication Landmark is required",
        );
        return false;
      }

      if (_comCityController
          .text
          .trim()
          .isEmpty) {
        _scrollToField(
          _comCityKey,
          "Communication City is required",
        );
        return false;
      }

      if (_comDistrictController
          .text
          .trim()
          .isEmpty) {
        _scrollToField(
          _comDistrictKey,
          "Communication District is required",
        );
        return false;
      }

      if (_comStateController
          .text
          .trim()
          .isEmpty) {
        _scrollToField(
          _comStateKey,
          "Communication State is required",
        );
        return false;
      }

      if (_comPincodeController
          .text
          .trim()
          .isEmpty) {
        _scrollToField(
          _comPinKey,
          "Communication Pincode required",
        );
        return false;
      }
    }

    log("COMM FLAT: ${_comFlatController.text}");
    log("COMM ROAD: ${_comRoadController.text}");
    log("COMM LANDMARK: ${_comLandmarkController.text}");
    log("COMM CITY: ${_comCityController.text}");
    log("COMM DISTRICT: ${_comDistrictController.text}");
    log("COMM STATE: ${_comStateController.text}");
    log("COMM PIN: ${_comPincodeController.text}");

    if (!_formKey.currentState!.validate()) {
      log("❌ Form validation failed");
      return false;
    }

    log("✅ Form validation passed");

    final isBasicValid = provider.validateMandatoryPersonalFields(
      // branchCode: _branchCodeController.text,
      title: _title,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      dob: _dobController.text,
      mobile: _mobileController.text,
      email: _emailController.text,
    );

    // log("Basic Validation Result: $isBasicValid");
    //
    // bool isPanTaxValid = true;
    // log("PAN VALIDATION INPUT VALUES");
    // log("panStatus: ${provider.panStatus}");
    // log("taxStatus: ${provider.taxAssess}");
    // log("panNumber: ${_panNumberController.text}");
    // log("panName: ${_panNameController.text}");
    // log("form60Number: ${_form60Controller.text}");
    // log("wardCircleRange: ${_wardCircleRangeController.text}");
    // log("reasonNoPan: ${_reasonNoPanController.text}");

    // if (showPanSection) {
    // isPanTaxValid = provider.validatePanAndTaxFields(
    //   panStatus: provider.panStatus,
    //   taxStatus: provider.taxAssess,
    //   panNumber: _panNumberController.text,
    //   panName: _panNameController.text,
    //   form60Number: _form60Controller.text,
    //   wardCircleRange: _wardCircleRangeController.text,
    //   reasonNoPan: _reasonNoPanController.text,
    // );
    //
    // log("PAN/TAX Validation Result: $isPanTaxValid");
    // // }
    //
    // if (!isBasicValid || !isPanTaxValid) {
    //   log("❌ Validation failed. Basic: $isBasicValid | PAN: $isPanTaxValid");
    //   return false;
    // }

    log("✅ All validations passed");

    final fullPhone =
        _stdController.text.trim() + _landlineController.text.trim();

    final Map<String, dynamic> dataToStore = {
      "BRANCH_CODE": _branchCodeController.text.trim(),
      "TITLE": _title,
      "FIRST_NAME": _firstNameController.text.trim(),
      "MIDDLE_NAME": _middleNameController.text.trim(),
      "LAST_NAME": _lastNameController.text.trim(),
      "FATHER_NAME": _fatherNameController.text.trim(),
      "SPOUSE_NAME": _spouseNameController.text.trim(),
      "MOTHER_NAME": _motherNameController.text.trim(),
      "MOTHER_MAIDEN_NAME": _motherMaidenController.text.trim(),
      "MARITAL_STATUS": _maritalStatus,
      "DOB": _dobController.text.trim(),

      "STD_CODE": _stdController.text.trim(),
      "LANDLINE_NO": _landlineController.text.trim(),
      "PHONE_NO_1": fullPhone,

      "MOBILE_NO": _mobileController.text.trim(),
      "EMAIL_ID": _emailController.text.trim(),
      "DECLARATION_OPTION": _commSameAsPerm ? 1 : 2,
      // "GENDER": _gender == "Male"
      //     ? "M"
      //     : _gender == "Female"
      //     ? "F"
      //     : "O",
      "GENDER": _genderController.text.trim(),
      "EDUCATION": _education,
      "RESIDENTIAL_STATUS": _residentialStatus,
      "OCCUPATION_TYPE": _occupationType,
      "SUB_OCCUPATION_TYPE": _subOccupationType,
      "EMPLOYER_NAME": _employerController.text.trim(),
      "SOURCE_OF_INCOME": _sourceOfIncome,
      "DESIGNATION": _designationController.text.trim(),
      // "GROSS_INCOME": _incomeController.text.trim(),
      "GROSS_INCOME": _annualIncome,

      // "PAN_STATUS": provider.panStatus,
      // "PAN_NO": _panNumberController.text.trim(),
      // "PAN_NAME": _panNameController.text.trim(),
      // // "PAN_FATHER_NAME": _panFatherController.text.trim(),
      // "PAN_DOB": _panDOBController.text.trim(),
      // "FORM60_NO": _form60Controller.text.trim(),
      // "WARD_CIRCLE_RANGE": _wardCircleRangeController.text.trim(),
      // "REASON_NO_PAN": _reasonNoPanController.text.trim(),
      // "TAX_ASSESSEE": provider.taxAssess,
      // "IS_TAX_ASSESSE": provider.taxAssess == "Y",
      "PERMANENT_ADDRESS_1": _permFlatController.text.trim(),
      "PERMANENT_ADDRESS_2": _permRoadController.text.trim(),
      "PHYSICAL_LANDMARK": _permLandmarkController.text.trim(),
      "PERMANENT_CITY": _permCityController.text.trim(),
      "PERMANENT_STATE": _permStateController.text.trim(),
      "PHYSICAL_DISTRICT": _permDistrictController.text.trim(),
      "PERMANENT_ZIP": _permPincodeController.text.trim(),
      "PERMANENT_COUNTRY": "INDIA",

      "COMMUNICATION_SAME_AS_PERMANENT": _commSameAsPerm ? "Y" : "N",

      "NATIONALITY_CODE": _nationalityCode,
      "SELF_DECLARED_COMMUNICATION_ADDRESS": _addressDeclarationChoice == 0
          ? "Y"
          : "N",
    };

    log("📦 Data Map Created");
    log("DATA: $dataToStore");

    if (!_commSameAsPerm) {
      dataToStore.addAll({
        "COMMUNICATION_ADDRESS_1": _comFlatController.text.trim(),
        "COMMUNICATION_ADDRESS_2": _comRoadController.text.trim(),
        "COMMUNICATION_LANDMARK": _comLandmarkController.text.trim(),
        "COMMUNICATION_CITY": _comCityController.text.trim(),
        "COMMUNICATION_STATE": _comStateController.text.trim(),
        "COMMUNICATION_DISTRICT": _comDistrictController.text.trim(),
        "COMMUNICATION_ZIP": _comPincodeController.text.trim(),
        "COMMUNICATION_COUNTRY": "INDIA",
      });

      log("📍 Communication address added");
    }

    if (_isNonIndian) {
      dataToStore["TYPE_OF_VISA"] = _typeOfVisaController.text.trim();
      dataToStore["VISA_NUMBER"] = _visaNumberController.text.trim();
      dataToStore["VISA_COUNTRY_OF_ISSUE"] = _visaCountryController.text.trim();
      dataToStore["VISA_EXPIRY_DATE"] = _visaExpiryController.text.trim();
      dataToStore["OVERSEAS_ADDRESS_ONE"] = _overseasAddress1Controller.text
          .trim();
      dataToStore["OVERSEAS_ADDRESS_LINE_TWO"] = _overseasAddress2Controller
          .text
          .trim();

      log("🌍 Non-Indian visa details added");
    }

    provider.setPersonalFormData(dataToStore);

    log("✅ Personal form data stored in provider");

    return true;
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = context.watch<PersonalKycProvider>();

    return SingleChildScrollView(
      controller: _scrollController,
      child: Form(
        key: _formKey,
        autovalidateMode: _autoValidate
            ? AutovalidateMode.always
            : AutovalidateMode.disabled,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: showPersonalSection,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RequiredLabel('Branch Code', isRequired: false),
                    SizedBox(height: 5),
                    TextFormField(
                      controller: _branchCodeController,
                      decoration: InputDecoration(
                        hintText: 'Enter branch code',
                        errorText: provider.branchCodeError,
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
                      // validator: _requiredValidator,
                    ),
                    const SizedBox(height: 10),

                    RequiredLabel('Title'),
                    SizedBox(height: 5),
                    Container(
                      key: _titleKey,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: 'Enter title',
                          errorText: provider.titleError,
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
                        value: _title,
                        items: _titleOptions
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                        onChanged: (s) => setState(() => _title = s),
                        validator: (v) =>
                            v == null ? 'Please select title' : null,
                      ),
                    ),
                    const SizedBox(height: 10),

                    RequiredLabel('First name'),
                    SizedBox(height: 5),
                    Container(
                      key: _firstNameKey,
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter first name',
                          errorText: provider.firstNameError,
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
                        onChanged: (val) {
                          provider.setPersonalFormData({
                            ...provider.personalFormData,
                            "FIRST_NAME": val,
                          });
                        },
                        validator: _requiredValidator,
                        readOnly: _firstNameController.text.isEmpty
                            ? false
                            : true,
                      ),
                    ),
                    const SizedBox(height: 10),

                    RequiredLabel('Middle name', isRequired: false),
                    SizedBox(height: 5),
                    TextFormField(
                      controller: _middleNameController,
                      decoration: InputDecoration(
                        hintText: 'Enter middle name',
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
                      validator: _requiredValidator,
                      onChanged: (val) {
                        provider.setPersonalFormData({
                          ...provider.personalFormData,
                          "MIDDLE_NAME": val,
                        });
                      },
                      readOnly: _middleNameController.text.isEmpty
                          ? false
                          : true,
                    ),
                    const SizedBox(height: 10),

                    RequiredLabel('Last name'),
                    SizedBox(height: 5),
                    Container(
                      key: _lastNameKey,
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter last name',
                          errorText: provider.lastNameError,
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
                        validator: _requiredValidator,
                        onChanged: (val) {
                          provider.setPersonalFormData({
                            ...provider.personalFormData,
                            "LAST_NAME": val,
                          });
                        },
                        readOnly: _lastNameController.text.isEmpty
                            ? false
                            : true,
                      ),
                    ),
                    const SizedBox(height: 10),

                    RequiredLabel('Father name'),
                    SizedBox(height: 5),
                    Container(
                      key: _fatherNameKey,
                      child: TextFormField(
                        controller: _fatherNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter father name',
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
                        validator: _requiredValidator,
                        onChanged: (val) {
                          provider.setPersonalFormData({
                            ...provider.personalFormData,
                            "FATHER_NAME": val,
                          });
                        },
                        readOnly: _fatherNameController.text.isEmpty
                            ? false
                            : true,
                      ),
                    ),
                    const SizedBox(height: 10),

                    RequiredLabel('Mother name'),
                    SizedBox(height: 5),
                    Container(
                      key: _motherNameKey,
                      child: TextFormField(
                        controller: _motherNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter mother name',
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
                        validator: _requiredValidator,
                      ),
                    ),
                    const SizedBox(height: 10),

                    RequiredLabel('Mother\'s Maiden name', isRequired: false),
                    SizedBox(height: 5),
                    TextFormField(
                      controller: _motherMaidenController,
                      decoration: InputDecoration(
                        hintText: 'Enter mother\'s maiden name',
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
                      // validator: _requiredValidator,
                    ),
                    const SizedBox(height: 10),

                    RequiredLabel('Marital status'),
                    SizedBox(height: 5),
                    Container(
                      key: _maritalKey,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: 'Enter marital status',
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
                        value: _maritalStatus,
                        items: _maritalOptions
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                        // onChanged: (s) => setState(() => _maritalStatus = s),
                        onChanged: (s) {
                          setState(() {
                            _maritalStatus = s;

                            // Clear spouse name if not married
                            if (_maritalStatus != 'Married') {
                              _spouseNameController.clear();
                            }
                          });
                        },
                        validator: (v) =>
                            v == null ? 'Please select marital status' : null,
                      ),
                    ),
                    const SizedBox(height: 10),

                    /// if Martial status selected as married then spouse name should be asked
                    if (_maritalStatus == 'Married') ...[
                      RequiredLabel('Spouse name'),
                      SizedBox(height: 5),
                      TextFormField(
                        controller: _spouseNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter spouse name',
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

                        // ✅ Validate only when visible
                        validator: (value) {
                          if (_maritalStatus == 'Married') {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter spouse name';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                    ],

                    RequiredLabel('Date of birth'),
                    SizedBox(height: 5),
                    Container(
                      key: _dobKey,
                      child: TextFormField(
                        controller: _dobController,
                        // readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Select date of birth',
                          errorText: provider.dobError,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_month),
                            onPressed: _dobController.text.isEmpty
                                ? _pickDob
                                : null,
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

                          final dob = parseDob(val);
                          if (dob == null) {
                            return "Invalid date format";
                          }

                          final today = DateTime.now();
                          int age = today.year - dob.year;

                          if (today.month < dob.month ||
                              (today.month == dob.month &&
                                  today.day < dob.day)) {
                            age--;
                          }

                          if (age < 18) return "Minimum age must be 18";

                          return null;
                        },

                        onChanged: (val) {
                          final dob = parseDob(val);

                          provider.setPersonalFormData({
                            ...provider.personalFormData,
                            "DOB": dob != null ? formatDob(dob) : val,
                            // normalize
                          });
                        },
                        readOnly: _dobController.text.isEmpty ? false : true,
                      ),
                    ),
                    const SizedBox(height: 10),

                    RequiredLabel('Landline Number', isRequired: false),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Flexible(
                          flex: 2,
                          child: TextFormField(
                            controller: _stdController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(5),
                            ],
                            decoration: InputDecoration(
                              hintText: 'STD',
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
                            validator: (value) {
                              if (_landlineController.text.isNotEmpty &&
                                  (value == null || value.isEmpty)) {
                                return 'Enter STD code';
                              }
                              if (value != null &&
                                  value.isNotEmpty &&
                                  value.length < 2) {
                                return 'STD code must be at least 2 digits';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          flex: 5,
                          child: TextFormField(
                            controller: _landlineController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            decoration: InputDecoration(
                              hintText: 'Enter landline number',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
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
                            // validator: (value) {
                            //   if (value == null || value.isEmpty) {
                            //     return 'Please enter landline number';
                            //   }
                            //   if (value.length < 11 || value.length > 15) {
                            //     return 'Landline number must be 11-15 digits';
                            //   }
                            //   return null;
                            // },
                            validator: (value) {
                              final std = _stdController.text.trim();
                              final landline = value?.trim() ?? "";

                              // both empty → ok
                              if (std.isEmpty && landline.isEmpty) {
                                return null;
                              }
                              // one missing → error
                              if (std.isEmpty || landline.isEmpty) {
                                return 'Enter both STD code and landline number';
                              }
                              // individual length check
                              if (landline.length < 6) {
                                return 'Landline must be at least 6 digits';
                              }
                              final fullNumber = std + landline;
                              if (fullNumber.length < 11 ||
                                  fullNumber.length > 15) {
                                return 'Total must be 11–15 digits';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    RequiredLabel('Mobile Number'),
                    SizedBox(height: 5),
                    Container(
                      key: _mobileKey,
                      child: TextFormField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          hintText: 'Enter mobile number',
                          errorText: provider.mobileError,
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
                        validator: _mobileValidator,
                        onChanged: (val) {
                          provider.setPersonalFormData({
                            ...provider.personalFormData,
                            "MOBILE_NO": val,
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    RequiredLabel('Email ID'),
                    SizedBox(height: 5),
                    Container(
                      key: _emailKey,
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Enter email ID',
                          errorText: provider.emailError,
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
                        keyboardType: TextInputType.emailAddress,
                        validator: _emailValidator,
                      ),
                    ),
                    const SizedBox(height: 10),

                    RequiredLabel('Gender'),
                    SizedBox(height: 5),
                    // DropdownButtonFormField<String>(
                    //   decoration: InputDecoration(
                    //     hintText: 'Select gender',
                    //     contentPadding: const EdgeInsets.symmetric(
                    //       horizontal: 16,
                    //       vertical: 12,
                    //     ),
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(10),
                    //       // Circular border
                    //       borderSide: const BorderSide(color: Colors.grey),
                    //     ),
                    //     enabledBorder: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(10),
                    //       borderSide: const BorderSide(color: Colors.grey),
                    //     ),
                    //     focusedBorder: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(10),
                    //       borderSide: const BorderSide(
                    //         color: Colors.blue,
                    //         width: 2,
                    //       ),
                    //     ),
                    //   ),
                    //   value: _gender,
                    //   items: _genderOptions
                    //       .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    //       .toList(),
                    //   onChanged: (s) => setState(() => _gender = s),
                    //   validator: (v) => v == null ? 'Please select gender' : null,
                    // ),
                    TextFormField(
                      controller: _genderController,
                      decoration: InputDecoration(
                        // hintText: 'Enter first name',
                        errorText: provider.firstNameError,
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
                      onChanged: (val) {
                        provider.setPersonalFormData({
                          ...provider.personalFormData,
                          "GENDER": val,
                        });
                      },
                      validator: _requiredValidator,
                      readOnly: _genderController.text.isEmpty ? false : true,
                    ),
                    const SizedBox(height: 10),

                    RequiredLabel('Education'),
                    SizedBox(height: 5),
                    Container(
                      key: _educationKey,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: 'Select education',
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
                        value: _education,
                        items: _educationOptions
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                        onChanged: (s) => setState(() => _education = s),
                        validator: (v) =>
                            v == null ? 'Please select education' : null,
                      ),
                    ),
                    const SizedBox(height: 10),

                    RequiredLabel('Residential Status'),
                    SizedBox(height: 5),
                    Container(
                      key: _residentialKey,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: 'Select residential status',
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
                        value: _residentialStatus,
                        items: _residentialOptions
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                        onChanged: (s) =>
                            setState(() => _residentialStatus = s),
                        validator: (v) => v == null
                            ? 'Please select residential status'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),

                    RequiredLabel('Occupation Type'),
                    SizedBox(height: 5),
                    Container(
                      key: _occupationKey,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: 'Select occupation type',
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
                        value: _occupationType,
                        items: _occupationOptions
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                        onChanged: (s) => setState(() => _occupationType = s),
                        validator: (v) =>
                            v == null ? 'Please select occupation type' : null,
                      ),
                    ),
                    const SizedBox(height: 10),

                    /// sub-occupation type
                    // RequiredLabel('Sub Occupation'),
                    // SizedBox(height: 5),
                    // DropdownButtonFormField<String>(
                    //   decoration: InputDecoration(
                    //     hintText: 'Select sub occupation type',
                    //     contentPadding: const EdgeInsets.symmetric(
                    //       horizontal: 16,
                    //       vertical: 12,
                    //     ),
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(10),
                    //       // Circular border
                    //       borderSide: const BorderSide(color: Colors.grey),
                    //     ),
                    //     enabledBorder: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(10),
                    //       borderSide: const BorderSide(color: Colors.grey),
                    //     ),
                    //     focusedBorder: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(10),
                    //       borderSide: const BorderSide(
                    //         color: Colors.blue,
                    //         width: 2,
                    //       ),
                    //     ),
                    //   ),
                    //   value: _subOccupationType,
                    //   items: _subOccupationOptions
                    //       .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    //       .toList(),
                    //   onChanged: (s) => setState(() => _subOccupationType = s),
                    //   validator: (v) =>
                    //       v == null ? 'Please select sub occupation type' : null,
                    // ),
                    // const SizedBox(height: 10),
                    RequiredLabel('Employer Name', isRequired: false),
                    SizedBox(height: 5),
                    TextFormField(
                      controller: _employerController,
                      decoration: InputDecoration(
                        hintText: 'Enter employer name',
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
                    ),
                    const SizedBox(height: 10),

                    RequiredLabel('Source of Income', isRequired: false),
                    SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        hintText: 'Select source of income',
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
                      value: _sourceOfIncome,
                      items: _sourceIncomeOptions
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (s) => setState(() => _sourceOfIncome = s),
                      // validator: (v) =>
                      //     v == null ? 'Please select source of income' : null,
                    ),
                    const SizedBox(height: 10),

                    RequiredLabel('Designation', isRequired: false),
                    SizedBox(height: 5),
                    TextFormField(
                      controller: _designationController,
                      decoration: InputDecoration(
                        hintText: 'Enter designation',
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
                    ),
                    const SizedBox(height: 10),

                    RequiredLabel('Annual Income'),
                    SizedBox(height: 5),
                    Container(
                      key: _annualIncomeKey,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: 'Select annual income',
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
                        value: _annualIncome,
                        items: _annualIncomeList
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                        onChanged: (s) => setState(() => _annualIncome = s),
                        validator: (v) =>
                            v == null ? 'Please select annual income' : null,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // RequiredLabel("Do you have a Pan Card?"),
                    // const SizedBox(height: 5),
                    // Consumer<PersonalKycProvider>(
                    //   builder: (context, provider, child) {
                    //     return Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         /// Radio Buttons
                    //         Center(
                    //           child: Container(
                    //             width: 360,
                    //             padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                    //             child: Column(
                    //               crossAxisAlignment: CrossAxisAlignment.start,
                    //               children: [
                    //                 CustomRadioButton(
                    //                   label: "Yes",
                    //                   isSelected: provider.panStatus == "Y",
                    //                   onTap: () {
                    //                     provider.setPanStatus("Y");
                    //                     _form60Controller.clear();
                    //                     _wardCircleRangeController.clear();
                    //                     _reasonNoPanController.clear();
                    //                   },
                    //                 ),
                    //
                    //                 const SizedBox(height: 15),
                    //
                    //                 CustomRadioButton(
                    //                   label: "No",
                    //                   isSelected: provider.panStatus == "N",
                    //                   onTap: () {
                    //                     provider.setPanStatus("N");
                    //                     _panNumberController.clear();
                    //                     _panNameController.clear();
                    //                     _panDOBController.clear();
                    //                     // if pan is no - assess must be yes
                    //                     provider.setTaxAssessStatus("Y");
                    //                   },
                    //                 ),
                    //
                    //                 /// 🔴 PAN STATUS ERROR HERE
                    //                 if (provider.panStatusError != null)
                    //                   Padding(
                    //                     padding: const EdgeInsets.only(
                    //                       left: 8.0,
                    //                       top: 4,
                    //                     ),
                    //                     child: Text(
                    //                       provider.panStatusError!,
                    //                       style: const TextStyle(
                    //                         color: Colors.red,
                    //                         fontSize: 12,
                    //                       ),
                    //                     ),
                    //                   ),
                    //
                    //                 const SizedBox(height: 10),
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //
                    //         const SizedBox(height: 10),
                    //
                    //         /// ✅ IF PAN = YES → SHOW 3 FIELDS
                    //         if (provider.panStatus == "Y") ...[
                    //           RequiredLabel("PAN Number"),
                    //           const SizedBox(height: 5),
                    //
                    //           TextFormField(
                    //             controller: _panNumberController,
                    //             textCapitalization: TextCapitalization.characters,
                    //             inputFormatters: [
                    //               _PanInputFormatter(),
                    //               LengthLimitingTextInputFormatter(10),
                    //             ],
                    //             onChanged: (val) => setState(() {}),
                    //             decoration: InputDecoration(
                    //               hintText: 'e.g. ABCDE1234F',
                    //               errorText: provider.panNumberError,
                    //               // live helper text below field
                    //               helperText: _buildPanHelper(
                    //                 _panNumberController.text,
                    //               ),
                    //               helperStyle: TextStyle(
                    //                 color:
                    //                     _isPanComplete(_panNumberController.text)
                    //                     ? Colors.green
                    //                     : Colors.grey[600],
                    //                 fontSize: 12,
                    //               ),
                    //               // green tick / red cross when 10 chars entered
                    //               suffixIcon:
                    //                   _panNumberController.text.length == 10
                    //                   ? Icon(
                    //                       _isPanComplete(
                    //                             _panNumberController.text,
                    //                           )
                    //                           ? Icons.check_circle
                    //                           : Icons.cancel,
                    //                       color:
                    //                           _isPanComplete(
                    //                             _panNumberController.text,
                    //                           )
                    //                           ? Colors.green
                    //                           : Colors.red,
                    //                     )
                    //                   : null,
                    //               contentPadding: const EdgeInsets.symmetric(
                    //                 horizontal: 16,
                    //                 vertical: 12,
                    //               ),
                    //               border: OutlineInputBorder(
                    //                 borderRadius: BorderRadius.circular(10),
                    //                 borderSide: const BorderSide(
                    //                   color: Colors.grey,
                    //                 ),
                    //               ),
                    //               enabledBorder: OutlineInputBorder(
                    //                 borderRadius: BorderRadius.circular(10),
                    //                 borderSide: BorderSide(
                    //                   color:
                    //                       _isPanComplete(
                    //                         _panNumberController.text,
                    //                       )
                    //                       ? Colors.green
                    //                       : Colors.grey,
                    //                 ),
                    //               ),
                    //               focusedBorder: OutlineInputBorder(
                    //                 borderRadius: BorderRadius.circular(10),
                    //                 borderSide: BorderSide(
                    //                   color:
                    //                       _isPanComplete(
                    //                         _panNumberController.text,
                    //                       )
                    //                       ? Colors.green
                    //                       : Colors.blue,
                    //                   width: 2,
                    //                 ),
                    //               ),
                    //             ),
                    //             validator: (val) {
                    //               if (val == null || val.trim().isEmpty) {
                    //                 return 'PAN number is required';
                    //               }
                    //               if (!RegExp(
                    //                 r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$',
                    //               ).hasMatch(val.trim())) {
                    //                 return 'Invalid PAN: 5 letters + 4 digits + 1 letter (e.g. ABCDE1234F)';
                    //               }
                    //               return null;
                    //             },
                    //           ),
                    //           const SizedBox(height: 10),
                    //
                    //           RequiredLabel("Name as on Card"),
                    //           const SizedBox(height: 5),
                    //
                    //           TextFormField(
                    //             controller: _panNameController,
                    //             decoration: InputDecoration(
                    //               hintText: 'Enter Name as on PAN Card',
                    //               errorText: provider.panNameError,
                    //               helperText: 'Name matching is case-insensitive',
                    //               helperStyle: TextStyle(
                    //                 color: Colors.grey[600],
                    //                 fontSize: 12,
                    //               ),
                    //               contentPadding: const EdgeInsets.symmetric(
                    //                 horizontal: 16,
                    //                 vertical: 12,
                    //               ),
                    //               border: OutlineInputBorder(
                    //                 borderRadius: BorderRadius.circular(10),
                    //               ),
                    //               enabledBorder: OutlineInputBorder(
                    //                 borderRadius: BorderRadius.circular(10),
                    //                 borderSide: const BorderSide(
                    //                   color: Colors.grey,
                    //                 ),
                    //               ),
                    //               focusedBorder: OutlineInputBorder(
                    //                 borderRadius: BorderRadius.circular(10),
                    //                 borderSide: const BorderSide(
                    //                   color: Colors.blue,
                    //                   width: 2,
                    //                 ),
                    //               ),
                    //             ),
                    //             validator: _requiredValidator,
                    //           ),
                    //
                    //           const SizedBox(height: 10),
                    //
                    //           RequiredLabel("Pan DOB"),
                    //           const SizedBox(height: 5),
                    //           TextFormField(
                    //             controller: _panDOBController,
                    //             readOnly: true,
                    //             decoration: InputDecoration(
                    //               hintText: 'Select Pan date of birth',
                    //               errorText: provider.dobError,
                    //               suffixIcon: IconButton(
                    //                 icon: const Icon(Icons.calendar_month),
                    //                 onPressed: _pickPANDob,
                    //               ),
                    //               contentPadding: const EdgeInsets.symmetric(
                    //                 horizontal: 16,
                    //                 vertical: 12,
                    //               ),
                    //               border: OutlineInputBorder(
                    //                 borderRadius: BorderRadius.circular(10),
                    //                 // Circular border
                    //                 borderSide: const BorderSide(
                    //                   color: Colors.grey,
                    //                 ),
                    //               ),
                    //               enabledBorder: OutlineInputBorder(
                    //                 borderRadius: BorderRadius.circular(10),
                    //                 borderSide: const BorderSide(
                    //                   color: Colors.grey,
                    //                 ),
                    //               ),
                    //               focusedBorder: OutlineInputBorder(
                    //                 borderRadius: BorderRadius.circular(10),
                    //                 borderSide: const BorderSide(
                    //                   color: Colors.blue,
                    //                   width: 2,
                    //                 ),
                    //               ),
                    //             ),
                    //             validator: (val) {
                    //               if (val == null || val.isEmpty) {
                    //                 return "This field is required";
                    //               }
                    //
                    //               final dob = DateFormat('dd/MM/yyyy').parse(val);
                    //               final today = DateTime.now();
                    //               int age = today.year - dob.year;
                    //
                    //               if (today.month < dob.month ||
                    //                   (today.month == dob.month &&
                    //                       today.day < dob.day)) {
                    //                 age--;
                    //               }
                    //
                    //               if (age < 18) return "Minimum age must be 18";
                    //
                    //               return null;
                    //             },
                    //           ),
                    //         ],
                    //
                    //         ///  if pan - no then show form 60 + ward/circle/range + reason
                    //         if (provider.panStatus == "N") ...[
                    //           RequiredLabel(
                    //             "To Be Filled by those who do not have PAN or GIR",
                    //           ),
                    //           const SizedBox(height: 5),
                    //
                    //           /// Form 60 number
                    //           TextFormField(
                    //             controller: _form60Controller,
                    //             decoration: InputDecoration(
                    //               hintText:
                    //                   'Enter Form 60 / Form 49A Application Number',
                    //               errorText: provider.form60Error,
                    //               border: OutlineInputBorder(
                    //                 borderRadius: BorderRadius.circular(10),
                    //               ),
                    //             ),
                    //             validator: _requiredValidator,
                    //           ),
                    //
                    //           const SizedBox(height: 10),
                    //
                    //           /// --------------- Tax Assesses Section -----------------
                    //           Consumer<PersonalKycProvider>(
                    //             builder: (context, provider, child) {
                    //               return Column(
                    //                 crossAxisAlignment: CrossAxisAlignment.start,
                    //                 children: [
                    //                   SizedBox(height: 10),
                    //                   RequiredLabel("Are you a Tax Assesses"),
                    //                   const SizedBox(height: 5),
                    //                   Center(
                    //                     child: Container(
                    //                       width: 360,
                    //                       padding: const EdgeInsets.fromLTRB(
                    //                         12,
                    //                         4,
                    //                         12,
                    //                         4,
                    //                       ),
                    //                       child: Column(
                    //                         crossAxisAlignment:
                    //                             CrossAxisAlignment.start,
                    //                         children: [
                    //                           CustomRadioButton(
                    //                             label: "Yes",
                    //                             isSelected:
                    //                                 provider.taxAssess == "Y",
                    //                             onTap: () => provider
                    //                                 .setTaxAssessStatus("Y"),
                    //                           ),
                    //
                    //                           SizedBox(height: 15),
                    //
                    //                           Opacity(
                    //                             opacity: provider.panStatus == "N"
                    //                                 ? 0.4
                    //                                 : 1.0,
                    //                             child: IgnorePointer(
                    //                               ignoring:
                    //                                   provider.panStatus == "N",
                    //                               child: CustomRadioButton(
                    //                                 label: "No",
                    //                                 isSelected:
                    //                                     provider.taxAssess == "N",
                    //                                 onTap: () => provider
                    //                                     .setTaxAssessStatus("N"),
                    //                               ),
                    //                             ),
                    //                           ),
                    //
                    //                           //  msg if PAN - no
                    //                           if (provider.panStatus == "N")
                    //                             const Padding(
                    //                               padding: EdgeInsets.only(
                    //                                 left: 8.0,
                    //                                 top: 6,
                    //                               ),
                    //                               child: Text(
                    //                                 'Tax Assessee must be Yes when PAN is not available',
                    //                                 style: TextStyle(
                    //                                   color: Colors.orange,
                    //                                   fontSize: 12,
                    //                                 ),
                    //                               ),
                    //                             ),
                    //
                    //                           /// 🔴 TAX ASSESSES ERROR
                    //                           if (provider.taxAssessesError !=
                    //                               null)
                    //                             Padding(
                    //                               padding: const EdgeInsets.only(
                    //                                 left: 8.0,
                    //                                 top: 4,
                    //                               ),
                    //                               child: Text(
                    //                                 provider.taxAssessesError!,
                    //                                 style: const TextStyle(
                    //                                   color: Colors.red,
                    //                                   fontSize: 12,
                    //                                 ),
                    //                               ),
                    //                             ),
                    //                         ],
                    //                       ),
                    //                     ),
                    //                   ),
                    //
                    //                   /// show only if yes, then open below
                    //                   if (provider.taxAssess == "Y") ...[
                    //                     const SizedBox(height: 10),
                    //
                    //                     /// Ward/Circle/Range field — now rendered and connected
                    //                     RequiredLabel(
                    //                       '(a) Details of ward/circle/range where the last return of income was filed',
                    //                     ),
                    //                     const SizedBox(height: 5),
                    //                     TextFormField(
                    //                       enabled: true,
                    //                       controller: _wardCircleRangeController,
                    //                       decoration: InputDecoration(
                    //                         hintText:
                    //                             'Enter ward/circle/range details',
                    //                         errorText:
                    //                             provider.wardCircleRangeError,
                    //                         contentPadding:
                    //                             const EdgeInsets.symmetric(
                    //                               horizontal: 16,
                    //                               vertical: 12,
                    //                             ),
                    //                         border: OutlineInputBorder(
                    //                           borderRadius: BorderRadius.circular(
                    //                             10,
                    //                           ),
                    //                           // Circular border
                    //                           borderSide: const BorderSide(
                    //                             color: Colors.grey,
                    //                           ),
                    //                         ),
                    //                         enabledBorder: OutlineInputBorder(
                    //                           borderRadius: BorderRadius.circular(
                    //                             10,
                    //                           ),
                    //                           borderSide: const BorderSide(
                    //                             color: Colors.grey,
                    //                           ),
                    //                         ),
                    //                         focusedBorder: OutlineInputBorder(
                    //                           borderRadius: BorderRadius.circular(
                    //                             10,
                    //                           ),
                    //                           borderSide: const BorderSide(
                    //                             color: Colors.blue,
                    //                             width: 2,
                    //                           ),
                    //                         ),
                    //                       ),
                    //                       validator: (val) {
                    //                         if (provider.panStatus == "N" &&
                    //                             provider.taxAssess == "Y") {
                    //                           return _requiredValidator(val);
                    //                         }
                    //                         return null;
                    //                       },
                    //                     ),
                    //
                    //                     const SizedBox(height: 10),
                    //
                    //                     /// Reason for no PAN field — now rendered and connected
                    //                     RequiredLabel(
                    //                       '(b) Reason for not having PAN No',
                    //                     ),
                    //
                    //                     const SizedBox(height: 5),
                    //                     TextFormField(
                    //                       enabled: provider.panStatus == "N",
                    //                       controller: _reasonNoPanController,
                    //                       decoration: InputDecoration(
                    //                         hintText:
                    //                             'Enter reason for not having PAN',
                    //                         errorText: provider.reasonNoPanError,
                    //                         contentPadding:
                    //                             const EdgeInsets.symmetric(
                    //                               horizontal: 16,
                    //                               vertical: 12,
                    //                             ),
                    //                         border: OutlineInputBorder(
                    //                           borderRadius: BorderRadius.circular(
                    //                             10,
                    //                           ),
                    //                           // Circular border
                    //                           borderSide: const BorderSide(
                    //                             color: Colors.grey,
                    //                           ),
                    //                         ),
                    //                         enabledBorder: OutlineInputBorder(
                    //                           borderRadius: BorderRadius.circular(
                    //                             10,
                    //                           ),
                    //                           borderSide: const BorderSide(
                    //                             color: Colors.grey,
                    //                           ),
                    //                         ),
                    //                         focusedBorder: OutlineInputBorder(
                    //                           borderRadius: BorderRadius.circular(
                    //                             10,
                    //                           ),
                    //                           borderSide: const BorderSide(
                    //                             color: Colors.blue,
                    //                             width: 2,
                    //                           ),
                    //                         ),
                    //                       ),
                    //                       validator: (val) {
                    //                         if (provider.panStatus == "N" &&
                    //                             provider.taxAssess == "Y") {
                    //                           return _requiredValidator(val);
                    //                         }
                    //                         return null;
                    //                       },
                    //                     ),
                    //                   ],
                    //                 ],
                    //               );
                    //             },
                    //           ),
                    //         ],
                    //       ],
                    //     );
                    //   },
                    // ),
                    const SizedBox(height: 12),
                    _buildSectionTitle('Permanent Address'),

                    const SizedBox(height: 10),
                    RequiredLabel('Flat no'),

                    SizedBox(height: 5),
                    Container(
                      key: _permFlatKey,
                      child: TextFormField(
                        controller: _permFlatController,
                        decoration: InputDecoration(
                          hintText: 'Enter flat no',
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
                        validator: _requiredValidator,
                        onChanged: (val) {
                          provider.setPersonalFormData({
                            ...provider.personalFormData,
                            "PERMANENT_ADDRESS_1": val,
                          });
                        },
                        readOnly: _permFlatController.text.isEmpty
                            ? false
                            : true,
                      ),
                    ),
                    const SizedBox(height: 10),

                    RequiredLabel('Road no'),
                    SizedBox(height: 5),
                    Container(
                      key: _permRoadKey,
                      child: TextFormField(
                        controller: _permRoadController,
                        decoration: InputDecoration(
                          hintText: 'Enter road no',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            // Circular b›order
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
                        validator: _requiredValidator,
                        onChanged: (val) {
                          provider.setPersonalFormData({
                            ...provider.personalFormData,
                            "PERMANENT_ADDRESS_2": val,
                          });
                        },
                        readOnly: _permRoadController.text.isEmpty
                            ? false
                            : true,
                      ),
                    ),
                    const SizedBox(height: 10),

                    RequiredLabel('Nearby Landmark'),
                    SizedBox(height: 5),
                    Container(
                      key: _permLandmarkKey,
                      child: TextFormField(
                        controller: _permLandmarkController,
                        decoration: InputDecoration(
                          hintText: 'Enter nearby landmark',
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
                        validator: _requiredValidator,
                        onChanged: (val) {
                          provider.setPersonalFormData({
                            ...provider.personalFormData,
                            "PHYSICAL_LANDMARK": val,
                          });
                        },
                        readOnly: _permLandmarkController.text.isEmpty
                            ? false
                            : true,
                      ),
                    ),
                    const SizedBox(height: 10),

                    RequiredLabel('City/Town/Village'),
                    SizedBox(height: 5),
                    Container(
                      key: _permCityKey,
                      child: TextFormField(
                        controller: _permCityController,
                        decoration: InputDecoration(
                          hintText: 'Enter City/Town/Village',
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
                        validator: _requiredValidator,
                        onChanged: (val) {
                          provider.setPersonalFormData({
                            ...provider.personalFormData,
                            "PERMANENT_CITY": val,
                          });
                        },
                        readOnly: _permCityController.text.isEmpty
                            ? false
                            : true,
                      ),
                    ),
                    const SizedBox(height: 10),

                    RequiredLabel('District'),
                    SizedBox(height: 5),
                    Container(
                      key: _permDistrictKey,
                      child: TextFormField(
                        controller: _permDistrictController,
                        decoration: InputDecoration(
                          hintText: 'Enter district',
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
                        validator: _requiredValidator,
                        onChanged: (val) {
                          provider.setPersonalFormData({
                            ...provider.personalFormData,
                            "PHYSICAL_DISTRICT": val,
                          });
                        },
                        readOnly: _permDistrictController.text.isEmpty
                            ? false
                            : true,
                      ),
                    ),
                    const SizedBox(height: 10),

                    RequiredLabel('State'),
                    SizedBox(height: 5),
                    Container(
                      key: _permStateKey,
                      child: TextFormField(
                        controller: _permStateController,
                        decoration: InputDecoration(
                          hintText: 'Enter state',
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
                        validator: _requiredValidator,
                        onChanged: (val) {
                          provider.setPersonalFormData({
                            ...provider.personalFormData,
                            "PERMANENT_STATE": val,
                          });
                        },
                        readOnly: _permStateController.text.isEmpty
                            ? false
                            : true,
                      ),
                    ),
                    const SizedBox(height: 10),

                    RequiredLabel('Pincode'),
                    SizedBox(height: 5),
                    Container(
                      key: _permPinKey,
                      child: TextFormField(
                        controller: _permPincodeController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        decoration: InputDecoration(
                          hintText: 'Enter pincode',
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
                        validator: _pinCodeValidator,
                        onChanged: (val) {
                          provider.setPersonalFormData({
                            ...provider.personalFormData,
                            "PERMANENT_ZIP": val,
                          });
                        },
                        readOnly: _permPincodeController.text.isEmpty
                            ? false
                            : true,
                      ),
                    ),
                    const SizedBox(height: 10),

                    CheckboxListTile(
                      value: _commSameAsPerm,
                      onChanged: (value) {
                        setState(() {
                          _commSameAsPerm = value ?? false;
                          _addressDeclarationChoice = _commSameAsPerm ? 1 : 0;
                          _copyPermToCommIfNeeded();
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      // 👈 checkbox first
                      title: const Text(
                        'Communication address same as permanent',
                      ),
                    ),
                    const SizedBox(height: 10),

                    _buildSectionTitle('Communication Address'),

                    const SizedBox(height: 10),
                    RequiredLabel('Flat no'),
                    SizedBox(height: 5),
                    Container(
                      key: _comFlatKey,
                      child: TextFormField(
                        controller: _comFlatController,
                        enabled: _commSameAsPerm ? false : true,
                        decoration: InputDecoration(
                          hintText: 'Enter flat no',
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
                          if (!_commSameAsPerm) return _requiredValidator(val);
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    RequiredLabel('Road no'),
                    SizedBox(height: 5),
                    Container(
                      key: _comRoadKey,
                      child: TextFormField(
                        controller: _comRoadController,
                        enabled: _commSameAsPerm ? false : true,
                        decoration: InputDecoration(
                          hintText: 'Enter road no',
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
                          if (!_commSameAsPerm) return _requiredValidator(val);
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    RequiredLabel('Nearby Landmark'),
                    SizedBox(height: 5),
                    Container(
                      key: _comLandmarkKey,
                      child: TextFormField(
                        controller: _comLandmarkController,
                        enabled: _commSameAsPerm ? false : true,
                        decoration: InputDecoration(
                          hintText: 'Enter nearby landmark',
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
                          if (!_commSameAsPerm) return _requiredValidator(val);
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    RequiredLabel('City/Town/Village*'),
                    SizedBox(height: 5),
                    Container(
                      key: _comCityKey,
                      child: TextFormField(
                        controller: _comCityController,
                        enabled: _commSameAsPerm ? false : true,
                        decoration: InputDecoration(
                          hintText: 'Enter City/Town/Village',
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
                          if (!_commSameAsPerm) return _requiredValidator(val);
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    RequiredLabel('District'),
                    SizedBox(height: 5),
                    TextFormField(
                      controller: _comDistrictController,
                      enabled: _commSameAsPerm ? false : true,
                      decoration: InputDecoration(
                        hintText: 'Enter district',
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
                        if (!_commSameAsPerm) return _requiredValidator(val);
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    RequiredLabel('State'),
                    SizedBox(height: 5),
                    Container(
                      key: _comStateKey,
                      child: TextFormField(
                        controller: _comStateController,
                        enabled: _commSameAsPerm ? false : true,
                        decoration: InputDecoration(
                          hintText: 'Enter state',
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
                          if (!_commSameAsPerm) return _requiredValidator(val);
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    RequiredLabel('Pincode'),
                    SizedBox(height: 5),
                    Container(
                      key: _comPinKey,
                      child: TextFormField(
                        controller: _comPincodeController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        enabled: _commSameAsPerm ? false : true,
                        decoration: InputDecoration(
                          hintText: 'Enter pincode',
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
                          if (!_commSameAsPerm) return _pinCodeValidator(val);
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    /// Nationality code
                    // RequiredLabel('Nationality Code'),
                    // SizedBox(height: 5),
                    // DropdownButtonFormField<String>(
                    //   isExpanded: true,
                    //   decoration: InputDecoration(
                    //     hintText: 'Enter nationality code',
                    //     errorText: provider.nationalityCodeError,
                    //     contentPadding: const EdgeInsets.symmetric(
                    //       horizontal: 16,
                    //       vertical: 12,
                    //     ),
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(10),
                    //       // Circular border
                    //       borderSide: const BorderSide(color: Colors.grey),
                    //     ),
                    //     enabledBorder: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(10),
                    //       borderSide: const BorderSide(color: Colors.grey),
                    //     ),
                    //     focusedBorder: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(10),
                    //       borderSide: const BorderSide(
                    //         color: Colors.blue,
                    //         width: 2,
                    //       ),
                    //     ),
                    //   ),
                    //   value: _nationalityCode,
                    //
                    //   items: getNationalityList()
                    //       .map(
                    //         (s) => DropdownMenuItem<String>(
                    //           value: s,
                    //           child: Text(s),
                    //         ),
                    //       )
                    //       .toList(),
                    //   onChanged: (s) {
                    //     setState(() {
                    //       _nationalityCode = s;
                    //       // _nationalityCodeController.text = s ?? "";
                    //     });
                    //   },
                    //   validator: (v) =>
                    //       v == null ? 'Please select nationality code' : null,
                    // ),
                    // const SizedBox(height: 12),

                    /// other than indian
                    if (_isNonIndian) ...[
                      RequiredLabel('Type of Visa'),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _typeOfVisaController,
                        decoration: InputDecoration(
                          hintText: 'Enter visa type',
                          errorText: provider.visaTypeError,
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
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 10),

                      RequiredLabel('Visa Number'),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _visaNumberController,
                        decoration: InputDecoration(
                          hintText: 'Enter visa number',
                          errorText: provider.visaNumberError,
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
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 10),

                      RequiredLabel('Visa Country of Issue'),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _visaCountryController,
                        decoration: InputDecoration(
                          hintText: 'Enter country of issue',
                          errorText: provider.visaCountryError,
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
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 10),

                      RequiredLabel('Visa Expiry Date'),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _visaExpiryController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Select expiry date',
                          errorText: provider.visaExpiryError,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_month),
                            // onPressed: _pickDob,
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                _visaExpiryController.text = DateFormat(
                                  'yyyy-MM-dd',
                                ).format(picked);
                              }
                            },
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
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 10),

                      RequiredLabel('Overseas Address Line 1'),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _overseasAddress1Controller,
                        decoration: InputDecoration(
                          hintText: 'Enter overseas address line 1',
                          errorText: provider.overseasAddress1Error,
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
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 10),

                      RequiredLabel('Overseas Address Line 2'),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _overseasAddress2Controller,
                        decoration: InputDecoration(
                          hintText: 'Enter overseas address line 2',
                          errorText: provider.overseasAddress2Error,
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
                        validator: _requiredValidator,
                      ),
                    ],
                    const SizedBox(height: 10),

                    /// declaration
                    _buildSectionTitle('Declaration'),
                    RadioListTile<int>(
                      value: 0,
                      groupValue: _addressDeclarationChoice,
                      onChanged: _commSameAsPerm
                          ? null
                          : (v) => setState(
                                () => _addressDeclarationChoice = v ?? 0,
                              ),
                      title: const Text(
                        'I hereby declare that above mentioned address is my communication address which is other than address mentioned on my Aadhaar.',
                      ),
                    ),
                    RadioListTile<int>(
                      value: 1,
                      groupValue: _addressDeclarationChoice,
                      onChanged: _commSameAsPerm
                          ? (v) => setState(
                                () => _addressDeclarationChoice = v ?? 1,
                              )
                          : null,
                      title: const Text(
                        'I hereby confirm my current residence/communication address as mentioned above shall be used for any correspondence by the bank in future.',
                      ),
                    ),
                  ],
                ),
              ),

              /// --------------- PAN CARD Section -----------------
              // Visibility(
              //   visible: showPanSection,
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       RequiredLabel("Do you have a Pan Card?"),
              //       const SizedBox(height: 5),
              //       Consumer<PersonalKycProvider>(
              //         builder: (context, provider, child) {
              //           return Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               /// Radio Buttons
              //               Center(
              //                 child: Container(
              //                   width: 360,
              //                   padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
              //                   child: Column(
              //                     crossAxisAlignment: CrossAxisAlignment.start,
              //                     children: [
              //                       CustomRadioButton(
              //                         label: "Yes",
              //                         isSelected: provider.panStatus == "Y",
              //                         onTap: () {
              //                           provider.setPanStatus("Y");
              //                           _form60Controller.clear();
              //                           _wardCircleRangeController.clear();
              //                           _reasonNoPanController.clear();
              //                         },
              //                       ),
              //
              //                       const SizedBox(height: 15),
              //
              //                       CustomRadioButton(
              //                         label: "No",
              //                         isSelected: provider.panStatus == "N",
              //                         onTap: () {
              //                           provider.setPanStatus("N");
              //                           _panNumberController.clear();
              //                           _panNameController.clear();
              //                           _panFatherController.clear();
              //                           // if pan is no - assess must be yes
              //                           provider.setTaxAssessStatus("Y");
              //                         },
              //                       ),
              //
              //                       /// 🔴 PAN STATUS ERROR HERE
              //                       if (provider.panStatusError != null)
              //                         Padding(
              //                           padding: const EdgeInsets.only(left: 8.0, top: 4),
              //                           child: Text(provider.panStatusError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              //                         ),
              //
              //                       const SizedBox(height: 10),
              //                     ],
              //                   ),
              //                 ),
              //               ),
              //
              //               const SizedBox(height: 10),
              //
              //               /// ✅ IF PAN = YES → SHOW 3 FIELDS
              //               if (provider.panStatus == "Y") ...[
              //                 RequiredLabel("PAN Number"),
              //                 const SizedBox(height: 5),
              //
              //                 TextFormField(
              //                   controller: _panNumberController,
              //                   textCapitalization: TextCapitalization.characters,
              //                   inputFormatters: [_PanInputFormatter(), LengthLimitingTextInputFormatter(10)],
              //                   onChanged: (val) => setState(() {}),
              //                   decoration: InputDecoration(
              //                     hintText: 'e.g. ABCDE1234F',
              //                     errorText: provider.panNumberError,
              //                     // live helper text below field
              //                     helperText: _buildPanHelper(_panNumberController.text),
              //                     helperStyle: TextStyle(
              //                       color: _isPanComplete(_panNumberController.text) ? Colors.green : Colors.grey[600],
              //                       fontSize: 12,
              //                     ),
              //                     // green tick / red cross when 10 chars entered
              //                     suffixIcon: _panNumberController.text.length == 10
              //                         ? Icon(
              //                             _isPanComplete(_panNumberController.text) ? Icons.check_circle : Icons.cancel,
              //                             color: _isPanComplete(_panNumberController.text) ? Colors.green : Colors.red,
              //                           )
              //                         : null,
              //                     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //                     border: OutlineInputBorder(
              //                       borderRadius: BorderRadius.circular(10),
              //                       borderSide: const BorderSide(color: Colors.grey),
              //                     ),
              //                     enabledBorder: OutlineInputBorder(
              //                       borderRadius: BorderRadius.circular(10),
              //                       borderSide: BorderSide(color: _isPanComplete(_panNumberController.text) ? Colors.green : Colors.grey),
              //                     ),
              //                     focusedBorder: OutlineInputBorder(
              //                       borderRadius: BorderRadius.circular(10),
              //                       borderSide: BorderSide(color: _isPanComplete(_panNumberController.text) ? Colors.green : Colors.blue, width: 2),
              //                     ),
              //                   ),
              //                   validator: (val) {
              //                     if (val == null || val.trim().isEmpty) {
              //                       return 'PAN number is required';
              //                     }
              //                     if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(val.trim())) {
              //                       return 'Invalid PAN: 5 letters + 4 digits + 1 letter (e.g. ABCDE1234F)';
              //                     }
              //                     return null;
              //                   },
              //                 ),
              //                 const SizedBox(height: 10),
              //
              //                 RequiredLabel("Name as on Card"),
              //                 const SizedBox(height: 5),
              //
              //                 TextFormField(
              //                   controller: _panNameController,
              //                   decoration: InputDecoration(
              //                     hintText: 'Enter Name as on PAN Card',
              //                     errorText: provider.panNameError,
              //                     helperText: 'Name matching is case-insensitive',
              //                     helperStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
              //                     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              //                     enabledBorder: OutlineInputBorder(
              //                       borderRadius: BorderRadius.circular(10),
              //                       borderSide: const BorderSide(color: Colors.grey),
              //                     ),
              //                     focusedBorder: OutlineInputBorder(
              //                       borderRadius: BorderRadius.circular(10),
              //                       borderSide: const BorderSide(color: Colors.blue, width: 2),
              //                     ),
              //                   ),
              //                   validator: _requiredValidator,
              //                 ),
              //
              //                 const SizedBox(height: 10),
              //
              //                 RequiredLabel("Father's / Husband Name"),
              //                 const SizedBox(height: 5),
              //                 TextFormField(
              //                   controller: _panFatherController,
              //                   controller: _panFatherController,
              //                   decoration: InputDecoration(
              //                     hintText: 'Enter Father/Husband Name',
              //                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              //                   ),
              //                   validator: _requiredValidator,
              //                 ),
              //               ],
              //
              //               ///  if pan - no then show form 60 + ward/circle/range + reason
              //               if (provider.panStatus == "N") ...[
              //                 RequiredLabel("To Be Filled by those who do not have PAN or GIR"),
              //                 const SizedBox(height: 5),
              //
              //                 /// Form 60 number
              //                 TextFormField(
              //                   controller: _form60Controller,
              //                   decoration: InputDecoration(
              //                     hintText: 'Enter Form 60 / Form 49A Application Number',
              //                     errorText: provider.form60Error,
              //                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              //                   ),
              //                   validator: _requiredValidator,
              //                 ),
              //
              //                 const SizedBox(height: 10),
              //
              //                 /// --------------- Tax Assesses Section -----------------
              //                 Consumer<PersonalKycProvider>(
              //                   builder: (context, provider, child) {
              //                     return Column(
              //                       crossAxisAlignment: CrossAxisAlignment.start,
              //                       children: [
              //                         SizedBox(height: 10),
              //                         RequiredLabel("Are you a Tax Assesses"),
              //                         const SizedBox(height: 5),
              //                         Center(
              //                           child: Container(
              //                             width: 360,
              //                             padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
              //                             child: Column(
              //                               crossAxisAlignment: CrossAxisAlignment.start,
              //                               children: [
              //                                 CustomRadioButton(
              //                                   label: "Yes",
              //                                   isSelected: provider.taxAssess == "Y",
              //                                   onTap: () => provider.setTaxAssessStatus("Y"),
              //                                 ),
              //
              //                                 SizedBox(height: 15),
              //
              //                                 Opacity(
              //                                   opacity: provider.panStatus == "N" ? 0.4 : 1.0,
              //                                   child: IgnorePointer(
              //                                     ignoring: provider.panStatus == "N",
              //                                     child: CustomRadioButton(
              //                                       label: "No",
              //                                       isSelected: provider.taxAssess == "N",
              //                                       onTap: () => provider.setTaxAssessStatus("N"),
              //                                     ),
              //                                   ),
              //                                 ),
              //
              //                                 //  msg if PAN - no
              //                                 if (provider.panStatus == "N")
              //                                   const Padding(
              //                                     padding: EdgeInsets.only(left: 8.0, top: 6),
              //                                     child: Text(
              //                                       'Tax Assessee must be Yes when PAN is not available',
              //                                       style: TextStyle(color: Colors.orange, fontSize: 12),
              //                                     ),
              //                                   ),
              //
              //                                 /// 🔴 TAX ASSESSES ERROR
              //                                 if (provider.taxAssessesError != null)
              //                                   Padding(
              //                                     padding: const EdgeInsets.only(left: 8.0, top: 4),
              //                                     child: Text(provider.taxAssessesError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              //                                   ),
              //                               ],
              //                             ),
              //                           ),
              //                         ),
              //
              //                         /// show only if yes, then open below
              //                         if (provider.taxAssess == "Y") ...[
              //                           const SizedBox(height: 10),
              //
              //                           /// Ward/Circle/Range field — now rendered and connected
              //                           RequiredLabel('(a) Details of ward/circle/range where the last return of income was filed'),
              //                           const SizedBox(height: 5),
              //                           TextFormField(
              //                             enabled: true,
              //                             controller: _wardCircleRangeController,
              //                             decoration: InputDecoration(
              //                               hintText: 'Enter ward/circle/range details',
              //                               errorText: provider.wardCircleRangeError,
              //                               contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //                               border: OutlineInputBorder(
              //                                 borderRadius: BorderRadius.circular(10),
              //                                 // Circular border
              //                                 borderSide: const BorderSide(color: Colors.grey),
              //                               ),
              //                               enabledBorder: OutlineInputBorder(
              //                                 borderRadius: BorderRadius.circular(10),
              //                                 borderSide: const BorderSide(color: Colors.grey),
              //                               ),
              //                               focusedBorder: OutlineInputBorder(
              //                                 borderRadius: BorderRadius.circular(10),
              //                                 borderSide: const BorderSide(color: Colors.blue, width: 2),
              //                               ),
              //                             ),
              //                             validator: (val) {
              //                               if (provider.panStatus == "N" && provider.taxAssess == "Y") {
              //                                 return _requiredValidator(val);
              //                               }
              //                               return null;
              //                             },
              //                           ),
              //
              //                           const SizedBox(height: 10),
              //
              //                           /// Reason for no PAN field — now rendered and connected
              //                           RequiredLabel('(b) Reason for not having PAN No'),
              //
              //                           const SizedBox(height: 5),
              //                           TextFormField(
              //                             enabled: provider.panStatus == "N",
              //                             controller: _reasonNoPanController,
              //                             decoration: InputDecoration(
              //                               hintText: 'Enter reason for not having PAN',
              //                               errorText: provider.reasonNoPanError,
              //                               contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //                               border: OutlineInputBorder(
              //                                 borderRadius: BorderRadius.circular(10),
              //                                 // Circular border
              //                                 borderSide: const BorderSide(color: Colors.grey),
              //                               ),
              //                               enabledBorder: OutlineInputBorder(
              //                                 borderRadius: BorderRadius.circular(10),
              //                                 borderSide: const BorderSide(color: Colors.grey),
              //                               ),
              //                               focusedBorder: OutlineInputBorder(
              //                                 borderRadius: BorderRadius.circular(10),
              //                                 borderSide: const BorderSide(color: Colors.blue, width: 2),
              //                               ),
              //                             ),
              //                             validator: (val) {
              //                               if (provider.panStatus == "N" && provider.taxAssess == "Y") {
              //                                 return _requiredValidator(val);
              //                               }
              //                               return null;
              //                             },
              //                           ),
              //                         ],
              //                       ],
              //                     );
              //                   },
              //                 ),
              //               ],
              //             ],
              //           );
              //         },
              //       ),
              //
              //       const SizedBox(height: 12),
              //       _buildSectionTitle('Permanent Address'),
              //       const SizedBox(height: 10),
              //       RequiredLabel('Flat no'),
              //       SizedBox(height: 5),
              //       TextFormField(
              //         controller: _permFlatController,
              //         decoration: InputDecoration(
              //           hintText: 'Enter flat no',
              //           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //           border: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             // Circular border
              //             borderSide: const BorderSide(color: Colors.grey),
              //           ),
              //           enabledBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: const BorderSide(color: Colors.grey),
              //           ),
              //           focusedBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: const BorderSide(color: Colors.blue, width: 2),
              //           ),
              //         ),
              //         validator: _requiredValidator,
              //       ),
              //       const SizedBox(height: 10),
              //
              //       RequiredLabel('Road no'),
              //       SizedBox(height: 5),
              //       TextFormField(
              //         controller: _permRoadController,
              //         decoration: InputDecoration(
              //           hintText: 'Enter road no',
              //           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //           border: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             // Circular b›order
              //             borderSide: const BorderSide(color: Colors.grey),
              //           ),
              //           enabledBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: const BorderSide(color: Colors.grey),
              //           ),
              //           focusedBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: const BorderSide(color: Colors.blue, width: 2),
              //           ),
              //         ),
              //         validator: _requiredValidator,
              //       ),
              //       const SizedBox(height: 10),
              //
              //       RequiredLabel('Nearby Landmark'),
              //       SizedBox(height: 5),
              //       TextFormField(
              //         controller: _permLandmarkController,
              //         decoration: InputDecoration(
              //           hintText: 'Enter nearby landmark',
              //           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //           border: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             // Circular border
              //             borderSide: const BorderSide(color: Colors.grey),
              //           ),
              //           enabledBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: const BorderSide(color: Colors.grey),
              //           ),
              //           focusedBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: const BorderSide(color: Colors.blue, width: 2),
              //           ),
              //         ),
              //         validator: _requiredValidator,
              //       ),
              //       const SizedBox(height: 10),
              //
              //       RequiredLabel('City/Town/Village'),
              //       SizedBox(height: 5),
              //       TextFormField(
              //         controller: _permCityController,
              //         decoration: InputDecoration(
              //           hintText: 'Enter City/Town/Village',
              //           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //           border: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             // Circular border
              //             borderSide: const BorderSide(color: Colors.grey),
              //           ),
              //           enabledBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: const BorderSide(color: Colors.grey),
              //           ),
              //           focusedBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: const BorderSide(color: Colors.blue, width: 2),
              //           ),
              //         ),
              //         validator: _requiredValidator,
              //       ),
              //       const SizedBox(height: 10),
              //
              //       RequiredLabel('State'),
              //       SizedBox(height: 5),
              //       TextFormField(
              //         controller: _permStateController,
              //         decoration: InputDecoration(
              //           hintText: 'Enter state',
              //           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //           border: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             // Circular border
              //             borderSide: const BorderSide(color: Colors.grey),
              //           ),
              //           enabledBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: const BorderSide(color: Colors.grey),
              //           ),
              //           focusedBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: const BorderSide(color: Colors.blue, width: 2),
              //           ),
              //         ),
              //         validator: _requiredValidator,
              //       ),
              //       const SizedBox(height: 10),
              //
              //       RequiredLabel('District'),
              //       SizedBox(height: 5),
              //       TextFormField(
              //         controller: _permDistrictController,
              //         decoration: InputDecoration(
              //           hintText: 'Enter district',
              //           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //           border: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             // Circular border
              //             borderSide: const BorderSide(color: Colors.grey),
              //           ),
              //           enabledBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: const BorderSide(color: Colors.grey),
              //           ),
              //           focusedBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: const BorderSide(color: Colors.blue, width: 2),
              //           ),
              //         ),
              //         validator: _requiredValidator,
              //       ),
              //       const SizedBox(height: 10),
              //
              //       RequiredLabel('Pincode'),
              //       SizedBox(height: 5),
              //       TextFormField(
              //         controller: _permPincodeController,
              //         keyboardType: TextInputType.phone,
              //         inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              //         decoration: InputDecoration(
              //           hintText: 'Enter pincode',
              //           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //           border: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             // Circular border
              //             borderSide: const BorderSide(color: Colors.grey),
              //           ),
              //           enabledBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: const BorderSide(color: Colors.grey),
              //           ),
              //           focusedBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: const BorderSide(color: Colors.blue, width: 2),
              //           ),
              //         ),
              //         validator: _pinCodeValidator,
              //       ),
              //       const SizedBox(height: 10),
              //
              //       CheckboxListTile(
              //         value: _commSameAsPerm,
              //         onChanged: (value) {
              //           setState(() {
              //             _commSameAsPerm = value ?? false;
              //             _copyPermToCommIfNeeded();
              //           });
              //         },
              //         controlAffinity: ListTileControlAffinity.leading,
              //         // 👈 checkbox first
              //         title: const Text('Communication address same as permanent'),
              //       ),
              //       const SizedBox(height: 10),
              //
              //       _buildSectionTitle('Communication Address'),
              //
              //       const SizedBox(height: 10),
              //       RequiredLabel('Flat no'),
              //       SizedBox(height: 5),
              //       TextFormField(
              //         controller: _comFlatController,
              //         enabled: _commSameAsPerm ? false : true,
              //         decoration: InputDecoration(
              //           hintText: 'Enter flat no',
              //           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //           border: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             // Circular border
              //             borderSide: const BorderSide(color: Colors.grey),
              //           ),
              //           enabledBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: const BorderSide(color: Colors.grey),
              //           ),
              //           focusedBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: const BorderSide(color: Colors.blue, width: 2),
              //           ),
              //         ),
              //         validator: (val) {
              //           if (!_commSameAsPerm) return _requiredValidator(val);
              //           return null;
              //         },
              //       ),
              //       const SizedBox(height: 10),
              //
              //       RequiredLabel('Road no'),
              //       SizedBox(height: 5),
              //       TextFormField(
              //         controller: _comRoadController,
              //         enabled: _commSameAsPerm ? false : true,
              //         decoration: InputDecoration(
              //           hintText: 'Enter road no',
              //           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //           border: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             // Circular border
              //             borderSide: const BorderSide(color: Colors.grey),
              //           ),
              //           enabledBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: const BorderSide(color: Colors.grey),
              //           ),
              //           focusedBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: const BorderSide(color: Colors.blue, width: 2),
              //           ),
              //         ),
              //         validator: (val) {
              //           if (!_commSameAsPerm) return _requiredValidator(val);
              //           return null;
              //         },
              //       ),
              //       const SizedBox(height: 10),
              //
              //       RequiredLabel('Nearby Landmark'),
              //       SizedBox(height: 5),
              //       TextFormField(
              //         controller: _comLandmarkController,
              //         enabled: _commSameAsPerm ? false : true,
              //         decoration: InputDecoration(
              //           hintText: 'Enter nearby landmark',
              //           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //           border: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             // Circular border
              //             borderSide: const BorderSide(color: Colors.grey),
              //           ),
              //           enabledBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: const BorderSide(color: Colors.grey),
              //           ),
              //           focusedBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: const BorderSide(color: Colors.blue, width: 2),
              //           ),
              //         ),
              //
              //         validator: (val) {
              //           if (!_commSameAsPerm) return _requiredValidator(val);
              //           return null;
              //         },
              //       ),
              //       const SizedBox(height: 10),
              //
              //       RequiredLabel('City/Town/Village*'),
              //       SizedBox(height: 5),
              //       TextFormField(
              //         controller: _comCityController,
              //         enabled: _commSameAsPerm ? false : true,
              //         decoration: InputDecoration(
              //           hintText: 'Enter City/Town/Village',
              //           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //           border: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             // Circular border
              //             borderSide: const BorderSide(color: Colors.grey),
              //           ),
              //           enabledBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: const BorderSide(color: Colors.grey),
              //           ),
              //           focusedBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: const BorderSide(color: Colors.blue, width: 2),
              //           ),
              //         ),
              //         validator: (val) {
              //           if (!_commSameAsPerm) return _requiredValidator(val);
              //           return null;
              //         },
              //       ),
              //       const SizedBox(height: 10),
              //
              //       RequiredLabel('State'),
              //       SizedBox(height: 5),
              //       TextFormField(
              //         controller: _comStateController,
              //         enabled: _commSameAsPerm ? false : true,
              //         decoration: InputDecoration(
              //           hintText: 'Enter state',
              //           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //           border: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             // Circular border
              //             borderSide: const BorderSide(color: Colors.grey),
              //           ),
              //           enabledBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: const BorderSide(color: Colors.grey),
              //           ),
              //           focusedBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: const BorderSide(color: Colors.blue, width: 2),
              //           ),
              //         ),
              //         validator: (val) {
              //           if (!_commSameAsPerm) return _requiredValidator(val);
              //           return null;
              //         },
              //       ),
              //       const SizedBox(height: 10),
              //
              //       RequiredLabel('District'),
              //       SizedBox(height: 5),
              //       TextFormField(
              //         controller: _comDistrictController,
              //         enabled: _commSameAsPerm ? false : true,
              //         decoration: InputDecoration(
              //           hintText: 'Enter district',
              //           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //           border: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             // Circular border
              //             borderSide: const BorderSide(color: Colors.grey),
              //           ),
              //           enabledBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: const BorderSide(color: Colors.grey),
              //           ),
              //           focusedBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: const BorderSide(color: Colors.blue, width: 2),
              //           ),
              //         ),
              //         validator: (val) {
              //           if (!_commSameAsPerm) return _requiredValidator(val);
              //           return null;
              //         },
              //       ),
              //       const SizedBox(height: 10),
              //
              //       RequiredLabel('Pincode'),
              //       SizedBox(height: 5),
              //       TextFormField(
              //         controller: _comPincodeController,
              //         keyboardType: TextInputType.phone,
              //         inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              //         enabled: _commSameAsPerm ? false : true,
              //         decoration: InputDecoration(
              //           hintText: 'Enter pincode',
              //           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //           border: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             // Circular border
              //             borderSide: const BorderSide(color: Colors.grey),
              //           ),
              //           enabledBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: const BorderSide(color: Colors.grey),
              //           ),
              //           focusedBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: const BorderSide(color: Colors.blue, width: 2),
              //           ),
              //         ),
              //         validator: (val) {
              //           if (!_commSameAsPerm) return _pinCodeValidator(val);
              //           return null;
              //         },
              //       ),
              //       const SizedBox(height: 10),
              //
              //       /// Nationality code
              //       RequiredLabel('Nationality Code'),
              //       SizedBox(height: 5),
              //       DropdownButtonFormField<String>(
              //         isExpanded: true,
              //         decoration: InputDecoration(
              //           hintText: 'Enter nationality code',
              //           errorText: provider.nationalityCodeError,
              //           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //           border: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             // Circular border
              //             borderSide: const BorderSide(color: Colors.grey),
              //           ),
              //           enabledBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: const BorderSide(color: Colors.grey),
              //           ),
              //           focusedBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //             borderSide: const BorderSide(color: Colors.blue, width: 2),
              //           ),
              //         ),
              //         value: _nationalityCode,
              //
              //         items: getNationalityList().map((s) => DropdownMenuItem<String>(value: s, child: Text(s))).toList(),
              //         onChanged: (s) {
              //           setState(() {
              //             _nationalityCode = s;
              //             // _nationalityCodeController.text = s ?? "";
              //           });
              //         },
              //         validator: (v) => v == null ? 'Please select nationality code' : null,
              //       ),
              //       const SizedBox(height: 12),
              //
              //       /// other than indian
              //       if (_isNonIndian) ...[
              //         RequiredLabel('Type of Visa'),
              //         const SizedBox(height: 5),
              //         TextFormField(
              //           controller: _typeOfVisaController,
              //           decoration: InputDecoration(
              //             hintText: 'Enter visa type',
              //             errorText: provider.visaTypeError,
              //             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //             border: OutlineInputBorder(
              //               borderRadius: BorderRadius.circular(10),
              //               // Circular border
              //               borderSide: const BorderSide(color: Colors.grey),
              //             ),
              //             enabledBorder: OutlineInputBorder(
              //               borderRadius: BorderRadius.circular(10),
              //               borderSide: const BorderSide(color: Colors.grey),
              //             ),
              //             focusedBorder: OutlineInputBorder(
              //               borderRadius: BorderRadius.circular(10),
              //               borderSide: const BorderSide(color: Colors.blue, width: 2),
              //             ),
              //           ),
              //           validator: _requiredValidator,
              //         ),
              //         const SizedBox(height: 10),
              //
              //         RequiredLabel('Visa Number'),
              //         const SizedBox(height: 5),
              //         TextFormField(
              //           controller: _visaNumberController,
              //           decoration: InputDecoration(
              //             hintText: 'Enter visa number',
              //             errorText: provider.visaNumberError,
              //             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //             border: OutlineInputBorder(
              //               borderRadius: BorderRadius.circular(10),
              //               // Circular border
              //               borderSide: const BorderSide(color: Colors.grey),
              //             ),
              //             enabledBorder: OutlineInputBorder(
              //               borderRadius: BorderRadius.circular(10),
              //               borderSide: const BorderSide(color: Colors.grey),
              //             ),
              //             focusedBorder: OutlineInputBorder(
              //               borderRadius: BorderRadius.circular(10),
              //               borderSide: const BorderSide(color: Colors.blue, width: 2),
              //             ),
              //           ),
              //           validator: _requiredValidator,
              //         ),
              //         const SizedBox(height: 10),
              //
              //         RequiredLabel('Visa Country of Issue'),
              //         const SizedBox(height: 5),
              //         TextFormField(
              //           controller: _visaCountryController,
              //           decoration: InputDecoration(
              //             hintText: 'Enter country of issue',
              //             errorText: provider.visaCountryError,
              //             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //             border: OutlineInputBorder(
              //               borderRadius: BorderRadius.circular(10),
              //               // Circular border
              //               borderSide: const BorderSide(color: Colors.grey),
              //             ),
              //             enabledBorder: OutlineInputBorder(
              //               borderRadius: BorderRadius.circular(10),
              //               borderSide: const BorderSide(color: Colors.grey),
              //             ),
              //             focusedBorder: OutlineInputBorder(
              //               borderRadius: BorderRadius.circular(10),
              //               borderSide: const BorderSide(color: Colors.blue, width: 2),
              //             ),
              //           ),
              //           validator: _requiredValidator,
              //         ),
              //         const SizedBox(height: 10),
              //
              //         RequiredLabel('Visa Expiry Date'),
              //         const SizedBox(height: 5),
              //         TextFormField(
              //           controller: _visaExpiryController,
              //           readOnly: true,
              //           decoration: InputDecoration(
              //             hintText: 'Select expiry date',
              //             errorText: provider.visaExpiryError,
              //             suffixIcon: IconButton(
              //               icon: const Icon(Icons.calendar_month),
              //               // onPressed: _pickDob,
              //               onPressed: () async {
              //                 final picked = await showDatePicker(
              //                   context: context,
              //                   initialDate: DateTime.now(),
              //                   firstDate: DateTime.now(),
              //                   lastDate: DateTime(2100),
              //                 );
              //                 if (picked != null) {
              //                   _visaExpiryController.text = DateFormat('yyyy-MM-dd').format(picked);
              //                 }
              //               },
              //             ),
              //             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //             border: OutlineInputBorder(
              //               borderRadius: BorderRadius.circular(10),
              //               // Circular border
              //               borderSide: const BorderSide(color: Colors.grey),
              //             ),
              //             enabledBorder: OutlineInputBorder(
              //               borderRadius: BorderRadius.circular(10),
              //               borderSide: const BorderSide(color: Colors.grey),
              //             ),
              //             focusedBorder: OutlineInputBorder(
              //               borderRadius: BorderRadius.circular(10),
              //               borderSide: const BorderSide(color: Colors.blue, width: 2),
              //             ),
              //           ),
              //           validator: _requiredValidator,
              //         ),
              //         const SizedBox(height: 10),
              //
              //         RequiredLabel('Overseas Address Line 1'),
              //         const SizedBox(height: 5),
              //         TextFormField(
              //           controller: _overseasAddress1Controller,
              //           decoration: InputDecoration(
              //             hintText: 'Enter overseas address line 1',
              //             errorText: provider.overseasAddress1Error,
              //             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //             border: OutlineInputBorder(
              //               borderRadius: BorderRadius.circular(10),
              //               // Circular border
              //               borderSide: const BorderSide(color: Colors.grey),
              //             ),
              //             enabledBorder: OutlineInputBorder(
              //               borderRadius: BorderRadius.circular(10),
              //               borderSide: const BorderSide(color: Colors.grey),
              //             ),
              //             focusedBorder: OutlineInputBorder(
              //               borderRadius: BorderRadius.circular(10),
              //               borderSide: const BorderSide(color: Colors.blue, width: 2),
              //             ),
              //           ),
              //           validator: _requiredValidator,
              //         ),
              //         const SizedBox(height: 10),
              //
              //         RequiredLabel('Overseas Address Line 2'),
              //         const SizedBox(height: 5),
              //         TextFormField(
              //           controller: _overseasAddress2Controller,
              //           decoration: InputDecoration(
              //             hintText: 'Enter overseas address line 2',
              //             errorText: provider.overseasAddress2Error,
              //             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //             border: OutlineInputBorder(
              //               borderRadius: BorderRadius.circular(10),
              //               // Circular border
              //               borderSide: const BorderSide(color: Colors.grey),
              //             ),
              //             enabledBorder: OutlineInputBorder(
              //               borderRadius: BorderRadius.circular(10),
              //               borderSide: const BorderSide(color: Colors.grey),
              //             ),
              //             focusedBorder: OutlineInputBorder(
              //               borderRadius: BorderRadius.circular(10),
              //               borderSide: const BorderSide(color: Colors.blue, width: 2),
              //             ),
              //           ),
              //           validator: _requiredValidator,
              //         ),
              //       ],
              //       const SizedBox(height: 10),
              //
              //       /// declaration
              //       _buildSectionTitle('Declaration'),
              //       RadioListTile<int>(
              //         value: 0,
              //         groupValue: _addressDeclarationChoice,
              //         onChanged: (v) => setState(() => _addressDeclarationChoice = v ?? 0),
              //         title: const Text(
              //           'I hereby declare that above mentioned address is my communication address which is other than address mentioned on my Aadhaar.',
              //         ),
              //       ),
              //       RadioListTile<int>(
              //         value: 1,
              //         groupValue: _addressDeclarationChoice,
              //         onChanged: (v) => setState(() => _addressDeclarationChoice = v ?? 1),
              //         title: const Text(
              //           'I hereby confirm my current residence/communication address as mentioned above shall be used for any correspondence by the bank in future.',
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              /// --------------- Permanent Address Details Screen -----------------
              // Visibility(
              //   visible: showAddressSection,
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
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
