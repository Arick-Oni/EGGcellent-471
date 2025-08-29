import 'package:flutter/material.dart';
import 'package:poultry_app/screens/farmsettings/addcustomer.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/floatbutton.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/navigation.dart';

class CustomerListPage extends StatelessWidget {
  const CustomerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    List cat = [
      {"name": "Subhash Mane", "mo": "+91-9355548313"},
      {"name": "Himanshu Bains", "mo": "+91-9355548313"},
      {"name": "Subhash Mane", "mo": "+91-9355548313"},
      {"name": "Subhash Mane", "mo": "+91-9355548313"},
    ];
    return Scaffold(
      floatingActionButton: FloatedButton(onTap: () {
        NextScreen(context, AddCustomer());
      }),
      appBar: PreferredSize(
        child: GeneralAppBar(
          
          title: "Customer List",
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
                itemCount: cat.length,
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 0,
                  );
                },
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      cat[index]['name'],
                      style: bodyText17w500(color: black),
                    ),
                    trailing: Text(
                      cat[index]['mo'],
                      style: bodyText12normal(color: black),
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
