import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../Theme/theme.dart';
import '../utils/alert_utils.dart';
import '../utils/stream_builder.dart';
import 'create_card_screen.dart';
import 'dashboard/dashboard_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  OtpScreen({required this.email});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final FocusNode pinFocusNode = FocusNode();
  final TextEditingController pinController = TextEditingController();

  void _verifyOtp() {
    final enteredOtp = pinController.text.trim();
    if (enteredOtp.length != 4 || int.tryParse(enteredOtp) == null) {
      AlertUtils.showSnackbarWarning(context, 'Please enter a valid 6-digit OTP.');
      return;
    }

    // TODO: Replace this with real OTP validation logic
    if (enteredOtp == "1234") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CreateCardScreen(isUser: true)));

      AlertUtils.showSnackbarSuccess(context, "OTP Verified!");
      // Navigate to dashboard or next screen
    } else {
      AlertUtils.showSnackbarWarning(context, 'Invalid OTP');
    }
  }

  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.darkPurple),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: Text("Enter OTP"), backgroundColor: AppColors.lightPurple, foregroundColor: Colors.white, elevation: 0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Enter the 4-digit code sent to your email",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
              Pinput(
                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                focusNode: pinFocusNode,
                controller: pinController,
                length: 4,
                defaultPinTheme: defaultPinTheme,
                onCompleted: (pin) async {
                  if (kIsWeb) {
                    await Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => DashboardScreen()), (route) => false);
                    StreamUtil.dashboardBottomSubject.add(0);
                  } else {
                    _verifyOtp();
                  }
                },
                onChanged: (value) {},
                preFilledWidget: Text('•', style: TextStyle(fontSize: 32, color: AppColors.darkPurple, fontWeight: FontWeight.w600)),
                submittedPinTheme: defaultPinTheme.copyDecorationWith(
                  color: AppColors.lightPurple,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.darkPurple),
                ),
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.darkPurple),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (kIsWeb) {
                    await Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => DashboardScreen()), (route) => false);
                    StreamUtil.dashboardBottomSubject.add(0);
                  } else {
                    _verifyOtp();
                  }
                },
                child: const Text("Verify", style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
//
// import '../Theme/theme.dart';
// import '../utils/alert_utils.dart';
// import '../utils/stream_builder.dart';
// import 'dashboard/dashboard_screen.dart';
//
// class OtpScreen extends StatefulWidget {
//   final String email;
//   OtpScreen({required this.email});
//
//   @override
//   _OtpScreenState createState() => _OtpScreenState();
// }
//
// class _OtpScreenState extends State<OtpScreen> {
//   final _otpController = TextEditingController();
//
//   void _verifyOtp() {
//     final enteredOtp = _otpController.text.trim();
//     if (enteredOtp.length != 6 || int.tryParse(enteredOtp) == null) {
//       AlertUtils.showSnackbarWarning(context, 'Please enter a valid 6-digit OTP.');
//       return;
//     }
//
//     // TODO: Replace this with real OTP validation logic
//     if (enteredOtp == "123456") {
//       Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardScreen()));
//       StreamUtil.dashboardBottomSubject.add(0);
//       AlertUtils.showSnackbarSuccess(context, "OTP Verified!");
//       // Navigate to dashboard or next screen
//     } else {
//       AlertUtils.showSnackbarWarning(context, 'Invalid OTP');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.cream,
//       appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: IconThemeData(color: AppColors.lightPurple)),
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             SizedBox(height: 60),
//             Text("Enter OTP", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.black)),
//             SizedBox(height: 8),
//             Text("An OTP has been sent to ${widget.email}", style: TextStyle(color: AppColors.black)),
//             SizedBox(height: 32),
//             TextField(
//               controller: _otpController,
//               keyboardType: TextInputType.number,
//               maxLength: 6,
//               decoration: InputDecoration(labelText: "6-digit OTP", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _verifyOtp,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.lightPurple,
//                 minimumSize: Size(double.infinity, 50),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               ),
//               child: Text("Verify OTP", style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
