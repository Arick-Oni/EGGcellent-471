import 'package:flutter/material.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import 'package:poultry_app/widgets/customtextfield.dart';
import 'package:poultry_app/widgets/generalappbar.dart';

class AddReminder extends StatefulWidget {
  const AddReminder({super.key});

  @override
  State<AddReminder> createState() => _AddReminderState();
}

class _AddReminderState extends State<AddReminder> {
  final date = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: GeneralAppBar(
          
          title: "Add Reminder",
        ),
        preferredSize: Size.fromHeight(50),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: height(context) * 0.88,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    addVerticalSpace(15),
                    CustomTextField(
                      hintText: "Date",
                      suffix: true,
                      controller: date,
                    ),
                    CustomTextField(hintText: "Reminder"),
                    CustomTextField(hintText: "Description"),
                  ],
                ),
                CustomButton(text: "Save", onClick: () {})
              ],
            ),
          ),
        ),
      ),
    );
  }
}
