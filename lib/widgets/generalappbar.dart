import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:poultry_app/choose_role_page.dart';
import 'package:poultry_app/screens/profile/showProfile.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import '../Responsive_helper.dart';
import '../screens/profile/farmerProfileshow.dart';
import '../utils/constants.dart';
import 'navigation.dart';

class GeneralAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;

  const GeneralAppBar({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: transparent,
      foregroundColor: Colors.yellowAccent,
      elevation: 0,
      title: Text(
        title ?? '',
        style: bodyText18w500(color: Colors.yellowAccent),
      ),
      actions: [
        PopupMenuButton<int>(
          offset: const Offset(0.0, 50),
          padding: EdgeInsets.zero,
          iconSize: 25,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          itemBuilder: (context) => [
            PopupMenuItem(
              height: 40,
              value: 1,
              child: Text(
                "Profile",
                style: bodyText14normal(color: Colors.cyanAccent),
              ),
            ),
            PopupMenuItem(
              height: 40,
              value: 2,
              child: Text(
                "Logout",
                style: bodyText14normal(color: Colors.cyanAccent),
              ),
            ),
          ],
          onSelected: (value) async {
            switch (value) {
              case 1:
              // Determine user type and open the correct profile page
                final uid = FirebaseAuth.instance.currentUser!.uid;

                final farmerDoc = await FirebaseFirestore.instance
                    .collection('farmers')
                    .doc(uid)
                    .get();

                if (farmerDoc.exists) {
                  NextScreen(context, const FarmerProfilePage());
                } else {
                  NextScreen(context, const ProfileDetailsPage());
                }
                break;

              case 2:
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => logoutDialog(context),
                );
                break;
            }
          },
        ),
      ],
    );
  }

  /// Logout Dialog
  logoutDialog(BuildContext context) {
    final theme = Theme.of(context);
    final dialogWidth = ResponsiveHelper.isDesktop(context)
        ? 400.0
        : ResponsiveHelper.widthPercentage(context, 90);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: Container(
          width: dialogWidth,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "assets/images/logout.png",
                width: dialogWidth * 0.4,
                height: dialogWidth * 0.4,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              Text(
                "Are you sure you want to logout?",
                style: TextStyle(
                  fontSize: ResponsiveHelper.isDesktop(context) ? 18 : 16,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onBackground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      buttonColor: theme.colorScheme.surface,
                      text: "Cancel",
                      textStyle: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize:
                        ResponsiveHelper.isDesktop(context) ? 16 : 14,
                      ),
                      onClick: () => Navigator.pop(context),
                      radius: 10,
                      height: 45,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      buttonColor: Colors.redAccent,
                      text: "Logout",
                      textStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize:
                        ResponsiveHelper.isDesktop(context) ? 16 : 14,
                      ),
                      onClick: () {
                        Navigator.pop(context);
                        NextScreenReplace(context, ChooseRolePage());
                      },
                      radius: 10,
                      height: 45,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
