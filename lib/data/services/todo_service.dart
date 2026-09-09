import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../models/todo_model.dart';

/// Service handling raw Todo CRUD API interactions
class TodoService {
  final ApiClient _apiClient;

  TodoService({required ApiClient apiClient}) : _apiClient = apiClient;

  // GET /api/todos
  Future<List<TodoModel>> getTodos({
    String? category,
    String? priority,
    bool? isCompleted,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (category != null && category != 'All') queryParams['category'] = category;
    if (priority != null && priority != 'All') queryParams['priority'] = priority;
    if (isCompleted != null) queryParams['is_completed'] = isCompleted.toString();
    if (search != null && search.trim().isNotEmpty) queryParams['search'] = search.trim();

    final response = await _apiClient.get(
      getTodosUrl(),
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );

    final list = response['data'] as List<dynamic>;
    return list.map((item) => TodoModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  // GET /api/todos/:id
  Future<TodoModel> getTodoById(String id) async {
    final response = await _apiClient.get(getTodoByIdUrl(id));
    final data = response['data'] as Map<String, dynamic>;
    return TodoModel.fromJson(data);
  }

  // POST /api/todos
  Future<TodoModel> createTodo({
    required String title,
    String description = '',
    String category = 'Personal',
    String priority = 'Medium',
    String? dueDate,
  }) async {
    final response = await _apiClient.post(
      getTodosUrl(),
      body: {
        'title': title,
        'description': description,
        'category': category,
        'priority': priority,
        'due_date': dueDate,
      },
    );

    final data = response['data'] as Map<String, dynamic>;
    return TodoModel.fromJson(data);
  }

  // PUT /api/todos/:id
  Future<TodoModel> updateTodo({
    required String id,
    String? title,
    String? description,
    String? category,
    String? priority,
    bool? isCompleted,
    String? dueDate,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (category != null) body['category'] = category;
    if (priority != null) body['priority'] = priority;
    if (isCompleted != null) body['is_completed'] = isCompleted;
    if (dueDate != null) body['due_date'] = dueDate;

    final response = await _apiClient.put(
      getTodoByIdUrl(id),
      body: body,
    );

    final data = response['data'] as Map<String, dynamic>;
    return TodoModel.fromJson(data);
  }

  // PATCH /api/todos/:id/toggle
  Future<bool> toggleTodoStatus(String id) async {
    final response = await _apiClient.patch(getToggleTodoUrl(id));
    final data = response['data'] as Map<String, dynamic>;
    return data['is_completed'] as bool;
  }

  // DELETE /api/todos/:id
  Future<void> deleteTodo(String id) async {
    await _apiClient.delete(getTodoByIdUrl(id));
  }
}
