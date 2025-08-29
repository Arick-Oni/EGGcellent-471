import 'package:flutter/material.dart';
import 'package:poultry_app/utils/constants.dart';

Widget popularCategory(BuildContext context, String image, String text,
    double height, double width,
    {Color? color, Color? bgColor}) {
  return Column(
    children: [
      Container(
        height: height,
        width: width,
        margin: EdgeInsets.symmetric(
            vertical: 10, horizontal: color != null ? 10 : 0),
        decoration: shadowDecoration(15, 0, bgColor ?? normalGray,
            bcolor: color ?? normalGray),
        child: Image.asset(image),
      ),
      Text(
        text,
        textAlign: TextAlign.center,
        style: bodyText12w600(color: black),
      )
    ],
  );
}

FloatedWidget(String image, String text, Color bgColor, Color iconColor,
    {void Function()? onTap}) {
  return Padding(
    padding: const EdgeInsets.only(top: 12),
    child: GestureDetector(
      onTap: onTap,
      child: Column(children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: bgColor,
          child: Image.asset(
            image,
            color: iconColor,
            height: 25,
          ),
        ),
        addVerticalSpace(5),
        Text(
          textAlign: TextAlign.center,
          text,
          style: bodyText10normal(color: black),
        )
      ]),
    ),
  );
}
