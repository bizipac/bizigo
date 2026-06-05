import 'dart:developer';
import 'package:flutter/material.dart';
import '../../core/models/home_screen_model.dart';
import '../../core/network/api_client.dart';
import '../../core/network/network_api.dart';

class PreferenceProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  HomeScreenCardTypesModel? _homeScreenCardTypesModel;

  HomeScreenCardTypesModel? get homeScreenCardTypesModel =>
      _homeScreenCardTypesModel;

  Map<String, dynamic>? _dailySummary;

  Map<String, dynamic>? get dailySummary => _dailySummary;

  String? selectedOption;
  String selectedPreference = '';

  bool _isPersonalized = false;

  bool get isPersonalized => _isPersonalized;

  void setPersonalized(bool value) {
    _isPersonalized = value;
    notifyListeners();
  }

  void selectOption(String option) {
    selectedOption = option;
    notifyListeners();
  }

  void selectPreference(String pref) {
    selectedPreference = pref;
    notifyListeners();
  }

  Future<HomeScreenCardTypesModel> fetchHomeScreenCardTypes() async {
    _isLoading = true;
    try {
      final response = await _apiClient.get(NetworkApi.homeScreen);
      // final decoded = json.decode(response);
      final homeScreenTypeData = HomeScreenCardTypesModel.fromJson(response);
      _homeScreenCardTypesModel = homeScreenTypeData;

      return homeScreenTypeData;
    } catch (e, stackTrace) {
      log(e.toString(), stackTrace: stackTrace);
      log("Error: $e");
      return HomeScreenCardTypesModel(
        message: "Something went wrong",
        success: false,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDailySummary() async {
    try {
      final response = await _apiClient.get(NetworkApi.kycSummaryToday);
      if (response is Map<String, dynamic> && response['success'] == true) {
        _dailySummary = response['today'] as Map<String, dynamic>?;
        notifyListeners();
      }
    } catch (e, stackTrace) {
      log(e.toString(), stackTrace: stackTrace);
    }
  }
}
