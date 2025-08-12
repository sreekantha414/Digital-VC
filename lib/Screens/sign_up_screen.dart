import 'package:flutter/material.dart';
import 'package:visiting_card_app/Theme/theme.dart';
import 'package:visiting_card_app/utils/alert_utils.dart';
import 'package:visiting_card_app/utils/app_helper.dart';

import 'otp_screen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool showEmailForm = false;
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _handleGoogleSignIn() async {
    // AppHelper.handleGoogleSignIn(context);
  }

  void _continueWithEmail() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => OtpScreen(email: _emailController.text.trim())));
    } else {
      AlertUtils.showSnackbarWarning(context, "Please enter a valid email.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 80),
              Text("Create your account", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.black)),
              SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: Size(double.infinity, 50),
                ),
                icon: Icon(Icons.login),
                label: Text("Continue with Google", style: TextStyle(color: Colors.white)),
                onPressed: _handleGoogleSignIn,
              ),
              SizedBox(height: 16),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.lightPurple),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text("Continue with Email", style: TextStyle(color: AppColors.lightPurple)),
                onPressed: () => setState(() => showEmailForm = true),
              ),
              if (showEmailForm) ...[
                SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || !value.contains('@')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: Size(double.infinity, 50),
                  ),
                  onPressed: _continueWithEmail,
                  child: Text("Send OTP", style: TextStyle(color: Colors.white)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
