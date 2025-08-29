import 'package:flutter/material.dart';
import 'package:poultry_app/utils/constants.dart';

class SocialAuthButton extends StatelessWidget {
  const SocialAuthButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: width(context) / 3.55,
          height: 60,
          decoration: shadowDecoration(8.5, 1, white),
          child: Image.asset(
            "assets/images/f.png",
          ),
        ),
        Container(
          width: width(context) / 3.55,
          height: 60,
          decoration: shadowDecoration(8.5, 1, white),
          child: Image.asset("assets/images/g.png"),
        ),
        Container(
          width: width(context) / 3.55,
          height: 60,
          decoration: shadowDecoration(8.5, 1, white),
          child: Image.asset("assets/images/a.png"),
        ),
      ],
    );
  }
}
