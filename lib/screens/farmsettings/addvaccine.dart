import 'package:flutter/material.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import 'package:poultry_app/widgets/customdropdown.dart';
import 'package:poultry_app/widgets/customtextfield.dart';
import 'package:poultry_app/widgets/generalappbar.dart';

class AddVaccine extends StatefulWidget {
  const AddVaccine({super.key});

  @override
  State<AddVaccine> createState() => _AddVaccineState();
}

class _AddVaccineState extends State<AddVaccine> {
  List breed = ["Broiler", "Deshi", "Layer", "Breeder Farm"];
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
        child: GeneralAppBar(
          
          title: "Add Vaccination",
        ),
        preferredSize: Size.fromHeight(50),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: height(context) - 135,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    addVerticalSpace(20),
                    CustomDropdown(list: breed, height: 58, hint: "Breed"),
                    CustomTextField(hintText: "Day"),
                    CustomDropdown(
                        list: vaccineMode, height: 58, hint: "Vaccine"),
                    CustomDropdown(
                        list: vaccineType, height: 58, hint: "Vaccine Type"),
                    CustomDropdown(
                        list: vaccineMethod, height: 58, hint: "Method"),
                    CustomTextField(hintText: "Description"),
                  ],
                ),
                CustomButton(text: "Add", onClick: () {})
              ],
            ),
          ),
        ),
      ),
    );
  }
}
