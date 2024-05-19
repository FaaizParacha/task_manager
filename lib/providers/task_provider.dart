import 'package:flutter/material.dart';


import '../models/task_model.dart';
import '../services/task_services.dart';

class TaskProvider with ChangeNotifier {
  TaskService taskService = TaskService();
  List<Task> _tasks = [];
  bool _isLoading = false;
  int _totalTasks = 0;
  int _skip = 0;
  int _limit = 10;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  int get totalTasks => _totalTasks;
  int get skip => _skip;
  int get limit => _limit;

  final TaskService _taskService = TaskService();

  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();
    try {
      final newTasks = await _taskService.fetchTasks(_limit, _skip);
      _tasks.addAll(newTasks);
      _skip += _limit;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  TaskProvider() {
    loadTasks();
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();
    _tasks = await _taskService.loadTaskList();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(String todo, bool completed, int userId) async {
    try {
      final newTask = await _taskService.addTask(todo, completed, userId);
      _tasks.add(newTask);
      await _taskService.saveTaskList(_tasks);
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateTask(int id, bool completed) async {
    try {

      final index = _tasks.indexWhere((task) => task.id == id);
      if (index != -1) {
        _tasks[index].completed = completed;
        await _taskService.saveTaskList(_tasks);
        notifyListeners();
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      _tasks.removeWhere((task) => task.id == id);
      await _taskService.saveTaskList(_tasks);
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }
}
