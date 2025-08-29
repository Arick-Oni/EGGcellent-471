import 'package:flutter/material.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import 'package:poultry_app/widgets/customdropdown.dart';
import 'package:poultry_app/widgets/dialogbox.dart';

class ReportsWidget extends StatefulWidget {
  const ReportsWidget({super.key});

  @override
  State<ReportsWidget> createState() => _ReportsWidgetState();
}

class _ReportsWidgetState extends State<ReportsWidget> {
  List list = [
    "All",
    "Income",
    "Expenses",
    "Chick feed Requiredment",
    'Feed Type',
    'Vaccination Schedule'
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: CustomDropdown(
                    list: list,
                    height: 30,
                    hint: "Financial Performance",
                    width: width(context) * .6,
                    textStyle: bodyText12w600(color: darkGray),
                  ),
                ),
              ],
            ),
            addVerticalSpace(10),
            ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 2,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Image.asset("assets/images/excel.png"),
                    title: Text(
                      "Export Analysis report in MS-Excel",
                      style: bodyText14normal(color: black),
                    ),
                  );
                }),
          ],
        ),
        addVerticalSpace(height(context) * .34),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: CustomButton(
              text: "Export",
              onClick: () {
                showDialog(context: context, builder: (context) => dialog());
              }),
        )
      ],
    );
  }

  Widget dialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Container(
        height: 275,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(
              "assets/images/download.png",
              height: 82,
              width: 82,
              fit: BoxFit.fill,
            ),
            Text(
              "Downloading!!",
              style: bodyText28Bold(color: black),
            ),
          ],
        ),
      ),
    );
  }
}
