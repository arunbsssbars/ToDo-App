import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Pure builder function that creates a modern Stitch-styled card
Widget buildStitchCard({
  required BuildContext context,
  required Widget child,
  EdgeInsetsGeometry? padding,
  EdgeInsetsGeometry? margin,
  VoidCallback? onTap,
  Color? backgroundColor,
  Border? border,
  double borderRadius = 20.0,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final defaultBg = isDark ? kDarkCardColor : kLightCardColor;
  final defaultBorder = Border.all(
    color: isDark ? kDarkBorderColor : kLightBorderColor,
    width: 1.2,
  );

  return Container(
    margin: margin ?? const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
    decoration: BoxDecoration(
      color: backgroundColor ?? defaultBg,
      borderRadius: BorderRadius.circular(borderRadius),
      border: border ?? defaultBorder,
      boxShadow: isDark ? getDarkShadows() : getLightShadows(),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    ),
  );
}

/// StitchCard widget adapter
class StitchCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Border? border;
  final double borderRadius;

  const StitchCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.border,
    this.borderRadius = 20.0,
  });

  @override
  Widget build(BuildContext context) => buildStitchCard(
        context: context,
        child: child,
        padding: padding,
        margin: margin,
        onTap: onTap,
        backgroundColor: backgroundColor,
        border: border,
        borderRadius: borderRadius,
      );
}
