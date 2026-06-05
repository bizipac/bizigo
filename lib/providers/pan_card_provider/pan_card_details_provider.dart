import 'package:flutter/material.dart';

class PanCardDetailsProvider extends ChangeNotifier {
  String? panStatus;
  String? taxAssess;

  String? panStatusError;
  String? taxAssessesError;
  String? panNumberError;
  String? panNameError;
  String? dobError;
  String? form60Error;
  String? wardCircleRangeError;
  String? reasonNoPanError;

  Map<String, dynamic> _panFormData = {};
  Map<String, dynamic> get panFormData => _panFormData;

  // void setPanStatus(String value) {
  //   panStatus = value;
  //   notifyListeners();
  // }

  void setPanStatus(String value) {
    panStatus = value;
    // ✅ When PAN = Y, default taxAssess to "Y"
    if (value == "Y") {
      taxAssess = "Y";
    }
    notifyListeners();
  }

  void setTaxAssessStatus(String value) {
    taxAssess = value;
    notifyListeners();
  }

  void setPanFormData(Map<String, dynamic> data) {
    _panFormData.addAll(data);
    notifyListeners();
  }

  bool validatePanAndTaxFields({
    required String? panStatus,
    required String? taxStatus,
    required String panNumber,
    required String panName,
    required String form60Number,
    required String wardCircleRange,
    required String reasonNoPan,
  }) {
    panStatusError = null;
    taxAssessesError = null;
    panNumberError = null;
    panNameError = null;
    form60Error = null;
    wardCircleRangeError = null;
    reasonNoPanError = null;

    bool isValid = true;

    if (panStatus == null || panStatus.isEmpty) {
      panStatusError = "Please select PAN status";
      isValid = false;
    }

    if (panStatus == "Y") {
      if (panNumber.trim().isEmpty) {
        panNumberError = "PAN number is mandatory";
        isValid = false;
      } else if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(panNumber.trim())) {
        panNumberError = "Enter valid PAN (e.g. ABCDE1234F)";
        isValid = false;
      }
      if (panName.trim().isEmpty) {
        panNameError = "Name as per PAN is mandatory";
        isValid = false;
      }
    }

    if (panStatus == "N") {
      if (form60Number.trim().isEmpty) {
        form60Error = "Form 60 number is mandatory";
        isValid = false;
      }
      if (wardCircleRange.trim().isEmpty) {
        wardCircleRangeError = "Ward/Circle/Range is mandatory";
        isValid = false;
      }
      if (reasonNoPan.trim().isEmpty) {
        reasonNoPanError = "Reason is mandatory";
        isValid = false;
      }
      if (taxStatus == null || taxStatus.isEmpty) {
        taxAssessesError = "Please select Tax Assessee";
        isValid = false;
      }
    }

    notifyListeners();
    return isValid;
  }

  bool validPanData() {
    if (panStatus == null) {
      panStatusError = "Please select PAN status";
      notifyListeners();
      return false;
    }
    if (_panFormData.isEmpty) {
      return false;
    }
    return true;
  }
}