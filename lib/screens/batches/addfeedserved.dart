import 'package:flutter/material.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import 'package:poultry_app/widgets/customdropdown.dart';
import 'package:poultry_app/widgets/customtextfield.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/navigation.dart';

class AddFeedServedPage extends StatefulWidget {
  const AddFeedServedPage({super.key});

  @override
  State<AddFeedServedPage> createState() => _AddFeedServedPageState();
}

class _AddFeedServedPageState extends State<AddFeedServedPage> {
  List list = ["lorem", "lorem", "lorem", "lorem"];
  final date = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: GeneralAppBar(
          
          title: 'Batch',
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      addVerticalSpace(20),
                      Center(
                        child: Text(
                          "Add Feed Served",
                          style: bodyText22w600(color: black),
                        ),
                      ),
                      addVerticalSpace(20),
                      CustomTextField(
                        hintText: "Date",
                        suffix: true,
                        controller: date,
                      ),
                      CustomDropdown(
                        list: list,
                        height: 58,
                        hint: "Feed Type",
                      ),
                      CustomTextField(hintText: "Total Feed given in Kg")
                    ]),
              ),
            ]),
            addVerticalSpace(height(context) * .39),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: CustomButton(
                  text: "Add",
                  onClick: () {},
                  width: width(context),
                  height: 55),
            )
          ],
        ),
      ),
    );
  }
}
