import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Pure builder function that creates a priority tag badge
Widget buildPriorityBadge(String priority) {
  final color = getPriorityColor(priority);

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withOpacity(0.3), width: 0.8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          priority,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    ),
  );
}

/// PriorityBadge widget adapter
class PriorityBadge extends StatelessWidget {
  final String priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) => buildPriorityBadge(priority);
}
