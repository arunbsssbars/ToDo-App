import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Pure builder function that creates an interactive Category Chip
Widget buildCategoryChip({
  required BuildContext context,
  required String label,
  bool isSelected = false,
  VoidCallback? onSelected,
  IconData? icon,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final categoryColor = getCategoryColor(label);

  return InkWell(
    borderRadius: BorderRadius.circular(20),
    onTap: onSelected,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? kPrimaryColor
            : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? kPrimaryColor
              : (isDark ? kDarkBorderColor : kLightBorderColor),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != 'All') ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : categoryColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ] else if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? Colors.white
                  : (isDark ? kDarkTextSecondary : kLightTextSecondary),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : (isDark ? kDarkTextPrimary : kLightTextPrimary),
            ),
          ),
        ],
      ),
    ),
  );
}

/// CategoryChip widget adapter
class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onSelected;
  final IconData? icon;

  const CategoryChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onSelected,
    this.icon,
  });

  @override
  Widget build(BuildContext context) => buildCategoryChip(
        context: context,
        label: label,
        isSelected: isSelected,
        onSelected: onSelected,
        icon: icon,
      );
}
