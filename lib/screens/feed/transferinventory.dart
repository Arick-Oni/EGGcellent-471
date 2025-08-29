import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import 'package:poultry_app/widgets/customdropdown.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/quantitybutton.dart';
import 'package:poultry_app/widgets/stockin.dart';
import 'package:poultry_app/widgets/stockout.dart';

class TransferInventory extends StatefulWidget {
  const TransferInventory({super.key});

  @override
  State<TransferInventory> createState() => _TransferInventoryState();
}

class _TransferInventoryState extends State<TransferInventory> {
  bool stockin = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: GeneralAppBar(
          
          title: "Transfer Inventory",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            addVerticalSpace(20),
            Row(
              children: [
                Text(
                  "Stock In",
                  style: bodyText15w500(color: darkGray),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: FlutterSwitch(
                    padding: 3,
                    value: stockin,
                    inactiveColor: yellow,
                    activeColor: yellow,
                    onToggle: (value) {
                      setState(() {
                        stockin = value;
                      });
                    },
                    width: 50,
                    height: 25,
                    toggleSize: 20,
                  ),
                ),
                Text(
                  "Stock Out",
                  style: bodyText15w500(color: black),
                ),
              ],
            ),
            addVerticalSpace(20),
            stockin ? StockOutWidget() : StockInWidget()
          ],
        ),
      ),
    );
  }
}
