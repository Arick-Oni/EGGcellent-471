import 'package:flutter/material.dart';
import 'package:poultry_app/screens/farmsettings/addvaccine.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/customdropdown.dart';
import 'package:poultry_app/widgets/floatbutton.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/navigation.dart';

class VaccinationSchedulePage extends StatefulWidget {
  const VaccinationSchedulePage({super.key});

  @override
  State<VaccinationSchedulePage> createState() =>
      _VaccinationSchedulePageState();
}

class _VaccinationSchedulePageState extends State<VaccinationSchedulePage> {
  List breed = ["Broiler", "Deshi", "Layer", "Breeder Farm"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatedButton(onTap: () {
        NextScreen(context, AddVaccine());
      }),
      appBar: PreferredSize(
        child: GeneralAppBar(
          
          title: "Vaccination Schedule",
        ),
        preferredSize: Size.fromHeight(50),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            addVerticalSpace(10),
            Row(
              children: [
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: CustomDropdown(
                    list: breed,
                    iconSize: 12,
                    hp: 5,
                    radius: 6,
                    height: 30,
                    hint: "Breed",
                    width: width(context) * .35,
                    textStyle: bodyText12w600(color: darkGray),
                  ),
                ),
              ],
            ),
            addVerticalSpace(15),
            Divider(
              height: 0,
            ),
            ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 4,
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 0,
                  );
                },
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    height: 90,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Day 1",
                          style: bodyText12normal(color: darkGray),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Vaccine",
                              style: bodyText17w500(color: black),
                            ),
                            Text(
                              "Vaccine Type:",
                              style: bodyText14normal(color: darkGray),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Breed:",
                              style: bodyText12normal(color: darkGray),
                            ),
                            Text(
                              "Method:",
                              style: bodyText12normal(color: darkGray),
                            )
                          ],
                        )
                      ],
                    ),
                  );
                }),
            Divider(
              height: 0,
            ),
          ],
        ),
      ),
    );
  }
}
