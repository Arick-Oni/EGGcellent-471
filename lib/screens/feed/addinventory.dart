import 'package:flutter/material.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import 'package:poultry_app/widgets/customdropdown.dart';
import 'package:poultry_app/widgets/customtextfield.dart';
import 'package:poultry_app/widgets/dialogbox.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/quantitybutton.dart';

class AddInventoryPage extends StatefulWidget {
  const AddInventoryPage({super.key});

  @override
  State<AddInventoryPage> createState() => _AddInventoryPageState();
}

class _AddInventoryPageState extends State<AddInventoryPage> {
  List list = ["Order 123", "Order 112", "Order 113", "Order 118"];
  int value = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: GeneralAppBar(
          
          title: "Add Inventory",
        ),
        preferredSize: Size.fromHeight(50),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              addVerticalSpace(15),
              CustomDropdown(
                list: list,
                height: 58,
                hint: "Order No.",
                iconSize: 25,
              ),
              CustomTextField(hintText: "Feed Type"),
              CustomTextField(hintText: "Feed Company"),
              CustomTextField(hintText: "50Kg"),
              QuantityButton(),
              CustomTextField(hintText: "Bag Price"),
              CustomTextField(hintText: "Total"),
              addVerticalSpace(60),
              CustomButton(
                  text: "Feed Received",
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
        ),
      ),
    );
  }
}
