import 'package:flutter/material.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/searchbox.dart';

class CurrencyPage extends StatefulWidget {
  const CurrencyPage({super.key});

  @override
  State<CurrencyPage> createState() => _CurrencyPageState();
}

class _CurrencyPageState extends State<CurrencyPage> {
  List currency = [
    {"currency": "INR"},
    {"currency": "USD"},
    {"currency": "AFN"},
    {"currency": "DZD"},
    {"currency": "EUR"},
    {"currency": "AUD"},
    {"currency": "CAD"},
    {"currency": "EGP"},
    {"currency": "ILS"},
  ];
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: GeneralAppBar(
          
          title: "Currency",
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
                hint: "Search Currency",
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Current',
                style: bodyText14Bold(color: black.withOpacity(0.3)),
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
                                currentIndex == index;
                              });
                            },
                            leading: Image.asset("assets/images/flag.png"),
                            title: Text(
                              currency[index]['currency'],
                              style: bodyText16w500(color: black),
                            ),
                            trailing: currentIndex == index
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
                itemCount: currency.length),
            Divider(
              height: 0,
            )
          ],
        ),
      ),
    );
  }
}
