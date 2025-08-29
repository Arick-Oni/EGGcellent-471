import 'package:flutter/material.dart';
import 'package:poultry_app/screens/profile/editprofile.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/customdropdown.dart';
import 'package:poultry_app/widgets/customtextfield.dart';
import 'package:poultry_app/widgets/navigation.dart';

class UserDataWidget extends StatefulWidget {
  const UserDataWidget({super.key});

  @override
  State<UserDataWidget> createState() => _UserDataWidgetState();
}

class _UserDataWidgetState extends State<UserDataWidget> {
  List list = ["Broiler", "Deshi", "Layer", "Breeder Farm"];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        addVerticalSpace(10),
        Container(
          height: 80,
          width: 85,
          child: Stack(
            children: [
              CircleAvatar(
                backgroundColor: white,
                radius: 40,
                backgroundImage: AssetImage("assets/images/profile.png"),
              ),
              Align(
                  alignment: AlignmentDirectional.bottomEnd,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: GestureDetector(
                      onTap: () {
                        NextScreen(context, EditProfilePage());
                      },
                      child: CircleAvatar(
                          backgroundColor: yellow,
                          radius: 14,
                          child: Icon(
                            Icons.edit,
                            size: 17,
                            color: white,
                          )),
                    ),
                  ))
            ],
          ),
        ),
        addVerticalSpace(10),
        CustomTextField(hintText: "Name"),
        CustomTextField(hintText: "Email"),
        CustomTextField(hintText: "Farm Name"),
        Row(
          children: [
            Expanded(child: CustomTextField(hintText: "Country")),
            addHorizontalySpace(20),
            Expanded(child: CustomTextField(hintText: "State")),
          ],
        ),
        Row(
          children: [
            Expanded(
                child: CustomTextField(
              hintText: "City",
            )),
            addHorizontalySpace(20),
            Expanded(
                child: CustomTextField(
              hintText: "Village",
            )),
          ],
        ),
        CustomTextField(hintText: "Farm Capacity"),
        CustomDropdown(list: list, height: 58, hint: "Farm")
      ],
    );
  }
}
