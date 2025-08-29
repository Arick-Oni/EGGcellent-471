import 'package:flutter/material.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import 'package:poultry_app/widgets/customtextfield.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/navigation.dart';

class AddMedicinePage extends StatefulWidget {
  const AddMedicinePage({super.key});

  @override
  State<AddMedicinePage> createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  final date = TextEditingController();
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
          height: height(context) - 135,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(children: [
                    Text(
                      "Add Medicine",
                      style: bodyText22w600(color: black),
                    ),
                    addVerticalSpace(20),
                    CustomTextField(
                      hintText: "Date",
                      suffix: true,
                      controller: date,
                    ),
                    CustomTextField(hintText: "Medicine"),
                    CustomTextField(hintText: "Description")
                  ]),
                ),
              ]),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                child: CustomButton(
                    text: "Save",
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
