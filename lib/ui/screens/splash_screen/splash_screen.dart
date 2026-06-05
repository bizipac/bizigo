import 'package:flutter/material.dart';
import 'package:icici_bank/core/constants/app_assets.dart';
import 'package:icici_bank/core/constants/app_strings.dart';
import 'package:icici_bank/providers/aadhaar_verification_provider/aadhaar_kyc_provider.dart';
import 'package:provider/provider.dart';

import '../../../core/util/app_preference.dart';
import '../../../core/util/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _ringSize;
  late Animation<double> _textOpacity;

  final Color _blueColor = const Color(0xFF003399);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _logoScale = Tween<double>(begin: 0.8, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _ringSize = Tween<double>(begin: 0.0, end: 180.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Wait 1 second before navigating to allow text to be visible
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _handleStartupNavigation();
          }
        });
      }
    });

    _controller.forward();
  }

  Future<void> _handleStartupNavigation() async {
    final isLoggedIn = AppPreference.getLoginStatus();
    final applicationId = AppPreference.getApplicationID();

    if (!isLoggedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    if (applicationId == null || applicationId.isEmpty) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
      return;
    }

    final continueKyc = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Continue KYC process?"),
          content: const Text("Do you want to continue the KYC process?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    final provider = context.read<AadhaarKycProvider>();
    if (continueKyc == true) {
      await provider.fetchApplicationStatus(applicationID: applicationId);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.biometricKycVerify);
    } else {
      await provider.cancelApplication(applicationID: applicationId);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Stack for logo and expanding circle
            SizedBox(
              height: 200,
              width: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Container(
                        width: _ringSize.value,
                        height: _ringSize.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _blueColor.withValues(alpha: 0.4),
                            width: 3,
                          ),
                        ),
                      );
                    },
                  ),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: child,
                        ),
                      );
                    },
                    child: Image.asset(
                      AppAssets.bizigoLogo,
                      width: 140,
                      height: 140,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // App name
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(opacity: _textOpacity.value, child: child);
              },
              child: Text(
                AppStrings.appName,
                style: TextStyle(
                  fontSize: 26,
                  fontFamily: AppStrings.elMessiri,
                  fontWeight: FontWeight.w600,
                  color: _blueColor,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
