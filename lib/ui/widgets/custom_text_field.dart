import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Pure builder function that creates a styled text form field
Widget buildCustomTextField({
  required BuildContext context,
  required TextEditingController controller,
  required String label,
  String? hint,
  IconData? prefixIcon,
  Widget? suffixIcon,
  bool obscureText = false,
  TextInputType keyboardType = TextInputType.text,
  String? Function(String?)? validator,
  int maxLines = 1,
  void Function(String)? onChanged,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? kDarkTextSecondary : kLightTextSecondary,
        ),
      ),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 15,
          color: isDark ? kDarkTextPrimary : kLightTextPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: isDark ? kDarkTextMuted : kLightTextMuted,
            fontSize: 14,
          ),
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  size: 20,
                  color: isDark ? kDarkTextSecondary : kLightTextSecondary,
                )
              : null,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: isDark ? kDarkBorderColor : kLightBorderColor,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: isDark ? kDarkBorderColor : kLightBorderColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: kPrimaryColor,
              width: 2,
            ),
          ),
        ),
      ),
    ],
  );
}

/// CustomTextField widget adapter
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => buildCustomTextField(
        context: context,
        controller: controller,
        label: label,
        hint: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        onChanged: onChanged,
      );
}
