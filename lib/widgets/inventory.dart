import 'package:flutter/material.dart';
import 'package:poultry_app/screens/feed/addinventory.dart';
import 'package:poultry_app/screens/feed/transferinventory.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/navigation.dart';
import 'package:poultry_app/widgets/searchbox.dart';

class InventoryWidget extends StatelessWidget {
  const InventoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        addVerticalSpace(15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: white,
                        minimumSize: Size(width(context), 45),
                        shape: RoundedRectangleBorder(
                            side: BorderSide(),
                            borderRadius: BorderRadius.circular(10))),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/addcircle.png",
                          height: 22,
                        ),
                        addHorizontalySpace(20),
                        Text(
                          "Add",
                          style: bodyText16w500(color: black),
                        )
                      ],
                    ),
                    onPressed: () {
                      NextScreen(context, AddInventoryPage());
                    },
                  )),
                  addHorizontalySpace(15),
                  Expanded(
                      child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: white,
                        minimumSize: Size(width(context), 45),
                        shape: RoundedRectangleBorder(
                            side: BorderSide(),
                            borderRadius: BorderRadius.circular(10))),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/restore.png",
                          height: 22,
                        ),
                        addHorizontalySpace(20),
                        Text(
                          "Transfer",
                          style: bodyText16w500(color: black),
                        )
                      ],
                    ),
                    onPressed: () {
                      NextScreen(context, TransferInventory());
                    },
                  ))
                ],
              ),
              addVerticalSpace(25),
              CustomSearchBox(),
            ],
          ),
        ),
        addVerticalSpace(20),
        Divider(
          height: 0,
        ),
        ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Pre Starter",
                          style: bodyText15w500(color: black),
                        ),
                        Text(
                          "Baramati",
                          style: bodyText12normal(color: darkGray),
                        ),
                        Text(
                          "Quantity: 50 bags",
                          style: bodyText12normal(color: black),
                        ),
                        Text(
                          "Bag Location: Stock Room",
                          style: bodyText12normal(color: black),
                        )
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Image.asset("assets/images/tpad.png"),
                            ),
                            Image.asset("assets/images/editI.png")
                          ],
                        ),
                        Text(
                          "Order No.: 125",
                          style: bodyText12normal(color: black),
                        ),
                        Text(
                          "Price: 1600/bag",
                          style: bodyText12normal(color: black),
                        )
                      ],
                    )
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) {
              return Divider(
                height: 0,
              );
            },
            itemCount: 6)
      ],
    );
  }
}
