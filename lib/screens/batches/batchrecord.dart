import 'package:flutter/material.dart';
import 'package:poultry_app/screens/batches/newbatch.dart';

import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/analysis.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/records.dart';
import 'package:poultry_app/widgets/reports.dart';
import 'package:poultry_app/screens/batches/bodyweight.dart';
import 'package:poultry_app/screens/batches/eggs.dart';
import 'package:poultry_app/screens/batches/expense.dart';
import 'package:poultry_app/screens/batches/feedserved.dart';
import 'package:poultry_app/screens/batches/income.dart';
import 'package:poultry_app/screens/batches/medicine.dart';
import 'package:poultry_app/screens/batches/mortality.dart';
import 'package:poultry_app/screens/batches/notes.dart';
import 'package:poultry_app/screens/batches/stocks.dart';
import 'package:poultry_app/screens/batches/subuser.dart';
import 'package:poultry_app/screens/batches/vaccination.dart';

class BatchRecordPage extends StatefulWidget {
  const BatchRecordPage({super.key});

  @override
  State<BatchRecordPage> createState() => _BatchRecordPageState();
}

class _BatchRecordPageState extends State<BatchRecordPage> {
  List<dynamic> record = [
    {
      "lead": "assets/images/income.png",
      "text": "income",
      "screen": IncomePage()
    },
    {
      "lead": "assets/images/expense.png",
      "text": "Expenses",
      "screen": ExpensesPage()
    },
    {
      "lead": "assets/images/feed.png",
      "text": "Feed Served",
      "screen": FeedServedPage()
    },
    {
      "lead": "assets/images/mort.png",
      "text": "Mortality",
      "screen": MortalityPage()
    },
    {
      "lead": "assets/images/body.png",
      "text": "Body weight",
      "screen": BodyWeightPage()
    },
    {
      "lead": "assets/images/stock.png",
      "text": "Stocks",
      "screen": StocksPage()
    },
    {
      "lead": "assets/images/vaccine.png",
      "text": "Vaccination",
      "screen": VaccinationPage()
    },
    {
      "lead": "assets/images/medi.png",
      "text": "Medicine",
      "screen": MedicinePage()
    },
    {"lead": "assets/images/medi.png", "text": "Notes", "screen": NotesPage()},
    {"lead": "assets/images/medi.png", "text": "Eggs", "screen": EggsPage()},
    {
      "lead": "assets/images/medi.png",
      "text": "Sub User",
      "screen": SubUserPage()
    },
  ];

  int index = 0;
  @override
  Widget build(BuildContext context) {
    List widgets = [
      RecordsWidget(
        record: record,
      ),
      AnalysisWidget(),
      ReportsWidget()
    ];
    return Scaffold(
      appBar: PreferredSize(
        child: GeneralAppBar(),
        preferredSize: Size.fromHeight(50),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  Container(
                    height: 101,
                    padding: EdgeInsets.only(left: 15, bottom: 10),
                    decoration: shadowDecoration(12, 0, white,
                        bcolor: yellow, width: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Batch Name",
                              style: bodyText16w600(color: black),
                            ),
                            Row(
                              children: [
                                Container(
                                  child: IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (ctx) =>
                                                    SubUserPage()));
                                      },
                                      icon: ImageIcon(AssetImage(
                                          "assets/images/useradd.png"))),
                                ),
                                IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (ctx) => NewBatch(
                                                    title: 'Edit Batch',
                                                  )));
                                    },
                                    icon: ImageIcon(
                                        AssetImage("assets/images/edit.png"))),
                                IconButton(
                                    onPressed: () {
                                      deleteWarning(context);
                                    },
                                    icon: ImageIcon(
                                      AssetImage(
                                        "assets/images/cross.png",
                                      ),
                                      size: 20,
                                    )),
                              ],
                            )
                          ],
                        ),
                        Text(
                          "1 week: 5 days",
                          style: bodyText14normal(color: darkGray),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total Chicks: 1100",
                                style: bodyText12normal(color: darkGray),
                              ),
                              Text(
                                "Sold: 1000",
                                style: bodyText12normal(color: darkGray),
                              ),
                              Text(
                                "Mortality: 0",
                                style: bodyText12normal(color: darkGray),
                              ),
                              Text(
                                "Live: 100",
                                style: bodyText12normal(color: darkGray),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                            radius: 10,
                            textStyle: bodyText16w600(
                                color: index == 0 ? white : darkGray),
                            text: "Records",
                            buttonColor: index == 0 ? yellow : utbColor,
                            onClick: () {
                              setState(() {
                                index = 0;
                              });
                            },
                            width: width(context),
                            height: 40),
                      ),
                      addHorizontalySpace(12),
                      Expanded(
                        child: CustomButton(
                            radius: 10,
                            textStyle: bodyText16w600(
                                color: index == 1 ? white : darkGray),
                            text: "Analysis",
                            onClick: () {
                              setState(() {
                                index = 1;
                              });
                            },
                            buttonColor: index == 1 ? yellow : utbColor,
                            width: width(context),
                            height: 40),
                      ),
                      addHorizontalySpace(12),
                      Expanded(
                        child: CustomButton(
                            radius: 10,
                            textStyle: bodyText16w600(
                                color: index == 2 ? white : darkGray),
                            text: "Reports",
                            buttonColor: index == 2 ? yellow : utbColor,
                            onClick: () {
                              setState(() {
                                index = 2;
                              });
                            },
                            width: width(context),
                            height: 40),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(),
            widgets[index],
            addVerticalSpace(20)
          ],
        ),
      ),
    );
  }

  Future<dynamic> deleteWarning(BuildContext context) {
    return showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.all(6),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              content: Builder(
                builder: (context) {
                  var height = MediaQuery.of(context).size.height;
                  var width = MediaQuery.of(context).size.width;

                  return Container(
                      height: height * 0.34,
                      padding: EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Image.asset('assets/images/close 1.png'),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              'Are you sure you want to close the batch?',
                              textAlign: TextAlign.center,
                              style: bodyText16Bold(color: black),
                            ),
                          ),
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {},
                                child: Container(
                                  height: 40,
                                  width: width * 0.3,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: yellow),
                                      borderRadius: BorderRadius.circular(6)),
                                  child: Center(
                                    child: Text(
                                      'Cancel',
                                      style: bodyText14Bold(color: black),
                                    ),
                                  ),
                                ),
                              ),
                              addHorizontalySpace(20),
                              InkWell(
                                onTap: () {},
                                child: Container(
                                  height: 40,
                                  width: width * 0.3,
                                  decoration: BoxDecoration(
                                      color: yellow,
                                      borderRadius: BorderRadius.circular(6)),
                                  child: Center(
                                    child: Text(
                                      'Close',
                                      style:
                                          bodyText14Bold(color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ));
                },
              ),
            ));
  }
}
