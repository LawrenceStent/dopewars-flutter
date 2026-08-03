import 'package:flutter/material.dart';

/// Responsive layout utilities for adapting UI to screen size.
class ResponsiveLayout {
  // Screen breakpoints
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 1024;
  static const double desktopMinWidth = 1025;

  // Padding scales
  static const double paddingXs = 4;
  static const double paddingSm = 8;
  static const double paddingMd = 16;
  static const double paddingLg = 24;
  static const double paddingXl = 32;

  /// Get responsive padding based on screen width.
  static double responsivePadding(
    BuildContext context, {
    double mobile = paddingMd,
    double tablet = paddingLg,
    double desktop = paddingXl,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileMaxWidth) return mobile;
    if (width < tabletMaxWidth) return tablet;
    return desktop;
  }

  /// Check if device is mobile.
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileMaxWidth;

  /// Check if device is tablet.
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileMaxWidth &&
      MediaQuery.of(context).size.width < tabletMaxWidth;

  /// Check if device is desktop.
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletMaxWidth;

  /// Get responsive max width for content containers.
  static double responsiveMaxWidth(
    BuildContext context, {
    double? override,
  }) {
    if (override != null) return override;

    final width = MediaQuery.of(context).size.width;
    if (width < mobileMaxWidth) return width - paddingMd * 2;
    if (width < tabletMaxWidth) return 600;
    return 900;
  }

  /// Get responsive font size based on screen width.
  static double responsiveFontSize(
    BuildContext context, {
    double mobile = 14,
    double tablet = 16,
    double desktop = 18,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileMaxWidth) return mobile;
    if (width < tabletMaxWidth) return tablet;
    return desktop;
  }

  /// Get responsive gap size for spacing between widgets.
  static double responsiveGap(
    BuildContext context, {
    double mobile = 8,
    double tablet = 12,
    double desktop = 16,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileMaxWidth) return mobile;
    if (width < tabletMaxWidth) return tablet;
    return desktop;
  }

  /// Get responsive icon size.
  static double responsiveIconSize(
    BuildContext context, {
    double mobile = 20,
    double tablet = 24,
    double desktop = 32,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileMaxWidth) return mobile;
    if (width < tabletMaxWidth) return tablet;
    return desktop;
  }

  /// Build a responsive column with automatic spacing.
  static Widget responsiveColumn({
    required BuildContext context,
    required List<Widget> children,
    bool shrinkWrap = true,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
  }) {
    final gap = responsiveGap(context);
    return Column(
      mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
      mainAxisAlignment: mainAxisAlignment,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1) SizedBox(height: gap),
        ],
      ],
    );
  }

  /// Build a responsive row with automatic spacing.
  static Widget responsiveRow({
    required BuildContext context,
    required List<Widget> children,
    bool shrinkWrap = true,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
  }) {
    final gap = responsiveGap(context);
    return Row(
      mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
      mainAxisAlignment: mainAxisAlignment,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1) SizedBox(width: gap),
        ],
      ],
    );
  }
}
