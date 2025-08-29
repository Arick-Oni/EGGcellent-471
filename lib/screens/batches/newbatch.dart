import 'package:flutter/material.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import 'package:poultry_app/widgets/customdropdown.dart';
import 'package:poultry_app/widgets/customtextfield.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class NewBatch extends StatefulWidget {
  const NewBatch({super.key, required this.title});
  final String title;

  @override
  State<NewBatch> createState() => _NewBatchState();
}

class _NewBatchState extends State<NewBatch> {
  List breed = ["Broiler", "Deshi", "Layer", "Breeder Farm"];
  final dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: GeneralAppBar(
          
          title: widget.title,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: height(context) - 135,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    CustomTextField(
                      hintText: "Date",
                      suffix: true,
                      controller: dateController,
                    ),
                    CustomTextField(hintText: "Batch Name"),
                    CustomDropdown(
                      hint: "Breed",
                      height: 58,
                      list: breed,
                      dropdownColor: Color.fromRGBO(232, 236, 244, 1),
                    ),
                    CustomTextField(hintText: "Number of birds"),
                    CustomTextField(hintText: "Cost per bird"),
                    CustomTextField(hintText: "Supplier"),
                  ],
                ),
                CustomButton(
                    text: "Submit",
                    onClick: () {},
                    width: width(context),
                    height: 55)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
