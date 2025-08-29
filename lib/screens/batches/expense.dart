import 'package:flutter/material.dart';
import 'package:poultry_app/screens/batches/addexpenses.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/floatbutton.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/navigation.dart';
import 'package:poultry_app/widgets/searchbox.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatedButton(onTap: () {
        NextScreen(context, AddExpensesPage());
      }),
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: GeneralAppBar(
          
          title: "Batch",
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  Text(
                    "Expense",
                    style: bodyText22w600(color: black),
                  ),
                  addVerticalSpace(20),
                  Row(
                    children: [
                      Expanded(child: CustomSearchBox()),
                      addHorizontalySpace(12),
                      Container(
                        decoration:
                            shadowDecoration(6, 1, white, bcolor: normalGray),
                        height: 40,
                        width: 40,
                        child: Image.asset("assets/images/filter.png"),
                      )
                    ],
                  ),
                ],
              ),
            ),
            addVerticalSpace(10),
            Divider(),
            ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    height: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "16/11/2021",
                              style: bodyText12normal(color: darkGray),
                            ),
                            Text(
                              "Name",
                              style: bodyText15w500(color: black),
                            ),
                            Text(
                              "Category Feed.",
                              style: bodyText12normal(color: darkGray),
                            )
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset("assets/images/share.png"),
                                addHorizontalySpace(10),
                                Image.asset("assets/images/delete.png"),
                              ],
                            ),
                            Text(
                              "7,000",
                              style: bodyText18w600(color: red),
                            )
                          ],
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 0,
                  );
                },
                itemCount: 6),
            Divider(
              height: 0,
            ),
            addVerticalSpace(20)
          ],
        ),
      ),
    );
  }
}
