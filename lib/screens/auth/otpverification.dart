import 'dart:async';

import 'package:flutter/material.dart';

import 'package:pinput/pinput.dart';
import 'package:poultry_app/screens/profile/createprofile.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/appbar.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import 'package:poultry_app/widgets/dialogbox.dart';
import 'package:poultry_app/widgets/ifnotbutton.dart';
import 'package:poultry_app/widgets/navigation.dart';

class OTPVerification extends StatefulWidget {
  const OTPVerification({super.key});

  @override
  State<OTPVerification> createState() => _OTPVerificationState();
}

class _OTPVerificationState extends State<OTPVerification> {
  final TextEditingController _pinPutController = TextEditingController();
  final GlobalKey<FormState> key = GlobalKey<FormState>();
  String? otp;

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: width(context) * .2,
      height: width(context) * .185,
      textStyle: bodyText24w600(color: black),
      decoration: BoxDecoration(
        border: Border.all(color: yellow),
        borderRadius: BorderRadius.circular(8.5),
      ),
    );
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomAppBar(),
      ),
      body: Container(
        height: height(context) - 92,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    addVerticalSpace(height(context) * .035),
                    Text(
                      "OTP Verification",
                      style: bodyText30Bold(color: black),
                    ),
                    addVerticalSpace(height(context) * .03),
                    Text(
                      "Enter the verification code we just sent on your email address.",
                      style: bodyText16normal(color: darkGray),
                    ),
                    addVerticalSpace(height(context) * 0.06),
                    Form(
                      child: Pinput(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        key: key,
                        length: 4,
                        defaultPinTheme: defaultPinTheme,
                        controller: _pinPutController,
                        pinAnimationType: PinAnimationType.fade,
                        onChanged: (value) {
                          setState(() {
                            otp = value;
                          });
                        },
                      ),
                    ),
                    addVerticalSpace(height(context) * 0.03),
                    CustomButton(
                        height: 55,
                        width: width(context),
                        text: "Verify",
                        onClick: () {
                          showDialog(
                              context: context,
                              builder: (context) => ShowDialogBox(
                                  message: "Registered!",
                                  subMessage: "You registered successfully."));
                          Timer(Duration(seconds: 5),
                              () => NextScreen(context, CreateProfilePage()));
                        })
                  ],
                ),
              ),
              IfNotButton(
                  onClick: () {},
                  message: "Didn't received code?",
                  action: "Resend")
            ]),
      ),
    );
  }
}
