import 'package:flutter/material.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/navigation.dart';

class StocksPage extends StatelessWidget {
  const StocksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: GeneralAppBar(
          
          title: 'Batch',
        ),
      ),
      body: Column(
        children: [
          addVerticalSpace(15),
          Text(
            "Stocks",
            style: bodyText22w600(color: black),
          ),
          addVerticalSpace(20),
          Divider(
            height: 0,
          ),
          ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    height: 80,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Pre Starter",
                              style: bodyText15w500(color: black),
                            ),
                            Text(
                              "17/12/2022",
                              style: bodyText12normal(color: darkGray),
                            )
                          ],
                        ),
                        Text(
                          "Baramati",
                          style: bodyText12normal(color: darkGray),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Received: 10 bags",
                              style: bodyText10normal(color: black),
                            ),
                            Text(
                              "Served: 10 bags",
                              style: bodyText10normal(color: black),
                            ),
                            Text(
                              "Remaining: 10 bags",
                              style: bodyText10normal(color: black),
                            ),
                          ],
                        )
                      ],
                    ));
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
