import 'package:flutter/material.dart';
import 'package:poultry_app/utils/constants.dart';

class CustomSearchBox extends StatelessWidget {
  final String? hint;
  const CustomSearchBox({super.key, this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      height: 40,
      decoration: shadowDecoration(10, 1, tfColor),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 2.5),
          child: TextFormField(
            style: bodyText16normal(color: black),
            cursorColor: black,
            decoration: InputDecoration(
                hintText: hint ?? "Search",
                hintStyle: bodyText15normal(color: gray),
                // filled: true,
                // fillColor: Color.fromRGBO(232, 236, 244, 1),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Icon(
                    Icons.search,
                    color: gray,
                  ),
                ),
                border: InputBorder.none),
          ),
        ),
      ),
    );
  }
}
