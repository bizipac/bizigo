class AadhaarOtpVerifyModel {
  final bool success;
  final String message;
  final AadhaarOtpVerifyData? data;

  AadhaarOtpVerifyModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory AadhaarOtpVerifyModel.fromJson(Map<String, dynamic> json) {
    return AadhaarOtpVerifyModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? AadhaarOtpVerifyData.fromJson(json['data'])
          : null,
    );
  }
}

class AadhaarOtpVerifyData {
  final EkycData? ekycData;
  final RawResponse? rawResponse;

  AadhaarOtpVerifyData({this.ekycData, this.rawResponse});

  factory AadhaarOtpVerifyData.fromJson(Map<String, dynamic> json) {
    return AadhaarOtpVerifyData(
      ekycData: json['ekyc_data'] != null
          ? EkycData.fromJson(json['ekyc_data'])
          : null,
      rawResponse: json['raw_response'] != null
          ? RawResponse.fromJson(json['raw_response'])
          : null,
    );
  }
}

class EkycData {
  final String aadhaarNumber;
  final String token;
  final String dob;
  final String gender;
  final String name;
  final String fatherName;
  final String country;
  final String district;
  final String houseNumber;
  final String landmark;
  final String location;
  final String pincode;
  final String state;
  final String street;
  final String villageTownCity;
  final String photo;
  final String prn;

  EkycData({
    required this.aadhaarNumber,
    required this.token,
    required this.dob,
    required this.gender,
    required this.name,
    required this.fatherName,
    required this.country,
    required this.district,
    required this.houseNumber,
    required this.landmark,
    required this.location,
    required this.pincode,
    required this.state,
    required this.street,
    required this.villageTownCity,
    required this.photo,
    required this.prn,
  });

  factory EkycData.fromJson(Map<String, dynamic> json) {
    return EkycData(
      aadhaarNumber: json['aadhaar_number'] ?? '',
      token: json['token'] ?? '',
      dob: json['dob'] ?? '',
      gender: json['gender'] ?? '',
      name: json['name'] ?? '',
      fatherName: json['father_name'] ?? '',
      country: json['country'] ?? '',
      district: json['district'] ?? '',
      houseNumber: json['house_number'] ?? '',
      landmark: json['landmark'] ?? '',
      location: json['location'] ?? '',
      pincode: json['pincode'] ?? '',
      state: json['state'] ?? '',
      street: json['street'] ?? '',
      villageTownCity: json['village_town_city'] ?? '',
      photo: json['photo'] ?? '',
      prn: json['prn'] ?? '',
    );
  }
}

class RawResponse {
  final UidData? uidData;

  RawResponse({this.uidData});

  factory RawResponse.fromJson(Map<String, dynamic> json) {
    return RawResponse(
      uidData: json['UidData'] != null
          ? UidData.fromJson(json['UidData'])
          : null,
    );
  }
}

class UidData {
  final String uid;
  final String token;
  final String dob;
  final String gender;
  final String name;
  final String co;
  final String country;
  final String district;
  final String house;
  final String landmark;
  final String location;
  final String pincode;
  final String state;
  final String street;
  final String vtc;
  final String photo;
  final String prn;

  UidData({
    required this.uid,
    required this.token,
    required this.dob,
    required this.gender,
    required this.name,
    required this.co,
    required this.country,
    required this.district,
    required this.house,
    required this.landmark,
    required this.location,
    required this.pincode,
    required this.state,
    required this.street,
    required this.vtc,
    required this.photo,
    required this.prn,
  });

  factory UidData.fromJson(Map<String, dynamic> json) {
    return UidData(
      uid: json['uid'] ?? '',
      token: json['tkn'] ?? '',
      dob: json['dob'] ?? '',
      gender: json['gender'] ?? '',
      name: json['name'] ?? '',
      co: json['co'] ?? '',
      country: json['country'] ?? '',
      district: json['dist'] ?? '',
      house: json['house'] ?? '',
      landmark: json['lm'] ?? '',
      location: json['loc'] ?? '',
      pincode: json['pc'] ?? '',
      state: json['state'] ?? '',
      street: json['street'] ?? '',
      vtc: json['vtc'] ?? '',
      photo: json['Pht'] ?? '',
      prn: json['Prn'] ?? '',
    );
  }
}
