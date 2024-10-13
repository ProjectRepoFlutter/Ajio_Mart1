import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'verification_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? validateMobileNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your mobile number';
    } else if (value.length != 10) {
      return 'Mobile number must be 10 digits';
    }
    return null;
  }
  String formatPhoneNumber(String mobileNumber) {
  // Assuming the user enters a 10-digit number
  if (mobileNumber.length == 10) {
    return '+91$mobileNumber'; // Format as E.164 for India
  } else {
    throw Exception('Invalid mobile number format');
  }
}
  Future<void> login(String mobileNumber) async {
     final formattedNumber = formatPhoneNumber(mobileNumber);
    final response = await http.post(
      Uri.parse('https://your-backend-url.com/api/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'mobile': formattedNumber,
      }),
    );

    if (response.statusCode == 200) {
      // Navigate to the VerificationScreen and pass the mobile number
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationScreen(phoneNumber: formattedNumber),
        ),
      );
    } else {
      // Handle error (show an alert or message)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log in or Sign up'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _mobileController,
                decoration: InputDecoration(
                  prefixText: '+91 ',
                  hintText: 'Enter Mobile Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: validateMobileNumber,
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    login(_mobileController.text.trim());
                  }
                },
                child: Text('Continue'),
              ),
              Text('By continuing, you agree to our terms of service and privacy policy.'),
            ],
          ),
        ),
      ),
    );
  }
}
