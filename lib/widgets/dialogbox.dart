import 'package:flutter/material.dart';
import 'package:poultry_app/screens/farmsettings/myads.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import '../Responsive_helper.dart';

class ShowDialogBox extends StatelessWidget {
  final String? message;
  final String? subMessage;
  final bool? isShowAds;

  const ShowDialogBox({
    super.key,
    this.message,
    this.subMessage,
    this.isShowAds,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final dialogWidth = isDesktop
        ? 400.0
        : MediaQuery.of(context).size.width * 0.85;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SingleChildScrollView(
        child: Container(
          width: dialogWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: isDesktop ? 20 : 10),
              Image.asset(
                "assets/images/verify.png",
                height: isDesktop ? 150 : 109,
                width: isDesktop ? 150 : 109,
                fit: BoxFit.fill,
              ),
              SizedBox(height: isDesktop ? 50 : 40),
              Text(
                message ?? "",
                style: TextStyle(
                  fontSize: isDesktop ? 28 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                ),
                textAlign: TextAlign.center,
              ),
              if (subMessage != null)
                Padding(
                  padding: EdgeInsets.only(
                    top: isDesktop ? 25 : 20,
                    bottom: isDesktop ? 40 : 35,
                  ),
                  child: Text(
                    subMessage ?? "",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : 16,
                      color: darkGray,
                      height: 1.5,
                    ),
                  ),
                )
              else
                Padding(
                  padding: EdgeInsets.only(top: isDesktop ? 25 : 20),
                  child: CustomButton(
                    text: "View Ad",
                    onClick: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => MyAds()),
                      );
                    },
                    width: isDesktop ? 250 : 200,
                    height: isDesktop ? 50 : 40,
                    textStyle: TextStyle(
                      fontSize: isDesktop ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
