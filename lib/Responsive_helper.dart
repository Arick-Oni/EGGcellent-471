import 'package:flutter/material.dart';

enum DeviceScreenType { mobile, tablet, desktop }

class ResponsiveHelper {
  // Breakpoints
  static const int mobileMaxWidth = 600;
  static const int tabletMaxWidth = 1024;

  // Determine device type
  static DeviceScreenType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= mobileMaxWidth) {
      return DeviceScreenType.mobile;
    } else if (width <= tabletMaxWidth) {
      return DeviceScreenType.tablet;
    } else {
      return DeviceScreenType.desktop;
    }
  }

  // Check helpers
  static bool isMobile(BuildContext context) =>
      getDeviceType(context) == DeviceScreenType.mobile;

  static bool isTablet(BuildContext context) =>
      getDeviceType(context) == DeviceScreenType.tablet;

  static bool isDesktop(BuildContext context) =>
      getDeviceType(context) == DeviceScreenType.desktop;

  // Get width percentage
  static double widthPercentage(BuildContext context, double percent) =>
      MediaQuery.of(context).size.width * percent / 100;

  // Get height percentage
  static double heightPercentage(BuildContext context, double percent) =>
      MediaQuery.of(context).size.height * percent / 100;

  // Padding helpers
  static EdgeInsets paddingAll(double value) => EdgeInsets.all(value);

  static EdgeInsets paddingSymmetric({double vertical = 0, double horizontal = 0}) =>
      EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal);

  static EdgeInsets paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);

  // Responsive widget wrapper
  static Widget responsiveLayout({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceScreenType.mobile:
        return mobile;
      case DeviceScreenType.tablet:
        return tablet ?? mobile;
      case DeviceScreenType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}
