import 'package:flutter/material.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/customdropdown.dart';
import 'package:poultry_app/widgets/navigation.dart';
import 'package:poultry_app/widgets/tablecal.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class OrderWidget extends StatefulWidget {
  const OrderWidget({super.key});

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  List list = ["lorem", "lorem", "lorem", "lorem"];
  String currentDate = DateFormat('dd/MMM/yyyy').format(DateTime.now());
  String hint = "Select Date";
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        decoration:
                            shadowDecoration(6, 0, white, bcolor: darkGray),
                        width: 36,
                        height: 30,
                        child: Image.asset(
                          "assets/images/filter.png",
                        ),
                      ),
                      addHorizontalySpace(10),
                      InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) => showCalDialog());
                        },
                        child: CustomDropdown(
                          icon: true,
                          hp: 5,
                          radius: 6,
                          bcolor: darkGray,
                          width: width(context) * .35,
                          list: [],
                          height: 30,
                          iconSize: 12,
                          hint: hint,
                          textStyle: bodyText12w600(color: darkGray),
                        ),
                      ),
                      addHorizontalySpace(5),
                      CustomDropdown(
                        hp: 5,
                        radius: 6,
                        bcolor: darkGray,
                        width: width(context) * .3,
                        list: list,
                        height: 30,
                        iconSize: 12,
                        hint: "Feed Type",
                        textStyle: bodyText12w600(color: darkGray),
                      )
                    ],
                  ),
                  addVerticalSpace(20),
                  Container(
                    height: 85,
                    decoration:
                        shadowDecoration(10, 4, white, offset: Offset(2, 2)),
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Feed Order Value",
                              style: bodyText12w500(color: black),
                            ),
                            Text(
                              "-10,56,180",
                              style: bodyText12w500(color: black),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Order Bags Quantity",
                              style: bodyText12w500(color: black),
                            ),
                            Text(
                              "0",
                              style: bodyText12w600(color: green),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            addVerticalSpace(25),
            Divider(
              height: 0,
            ),
            ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    height: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Order No. 123",
                          style: bodyText10w600(color: yellow),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Feed Type",
                              style: bodyText15w500(color: black),
                            ),
                            Text(
                              "3,000",
                              style: bodyText18w600(color: black),
                            ),
                          ],
                        ),
                        Text(
                          "Quantity",
                          style: bodyText12w500(color: darkGray),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "23rd Decemeber 2022",
                              style: bodyText12w500(color: darkGray),
                            ),
                            Text(
                              "Order Status: Not Received",
                              style: bodyText12w500(color: darkGray),
                            ),
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
                itemCount: 8)
          ],
        )
      ],
    );
  }

  Widget showCalDialog() {
    return AlertDialog(
      insetPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: Container(
        height: 300,
        width: 275,
        child: TableCalendar(
          calendarStyle: CalendarStyle(
            canMarkersOverflow: true,
          ),
          startingDayOfWeek: StartingDayOfWeek.monday,
          daysOfWeekHeight: 35,
          headerStyle: const HeaderStyle(
              titleTextStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w400),
              formatButtonVisible: false,
              titleCentered: true),
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: DateTime.now(),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              currentDate = DateFormat('dd/MMM/yyyy').format(selectedDay);
              hint = currentDate.toLowerCase();
              goBack(context);
            });
          },
          // selectedDayPredicate: (day) {
          //   return isSameDay(dateTime, day);
          // },
          calendarFormat: CalendarFormat.month,
          rowHeight: 40,
        ),
      ),
      // actions: [
      //   ElevatedButton(
      //       style: ElevatedButton.styleFrom(
      //           minimumSize: Size(80, 35),
      //           backgroundColor: Color.fromARGB(255, 237, 241, 245),
      //           shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.circular(10))),
      //       onPressed: () {},
      //       child: Text(
      //         "Clear",
      //         style: bodyText16normal(color: black),
      //       )),
      //   Padding(
      //     padding: const EdgeInsets.only(left: 10, right: 5),
      //     child: ElevatedButton(
      //         style: ElevatedButton.styleFrom(
      //             minimumSize: Size(90, 40),
      //             shape: RoundedRectangleBorder(
      //                 borderRadius: BorderRadius.circular(10))),
      //         onPressed: () {},
      //         child: Text(
      //           "Apply",
      //           style: bodyText16normal(color: white),
      //         )),
      //   ),
      // ],
    );
  }
}
