import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import 'package:poultry_app/widgets/generalappbar.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

int selected = 0;

class _SubscriptionPageState extends State<SubscriptionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: PreferredSize(
        child: GeneralAppBar(
          title: "Subscription",
        ),
        preferredSize: Size.fromHeight(50),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              addVerticalSpace(30),
              Image.asset("assets/images/crown.png"),
              addVerticalSpace(20),
              Text(
                "Upgrade to Premium",
                style: bodyText20w600(color: black),
              ),
              addVerticalSpace(40),
              Container(
                height: 267,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Text(
                              "Services",
                              style: bodyText10w600(color: black),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(bottom: 25),
                            height: 180,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "View Market Rates",
                                  style: bodyText10normal(color: black),
                                ),
                                Text(
                                  "Sell Products",
                                  style: bodyText10normal(color: black),
                                ),
                                Text(
                                  "Manage your Broiler,\nDeshi Farm",
                                  style: bodyText10normal(color: black),
                                ),
                                Text(
                                  "Manage Layer Farm",
                                  style: bodyText10normal(color: black),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 10),
                      decoration: shadowDecoration(8, 1.5, white,
                          bcolor: selected == 0 ? yellow : normalGray),
                      width: 65,
                      height: 267,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            textAlign: TextAlign.center,
                            "Poultry\nMarket",
                            style: bodyText10w600(color: black),
                          ),
                          Container(
                            padding: EdgeInsets.only(bottom: 25),
                            height: 180,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  Icons.check,
                                  size: 18,
                                ),
                                Icon(
                                  Icons.check,
                                  size: 18,
                                ),
                                Icon(
                                  Icons.close,
                                  size: 18,
                                ),
                                Icon(
                                  Icons.close,
                                  size: 18,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 10),
                      decoration: shadowDecoration(8, 1.5, white,
                          bcolor: selected == 1 ? yellow : normalGray),
                      width: 65,
                      height: 267,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            textAlign: TextAlign.center,
                            "Farm\nManagement",
                            style: bodyText10w600(color: black),
                          ),
                          Container(
                            padding: EdgeInsets.only(bottom: 25),
                            height: 180,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  Icons.close,
                                  size: 18,
                                ),
                                Icon(
                                  Icons.close,
                                  size: 18,
                                ),
                                Icon(
                                  Icons.check,
                                  size: 18,
                                ),
                                Icon(
                                  Icons.check,
                                  size: 18,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 10),
                      decoration: shadowDecoration(8, 1.5, white,
                          bcolor: selected == 2 ? yellow : normalGray),
                      width: 65,
                      height: 267,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            textAlign: TextAlign.center,
                            "Poultry\nMarket\n+\nFarm\nManagement",
                            style: bodyText10w600(color: black),
                          ),
                          Container(
                            padding: EdgeInsets.only(bottom: 25),
                            height: 180,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  Icons.check,
                                  size: 18,
                                ),
                                Icon(
                                  Icons.check,
                                  size: 18,
                                ),
                                Icon(
                                  Icons.check,
                                  size: 18,
                                ),
                                Icon(
                                  Icons.check,
                                  size: 18,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              addVerticalSpace(25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selected = 0;
                      });
                    },
                    child: SubscriptionWidget(
                        "1 Month", "99", selected == 0 ? yellow : normalGray),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selected = 1;
                      });
                    },
                    child: SubscriptionWidget(
                        "6 Months", "299", selected == 1 ? yellow : normalGray),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selected = 2;
                      });
                    },
                    child: SubscriptionWidget(
                        "Yearly", "499", selected == 2 ? yellow : normalGray),
                  ),
                ],
              ),
              addVerticalSpace(60),
              CustomButton(
                  text: "Buy Now",
                  onClick: () {},
                  width: width(context),
                  height: 58)
            ],
          ),
        ),
      ),
    );
  }

  Widget SubscriptionWidget(String validity, String price, Color color) {
    return Container(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          validity,
          style: bodyText12w500(color: black),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "\u{20B9}",
              style: bodyText12normal(color: black),
            ),
            addHorizontalySpace(2),
            Text(
              price,
              style: bodyText24w600(color: black),
            ),
          ],
        )
      ]),
      width: width(context) * .28,
      height: width(context) * .2,
      decoration: shadowDecoration(10, 2, white, bcolor: color),
    );
  }
}
