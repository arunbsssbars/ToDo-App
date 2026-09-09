import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/data/models/todo_model.dart';
import 'package:todo_app/data/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    test('fromJson and toJson should match correctly', () {
      final json = {
        'id': 'user-123',
        'name': 'John Doe',
        'email': 'john@example.com',
        'created_at': '2026-08-26T12:00:00.000Z',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 'user-123');
      expect(user.name, 'John Doe');
      expect(user.email, 'john@example.com');
      expect(user.createdAt, isNotNull);

      final outputJson = user.toJson();
      expect(outputJson['id'], 'user-123');
      expect(outputJson['name'], 'John Doe');
      expect(outputJson['email'], 'john@example.com');
    });
  });

  group('TodoModel Tests', () {
    test('fromJson correctly parses boolean completion status and priority', () {
      final json = {
        'id': 'todo-456',
        'user_id': 'user-123',
        'title': 'Test Todo',
        'description': 'Description content',
        'category': 'Work',
        'priority': 'High',
        'is_completed': 1,
        'due_date': '2026-08-30',
        'created_at': '2026-08-26T12:00:00.000Z',
      };

      final todo = TodoModel.fromJson(json);

      expect(todo.id, 'todo-456');
      expect(todo.userId, 'user-123');
      expect(todo.title, 'Test Todo');
      expect(todo.category, 'Work');
      expect(todo.priority, 'High');
      expect(todo.isCompleted, isTrue);
      expect(todo.dueDate, '2026-08-30');
    });

    test('copyWith updates fields immutably', () {
      final original = TodoModel(
        id: 'todo-1',
        userId: 'user-1',
        title: 'Original Title',
        isCompleted: false,
      );

      final modified = original.copyWith(
        title: 'Updated Title',
        isCompleted: true,
      );

      expect(modified.id, 'todo-1');
      expect(modified.title, 'Updated Title');
      expect(modified.isCompleted, isTrue);
      expect(original.title, 'Original Title');
      expect(original.isCompleted, isFalse);
    });
  });
}
