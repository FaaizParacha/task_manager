import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:overlay_loading_progress/overlay_loading_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_model.dart';


class TaskService {
  final String _baseUrl = 'https://dummyjson.com';
    http.Client? client;

  TaskService({http.Client? client});
  Future<List<Task>> fetchTasks(int limit, int skip) async {
    final response = await http.get(Uri.parse('$_baseUrl/todos?limit=$limit&skip=$skip'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> todosJson = data['todos'];
      return todosJson.map((taskJson) => Task.fromJson(taskJson)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }
  Future<Task> addTask(String todo, bool completed, int userId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/todos/add'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'todo': todo,
        'completed': completed,
        'userId': userId,
      }),
    );
    if (response.statusCode == 200) {
      final task = Task.fromJson(json.decode(response.body));
      await saveTaskList([task]);
      return task;
    } else {
      throw Exception('Failed to add task');
    }
  }

  Future<void> saveTaskList(List<Task> tasks) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> taskJsonList = tasks.map((task) => json.encode(task.toJson())).toList();
    await prefs.setStringList('tasks', taskJsonList);
  }

  Future<List<Task>> loadTaskList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> taskJsonList = prefs.getStringList('tasks') ?? [];
    return taskJsonList.map((taskJson) => Task.fromJson(json.decode(taskJson))).toList();
  }

  Future<Task> updateTask(int id, bool completed) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/todos/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'completed': completed,
      }),
    );
    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('lastUpdatedTask', response.body);
      return Task.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update task');
    }
  }

  Future<void> deleteTask(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/todos/$id'));
    if (response.statusCode != 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('lastDeletedTask', 'Task with id $id deleted');
      throw Exception('Failed to delete task');
    }
  }

  void showProgressDialog(BuildContext context) {
    OverlayLoadingProgress.start(
      context,
      barrierColor: Colors.black26,
      widget: Container(
          width: MediaQuery.of(context).size.width / 4,
          height: MediaQuery.of(context).size.height / 8,
          padding: EdgeInsets.all(25),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: const CircularProgressIndicator(
            
          )),
    );
  }

  void dismissProgressDialog() {
    try {
      OverlayLoadingProgress.stop();
    } catch (e) {
      debugPrint("catch $e");
    }
  }
}
