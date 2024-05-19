import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:task_manager/models/task_model.dart';
import 'dart:convert';

import 'package:task_manager/services/task_services.dart';

void main() {
  late TaskService taskService;
  late MockClient mockClient;
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    mockClient = MockClient((request) async {
      if (request.url.path == '/todos/add' && request.method == 'POST') {
        return http.Response(
          json.encode({
            'id': 1,
            'todo': 'Test task',
            'completed': false,
            'userId': 1,
          }),
          200,
          headers: {'Content-Type': 'application/json'},
        );
      } else if (request.url.path == '/todos/1' && request.method == 'PUT') {
        return http.Response(
          json.encode({
            'id': 1,
            'todo': 'Test task',
            'completed': request.body.contains('"completed":true'),
            'userId': 1,
          }),
          200,
          headers: {'Content-Type': 'application/json'},
        );
      } else if (request.url.path == '/todos/1' && request.method == 'DELETE') {
        return http.Response(
          json.encode({'success': true}),
          200,
          headers: {'Content-Type': 'application/json'},
        );
      }
      return http.Response('Not Found', 404);
    });

    taskService = TaskService(client: mockClient);
  });

  group('TaskService', () {
    test('addTask returns a Task if the http call completes successfully', () async {
      final taskJson = {
        'id': 1,
        'todo': 'Test task',
        'completed': false,
        'userId': 1,
      };

      final task = await taskService.addTask('Test task', false, 1);

      expect(task, isA<Task>());
      expect(task.todo, 'Test task');
      expect(task.completed, false);
      expect(task.userId, 1);

    });

    test('loadTaskList returns a list of Tasks from SharedPreferences', () async {
      final taskJsonList = [
        json.encode({'id': 1, 'todo': 'Test task 1', 'completed': false, 'userId': 1}),
        json.encode({'id': 2, 'todo': 'Test task 2', 'completed': true, 'userId': 1}),
      ];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('tasks', taskJsonList);

      final tasks = await taskService.loadTaskList();

      expect(tasks.length, 2);
      expect(tasks[0].id, 1);
      expect(tasks[1].id, 2);
    });
  });
}
