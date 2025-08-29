import 'package:flutter/material.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import 'package:poultry_app/widgets/customdropdown.dart';
import 'package:poultry_app/widgets/customtextfield.dart';
import 'package:poultry_app/widgets/dialogbox.dart';

class StockInWidget extends StatefulWidget {
  const StockInWidget({super.key});

  @override
  State<StockInWidget> createState() => _StockInWidgetState();
}

class _StockInWidgetState extends State<StockInWidget> {
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
              CustomDropdown(list: batch, height: 58, hint: "From Batch"),
              CustomDropdown(list: feedType, height: 58, hint: "Feed Type"),
              CustomTextField(hintText: "Quantity: Stock Available")
            ],
          ),
          CustomButton(
              // text: "Receive Feed",
              text: 'Transfer Feed to Inventory',
              onClick: () {
                showDialog(
                    context: context,
                    builder: (context) => ShowDialogBox(
                          message: "Feed Received!!",
                          subMessage: '',
                        ));
              })
        ],
      ),
    );
  }
}
