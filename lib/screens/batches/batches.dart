import 'package:flutter/material.dart';
import 'package:poultry_app/screens/batches/batchrecord.dart';
import 'package:poultry_app/screens/batches/newbatch.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import 'package:poultry_app/widgets/floatbutton.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/navigation.dart';

class BatchPage extends StatefulWidget {
  const BatchPage({super.key});

  @override
  State<BatchPage> createState() => _BatchPageState();
}

class _BatchPageState extends State<BatchPage> with TickerProviderStateMixin {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    final TabController _tabController = TabController(length: 2, vsync: this);

    return Scaffold(
      floatingActionButton: FloatedButton(onTap: () {
        NextScreen(
            context,
            NewBatch(
              title: 'New Batch',
            ));
      }),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: GeneralAppBar(
          
          title: "Batches",
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Expanded(
                      child: CustomButton(
                          buttonColor: index == 0 ? yellow : normalGray,
                          textStyle: bodyText16w600(
                              color: index == 0 ? white : darkGray),
                          text: "Active Batch",
                          onClick: () {
                            setState(() {
                              index = 0;
                            });
                          },
                          width: width(context) * .35,
                          height: 40)),
                  addHorizontalySpace(15),
                  Expanded(
                      child: CustomButton(
                          buttonColor: index == 1 ? yellow : normalGray,
                          text: "Closed Batch",
                          textStyle: bodyText16w600(
                              color: index == 1 ? white : darkGray),
                          onClick: () {
                            setState(() {
                              index = 1;
                            });
                          },
                          width: width(context) * .35,
                          height: 40)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 70),
              child: Text(
                "Total Batches: 5",
                style: bodyText18w400(color: darkGray),
              ),
            ),
            addVerticalSpace(10),
            Divider(),
            ListView.separated(
                separatorBuilder: (context, index) {
                  return Divider();
                },
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      NextScreen(context, BatchRecordPage());
                    },
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: yellow,
                      child: Image.asset("assets/images/henI.png"),
                    ),
                    title: Text(
                      "Batch Name",
                      style: bodyText16w500(color: black),
                    ),
                    subtitle: Text(
                      "6 Weeks : 5 Days",
                      style: bodyText12normal(color: darkGray),
                    ),
                  );
                }),
            Divider()
          ],
        ),
      ),
    );
  }
}
