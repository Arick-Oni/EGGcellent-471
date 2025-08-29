import 'package:flutter/material.dart';
import 'package:poultry_app/screens/batches/addfeedserved.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import 'package:poultry_app/widgets/customdropdown.dart';
import 'package:poultry_app/widgets/floatbutton.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/navigation.dart';

class FeedServedPage extends StatefulWidget {
  const FeedServedPage({super.key});

  @override
  State<FeedServedPage> createState() => _FeedServedPageState();
}

class _FeedServedPageState extends State<FeedServedPage> {
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
        NextScreen(context, AddFeedServedPage());
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  Text(
                    "Feed Served",
                    style: bodyText22w600(color: black),
                  ),
                  Row(
                    children: [
                      CustomDropdown(
                        iconSize: 10,
                        hp: 5,
                        dropdownColor: white,
                        bcolor: darkGray,
                        hint: "All Time",
                        height: 30,
                        width: width(context) * .3,
                        list: list,
                        textStyle: bodyText12w600(color: darkGray),
                      ),
                      addHorizontalySpace(15),
                      Expanded(
                          child: CustomButton(
                              bcolor: darkGray,
                              buttonColor: white,
                              textStyle: bodyText12w600(color: darkGray),
                              text: "Today's Feed Requirement: 50 kg",
                              onClick: () {},
                              width: width(context),
                              height: 30)),
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
                    height: 70,
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
                              "Feed Served: 25kg",
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
                              "Feed Type:",
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
      ),
    );
  }
}
