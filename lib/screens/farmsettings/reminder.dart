import 'package:flutter/material.dart';
import 'package:poultry_app/screens/farmsettings/addreminder.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/floatbutton.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/navigation.dart';

class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatedButton(onTap: () {
        NextScreen(context, AddReminder());
      }),
      appBar: PreferredSize(
        child: GeneralAppBar(
          
          title: "Reminders",
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
                itemCount: 4,
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 0,
                  );
                },
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                    height: 100,
                    child: Row(
                      children: [
                        Container(
                            width: 65,
                            child: Image.asset("assets/images/noti.png")),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Reminder Title",
                                style: bodyText14w500(color: black),
                              ),
                              Text(
                                "Lorem ipsum dolor sit amet consectetur. Arcu sit vel erat ullamcorper molestie parturient.",
                                style: bodyText10normal(color: black),
                              ),
                              Text(
                                "21/12/2022 at 3:58pm",
                                style: bodyText12normal(color: darkGray),
                              )
                            ],
                          ),
                        )
                      ],
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
