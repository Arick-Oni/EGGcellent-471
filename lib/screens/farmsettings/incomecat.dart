import 'package:flutter/material.dart';
import 'package:poultry_app/screens/farmsettings/addincomecat.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/floatbutton.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/navigation.dart';

class IncomeCategoryPage extends StatelessWidget {
  const IncomeCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatedButton(onTap: () {
        NextScreen(context, AddIncomeCategory());
      }),
      appBar: PreferredSize(
        child: GeneralAppBar(
          
          title: "Income Category",
        ),
        preferredSize: Size.fromHeight(50),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            addVerticalSpace(15),
            Divider(
              height: 0,
            ),
            ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 8,
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 0,
                  );
                },
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      "Lorem Ipsum",
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
