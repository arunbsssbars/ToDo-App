import 'package:flutter/material.dart';
import '../data/models/todo_model.dart';
import '../data/repositories/todo_repository.dart';

enum TodoFilter { all, pending, completed }
enum TodoSortBy { newest, oldest, dueDate, priority }

/// TodoProvider acts as the Todo ViewModel / Controller.
/// Manages list state, filtering, search, sorting, statistics, and CRUD operations.
class TodoProvider extends ChangeNotifier {
  final TodoRepository _todoRepository;

  List<TodoModel> _todos = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filter & Search states
  TodoFilter _activeFilter = TodoFilter.all;
  String _selectedCategory = 'All';
  String _selectedPriority = 'All';
  String _searchQuery = '';
  TodoSortBy _sortBy = TodoSortBy.newest;

  TodoProvider({required TodoRepository todoRepository})
      : _todoRepository = todoRepository;

  // --- Getters ---
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TodoFilter get activeFilter => _activeFilter;
  String get selectedCategory => _selectedCategory;
  String get selectedPriority => _selectedPriority;
  String get searchQuery => _searchQuery;
  TodoSortBy get sortBy => _sortBy;

  // Filtered & Sorted Todos exposed to the UI
  List<TodoModel> get filteredTodos {
    return _todos.where((todo) {
      // 1. Completion status filter
      if (_activeFilter == TodoFilter.pending && todo.isCompleted) return false;
      if (_activeFilter == TodoFilter.completed && !todo.isCompleted) return false;

      // 2. Category filter
      if (_selectedCategory != 'All' &&
          todo.category.toLowerCase() != _selectedCategory.toLowerCase()) {
        return false;
      }

      // 3. Priority filter
      if (_selectedPriority != 'All' &&
          todo.priority.toLowerCase() != _selectedPriority.toLowerCase()) {
        return false;
      }

      // 4. Search query filter
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchTitle = todo.title.toLowerCase().contains(query);
        final matchDesc = todo.description.toLowerCase().contains(query);
        if (!matchTitle && !matchDesc) return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        switch (_sortBy) {
          case TodoSortBy.oldest:
            return (a.createdAt ?? DateTime(2000)).compareTo(b.createdAt ?? DateTime(2000));
          case TodoSortBy.dueDate:
            if (a.dueDate == null && b.dueDate == null) return 0;
            if (a.dueDate == null) return 1;
            if (b.dueDate == null) return -1;
            return a.dueDate!.compareTo(b.dueDate!);
          case TodoSortBy.priority:
            final priorityWeight = {'High': 3, 'Medium': 2, 'Low': 1};
            final weightA = priorityWeight[a.priority] ?? 0;
            final weightB = priorityWeight[b.priority] ?? 0;
            return weightB.compareTo(weightA);
          case TodoSortBy.newest:
          default:
            return (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now());
        }
      });
  }

  // --- Statistics ---
  int get totalCount => _todos.length;
  int get completedCount => _todos.where((t) => t.isCompleted).length;
  int get pendingCount => _todos.where((t) => !t.isCompleted).length;
  double get completionPercentage =>
      totalCount == 0 ? 0.0 : (completedCount / totalCount);

  // --- Filter and Search Setters ---
  void setFilter(TodoFilter filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setPriority(String priority) {
    _selectedPriority = priority;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortBy(TodoSortBy sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }

  // --- CRUD Operations ---

  // 1. Fetch Todos
  Future<void> fetchTodos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _todos = await _todoRepository.fetchTodos();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Create Todo
  Future<bool> createTodo({
    required String title,
    String description = '',
    String category = 'Personal',
    String priority = 'Medium',
    String? dueDate,
  }) async {
    try {
      final newTodo = await _todoRepository.createTodo(
        title: title,
        description: description,
        category: category,
        priority: priority,
        dueDate: dueDate,
      );
      _todos = [newTodo, ..._todos];
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 3. Update Todo
  Future<bool> updateTodo({
    required String id,
    String? title,
    String? description,
    String? category,
    String? priority,
    bool? isCompleted,
    String? dueDate,
  }) async {
    try {
      final updated = await _todoRepository.updateTodo(
        id: id,
        title: title,
        description: description,
        category: category,
        priority: priority,
        isCompleted: isCompleted,
        dueDate: dueDate,
      );

      _todos = _todos.map((t) => t.id == id ? updated : t).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 4. Toggle completion with optimistic update
  Future<void> toggleTodo(String id) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final original = _todos[index];
    // Optimistic UI update
    _todos[index] = original.copyWith(isCompleted: !original.isCompleted);
    notifyListeners();

    try {
      await _todoRepository.toggleTodoStatus(id);
    } catch (e) {
      // Revert optimistic update on failure
      _todos[index] = original;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // 5. Delete Todo
  Future<bool> deleteTodo(String id) async {
    final originalTodos = List<TodoModel>.from(_todos);
    _todos = _todos.where((t) => t.id != id).toList();
    notifyListeners();

    try {
      await _todoRepository.deleteTodo(id);
      return true;
    } catch (e) {
      // Revert on failure
      _todos = originalTodos;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Clear state on logout
  void resetState() {
    _todos = [];
    _todoRepository.clearCache();
    _activeFilter = TodoFilter.all;
    _selectedCategory = 'All';
    _selectedPriority = 'All';
    _searchQuery = '';
    _errorMessage = null;
    notifyListeners();
  }
}
