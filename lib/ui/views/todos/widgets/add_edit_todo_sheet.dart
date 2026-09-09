import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/todo_model.dart';
import '../../../../providers/todo_provider.dart';
import '../../../widgets/category_chip.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

/// Modal bottom sheet to create or edit a Todo note
class AddEditTodoSheet extends StatefulWidget {
  final TodoModel? todoToEdit;

  const AddEditTodoSheet({super.key, this.todoToEdit});

  @override
  State<AddEditTodoSheet> createState() => _AddEditTodoSheetState();
}

class _AddEditTodoSheetState extends State<AddEditTodoSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late String _selectedCategory;
  late String _selectedPriority;
  DateTime? _selectedDueDate;
  bool _isLoading = false;

  final List<String> _categories = ['Personal', 'Work', 'Study', 'Urgent'];
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();
    final todo = widget.todoToEdit;
    _titleController = TextEditingController(text: todo?.title ?? '');
    _descController = TextEditingController(text: todo?.description ?? '');
    _selectedCategory = todo?.category ?? 'Personal';
    _selectedPriority = todo?.priority ?? 'Medium';
    _selectedDueDate = todo?.dueDate != null ? DateTime.tryParse(todo!.dueDate!) : null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 3650)),
    );

    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final todoProvider = context.read<TodoProvider>();
    final formattedDate = _selectedDueDate != null
        ? DateFormat('yyyy-MM-dd').format(_selectedDueDate!)
        : null;

    bool success;
    if (widget.todoToEdit == null) {
      // Create new
      success = await todoProvider.createTodo(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
        dueDate: formattedDate,
      );
    } else {
      // Update existing
      success = await todoProvider.updateTodo(
        id: widget.todoToEdit!.id,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
        dueDate: formattedDate,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context);
    } else if (todoProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(todoProvider.errorMessage!),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.todoToEdit != null;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Task' : 'Create New Task',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Task Title Input
              CustomTextField(
                controller: _titleController,
                label: 'Task Title',
                hint: 'What do you want to accomplish?',
                prefixIcon: Icons.edit_note_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description Input
              CustomTextField(
                controller: _descController,
                label: 'Description (Optional)',
                hint: 'Add any relevant notes or details...',
                prefixIcon: Icons.subject_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 18),

              // Category Picker
              Text(
                'Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  return CategoryChip(
                    label: cat,
                    isSelected: _selectedCategory == cat,
                    onSelected: () => setState(() => _selectedCategory = cat),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // Priority Selector
              Text(
                'Priority',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: _priorities.map((pri) {
                  final isSelected = _selectedPriority == pri;
                  final priColor = AppColors.getPriorityColor(pri);

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setState(() => _selectedPriority = pri),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? priColor.withOpacity(0.15)
                                : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? priColor : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              pri,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected
                                    ? priColor
                                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // Due Date Selector
              Text(
                'Due Date',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _pickDueDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _selectedDueDate != null
                                ? DateFormat('EEE, MMM d, yyyy').format(_selectedDueDate!)
                                : 'No date set',
                            style: TextStyle(
                              fontSize: 14,
                              color: _selectedDueDate != null
                                  ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                                  : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                            ),
                          ),
                        ],
                      ),
                      if (_selectedDueDate != null)
                        GestureDetector(
                          onTap: () => setState(() => _selectedDueDate = null),
                          child: Icon(
                            Icons.clear_rounded,
                            size: 18,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Submit Button
              CustomButton(
                text: isEditing ? 'Save Changes' : 'Create Task',
                isLoading: _isLoading,
                onPressed: _saveTodo,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
