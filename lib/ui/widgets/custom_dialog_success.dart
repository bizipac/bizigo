import 'dart:async';
import 'package:flutter/material.dart';
import 'package:icici_bank/ui/screens/biometric_kyc_screen/biometric_kyc_screen.dart';
import 'package:provider/provider.dart';

import '../../providers/aadhaar_verification_provider/aadhaar_kyc_provider.dart';
import '../../providers/biometric_kyc_provider/dialog_box_provider.dart';

class CustomDialogSuccess extends StatefulWidget {
  const CustomDialogSuccess({super.key});

  @override
  State<CustomDialogSuccess> createState() => _CustomDialogSuccessState();
}

class _CustomDialogSuccessState extends State<CustomDialogSuccess> {

  @override
  void initState() {
    super.initState();

    /// ⏳ Auto redirect after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        final dialogProvider = context.read<DialogBoxProvider>();

        dialogProvider.closeDialog();

        Navigator.pop(context); // close dialog

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const BiometricKYCScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: SizedBox(
        height: 350,
        width: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              /// ✅ Just UI now (no click needed)
              Image.asset(
                'assets/success.png',
                height: 200,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 10),

              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Biometric Verification Successful ✅\nRedirecting to next step...",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:icici_bank/ui/screens/biometric_kyc_screen/biometric_kyc_screen.dart';
// import 'package:provider/provider.dart';
//
// import '../../providers/aadhaar_verification_provider/aadhaar_kyc_provider.dart';
// import '../../providers/biometric_kyc_provider/dialog_box_provider.dart';
//
// class CustomDialogSuccess extends StatelessWidget {
//   const CustomDialogSuccess({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final dialogProvider = Provider.of<DialogBoxProvider>(context);
//     final aadhaarProvider = context.read<AadhaarKycProvider>();
//
//     return Dialog(
//       backgroundColor: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
//       child: SizedBox(
//         height: 350,
//         width: 300,
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   dialogProvider.closeDialog();
//                   Navigator.pop(context);
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => const BiometricKYCScreen(),
//                     ),
//                   );
//                 },
//                 child: Image.asset(
//                   'assets/success.png',
//                   height: 200,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   "Congratulations \n Please click above to continue.",
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontFamily: 'Poppins',
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
