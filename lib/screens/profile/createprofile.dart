import 'dart:async';

import 'package:flutter/material.dart';
import 'package:poultry_app/screens/bottomnav.dart';
import 'package:poultry_app/screens/mainscreens/homepage.dart';
import 'package:poultry_app/screens/profile/editprofile.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import 'package:poultry_app/widgets/customtextfield.dart';
import 'package:poultry_app/widgets/dialogbox.dart';
import 'package:poultry_app/widgets/navigation.dart';
import 'package:poultry_app/widgets/userdatawidget.dart';

class CreateProfilePage extends StatefulWidget {
  const CreateProfilePage({super.key});

  @override
  State<CreateProfilePage> createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: transparent,
        elevation: 0,
        foregroundColor: black,
        title: Text(
          "Create Profile",
          style: bodyText18w600(color: black),
        ),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              UserDataWidget(),
              addVerticalSpace(10),
              CustomButton(
                  height: 55,
                  width: width(context),
                  text: "Register",
                  onClick: () {
                    showDialog(
                        context: context,
                        builder: (context) => ShowDialogBox(
                            message: "Profile Created!",
                            subMessage:
                                "Your profile has been created\nsuccessfully."));
                    Timer(Duration(seconds: 4),
                        () => NextScreen(context, BottomNavigation()));
                  })
            ],
          ),
        ),
      ),
    );
  }
}
