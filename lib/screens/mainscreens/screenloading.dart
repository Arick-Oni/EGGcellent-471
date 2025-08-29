import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/generalappbar.dart';

class ScreenLoadingPage extends StatefulWidget {
  const ScreenLoadingPage({super.key});

  @override
  State<ScreenLoadingPage> createState() => _ScreenLoadingPageState();
}

class _ScreenLoadingPageState extends State<ScreenLoadingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: GeneralAppBar(
          
        ),
        preferredSize: Size.fromHeight(50),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/bi.png",
            ),
            addVerticalSpace(25),
            LinearPercentIndicator(
              lineHeight: 13,
              barRadius: Radius.circular(5),
              progressColor: yellow,
              percent: .43,
              backgroundColor: normalGray,
            ),
            addVerticalSpace(20),
            Text(
              "Loading",
              style: bodyText18w500(color: black),
            ),
            addVerticalSpace(20),
            Text(
              "43%",
              style: bodyText18w500(color: black),
            ),
          ],
        ),
      ),
    );
  }
}
