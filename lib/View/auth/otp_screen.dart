import 'package:ai_food/Constants/app_logger.dart';
import 'package:ai_food/Utils/resources/res/app_theme.dart';
import 'package:ai_food/Utils/utils.dart';
import 'package:ai_food/Utils/widgets/others/app_button.dart';
import 'package:ai_food/Utils/widgets/others/app_text.dart';
import 'package:ai_food/Utils/widgets/others/custom_card.dart';
import 'package:ai_food/config/app_urls.dart';
import 'package:ai_food/config/dio/app_dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:sizer/sizer.dart';

import 'set_password_screen.dart';

class OTPScreen extends StatefulWidget {
  final verificationId;
  final mobileNumber;
  final otp;
  final email;
  final type;
  const OTPScreen(
      {super.key,
      this.verificationId,
      this.mobileNumber,
      this.otp,
      this.email,
      this.type});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _smsCodeController = TextEditingController();
  bool _verificationInProgress = false;
  String? verificationIdCheck;
  late AppDio dio;
  AppLogger logger = AppLogger();
  var responseData;
  bool isLoading = false;

  Future<void> _signInWithPhoneNumber(String smsCode) async {
    setState(() {
      _verificationInProgress = true;
    });

    final AuthCredential credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: smsCode,
    );
    await FirebaseAuth.instance
        .signInWithCredential(credential)
        .then((userCredential) {
      setState(() {
        _verificationInProgress = false;
      });

      verfyOTP(code: smsCode);

      // _timer.cancel();
    }).catchError((error) {
      setState(() {
        _verificationInProgress = false;
      });

      print("exception_code ${error.code}");
      print("exception_message ${error.message}");

      if (error.code == 'session-expired') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('SMS code Expired. Resend verification code to try again.'),
        ));
      } else if (error.code == 'sms-code-timeout') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Request timed out. Please try again.'),
        ));
      } else if (error.code == 'invalid-verification-code') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Invalid SMS code. Resend and check user-provided code.'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${error.message}'),
        ));
      }
    });
  }

  Future<void> _resendPhoneNumber(String phoneNumber) async {
    setState(() {
      _verificationInProgress = true;
    });

    verificationCompleted(AuthCredential phoneAuthCredential) {
      setState(() {
        _verificationInProgress = false;
      });

      FirebaseAuth.instance
          .signInWithCredential(phoneAuthCredential)
          .then((userCredential) {})
          .catchError((error) {
        setState(() {
          _verificationInProgress = false;
        });
      });
    }

    verificationFailed(FirebaseAuthException authException) {
      setState(() {
        _verificationInProgress = false;
      });

      if (authException.code == 'missing-phone-number') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('The phone number is missing.'),
        ));
      } else if (authException.code == 'missing-client-identifier') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Invalid captcha. Try again.'),
        ));
      } else if (authException.code == 'too-many-requests') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'You have been blocked due to unusual activity. Try again later.'),
        ));
      } else if (authException.code == 'quota-exceeded') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('The SMS quota for the project has been exceeded.'),
        ));
      } else if (authException.code == 'user-disabled') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('The user account has been disabled by an administrator.'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${authException.message}'),
        ));
      }
    }

    codeSent(String verificationId, [int? forceResendingToken]) async {
      setState(() {
        verificationIdCheck = verificationId;
        _verificationInProgress = false;
        print(
            "Check_phone $phoneNumber and verification id $verificationIdCheck");
      });

      // _forceResendingToken = forceResendingToken;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Verification code sent to $phoneNumber'),
      ));
      // Navigator.of(context)
      //     .pushReplacement(MaterialPageRoute(builder: (_) =>
      //     ConfirmOtpPage(verificationId: verificationIdCheck!, mobileNumber: phoneNumber)));
    }

    codeAutoRetrievalTimeout(String verificationId) {
      setState(() {
        verificationIdCheck = verificationId;
        print(
            "Check_phone $phoneNumber and verification id $verificationIdCheck");
      });
    }

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 80),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } catch (error) {
      setState(() {
        _verificationInProgress = false;
      });
    }
  }

  @override
  void initState() {
    dio = AppDio(context);
    logger.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    print("otp${widget.email}");
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 10, top: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.appText("Forgot Password",
                  fontSize: 32,
                  textColor: AppTheme.appColor,
                  fontWeight: FontWeight.w600),
              AppText.appText(
                "Enter OTP to continue",
                fontSize: 16,
                textColor: AppTheme.appColor,
              ),
              const SizedBox(
                height: 60,
              ),
              Customcard(
                  childWidget: Column(
                children: [
                  const SizedBox(
                    height: 80,
                  ),
                  OtpTextField(
                    handleControllers: _handleControllers,
                    textStyle:
                        TextStyle(fontSize: 18, color: AppTheme.appColor),
                    numberOfFields: 6,
                    margin: const EdgeInsets.only(left: 15, top: 15),
                    showFieldAsBox: false,
                    fieldWidth: 35,
                    hasCustomInputDecoration: true,
                    cursorColor: AppTheme.appColor,
                    decoration: InputDecoration(
                      counterText: "",
                      isDense: true,
                      contentPadding: const EdgeInsets.all(10),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.appColor)),
                      disabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide.none),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                        color: AppTheme.appColor,
                      )),
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.appColor)),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 40),
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                            onTap: () {
                              _resendPhoneNumber(widget.mobileNumber);
                            },
                            child: AppText.appText("Resend OTP",
                                textColor: AppTheme.appColor,
                                underLine: true))),
                  ),
                  const SizedBox(
                    height: 160,
                  ),
                  // _verificationInProgress ||
                  isLoading == true
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.appColor,
                            strokeWidth: 4,
                          ),
                        )
                      : AppButton.appButton("Continue", onTap: () {
                          if (widget.type == 0) {
                            if (!_verificationInProgress) {
                              String smsCode = _smsCodeController.text.trim();
                              if (smsCode.isNotEmpty) {
                                print("Check_sms $smsCode");
                                _smsCodeController.clear();
                                _signInWithPhoneNumber(smsCode);
                              }
                            }
                          } else if (widget.type == 1) {
                            verfyOTP(code: widget.otp);
                          }
                        },
                          width: 43.w,
                          height: 5.5.h,
                          border: false,
                          backgroundColor: AppTheme.appColor,
                          textColor: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600)
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _handleControllers(List<TextEditingController?> controllers) {
    final code = controllers.map((c) => c?.text).join('');
    _smsCodeController.text = code;
  }

  void verfyOTP({code}) async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> params = {
      "email": widget.email,
      "OTP": widget.otp,
    };

    final response = await dio.post(path: AppUrls.verifyUrl, data: params);

    if (response.statusCode == 200) {
      print("response_data_is  ${response.data}");
      setState(() {
        isLoading = false;
      });
      pushReplacement(
          context,
          SetPasswordScreen(
            email: widget.email,
            otp: code,
          ));
    } else {
      if (response.statusCode == 402) {
        setState(() {
          isLoading = false;
        });
        showSnackBar(context, "${response.statusMessage}");
      } else {
        setState(() {
          isLoading = false;
        });
        print('API request failed with status code: ${response.statusCode}');
        showSnackBar(context, "${response.statusMessage}");
      }
    }
  }
}
