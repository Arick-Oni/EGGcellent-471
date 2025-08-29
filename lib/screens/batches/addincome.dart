import 'package:flutter/material.dart';
import 'package:poultry_app/screens/farmsettings/addincomecat.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import 'package:poultry_app/widgets/customdropdown.dart';
import 'package:poultry_app/widgets/customtextfield.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/navigation.dart';

class AddIncomePage extends StatefulWidget {
  const AddIncomePage({super.key});

  @override
  State<AddIncomePage> createState() => _AddIncomePageState();
}

class _AddIncomePageState extends State<AddIncomePage> {
  List list = ["lorem", "lorem", "lorem", "lorem"];
  List paymentList = ['Cash', 'Online', 'Unpaid'];
  int selectedIndex = 0;
  String? method;
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
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    addVerticalSpace(10),
                    Center(
                      child: Text(
                        "Add Income",
                        style: bodyText22w600(color: black),
                      ),
                    ),
                    addVerticalSpace(15),
                    CustomTextField(hintText: "Name"),
                    CustomTextField(hintText: "Contact"),
                    Row(
                      children: [
                        Expanded(
                            child: CustomDropdown(
                                list: list,
                                height: 58,
                                hint: "Income Category")),
                        addHorizontalySpace(15),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (ctx) => AddIncomeCategory()));
                          },
                          child: Container(
                            height: 58,
                            width: 58,
                            decoration: shadowDecoration(10, 0, yellow),
                            child: Center(
                                child: Icon(
                              Icons.add,
                              color: white,
                            )),
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: CustomTextField(hintText: "Quantity")),
                        addHorizontalySpace(10),
                        Expanded(child: CustomTextField(hintText: "Weight")),
                        addHorizontalySpace(10),
                        Expanded(child: CustomTextField(hintText: "Rate")),
                      ],
                    ),
                    CustomTextField(hintText: "Bill Amount"),
                    addVerticalSpace(5),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(
                        "Payment Method:",
                        style: bodyText15w500(color: black),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                          itemCount: paymentList.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (ctx, i) {
                            return InkWell(
                              onTap: () {
                                selectedIndex = i;
                                setState(() {});
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 13, right: 25.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      selectedIndex == i
                                          ? Icons.radio_button_checked_outlined
                                          : Icons.radio_button_off_outlined,
                                      color: selectedIndex == i
                                          ? yellow
                                          : Colors.grey,
                                    ),
                                    addHorizontalySpace(6),
                                    Text(
                                      paymentList[i],
                                      style: bodyText15normal(
                                          color: black.withOpacity(0.6)),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }),
                    ),
                    CustomTextField(hintText: "Amount Paid"),
                    CustomTextField(hintText: "Amount Due"),
                    CustomTextField(hintText: "Description"),
                    CustomButton(
                        text: "Cash In",
                        onClick: () {
                          Navigator.pop(context);
                        },
                        width: width(context),
                        height: 55)
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
