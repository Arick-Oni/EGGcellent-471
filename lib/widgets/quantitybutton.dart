import 'package:flutter/material.dart';
import 'package:poultry_app/utils/constants.dart';

class QuantityButton extends StatefulWidget {
  const QuantityButton({super.key});

  @override
  State<QuantityButton> createState() => _QuantityButtonState();
}

class _QuantityButtonState extends State<QuantityButton> {
  int value = 50;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              "Bags Quantity",
              style: bodyText15w500(color: darkGray),
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (value > 0) {
                    setState(() {
                      value--;
                    });
                  }
                },
                child: Container(
                  width: 42,
                  height: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                      color: tfColor,
                      border: Border.all(color: yellow)),
                  child: Icon(
                    Icons.remove,
                    size: 25,
                    color: yellow,
                  ),
                ),
              ),
              Container(
                height: 60,
                width: 51,
                decoration: BoxDecoration(
                    color: tfColor,
                    border: Border(
                      bottom: BorderSide(color: normalGray),
                      top: BorderSide(color: normalGray),
                    )),
                child: Center(
                  child: Text(
                    value.toString(),
                    style: bodyText15w500(color: darkGray),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    value++;
                  });
                },
                child: Container(
                  height: 60,
                  child: Icon(
                    Icons.add,
                    size: 25,
                    color: yellow,
                  ),
                  width: 42,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      color: tfColor,
                      border: Border.all(color: yellow)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
