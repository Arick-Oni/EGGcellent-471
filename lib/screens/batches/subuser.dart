import 'package:flutter/material.dart';
import 'package:poultry_app/screens/batches/addsubuser.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/floatbutton.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/navigation.dart';

class SubUserPage extends StatelessWidget {
  const SubUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatedButton(
        onTap: () {
          NextScreen(context, AddSubUserPage());
        },
      ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: GeneralAppBar(
            
          title: 'Batch',
        ),
      ),
      body: Column(
        children: [
          addVerticalSpace(20),
          Text(
            "Sub User",
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
                return ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: transparent,
                    backgroundImage: AssetImage("assets/images/adduser.png"),
                  ),
                  title: Text(
                    "Subhash Kale",
                    style: bodyText16w500(color: black),
                  ),
                  subtitle: Text("Can View"),
                  trailing: Image.asset("assets/images/delete.png"),
                );
              },
              separatorBuilder: (context, index) {
                return Divider(
                  height: 0,
                );
              },
              itemCount: 6),
          Divider(
            height: 0,
          ),
          addVerticalSpace(20)
        ],
      ),
    );
  }
}
