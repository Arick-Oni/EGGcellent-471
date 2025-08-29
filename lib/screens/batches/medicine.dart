import 'package:flutter/material.dart';
import 'package:poultry_app/screens/batches/addmedicine.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/floatbutton.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/navigation.dart';

class MedicinePage extends StatelessWidget {
  const MedicinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatedButton(onTap: () {
        NextScreen(context, AddMedicinePage());
      }),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: GeneralAppBar(
          
          title: 'Batch',
        ),
      ),
      body: Column(
        children: [
          addVerticalSpace(20),
          Text(
            "Medicine",
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
                  height: 70,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "17/11/2022 ",
                        style: bodyText12normal(color: darkGray),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Day 1",
                            style: bodyText17w500(color: black),
                          ),
                          Text(
                            "Medicine Name",
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
