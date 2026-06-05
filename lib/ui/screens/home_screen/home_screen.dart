import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:icici_bank/core/constants/app_assets.dart';
import 'package:icici_bank/core/constants/app_strings.dart';
import 'package:icici_bank/core/util/app_routes.dart';
import 'package:icici_bank/providers/aadhaar_verification_provider/aadhaar_kyc_provider.dart';
import 'package:icici_bank/providers/home_preference_provider/preference_provider.dart';
import 'package:icici_bank/ui/widgets/custom_option_card.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../core/util/app_preference.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _captureLocation() async {
    final applicationId = AppPreference.getApplicationID();
    if (applicationId == null || applicationId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No active KYC application found")),
      );
      return;
    }

    final permissionStatus = await Permission.locationWhenInUse.request();
    if (!permissionStatus.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location not captured")),
      );
      return;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location services are disabled")),
      );
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final success = await context.read<AadhaarKycProvider>().captureLocation(
            applicationID: applicationId,
            latitude: position.latitude,
            longitude: position.longitude,
          );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location captured successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Location capture failed"),
            action: SnackBarAction(
              label: "Retry",
              onPressed: _captureLocation,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Location capture error: $e"),
          action: SnackBarAction(
            label: "Retry",
            onPressed: _captureLocation,
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<PreferenceProvider>();
      await provider.fetchHomeScreenCardTypes();
      await provider.fetchDailySummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PreferenceProvider>(context, listen: false);

    // String agentInfo = AppPreference.getAgentInfo();
    Map<String, dynamic>? agentInfo = AppPreference.getAgentInfo();

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F8),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final screenWidth = constraints.maxWidth;

            double w(double val) => screenWidth * (val / 375);
            double h(double val) => screenHeight * (val / 812);

            // ✅ Smart scroll: only scrolls if content exceeds available height
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: screenHeight),
                child: Consumer<PreferenceProvider>(
                  builder: (context, homeScreenProvider, _) {
                    final homeScreenTypesModel =
                        homeScreenProvider.homeScreenCardTypesModel;

                    if (homeScreenTypesModel == null ||
                        homeScreenTypesModel.data == null ||
                        homeScreenTypesModel.data!.kycTypes.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final kycTypes = homeScreenTypesModel.data!.kycTypes;

                    final personalizedKyc = kycTypes.firstWhere(
                      (e) => e.type == 'full_kyc',
                    );

                    final nonPersonalizedKyc = kycTypes.firstWhere(
                      (e) => e.type == 'min_kyc',
                    );

                    return homeScreenProvider.isLoading
                        ? Center(child: CircularProgressIndicator())
                        : Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: w(24),
                              vertical: h(24),
                            ),
                            child: Column(
                              children: [
                                // Logo
                                Center(
                                  child: Image.asset(
                                    AppAssets.iciciLogo,
                                    width: w(100),
                                  ),
                                ),
                                SizedBox(height: h(20)),

                                // Card image
                                Center(
                                  child: Image.asset(
                                    'assets/kyc_card3.png',
                                    height: h(230),
                                    width: w(180),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(height: h(20)),

                                // Hello text
                                Text(
                                  'Hello ${agentInfo!['agent_name']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    fontFamily: AppStrings.poppins,
                                    color: const Color(0xFF000000),
                                  ),
                                ),
                                SizedBox(height: 6),

                                // Subtitle
                                const Text(
                                  'Please select your preferences',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontFamily: AppStrings.poppins,
                                    color: Color(0xFF656565),
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(height: h(24)),

                                if (homeScreenProvider.dailySummary != null)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: const Color(0xFFE1E1E8),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Today KYC',
                                          style: TextStyle(
                                            fontFamily: AppStrings.poppins,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          'Created: ${homeScreenProvider.dailySummary!['total'] ?? 0}  Completed: ${homeScreenProvider.dailySummary!['completed'] ?? 0}',
                                          style: const TextStyle(
                                            fontFamily: AppStrings.poppins,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (homeScreenProvider.dailySummary != null)
                                  SizedBox(height: h(18)),

                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: OutlinedButton.icon(
                                    onPressed: _captureLocation,
                                    icon: const Icon(Icons.my_location_outlined),
                                    label: const Text("Capture Location"),
                                  ),
                                ),
                                SizedBox(height: h(18)),

                                // Cards
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Personalized Card
                                    Flexible(
                                      flex: 1,
                                      child: CustomOptionCard(
                                        title: personalizedKyc.displayName,
                                        imageAsset: 'assets/kyc_card4.png',
                                        onTap: () {
                                          provider.setPersonalized(true);
                                          log(
                                            'Personalized Card selected: ${personalizedKyc.type}',
                                          );
                                          provider.selectOption(
                                            'Personalized Card',
                                          );
                                          AppPreference.setKycType(
                                            'Personalized',
                                          );
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.aadhaarKycVerify,
                                            arguments: {
                                              'kycType': personalizedKyc.type,
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(width: w(16)),

                                    // Non-Personalized Card
                                    Flexible(
                                      flex: 1,
                                      child: CustomOptionCard(
                                        title: nonPersonalizedKyc.displayName,
                                        imageAsset: 'assets/kyc_card5.png',
                                        onTap: () {
                                          provider.setPersonalized(false);
                                          log(
                                            'NonPersonalized Card selected: ${nonPersonalizedKyc.type}',
                                          );
                                          AppPreference.setKycType(
                                            'Non-personalized',
                                          );
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.aadhaarKycVerify,
                                            arguments: {
                                              'kycType':
                                                  nonPersonalizedKyc.type,
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: h(24)),

                                // KYC-Conversion Card
                                // CustomOptionCard(
                                //   title: 'KYC Conversion',
                                //   imageAsset: 'assets/kyc_card4.png',
                                //   onTap: () => provider.selectOption('KYC Conversion'),
                                // ),
                              ],
                            ),
                          );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
