import 'package:flutter/material.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import 'package:poultry_app/widgets/customdropdown.dart';
import 'package:poultry_app/widgets/dialogbox.dart';
import 'package:poultry_app/widgets/quantitybutton.dart';

class StockOutWidget extends StatefulWidget {
  const StockOutWidget({super.key});

  @override
  State<StockOutWidget> createState() => _StockOutWidgetState();
}

class _StockOutWidgetState extends State<StockOutWidget> {
  List feedType = ['Breeder Farm', 'Broiler', 'Deshi', 'Layer'];
  List batch = [
    'Batch Name',
    'Batch Name',
    'Batch Name',
    'Batch Name',
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height(context) - 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              CustomDropdown(list: feedType, height: 58, hint: "Feed Type"),
              CustomDropdown(
                  list: batch, height: 58, hint: "Transfer to Batch"),
              QuantityButton(),
            ],
          ),
          CustomButton(
              text: "Transfer Feed",
              onClick: () {
                showDialog(
                    context: context,
                    builder: (context) => ShowDialogBox(
                          message: "Feed Transferred!!",
                        ));
              })
        ],
      ),
    );
  }
}
