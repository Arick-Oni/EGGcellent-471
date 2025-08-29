import 'package:flutter/material.dart';
import '../../Responsive_helper.dart';
import 'package:poultry_app/choose_role_page.dart';
import 'package:poultry_app/screens/auth/login.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/navigation.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController();
    int logIndex = 2;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: ResponsiveHelper.heightPercentage(context, 100),
            child: PageView(
              controller: pageController,
              onPageChanged: (i) {
                setState(() {
                  if (logIndex == i) {
                    NextScreenReplace(context, const ChooseRolePage());
                  }
                });
              },
              children: const [
                PageViewItemWidget(assetUrl: 'assets/images/intro1.png'),
                PageViewItemWidget(assetUrl: 'assets/images/intro2.png'),
                ChooseRolePage()
              ],
            ),
          ),
          Positioned(
            right: ResponsiveHelper.widthPercentage(context, 5),
            bottom: ResponsiveHelper.heightPercentage(context, 2.5),
            child: InkWell(
              onTap: () {
                pageController.nextPage(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut);
              },
              child: CircleAvatar(
                radius: ResponsiveHelper.isMobile(context) ? 28 : 38,
                backgroundColor: yellow,
                child: CircleAvatar(
                  radius: ResponsiveHelper.isMobile(context) ? 26 : 36,
                  backgroundColor: white,
                  child: CircleAvatar(
                    radius: ResponsiveHelper.isMobile(context) ? 21 : 29,
                    backgroundColor: yellow,
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.black,
                      size: ResponsiveHelper.isMobile(context) ? 18 : 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PageViewItemWidget extends StatelessWidget {
  final String assetUrl;

  const PageViewItemWidget({
    Key? key,
    required this.assetUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double imageHeight;
    double imageWidth;

    if (ResponsiveHelper.isMobile(context)) {
      imageHeight = ResponsiveHelper.heightPercentage(context, 50);
      imageWidth = ResponsiveHelper.widthPercentage(context, 90);
    } else if (ResponsiveHelper.isTablet(context)) {
      imageHeight = ResponsiveHelper.heightPercentage(context, 60);
      imageWidth = ResponsiveHelper.widthPercentage(context, 70);
    } else {
      // Desktop
      imageHeight = ResponsiveHelper.heightPercentage(context, 65);
      imageWidth = ResponsiveHelper.widthPercentage(context, 50);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            height: imageHeight,
            width: imageWidth,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(assetUrl),
                fit: BoxFit.contain, // fixes stretching
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              left: ResponsiveHelper.widthPercentage(context, 8)),
          child: SizedBox(
            height: ResponsiveHelper.heightPercentage(context, 12),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    height: ResponsiveHelper.heightPercentage(context, 1),
                    width: ResponsiveHelper.widthPercentage(context, 25),
                    color: yellow,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Farming Enhanced",
                      style: bodyText24w400(color: yellow),
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.heightPercentage(context, 0.5)),
                    Text(
                      "Your Personal Helping Companion",
                      style: bodyText24w600(color: yellow),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
