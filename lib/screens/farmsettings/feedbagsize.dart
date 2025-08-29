import 'package:flutter/material.dart';
import 'package:poultry_app/screens/farmsettings/addfeedbag.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/floatbutton.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/navigation.dart';

class FeedBagSizePage extends StatelessWidget {
  const FeedBagSizePage({super.key});

  @override
  Widget build(BuildContext context) {
    List cat = [
      "50 kg",
      "40 kg",
      "30 kg",
    ];
    return Scaffold(
      floatingActionButton: FloatedButton(onTap: () {
        NextScreen(context, AddFeedBagSize());
      }),
      appBar: PreferredSize(
        child: GeneralAppBar(
          
          title: "Feed Bag Size",
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
