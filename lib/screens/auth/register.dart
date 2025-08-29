import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:poultry_app/screens/auth/login.dart';
import 'package:poultry_app/screens/auth/otpverification.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/appbar.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import 'package:poultry_app/widgets/customtextfield.dart';
import 'package:poultry_app/widgets/ifnotbutton.dart';
import 'package:poultry_app/widgets/navigation.dart';
import 'package:poultry_app/widgets/socialauthbutton.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  GlobalKey<FormState> formKey = GlobalKey();
  Validation() {
    if (formKey.currentState!.validate()) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: CustomAppBar(),
        preferredSize: Size.fromHeight(60),
      ),
      body: SingleChildScrollView(
        child: Container(
            height: height(context) - 92,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      addVerticalSpace(height(context) * .035),
                      Text(
                        "Hello! Register to get\nstarted",
                        style: bodyText30Bold(color: black),
                      ),
                      addVerticalSpace(height(context) * .075),
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            CustomTextField(
                              hintText: "Username",
                              validator: RequiredValidator(errorText: ""),
                            ),
                            CustomTextField(
                              hintText: "Phone Number",
                              validator: RequiredValidator(errorText: ""),
                            ),
                          ],
                        ),
                      ),
                      addVerticalSpace(height(context) * .002),
                      CustomButton(
                        width: width(context),
                        height: 55,
                        text: "Send OTP",
                        onClick: () {
                          Validation();
                          NextScreen(context, OTPVerification());
                        },
                      ),
                      addVerticalSpace(height(context) * .05),
                      Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "Or Register with",
                              style: bodyText14w600(color: darkGray),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      addVerticalSpace(15),
                      SocialAuthButton()
                    ],
                  ),
                ),
                IfNotButton(
                    onClick: () => NextScreen(context, LogIn()),
                    action: "Login Now",
                    message: "Already have an account?")
              ],
            )),
      ),
    );
  }
}
