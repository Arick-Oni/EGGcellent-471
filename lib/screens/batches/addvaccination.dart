import 'package:flutter/material.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import 'package:poultry_app/widgets/customdropdown.dart';
import 'package:poultry_app/widgets/customtextfield.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/navigation.dart';

class AddVaccinationPage extends StatefulWidget {
  const AddVaccinationPage({super.key});

  @override
  State<AddVaccinationPage> createState() => _AddVaccinationPageState();
}

class _AddVaccinationPageState extends State<AddVaccinationPage> {
  final date = TextEditingController();
  List list = ["lorem", "lorem", "lorem", "lorem"];
  List vaccineMode = ['Live', 'Killed'];
  List vaccineType = [
    'Newcastle Disease( ND) B1',
    'Newcastle Disease( ND) LaSota',
    'Newcastle Disease( ND) R2B',
    'Fow Pox',
    'Avian Infectious Bronchitis',
    'Infectious Bursal Disease (Gaumboro I+)',
    'Massachusetts Type H-120 Strain',
  ];
  List vaccineMethod = ['Eye Drop', 'Drinking Water', 'SC', 'IM'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: GeneralAppBar(
          
          title: 'Batch',
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      addVerticalSpace(20),
                      Center(
                        child: Text(
                          "Add Vaccination",
                          style: bodyText22w600(color: black),
                        ),
                      ),
                      addVerticalSpace(20),
                      CustomTextField(
                        hintText: "Date",
                        suffix: true,
                        controller: date,
                      ),
                      CustomDropdown(
                          list: vaccineMode, height: 58, hint: "Vaccine"),
                      CustomDropdown(
                          list: vaccineType, height: 58, hint: "Vaccine Type"),
                      CustomDropdown(
                          list: vaccineMethod, height: 58, hint: "Method"),
                      CustomTextField(hintText: "Description")
                    ]),
              ),
            ]),
            addVerticalSpace(height(context) * 0.22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: CustomButton(
                  text: "Add",
                  onClick: () {},
                  width: width(context),
                  height: 55),
            )
          ],
        ),
      ),
    );
  }
}
