import 'package:flutter/material.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import 'package:poultry_app/widgets/customdropdown.dart';
import 'package:poultry_app/widgets/customtextfield.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/navigation.dart';

class AddSubUserPage extends StatefulWidget {
  const AddSubUserPage({super.key});

  @override
  State<AddSubUserPage> createState() => _AddSubUserPageState();
}

class _AddSubUserPageState extends State<AddSubUserPage> {
  List list = ['View Only', 'Edit Only'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: GeneralAppBar(
          
          title: "Batch",
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: height(context) * 0.9,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(children: [
                    addVerticalSpace(20),
                    Text(
                      "Add Sub User",
                      style: bodyText22w600(color: black),
                    ),
                    addVerticalSpace(40),
                    Image.asset("assets/images/adduser.png"),
                    addVerticalSpace(20),
                    CustomTextField(hintText: "Name"),
                    CustomTextField(hintText: "Search by Mobile Number"),
                    CustomDropdown(list: list, height: 58, hint: "View only")
                  ]),
                ),
              ]),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                child: CustomButton(
                    text: "Add",
                    onClick: () {},
                    width: width(context),
                    height: 55),
              )
            ],
          ),
        ),
      ),
    );
  }
}
