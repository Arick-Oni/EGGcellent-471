import 'package:flutter/material.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/generalappbar.dart';

class TermsandConditions extends StatefulWidget {
  const TermsandConditions({super.key});

  @override
  State<TermsandConditions> createState() => _TermsandConditionsState();
}

class _TermsandConditionsState extends State<TermsandConditions> {
  List terms = [
    {
      "title": "1. Acceptance of Terms:",
      "detail":
          "By accessing or using the  Happy Poultry Farm app, you agree to be legally bound by these Terms and Conditions. If you do not agree to these Terms and Conditions, you must not access or use the  Happy Poultry Farm app. "
    },
    {
      "title": "2. License:",
      "detail":
          "Happy Poultry Farm grants you a limited, non-exclusive, non-transferable license to use the  Happy Poultry Farm app. This license gives you the right to access and use the Happy Poultry Farm app for your personal, non-commercial purposes."
    },
    {
      "title": "3. User Content:",
      "detail":
          "You understand that any content that you post or submit to the  Happy Poultry Farm app may be viewed by other users. You are solely responsible for all the content that you post or submit to the  Happy Poultry Farm app and any consequences arising out of such content. You agree to not post or submit any content that is defamatory, offensive, pornographic, or otherwise inappropriate."
    },
    {
      "title": "4. Disclaimer:",
      "detail":
          "The Happy Poultry Farm app and all content and services provided on the app are provided on an “as is” basis.  Happy Poultry Farm does not warrant or guarantee the accuracy or completeness of any content or services provided on the app.  Happy Poultry Farm is not responsible for any errors or omissions in the content or services provided on the app."
    },
    {
      "title": "5. Limitation of Liability:",
      "detail":
          "Happy Poultry Farm is not liable for any direct, indirect, incidental, punitive, or consequential damages arising out of the use of the  Happy Poultry Farm app. This includes, but is not limited to, damages resulting from errors or omissions in the content or services provided on the app."
    },
    {
      "title": "6. Indemnification:",
      "detail":
          "You agree to indemnify and hold harmless  Happy Poultry Farm from and against all claims, damages, losses, and expenses (including legal fees) arising out of or related to your use of the  Happy Poultry Farm app."
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: GeneralAppBar(
          title: "Terms and Conditions",
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          terms[index]['title'],
                          style: bodyText10w600(color: black),
                        ),
                        addVerticalSpace(5),
                        Text(
                          terms[index]['detail'],
                          style: bodyText10normal(color: black),
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (context, index) {
                    return addVerticalSpace(15);
                  },
                  itemCount: 6)
            ],
          ),
        ),
      ),
    );
  }
}
