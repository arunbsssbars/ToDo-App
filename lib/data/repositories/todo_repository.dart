import '../models/todo_model.dart';
import '../services/todo_service.dart';

/// Repository for managing Todo domain logic and caching
class TodoRepository {
  final TodoService _todoService;
  List<TodoModel> _cachedTodos = [];

  TodoRepository({required TodoService todoService}) : _todoService = todoService;

  List<TodoModel> get cachedTodos => List.unmodifiable(_cachedTodos);

  // Fetch todos from API and update in-memory cache
  Future<List<TodoModel>> fetchTodos({
    String? category,
    String? priority,
    bool? isCompleted,
    String? search,
  }) async {
    final todos = await _todoService.getTodos(
      category: category,
      priority: priority,
      isCompleted: isCompleted,
      search: search,
    );
    _cachedTodos = todos;
    return _cachedTodos;
  }

  // Create new todo and prepend to cache
  Future<TodoModel> createTodo({
    required String title,
    String description = '',
    String category = 'Personal',
    String priority = 'Medium',
    String? dueDate,
  }) async {
    final newTodo = await _todoService.createTodo(
      title: title,
      description: description,
      category: category,
      priority: priority,
      dueDate: dueDate,
    );
    _cachedTodos = [newTodo, ..._cachedTodos];
    return newTodo;
  }

  // Update existing todo in cache and backend
  Future<TodoModel> updateTodo({
    required String id,
    String? title,
    String? description,
    String? category,
    String? priority,
    bool? isCompleted,
    String? dueDate,
  }) async {
    final updated = await _todoService.updateTodo(
      id: id,
      title: title,
      description: description,
      category: category,
      priority: priority,
      isCompleted: isCompleted,
      dueDate: dueDate,
    );

    _cachedTodos = _cachedTodos.map((t) => t.id == id ? updated : t).toList();
    return updated;
  }

  // Toggle completion status with optimistic cache update
  Future<bool> toggleTodoStatus(String id) async {
    final newStatus = await _todoService.toggleTodoStatus(id);
    _cachedTodos = _cachedTodos.map((t) {
      if (t.id == id) {
        return t.copyWith(isCompleted: newStatus);
      }
      return t;
    }).toList();
    return newStatus;
  }

  // Delete todo from cache and backend
  Future<void> deleteTodo(String id) async {
    await _todoService.deleteTodo(id);
    _cachedTodos = _cachedTodos.where((t) => t.id != id).toList();
  }

  // Clear cache on logout
  void clearCache() {
    _cachedTodos = [];
  }
}
