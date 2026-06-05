import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:icici_bank/core/network/api_client.dart';
import 'package:icici_bank/core/network/network_api.dart';
import 'package:icici_bank/providers/personal_provider/personal_kyc_provider.dart';

void main() {
  test(
    'saves personal details before address details with mocked endpoints',
    () async {
      final dio = Dio();
      final adapter = DioAdapter(dio: dio);
      final apiClient = ApiClient(dio: dio);
      final provider = PersonalKycProvider(apiClient: apiClient);
      final calls = <String>[];

      adapter.onPost(
        NetworkApi.savePersonalDetails,
        (server) {
          calls.add('personal');
          return server.reply(
            200,
            <String, dynamic>{
              'success': true,
              'message': 'personal saved',
            },
          );
        },
      );

      adapter.onPost(
        NetworkApi.saveAddressDetails,
        (server) {
          calls.add('address');
          return server.reply(
            200,
            <String, dynamic>{
              'success': true,
              'message': 'address saved',
            },
          );
        },
      );

      final personalInput = <String, dynamic>{
        'PRODUCT_CODE': 'P001',
        'BRANCH_CODE': 'BR001',
        'TITLE': 'MR',
        'FIRST_NAME': 'Aman',
        'MIDDLE_NAME': '',
        'LAST_NAME': 'Shah',
        'FATHER_NAME': 'Ramesh',
        'MOTHER_NAME': 'Sita',
        'MOTHER_MAIDEN_NAME': '',
        'MARITAL_STATUS': 'S',
        'DOB': '1990-01-15',
        'GENDER': 'M',
        'NATIONALITY_CODE': 'IN - INDIA',
        'MOBILE_NO': '9999999999',
        'EMAIL_ID': 'aman@example.com',
        'STD_CODE': '011',
        'LANDLINE_NO': '12345678',
        'EDUCATION': 'GRADUATE',
        'RESIDENTIAL_STATUS': 'RESIDENT',
        'OCCUPATION_TYPE': 'SALARIED',
        'SUB_OCCUPATION_TYPE': 'PRIVATE',
        'EMPLOYER_NAME': 'ICICI',
        'DESIGNATION': 'ENGINEER',
        'SOURCE_OF_INCOME': 'SALARY',
        'GROSS_INCOME': '1000000',
        'COMMUNICATION_SAME_AS_PERMANENT': 'Y',
        'DECLARATION_OPTION': 'D1',
        'SELF_DECLARED_COMMUNICATION_ADDRESS': 'N',
        'PERMANENT_ADDRESS_1': 'House 10',
        'PERMANENT_ADDRESS_2': 'Main Road',
        'PHYSICAL_LANDMARK': 'Near Park',
        'PERMANENT_CITY': 'Delhi',
        'PERMANENT_STATE': 'Delhi',
        'PHYSICAL_DISTRICT': 'Central Delhi',
        'PERMANENT_ZIP': '110001',
        'PERMANENT_COUNTRY': 'INDIA',
        'COMMUNICATION_ADDRESS_1': 'House 10',
        'COMMUNICATION_ADDRESS_2': 'Main Road',
        'COMMUNICATION_LANDMARK': 'Near Park',
        'COMMUNICATION_CITY': 'Delhi',
        'COMMUNICATION_STATE': 'Delhi',
        'COMMUNICATION_DISTRICT': 'Central Delhi',
        'COMMUNICATION_ZIP': '110001',
        'COMMUNICATION_COUNTRY': 'INDIA',
        'PAN_NO': 'ABCDE1234F',
        'IDENTIFICATION_PROOF_NUMBER': '123456789012',
      };

      final personalSaved = await provider.savePersonalDetails(
        applicationId: 'APP123',
        kycType: 'full_kyc',
        personalData: personalInput,
      );
      expect(personalSaved, isTrue);

      final addressSaved = await provider.saveAddressDetails(
        applicationId: 'APP123',
        kycType: 'full_kyc',
        addressData: provider.buildAddressKycData(personalInput),
      );
      expect(addressSaved, isTrue);
      expect(calls, <String>['personal', 'address']);
      expect(provider.errorMessage, isNull);
    },
  );
}
