import 'package:flutter/material.dart';
import 'package:poultry_app/screens/feed/addorder.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import 'package:poultry_app/widgets/floatbutton.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/inventory.dart';
import 'package:poultry_app/widgets/navigation.dart';
import 'package:poultry_app/widgets/order.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  List<Widget> widgets = [InventoryWidget(), OrderWidget()];
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatedButton(onTap: () {
        NextScreen(context, AddOrderPage());
      }),
      appBar: PreferredSize(
        child: GeneralAppBar(
          
        ),
        preferredSize: Size.fromHeight(50),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: "Inventory",
                      radius: 10,
                      onClick: () {
                        setState(() {
                          index = 0;
                        });
                      },
                      buttonColor: index == 0 ? yellow : utbColor,
                      height: 40,
                      textStyle:
                          bodyText16w600(color: index == 0 ? white : darkGray),
                    ),
                  ),
                  addHorizontalySpace(15),
                  Expanded(
                    child: CustomButton(
                      radius: 10,
                      text: "Orders",
                      onClick: () {
                        setState(() {
                          index = 1;
                        });
                      },
                      height: 40,
                      buttonColor: index == 1 ? yellow : utbColor,
                      textStyle:
                          bodyText16w600(color: index == 1 ? white : darkGray),
                    ),
                  ),
                ],
              ),
            ),
            widgets[index]
          ],
        ),
      ),
    );
  }
}
