import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import 'package:poultry_app/widgets/customdropdown.dart';
import 'package:poultry_app/widgets/customtextfield.dart';
import 'package:poultry_app/widgets/dialogbox.dart';
import 'package:poultry_app/widgets/generalappbar.dart';

class EditMyAds extends StatefulWidget {
  final String? title;
  const EditMyAds({super.key, this.title});

  @override
  State<EditMyAds> createState() => _EditMyAdsState();
}

class _EditMyAdsState extends State<EditMyAds> {
  List list = ["lorem ipsum", "lorem ipsum", "lorem ipsum", "lorem ipsum"];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: GeneralAppBar(
          title: "Post Your Ad",
        ),
        preferredSize: Size.fromHeight(50),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  widget.title ?? "",
                  style: bodyText18w600(color: black),
                ),
              ),
              Container(
                child: Image.asset('assets/images/newMurgi.png'),
                width: width(context),
                height: width(context) * .35,
              ),
              addVerticalSpace(20),
              CustomDropdown(list: list, height: 58, hint: "Category"),
              CustomTextField(hintText: "Quantity"),
              CustomTextField(hintText: "Contact Number"),
              CustomTextField(hintText: "State"),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(hintText: "City"),
                  ),
                  addHorizontalySpace(20),
                  Expanded(
                    child: CustomTextField(hintText: "Village"),
                  )
                ],
              ),
              CustomTextField(hintText: "Description"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Status: ',
                    style: bodyText15normal(color: black.withOpacity(0.6)),
                  ),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      height: 40,
                      width: width(context) * 0.3,
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(40, 180, 70, 0.35),
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(6)),
                      child: Center(
                        child: Text(
                          'Sold',
                          style: bodyText14Bold(color: Colors.green),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      height: 40,
                      width: width(context) * 0.3,
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(241, 67, 54, 0.35),
                          border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(6)),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: bodyText14Bold(color: Colors.red),
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
