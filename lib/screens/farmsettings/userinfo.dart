import 'package:flutter/material.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/userdatawidget.dart';

class UserInformationPage extends StatelessWidget {
  const UserInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: GeneralAppBar(
          
          title: "User Information",
        ),
        preferredSize: Size.fromHeight(50),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              UserDataWidget(),
              CustomButton(text: "Save", onClick: () {})
            ],
          ),
        ),
      ),
    );
  }
}
