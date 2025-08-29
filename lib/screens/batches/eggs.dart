import 'package:flutter/material.dart';
import 'package:poultry_app/screens/batches/addeggs.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/customdropdown.dart';
import 'package:poultry_app/widgets/floatbutton.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/navigation.dart';

class EggsPage extends StatefulWidget {
  const EggsPage({super.key});

  @override
  State<EggsPage> createState() => _EggsPageState();
}

class _EggsPageState extends State<EggsPage> {
  List list = [
    "Last 7 days",
    "Last 15 Days",
    "Last 1 Month",
    "Last6 Months",
    "Last 1 Year"
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatedButton(onTap: () {
        NextScreen(context, AddEggsPage());
      }),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: GeneralAppBar(
          
          title: "Batch",
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            addVerticalSpace(20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Eggs",
                      style: bodyText22w600(color: black),
                    ),
                  ),
                  addVerticalSpace(20),
                  Row(
                    children: [
                      Spacer(),
                      CustomDropdown(
                        hp: 5,
                        iconSize: 10,
                        dropdownColor: white,
                        bcolor: darkGray,
                        hint: "All Time",
                        height: 30,
                        width: width(context) * .35,
                        list: list,
                        textStyle: bodyText12w600(color: darkGray),
                      ),
                    ],
                  ),
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
                    height: 90,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "16/11/2022 -- ",
                                  style: bodyText12normal(color: darkGray),
                                ),
                                Text(
                                  "Today",
                                  style: bodyText12normal(color: yellow),
                                )
                              ],
                            ),
                            Text(
                              "Laying Percentage: 90%",
                              style: bodyText12normal(color: black),
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
                              "Cost: 6/egg",
                              style: bodyText14w500(color: black),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Egg Tray Collection: 11 Trays",
                              style: bodyText10normal(color: black),
                            ),
                            Text("Pullet Eggs: 50 Eggs",
                                style: bodyText10normal(color: black)),
                            Text("Broken Eggs: 9",
                                style: bodyText10normal(color: black)),
                          ],
                        )
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 8,
                  );
                },
                itemCount: 6),
            Divider(
              height: 0,
            ),
            addVerticalSpace(20)
          ],
        ),
      ),
    );
  }
}
