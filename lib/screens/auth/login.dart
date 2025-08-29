import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:poultry_app/screens/auth/otpverification.dart';
import 'package:poultry_app/screens/auth/register.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/appbar.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import 'package:poultry_app/widgets/customtextfield.dart';
import 'package:poultry_app/widgets/ifnotbutton.dart';
import 'package:poultry_app/widgets/navigation.dart';
import 'package:poultry_app/widgets/socialauthbutton.dart';

class LogIn extends StatefulWidget {
  const LogIn({
    super.key,
  });

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final _phone = TextEditingController();
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  Validation() {
    if (formkey.currentState!.validate()) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomAppBar(),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: height(context) - 92,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    addVerticalSpace(height(context) * .035),
                    Text(
                      "Welcome back! Glad\nto see you, Again!",
                      style: bodyText30Bold(color: black),
                    ),
                    addVerticalSpace(height(context) * .05),
                    Form(
                      autovalidateMode: AutovalidateMode.always,
                      key: formkey,
                      child: CustomTextField(
                        maxLength: 10,
                        controller: _phone,
                        textType: TextInputType.number,
                        validator: MinLengthValidator(10,
                            errorText: "Enter a valid number"),
                        hintText: "Phone Number",
                      ),
                    ),
                    addVerticalSpace(height(context) * .03),
                    CustomButton(
                      height: 55,
                      width: width(context),
                      onClick: () {
                        // Validation();
                        if (Validation()) {
                          NextScreen(context, OTPVerification());
                        }
                      },
                      text: "Send OTP",
                    ),
                    addVerticalSpace(height(context) * .1),
                    Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "Or Login with",
                            style: bodyText14w600(color: darkGray),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    addVerticalSpace(15),
                    SocialAuthButton(),
                  ],
                ),
                IfNotButton(
                    onClick: () => NextScreen(context, Register()),
                    message: "Don't have an account?",
                    action: "Register Now")
              ],
            ),
          ),
        ),
      ),
    );
  }
}
