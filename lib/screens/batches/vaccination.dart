import 'package:flutter/material.dart';
import 'package:poultry_app/screens/batches/addvaccination.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import 'package:poultry_app/widgets/floatbutton.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/navigation.dart';

class VaccinationPage extends StatefulWidget {
  const VaccinationPage({super.key});

  @override
  State<VaccinationPage> createState() => _VaccinationPageState();
}

class _VaccinationPageState extends State<VaccinationPage> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatedButton(
        onTap: () {
          NextScreen(context, AddVaccinationPage());
        },
      ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: GeneralAppBar(
          
          title: 'Batch',
        ),
      ),
      body: Column(
        children: [
          addVerticalSpace(20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                Text(
                  "Vaccination",
                  style: bodyText22w600(color: black),
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                          buttonColor: index == 0 ? yellow : utbColor,
                          textStyle: bodyText12w600(
                              color: index == 0 ? white : darkGray),
                          text: "Vaccination Schedule",
                          onClick: () {
                            setState(() {
                              index = 0;
                            });
                          },
                          width: width(context),
                          height: 40),
                    ),
                    addHorizontalySpace(15),
                    Expanded(
                      child: CustomButton(
                          buttonColor: index == 1 ? yellow : utbColor,
                          textStyle: bodyText12w600(
                              color: index == 1 ? white : darkGray),
                          text: "Actual Vaccination",
                          onClick: () {
                            setState(() {
                              index = 1;
                            });
                          },
                          width: width(context),
                          height: 40),
                    ),
                  ],
                )
              ],
            ),
          ),
          Divider(
            height: 0,
          ),
          ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  height: 70,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "17/11/2022 ",
                            style: bodyText12normal(color: darkGray),
                          ),
                          Text(
                            "Vaccination",
                            style: bodyText14normal(color: darkGray),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Day 1",
                            style: bodyText17w500(color: black),
                          ),
                          Text(
                            "Method",
                            style: bodyText14normal(color: darkGray),
                          )
                        ],
                      )
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return Divider(
                  height: 0,
                );
              },
              itemCount: 6),
          Divider(
            height: 0,
          ),
          addVerticalSpace(20)
        ],
      ),
    );
  }
}
