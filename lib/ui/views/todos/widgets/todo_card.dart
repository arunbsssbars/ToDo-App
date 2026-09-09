import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/todo_model.dart';
import '../../../widgets/priority_badge.dart';
import '../../../widgets/stitch_card.dart';

/// Modern Stitch UI Todo Card displaying task details, priority, and animated completion
class TodoCard extends StatelessWidget {
  final TodoModel todo;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TodoCard({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = AppColors.getCategoryColor(todo.category);

    String? formattedDueDate;
    if (todo.dueDate != null) {
      try {
        final parsed = DateTime.parse(todo.dueDate!);
        formattedDueDate = DateFormat('MMM d').format(parsed);
      } catch (_) {}
    }

    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Task?'),
            content: Text('Are you sure you want to delete "${todo.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: StitchCard(
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Animated Completion Checkbox
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 26,
                height: 26,
                margin: const EdgeInsets.only(top: 2, right: 14),
                decoration: BoxDecoration(
                  color: todo.isCompleted ? AppColors.success : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: todo.isCompleted
                        ? AppColors.success
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    width: 2,
                  ),
                ),
                child: todo.isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),

            // Content Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    todo.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: todo.isCompleted
                          ? (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
                          : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                      decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                      decorationColor: AppColors.lightTextMuted,
                    ),
                  ),
                  if (todo.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      todo.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),

                  // Metadata Badges Row
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Priority Badge
                      PriorityBadge(priority: todo.priority),

                      // Category Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: categoryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              todo.category,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: categoryColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Due Date Tag
                      if (formattedDueDate != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.event_outlined,
                              size: 13,
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              formattedDueDate,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // More Options / Edit
            IconButton(
              icon: Icon(
                Icons.edit_outlined,
                size: 18,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              onPressed: onEdit,
              tooltip: 'Edit Task',
            ),
          ],
        ),
      ),
    );
  }
}
