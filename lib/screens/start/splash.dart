import 'dart:async';
import 'package:flutter/material.dart';
import '../../Responsive_helper.dart';
import 'intropage.dart';
import '../../widgets/navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 4), () {
      NextScreenReplace(context, const IntroPage());
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveHelper.getDeviceType(context);

    // Set image size based on device
    double imageSize;
    switch (deviceType) {
      case DeviceScreenType.mobile:
        imageSize = ResponsiveHelper.widthPercentage(context, 50);
        break;
      case DeviceScreenType.tablet:
        imageSize = ResponsiveHelper.widthPercentage(context, 30);
        break;
      case DeviceScreenType.desktop:
        imageSize = ResponsiveHelper.widthPercentage(context, 15);
        break;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SizedBox(
          width: imageSize,
          height: imageSize,
          child: Image.asset(
            "assets/images/eggLogo.jpeg",
            fit: BoxFit.contain, // prevents stretching on desktop
          ),
        ),
      ),
    );
  }
}
