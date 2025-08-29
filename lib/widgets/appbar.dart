import 'package:flutter/material.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/navigation.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: transparent,
        elevation: 0,
        foregroundColor: black,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: shadowDecoration(12, 1, white),
            child: Padding(
              padding: const EdgeInsets.only(left: 7),
              child: IconButton(
                  onPressed: () {
                    goBack(context);
                  },
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 16,
                  )),
            ),
          ),
        ));
  }
}
