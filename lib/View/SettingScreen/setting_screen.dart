import 'dart:io';

import 'package:ai_food/Utils/resources/res/app_theme.dart';
import 'package:ai_food/Utils/utils.dart';
import 'package:ai_food/Utils/widgets/others/app_button.dart';
import 'package:ai_food/Utils/widgets/others/app_text.dart';
import 'package:ai_food/Utils/widgets/others/custom_app_bar.dart';
import 'package:ai_food/View/SettingScreen/privacypolicy_screen.dart';
import 'package:ai_food/View/SettingScreen/profile_screen.dart';
import 'package:ai_food/View/SettingScreen/termsofuse_screen.dart';
import 'package:ai_food/View/auth/GoogleSignIn/authentication.dart';
import 'package:ai_food/config/keys/pref_keys.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final _formKeyName = GlobalKey<FormState>();
  final _formKeyEmail = GlobalKey<FormState>();
  final _formKeyMessage = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Settings",
          style: TextStyle(
              color: AppTheme.appColor,
              fontWeight: FontWeight.w600,
              fontSize: 24),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 5.w, right: 5.w),
        child: Column(children: [
          const SizedBox(height: 30),
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const ProfileScreen(),
            )),
            child: Row(
              children: [
                Icon(Icons.account_circle_outlined,
                    size: 20, color: AppTheme.appColor),
                SizedBox(width: 2.w),
                AppText.appText("Profile",
                    fontSize: 20,
                    textColor: AppTheme.appColor,
                    fontWeight: FontWeight.w600),
              ],
            ),
          ),
          Divider(
            height: 12,
            color: AppTheme.appColor,
            thickness: 1.5,
          ),
          SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const PrivacyPolicyScreen(),
            )),
            child: Row(
              children: [
                Icon(Icons.privacy_tip_outlined,
                    size: 20, color: AppTheme.appColor),
                SizedBox(width: 2.w),
                AppText.appText("Privacy Policy",
                    fontSize: 20,
                    textColor: AppTheme.appColor,
                    fontWeight: FontWeight.w600),
              ],
            ),
          ),
          Divider(
            height: 12,
            color: AppTheme.appColor,
            thickness: 1.5,
          ),
          SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const TermsScreen(),
            )),
            child: Row(
              children: [
                const Image(
                    image: AssetImage("assets/images/Vector.png"),
                    width: 18,
                    height: 18),
                SizedBox(width: 2.w),
                AppText.appText("Terms of Use",
                    fontSize: 20,
                    textColor: AppTheme.appColor,
                    fontWeight: FontWeight.w600),
              ],
            ),
          ),
          Divider(
            height: 12,
            color: AppTheme.appColor,
            thickness: 1.5,
          ),
          SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {
              showCustomAlert(context);
            },
            child: Row(
              children: [
                const Image(
                    image: AssetImage("assets/images/headset.png"),
                    width: 18,
                    height: 18),
                SizedBox(width: 2.w),
                AppText.appText("Contact Us",
                    fontSize: 20,
                    textColor: AppTheme.appColor,
                    fontWeight: FontWeight.w600),
              ],
            ),
          ),
          Divider(
            height: 12,
            color: AppTheme.appColor,
            thickness: 1.5,
          ),
          SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {
              // await Authentication.signOut(context: context);
              showLogOutALert(context);
            },
            child: Row(
              children: [
                Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/images/logout.png"))),
                ),
                SizedBox(width: 2.w),
                AppText.appText("Log out",
                    fontSize: 20,
                    textColor: AppTheme.appColor,
                    fontWeight: FontWeight.w600),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  static Future<void> signOut({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        Authentication.customSnackBar(
          content: 'Error signing out. Try again.',
        ),
      );
    }
  }

  showLogOutALert(BuildContext context, {controller}) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            child: SingleChildScrollView(
              child: Container(
                // width: 100,
                // height: 500,
                decoration: BoxDecoration(
                  color: const Color(0xFFB38ADE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Are you sure, you want\nto',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.33,
                            ),
                          ),
                          TextSpan(
                            text: ' Log out?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.33,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Divider(
                        thickness: 2,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await logout(context);
                          },
                          child: const Text(
                            'Yes',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.33,
                            ),
                          ),
                        ),
                        Container(
                          height: 30,
                          width: 2,
                          color: AppTheme.whiteColor,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'No',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.33,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ));
      },
    );
  }

  showCustomAlert(BuildContext context, {controller}) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          child: SingleChildScrollView(
            child: Container(
              // width: 100,
              // height: 500,
              decoration: BoxDecoration(
                color: const Color(0xFFB38ADE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.whiteColor,
                      // color: Color(0xFFB38ADE),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          topRight: Radius.circular(8.0)),
                    ),
                    height: 56,
                    width: MediaQuery.sizeOf(context).width,
                    child: Center(
                      child: Text(
                        "Contact Us",
                        style: TextStyle(
                          color: AppTheme.appColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Container(
                    // height: 200,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Form(
                            key: _formKeyName,
                            autovalidateMode:
                            AutovalidateMode.onUserInteraction,
                            child: TextFormField(
                              controller: nameController,
                              validator: ((value) {
                                if (value == null || value.isEmpty) {
                                  return "Please Enter Name";
                                }
                              }),
                              style: TextStyle(color: AppTheme.whiteColor),
                              cursorColor: AppTheme.whiteColor,
                              decoration: InputDecoration(
                                  contentPadding:
                                  EdgeInsets.only(top: 20, left: 10),
                                  hintStyle: TextStyle(
                                      color: AppTheme.whiteColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                                  hintText: "jessica hanson",
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppTheme.whiteColor)),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppTheme.whiteColor))),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Form(
                          key: _formKeyEmail,
                          child: TextFormField(
                            controller: emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              final emailRegex = RegExp(
                                  r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
                              if (!emailRegex.hasMatch(value)) {
                                return 'Invalid Email';
                              }
                              return null;
                            },
                            style: TextStyle(color: AppTheme.whiteColor),
                            cursorColor: AppTheme.whiteColor,
                            decoration: InputDecoration(
                                contentPadding:
                                EdgeInsets.only(top: 20, left: 10),
                                hintStyle: TextStyle(
                                    color: AppTheme.whiteColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400),
                                hintText: "jessicahanson@gmail.com",
                                focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                    BorderSide(color: AppTheme.whiteColor)),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: AppTheme.whiteColor))),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Form(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      key: _formKeyMessage,
                      child: TextFormField(
                        controller: messageController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please Enter Message";
                          } else {
                            return null;
                          }
                        },
                        maxLines: 4,
                        style: TextStyle(color: AppTheme.whiteColor),
                        cursorColor: AppTheme.whiteColor,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(top: 20, left: 10),
                            hintStyle: TextStyle(
                                color: AppTheme.whiteColor.withOpacity(0.5)),
                            hintText: "Your message",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: AppTheme.whiteColor,
                                )),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: AppTheme.whiteColor,
                                )),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                BorderSide(color: AppTheme.whiteColor))),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Center(
                    child: AppButton.appButton("Send message ",
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        textColor: AppTheme.appColor,
                        height: 50,
                        width: 180,
                        backgroundColor: AppTheme.whiteColor, onTap: () {
                          if (_formKeyName.currentState!.validate() &&
                              _formKeyEmail.currentState!.validate() &&
                              _formKeyMessage.currentState!.validate()) {
                            Navigator.pop(context);
                          }
                          // push(context, ForgotPasswordScreen());
                          // push(context, const ForgotPasswordPage());
                        }),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> logout(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(PrefKey.authorization);
    await Authentication.signOut(context: context);
  }
}