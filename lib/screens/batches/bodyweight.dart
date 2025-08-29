import 'package:flutter/material.dart';
import 'package:poultry_app/screens/batches/addbodyweight.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/customdropdown.dart';
import 'package:poultry_app/widgets/floatbutton.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/navigation.dart';

class BodyWeightPage extends StatefulWidget {
  const BodyWeightPage({super.key});

  @override
  State<BodyWeightPage> createState() => _BodyWeightPageState();
}

class _BodyWeightPageState extends State<BodyWeightPage> {
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: GeneralAppBar(
          
          title: 'Batch',
        ),
      ),
      floatingActionButton: FloatedButton(onTap: () {
        NextScreen(context, AddBodyWeight());
      }),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Body Weight",
                    style: bodyText22w600(color: black),
                  ),
                ),
                addVerticalSpace(15),
                Row(
                  children: [
                    Spacer(),
                    CustomDropdown(
                      hp: 5,
                      list: list,
                      height: 30,
                      hint: "Last 15 days",
                      iconSize: 10,
                      textStyle: bodyText12w600(color: darkGray),
                      width: width(context) * .35,
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
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  height: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "16/11/2022",
                            style: bodyText12normal(color: darkGray),
                          ),
                          Text(
                            "Day 1",
                            style: bodyText17w500(color: black),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Avg. Weight: 100gms",
                            style: bodyText14normal(color: darkGray),
                          ),
                          Text(
                            "FCR: 3",
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
