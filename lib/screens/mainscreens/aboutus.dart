import 'package:flutter/material.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/generalappbar.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: GeneralAppBar(
          title: "About Us",
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              addVerticalSpace(35),
              Image.asset(
                "assets/images/logo.png",
                width: 162,
                height: 162,
              ),
              addVerticalSpace(20),
              Text(
                "Happy Poultry Farm",
                style: bodyText16Bold(color: black),
              ),
              addVerticalSpace(20),
              Text(
                "Welcome to Happy Poultry Farm! We are a user-friendly, modern farming app helping farmers, growers, and agricultural professionals to easily access the latest farming information and resources they need. We offer a comprehensive suite of tools and resources to simplify your farming operations.",
                style: bodyText12normal(color: black),
              ),
              addVerticalSpace(20),
              Text(
                "Our app provides access to detailed weather data, crop growth charts, soil analysis reports, financial calculators, and more. Our focus is on being the best source of reliable and up-to-date information on the latest farming trends. We understand the unique needs of farmers and growers, and strive to make their lives easier through our app. We also provide access to a community of like-minded people who are passionate about farming and agriculture.",
                style: bodyText12normal(color: black),
              ),
              addVerticalSpace(20),
              Text(
                "Our users can connect with each other for advice, support, and to exchange industry-specific information. We hope you find Happy Poultry Farm to be a helpful and useful tool in managing your farming operations.",
                style: bodyText12normal(color: black),
              )
            ],
          ),
        ),
      ),
    );
  }
}
