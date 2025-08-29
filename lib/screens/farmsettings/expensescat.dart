import 'package:flutter/material.dart';
import 'package:poultry_app/screens/farmsettings/addexpensescat.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/floatbutton.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/navigation.dart';

class ExpensesCategoryPage extends StatefulWidget {
  const ExpensesCategoryPage({super.key});

  @override
  State<ExpensesCategoryPage> createState() => _ExpensesCategoryPageState();
}

class _ExpensesCategoryPageState extends State<ExpensesCategoryPage> {
  List cat = [
    "Chicks",
    "Cleaning",
    "Debeaking",
    "Electricity",
    "Feed",
    "Labour",
    "Medicine",
    "Transportation",
    "Vaccination"
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatedButton(onTap: () {
        NextScreen(context, AddExpensesCategory());
      }),
      appBar: PreferredSize(
        child: GeneralAppBar(
          
          title: "Expenses Category",
        ),
        preferredSize: Size.fromHeight(50),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            addVerticalSpace(20),
            Divider(
              height: 0,
            ),
            ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: cat.length,
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 0,
                  );
                },
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      cat[index],
                      style: bodyText17w500(color: black),
                    ),
                  );
                }),
            Divider(
              height: 0,
            ),
          ],
        ),
      ),
    );
  }
}
