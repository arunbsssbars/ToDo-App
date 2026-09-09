import 'package:flutter/material.dart';

// Top-level Color Constants
const Color kPrimaryColor = Color(0xFF6366F1); // Indigo
const Color kPrimary = kPrimaryColor;
const Color kPrimaryLightColor = Color(0xFF818CF8);
const Color kPrimaryLight = kPrimaryLightColor;
const Color kPrimaryDarkColor = Color(0xFF4F46E5);
const Color kPrimaryDark = kPrimaryDarkColor;
const Color kAccentColor = Color(0xFF8B5CF6); // Purple/Violet
const Color kAccent = kAccentColor;

const Color kSecondaryColor = Color(0xFF06B6D4); // Cyan
const Color kSecondary = kSecondaryColor;
const Color kSuccessColor = Color(0xFF10B981); // Emerald Green
const Color kSuccess = kSuccessColor;
const Color kWarningColor = Color(0xFFF59E0B); // Amber
const Color kWarning = kWarningColor;
const Color kErrorColor = Color(0xFFEF4444); // Rose Red
const Color kError = kErrorColor;
const Color kInfoColor = Color(0xFF3B82F6); // Blue
const Color kInfo = kInfoColor;

// Priority Colors
const Color kPriorityLowColor = Color(0xFF10B981); // Green
const Color kPriorityLow = kPriorityLowColor;
const Color kPriorityMediumColor = Color(0xFFF59E0B); // Orange
const Color kPriorityMedium = kPriorityMediumColor;
const Color kPriorityHighColor = Color(0xFFEF4444); // Red
const Color kPriorityHigh = kPriorityHighColor;

// Category Colors
const Color kCategoryWorkColor = Color(0xFF3B82F6);
const Color kCategoryWork = kCategoryWorkColor;
const Color kCategoryPersonalColor = Color(0xFF8B5CF6);
const Color kCategoryPersonal = kCategoryPersonalColor;
const Color kCategoryStudyColor = Color(0xFFEC4899);
const Color kCategoryStudy = kCategoryStudyColor;
const Color kCategoryUrgentColor = Color(0xFFEF4444);
const Color kCategoryUrgent = kCategoryUrgentColor;
const Color kCategoryOtherColor = Color(0xFF64748B);
const Color kCategoryOther = kCategoryOtherColor;

// Light Theme Surfaces
const Color kLightBackgroundColor = Color(0xFFF8FAFC);
const Color kLightBackground = kLightBackgroundColor;
const Color kLightSurfaceColor = Color(0xFFFFFFFF);
const Color kLightSurface = kLightSurfaceColor;
const Color kLightCardColor = Color(0xFFFFFFFF);
const Color kLightCard = kLightCardColor;
const Color kLightBorderColor = Color(0xFFE2E8F0);
const Color kLightBorder = kLightBorderColor;
const Color kLightTextPrimary = Color(0xFF0F172A);
const Color kLightTextSecondary = Color(0xFF64748B);
const Color kLightTextMuted = Color(0xFF94A3B8);

// Dark Theme Surfaces
const Color kDarkBackgroundColor = Color(0xFF0F172A); // Slate 900
const Color kDarkBackground = kDarkBackgroundColor;
const Color kDarkSurfaceColor = Color(0xFF1E293B); // Slate 800
const Color kDarkSurface = kDarkSurfaceColor;
const Color kDarkCardColor = Color(0xFF1E293B);
const Color kDarkCard = kDarkCardColor;
const Color kDarkBorderColor = Color(0xFF334155);
const Color kDarkBorder = kDarkBorderColor;
const Color kDarkTextPrimary = Color(0xFFF8FAFC);
const Color kDarkTextSecondary = Color(0xFF94A3B8);
const Color kDarkTextMuted = Color(0xFF64748B);

/// Pure function to map priority string to theme color
Color mapPriorityToColor(String priority) {
  switch (priority.toLowerCase()) {
    case 'high':
      return kPriorityHighColor;
    case 'medium':
      return kPriorityMediumColor;
    case 'low':
    default:
      return kPriorityLowColor;
  }
}

Color getPriorityColor(String priority) => mapPriorityToColor(priority);

/// Pure function to map category string to theme color
Color mapCategoryToColor(String category) {
  switch (category.toLowerCase()) {
    case 'work':
      return kCategoryWorkColor;
    case 'personal':
      return kCategoryPersonalColor;
    case 'study':
      return kCategoryStudyColor;
    case 'urgent':
      return kCategoryUrgentColor;
    default:
      return kCategoryOtherColor;
  }
}

Color getCategoryColor(String category) => mapCategoryToColor(category);

/// Pure functions returning shadows
List<BoxShadow> getLightShadows() => [
      BoxShadow(
        color: const Color(0xFF0F172A).withOpacity(0.04),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: const Color(0xFF0F172A).withOpacity(0.02),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ];

List<BoxShadow> getDarkShadows() => [
      BoxShadow(
        color: Colors.black.withOpacity(0.25),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ];

/// AppColors namespace wrapper for backward compatibility
class AppColors {
  static const Color primary = kPrimaryColor;
  static const Color primaryLight = kPrimaryLightColor;
  static const Color primaryDark = kPrimaryDarkColor;
  static const Color accent = kAccentColor;
  static const Color secondary = kSecondaryColor;
  static const Color success = kSuccessColor;
  static const Color warning = kWarningColor;
  static const Color error = kErrorColor;
  static const Color info = kInfoColor;

  static const Color priorityLow = kPriorityLowColor;
  static const Color priorityMedium = kPriorityMediumColor;
  static const Color priorityHigh = kPriorityHighColor;

  static const Color categoryWork = kCategoryWorkColor;
  static const Color categoryPersonal = kCategoryPersonalColor;
  static const Color categoryStudy = kCategoryStudyColor;
  static const Color categoryUrgent = kCategoryUrgentColor;
  static const Color categoryOther = kCategoryOtherColor;

  static const Color lightBackground = kLightBackgroundColor;
  static const Color lightSurface = kLightSurfaceColor;
  static const Color lightCard = kLightCardColor;
  static const Color lightBorder = kLightBorderColor;
  static const Color lightTextPrimary = kLightTextPrimary;
  static const Color lightTextSecondary = kLightTextSecondary;
  static const Color lightTextMuted = kLightTextMuted;

  static const Color darkBackground = kDarkBackgroundColor;
  static const Color darkSurface = kDarkSurfaceColor;
  static const Color darkCard = kDarkCardColor;
  static const Color darkBorder = kDarkBorderColor;
  static const Color darkTextPrimary = kDarkTextPrimary;
  static const Color darkTextSecondary = kDarkTextSecondary;
  static const Color darkTextMuted = kDarkTextMuted;

  static List<BoxShadow> get lightShadow => getLightShadows();
  static List<BoxShadow> get darkShadow => getDarkShadows();

  static Color getPriorityColor(String priority) => mapPriorityToColor(priority);
  static Color getCategoryColor(String category) => mapCategoryToColor(category);
}
