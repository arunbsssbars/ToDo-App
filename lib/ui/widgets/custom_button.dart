import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Pure builder function that creates a modern gradient / outlined button
Widget buildCustomButton({
  required BuildContext context,
  required String text,
  VoidCallback? onPressed,
  bool isLoading = false,
  IconData? icon,
  Color? backgroundColor,
  Color? textColor,
  bool isOutlined = false,
  double height = 52.0,
  double borderRadius = 14.0,
}) {
  Widget buildChild(Color color) {
    if (isLoading) {
      return SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  if (isOutlined) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: kPrimaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: buildChild(kPrimaryColor),
      ),
    );
  }

  return Container(
    height: height,
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: backgroundColor == null
          ? const LinearGradient(
              colors: [kPrimaryColor, kAccentColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: onPressed == null
          ? null
          : [
              BoxShadow(
                color: kPrimaryColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: isLoading ? null : onPressed,
        child: Center(
          child: buildChild(textColor ?? Colors.white),
        ),
      ),
    ),
  );
}

/// CustomButton widget adapter
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isOutlined;
  final double height;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.isOutlined = false,
    this.height = 52.0,
    this.borderRadius = 14.0,
  });

  @override
  Widget build(BuildContext context) => buildCustomButton(
        context: context,
        text: text,
        onPressed: onPressed,
        isLoading: isLoading,
        icon: icon,
        backgroundColor: backgroundColor,
        textColor: textColor,
        isOutlined: isOutlined,
        height: height,
        borderRadius: borderRadius,
      );
}
