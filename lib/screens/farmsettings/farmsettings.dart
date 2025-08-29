import 'package:flutter/material.dart';
import 'package:poultry_app/screens/farmsettings/chickfeedreq.dart';
import 'package:poultry_app/screens/farmsettings/currency.dart';
import 'package:poultry_app/screens/farmsettings/customerlist.dart';
import 'package:poultry_app/screens/farmsettings/eggtraysize.dart';
import 'package:poultry_app/screens/farmsettings/expensescat.dart';
import 'package:poultry_app/screens/farmsettings/feedbagsize.dart';
import 'package:poultry_app/screens/farmsettings/feedtype.dart';
import 'package:poultry_app/screens/farmsettings/incomecat.dart';
import 'package:poultry_app/screens/farmsettings/language.dart';
import 'package:poultry_app/screens/farmsettings/myads.dart';
import 'package:poultry_app/screens/farmsettings/reminder.dart';
import 'package:poultry_app/screens/farmsettings/report.dart';
import 'package:poultry_app/screens/farmsettings/userinfo.dart';
import 'package:poultry_app/screens/farmsettings/vaccinationschedule.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/records.dart';

class FarmSettingsPage extends StatefulWidget {
  const FarmSettingsPage({super.key});

  @override
  State<FarmSettingsPage> createState() => _FarmSettingsPageState();
}

class _FarmSettingsPageState extends State<FarmSettingsPage> {
  List<dynamic> record = [
    {
      "lead": "assets/images/user.png",
      "text": "User Information",
      "screen": UserInformationPage()
    },
    {
      "lead": "assets/images/income.png",
      "text": "income",
      "screen": IncomeCategoryPage()
    },
    {
      "lead": "assets/images/expense.png",
      "text": "Expenses",
      "screen": ExpensesCategoryPage()
    },
    {
      "lead": "assets/images/feedreq.png",
      "text": "Chick Feed Requirement",
      "screen": ChickFeedRequirementPage()
    },
    {
      "lead": "assets/images/feed.png",
      "text": "Feed Type",
      "screen": FeedType()
    },
    {
      "lead": "assets/images/feedbag.png",
      "text": "Feed Bag Size",
      "screen": FeedBagSizePage()
    },
    {
      "lead": "assets/images/vaccine.png",
      "text": "Vaccination Schedule",
      "screen": VaccinationSchedulePage()
    },
    {
      "lead": "assets/images/eggtrau.png",
      "text": "Egg Tray Size",
      "screen": EggTraySize()
    },
    {
      "lead": "assets/images/remind.png",
      "text": "Reminders",
      "screen": RemindersPage()
    },
    {"lead": "assets/images/ads.png", "text": "My Ads", "screen": MyAds()},
    {
      "lead": "assets/images/list.png",
      "text": "Customer List",
      "screen": CustomerListPage()
    },
    {
      "lead": "assets/images/rs.png",
      "text": "Currency",
      "screen": CurrencyPage()
    },
    {
      "lead": "assets/images/lang.png",
      "text": "Language",
      "screen": LanguagePage()
    },
    {
      "lead": "assets/images/report.png",
      "text": "Report",
      "screen": ReportsPage()
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: GeneralAppBar(
        
        ),
        preferredSize: Size.fromHeight(50),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text(
                "Farm Settings",
                style: bodyText18w500(color: black),
              ),
            ),
            addVerticalSpace(20),
            Divider(
              height: 0,
            ),
            RecordsWidget(record: record),
            Divider(
              height: 0,
            ),
            addVerticalSpace(20)
          ],
        ),
      ),
    );
  }
}
