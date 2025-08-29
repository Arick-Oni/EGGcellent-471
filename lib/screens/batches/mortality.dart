import 'package:flutter/material.dart';
import 'package:poultry_app/screens/batches/addmortality.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/customdropdown.dart';
import 'package:poultry_app/widgets/floatbutton.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/navigation.dart';

class MortalityPage extends StatefulWidget {
  const MortalityPage({super.key});

  @override
  State<MortalityPage> createState() => _MortalityPageState();
}

class _MortalityPageState extends State<MortalityPage> {
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
        NextScreen(context, AddMortalityPage());
      }),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: GeneralAppBar(
          
          title: "Batch",
        ),
      ),
      body: Column(
        children: [
          Column(
            children: [
              Text(
                "Mortality",
                style: bodyText22w600(color: black),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomDropdown(
                        hp: 5,
                        list: list,
                        radius: 6,
                        height: 30,
                        hint: "select date",
                        textStyle: bodyText12w600(color: darkGray),
                        iconSize: 10,
                        bcolor: darkGray,
                      ),
                    ),
                    addHorizontalySpace(10),
                    Expanded(
                      child: Container(
                        height: 30,
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Center(
                            child: Text(
                          "Total Mortality:  ",
                          style: bodyText12w600(color: darkGray),
                        )),
                        decoration:
                            shadowDecoration(6, 0, tfColor, bcolor: darkGray),
                      ),
                    ),
                    addHorizontalySpace(10),
                    Expanded(
                      child: Container(
                        height: 30,
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Center(
                            child: Text(
                          "Mortality %:   ",
                          style: bodyText12w600(color: darkGray),
                        )),
                        decoration:
                            shadowDecoration(6, 0, tfColor, bcolor: darkGray),
                      ),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                      height: 70,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "16/11/2022",
                            style: bodyText12normal(color: darkGray),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Day 4",
                                style: bodyText17w500(color: black),
                              ),
                              Text(
                                "Birds: 2",
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
          )
        ],
      ),
    );
  }
}
