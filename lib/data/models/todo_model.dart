/// Todo item model with priority, category, completion status, and dates
class TodoModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category; // 'Personal', 'Work', 'Study', 'Urgent'
  final String priority; // 'Low', 'Medium', 'High'
  final bool isCompleted;
  final String? dueDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TodoModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    this.category = 'Personal',
    this.priority = 'Medium',
    this.isCompleted = false,
    this.dueDate,
    this.createdAt,
    this.updatedAt,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'Personal',
      priority: json['priority'] as String? ?? 'Medium',
      isCompleted: json['is_completed'] is bool
          ? json['is_completed'] as bool
          : (json['is_completed'] == 1),
      dueDate: json['due_date'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'is_completed': isCompleted,
      'due_date': dueDate,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  TodoModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    String? priority,
    bool? isCompleted,
    String? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
