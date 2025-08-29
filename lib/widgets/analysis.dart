import 'package:flutter/material.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/navigation.dart';

class AnalysisWidget extends StatefulWidget {
  const AnalysisWidget({super.key});

  @override
  State<AnalysisWidget> createState() => _AnalysisWidgetState();
}

class _AnalysisWidgetState extends State<AnalysisWidget> {
  List analysis = [
    {
      "title": "Financial Performance",
      "c1data1": "Rs. 2,00,000",
      "c1data2": "Total Expenses",
      "c2data1": "Rs. 2,50,000",
      "c2data2": "Total income",
      "c3data1": "Rs. 50,000",
      "c3data2": "Net Balance",
    },
    {
      "title": "Financial Analysis",
      "c1data1": "Rs. 100",
      "c1data2": "Cost per bird",
      "c2data1": "5,000",
      "c2data2": "Solid Birds",
      "c3data1": "Rs. 1,25,000",
      "c3data2": "Profit On Sold Birds",
    },
    {
      "title": "Feed",
      "c1data1": "15,000 kg",
      "c1data2": "Total Feed Consumed",
      "c2data1": "Rs. 120",
      "c2data2": "Per Bird Feed Cost",
    },
    {
      "title": "Feed Performance",
      "c1data1": "3,000 gms",
      "c1data2": "Per Bird Feed Intake/\ngms",
      "c2data1": "1,000 gms",
      "c2data2": "Average Body\nWeight",
      "c3data1": "3",
      "c3data2": "FCR",
    },
  ];
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        separatorBuilder: (context, index) {
          return addVerticalSpace(15);
        },
        itemCount: analysis.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              height: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: Text(
                      analysis[index]['title'],
                      style: bodyText14w500(color: black),
                    ),
                  ),
                  Container(
                    height: 60,
                    decoration: shadowDecoration(
                        10, 1, Color.fromRGBO(232, 236, 244, 1),
                        bcolor: Color.fromRGBO(232, 236, 244, 1)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              analysis[index]['c1data1'],
                              style: bodyText12w600(color: black),
                            ),
                            Text(
                              analysis[index]['c1data2'],
                              textAlign: TextAlign.center,
                              style: bodyText10normal(color: black),
                            ),
                          ],
                        ),
                        verticalDivider(1, 60),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              analysis[index]['c2data1'],
                              style: bodyText12w600(color: black),
                            ),
                            Text(
                              analysis[index]['c2data2'],
                              textAlign: TextAlign.center,
                              style: bodyText10normal(color: black),
                            ),
                          ],
                        ),
                        analysis[index]['c3data1'] == null
                            ? addVerticalSpace(0)
                            : verticalDivider(1, 60),
                        analysis[index]['c3data2'] == null
                            ? addVerticalSpace(0)
                            : Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    analysis[index]['c3data1'],
                                    style: bodyText12w600(color: black),
                                  ),
                                  Text(
                                    analysis[index]['c3data2'],
                                    style: bodyText10normal(color: black),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
