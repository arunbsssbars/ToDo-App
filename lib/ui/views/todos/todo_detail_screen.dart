import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/todo_model.dart';
import '../../../providers/todo_provider.dart';
import '../../widgets/priority_badge.dart';
import '../../widgets/stitch_card.dart';
import 'widgets/add_edit_todo_sheet.dart';

/// Detailed view of a Todo Note
class TodoDetailScreen extends StatelessWidget {
  final String todoId;

  const TodoDetailScreen({super.key, required this.todoId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todoProvider = context.watch<TodoProvider>();

    // Retrieve fresh todo state from provider
    final todo = todoProvider.filteredTodos.firstWhere(
      (t) => t.id == todoId,
      orElse: () => TodoModel(
        id: '',
        userId: '',
        title: 'Task Not Found',
        isCompleted: false,
      ),
    );

    if (todo.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('This task is no longer available.')),
      );
    }

    final categoryColor = AppColors.getCategoryColor(todo.category);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AddEditTodoSheet(todoToEdit: todo),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            onPressed: () async {
              final confirm = await showDialog<bool>(
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

              if (confirm == true && context.mounted) {
                await todoProvider.deleteTodo(todo.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Status Banner Card
            StitchCard(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PriorityBadge(priority: todo.priority),
                      GestureDetector(
                        onTap: () => todoProvider.toggleTodo(todo.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: todo.isCompleted
                                ? AppColors.success.withOpacity(0.15)
                                : AppColors.warning.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                todo.isCompleted
                                    ? Icons.check_circle_rounded
                                    : Icons.hourglass_top_rounded,
                                size: 16,
                                color: todo.isCompleted ? AppColors.success : AppColors.warning,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                todo.isCompleted ? 'Completed' : 'Pending',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: todo.isCompleted ? AppColors.success : AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    todo.title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  if (todo.description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      todo.description,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Metadata Cards
            StitchCard(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _buildMetaRow(
                    icon: Icons.category_outlined,
                    iconColor: categoryColor,
                    label: 'Category',
                    value: todo.category,
                    isDark: isDark,
                  ),
                  const Divider(height: 24),
                  _buildMetaRow(
                    icon: Icons.flag_outlined,
                    iconColor: AppColors.getPriorityColor(todo.priority),
                    label: 'Priority',
                    value: '${todo.priority} Priority',
                    isDark: isDark,
                  ),
                  if (todo.dueDate != null) ...[
                    const Divider(height: 24),
                    _buildMetaRow(
                      icon: Icons.calendar_today_outlined,
                      iconColor: AppColors.info,
                      label: 'Due Date',
                      value: todo.dueDate!,
                      isDark: isDark,
                    ),
                  ],
                  if (todo.createdAt != null) ...[
                    const Divider(height: 24),
                    _buildMetaRow(
                      icon: Icons.access_time_rounded,
                      iconColor: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      label: 'Created At',
                      value: DateFormat('MMM d, yyyy • h:mm a').format(todo.createdAt!),
                      isDark: isDark,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 14),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }
}
