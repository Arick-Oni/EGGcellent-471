import 'package:flutter/material.dart';
import 'package:poultry_app/screens/batches/addmortality.dart';
import 'package:poultry_app/screens/batches/addnotes.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/floatbutton.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/navigation.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatedButton(onTap: () {
        NextScreen(context, AddNotesPage());
      }),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: GeneralAppBar(
          
          title: 'Batch',
        ),
      ),
      body: Column(
        children: [
          addVerticalSpace(20),
          Column(
            children: [
              Text(
                "Notes",
                style: bodyText22w600(color: black),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                      height: 80,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "29/11/2022",
                            style: bodyText12normal(color: darkGray),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Title",
                                style: bodyText17w500(color: black),
                              ),
                              Icon(Icons.delete_outline_rounded)
                            ],
                          ),
                          Text(
                            "Lorem ipsum dolor sit......",
                            style: bodyText12normal(color: darkGray),
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
                  itemCount: 4),
              Divider(
                height: 0,
              ),
              addVerticalSpace(20)
            ],
          )
        ],
      ),
    );
  }
}
