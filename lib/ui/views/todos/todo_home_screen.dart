import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/todo_provider.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/stats_overview_card.dart';
import '../profile/profile_screen.dart';
import 'todo_detail_screen.dart';
import 'widgets/add_edit_todo_sheet.dart';
import 'widgets/todo_card.dart';

class TodoHomeScreen extends StatefulWidget {
  const TodoHomeScreen({super.key});

  @override
  State<TodoHomeScreen> createState() => _TodoHomeScreenState();
}

class _TodoHomeScreenState extends State<TodoHomeScreen> {
  final _searchController = TextEditingController();
  bool _isSearchOpen = false;

  final List<String> _categories = ['All', 'Personal', 'Work', 'Study', 'Urgent'];

  @override
  void initState() {
    super.initState();
    // Fetch user's isolated todos on initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoProvider>().fetchTodos();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddEditTodoSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final todoProvider = context.watch<TodoProvider>();
    final user = authProvider.currentUser;
    final todos = todoProvider.filteredTodos;

    return Scaffold(
      appBar: AppBar(
        title: _isSearchOpen
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
                onChanged: (val) => todoProvider.setSearchQuery(val),
              )
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 10),
                  const Text('TaskFlow'),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearchOpen ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () {
              setState(() {
                if (_isSearchOpen) {
                  _searchController.clear();
                  todoProvider.setSearchQuery('');
                }
                _isSearchOpen = !_isSearchOpen;
              });
            },
          ),
          PopupMenuButton<TodoSortBy>(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Sort by',
            onSelected: (sort) => todoProvider.setSortBy(sort),
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: TodoSortBy.newest,
                child: Text('Newest First'),
              ),
              const PopupMenuItem(
                value: TodoSortBy.oldest,
                child: Text('Oldest First'),
              ),
              const PopupMenuItem(
                value: TodoSortBy.dueDate,
                child: Text('Due Date'),
              ),
              const PopupMenuItem(
                value: TodoSortBy.priority,
                child: Text('Priority'),
              ),
            ],
          ),
          IconButton(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: Text(
                user != null && user.name.isNotEmpty
                    ? user.name.substring(0, 1).toUpperCase()
                    : 'U',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => todoProvider.fetchTodos(),
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // 1. Dashboard Statistics Card
            SliverToBoxAdapter(
              child: StatsOverviewCard(
                userName: user?.name ?? 'Friend',
                total: todoProvider.totalCount,
                completed: todoProvider.completedCount,
                pending: todoProvider.pendingCount,
                percentage: todoProvider.completionPercentage,
              ),
            ),

            // 2. Status Segment Filter (All / Pending / Done)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      _buildSegmentBtn('All', TodoFilter.all, todoProvider, isDark),
                      _buildSegmentBtn('Pending', TodoFilter.pending, todoProvider, isDark),
                      _buildSegmentBtn('Completed', TodoFilter.completed, todoProvider, isDark),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Category Horizontal Pills
            SliverToBoxAdapter(
              child: SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    return CategoryChip(
                      label: cat,
                      isSelected: todoProvider.selectedCategory == cat,
                      onSelected: () => todoProvider.setCategory(cat),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // 4. Todo Cards List or Empty/Loading State
            if (todoProvider.isLoading && todoProvider.totalCount == 0)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (todos.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.task_alt_rounded,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          todoProvider.searchQuery.isNotEmpty
                              ? 'No tasks match "${todoProvider.searchQuery}"'
                              : 'No tasks found',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          todoProvider.searchQuery.isNotEmpty
                              ? 'Try searching with different keywords'
                              : 'Tap the + button below to create your first task',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final todo = todos[index];
                    return TodoCard(
                      todo: todo,
                      onToggle: () => todoProvider.toggleTodo(todo.id),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TodoDetailScreen(todoId: todo.id),
                          ),
                        );
                      },
                      onEdit: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => AddEditTodoSheet(todoToEdit: todo),
                        );
                      },
                      onDelete: () => todoProvider.deleteTodo(todo.id),
                    );
                  },
                  childCount: todos.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSheet,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'New Task',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentBtn(
    String title,
    TodoFilter filter,
    TodoProvider provider,
    bool isDark,
  ) {
    final isSelected = provider.activeFilter == filter;

    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setFilter(filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.darkSurface : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
