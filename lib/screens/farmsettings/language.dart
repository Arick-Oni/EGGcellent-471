import 'package:flutter/material.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/searchbox.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  List language = [
    {"language": "English"},
    {"language": "Germany"},
    {"language": "French"},
    {"language": "Spanish"},
    {"language": "Arabic"},
    {"language": "Japanese"},
    {"language": "Italian"},
    {"language": "Korean"},
    {"language": "Russian"},
  ];
  int value = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: GeneralAppBar(
          
          title: "Language",
        ),
        preferredSize: Size.fromHeight(50),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: CustomSearchBox(
                hint: "Search Language",
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, top: 10),
              child: Text(
                "Current",
                style: bodyText17w500(color: darkGray),
              ),
            ),
            Divider(
              height: 0,
            ),
            ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 60,
                        child: Center(
                          child: ListTile(
                            onLongPress: () {
                              setState(() {
                                value == index;
                              });
                            },
                            leading: Image.asset("assets/images/flag.png"),
                            title: Text(
                              language[index]['language'],
                              style: bodyText16w500(color: black),
                            ),
                            trailing: value == index
                                ? Icon(
                                    Icons.check_circle_outline_outlined,
                                    color: black,
                                  )
                                : SizedBox(),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 0,
                  );
                },
                itemCount: language.length),
            Divider(
              height: 0,
            )
          ],
        ),
      ),
    );
  }
}
