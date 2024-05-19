import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/services/task_services.dart';
import 'package:task_manager/view/task_detail_screen.dart';

import '../models/task_model.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TaskService _taskService = TaskService();
  @override
  void initState() {
    super.initState();
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.fetchTasks();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
          !taskProvider.isLoading &&
          taskProvider.tasks.length < taskProvider.totalTasks) {
        taskProvider.fetchTasks();
      }
    });
  }

  void _addTask() {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    _taskService.showProgressDialog(context);
    taskProvider.addTask('Use DummyJSON in the project', false, 5).then((_) {
      _taskService.dismissProgressDialog();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task added successfully')),
      );
    }).catchError((error) {
      _taskService.dismissProgressDialog();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add task')),
      );
    });
  }

  void _toggleTaskCompletion(Task task) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    _taskService.showProgressDialog(context);

    Future.delayed(Duration(seconds: 1), () {
      taskProvider.updateTask(task.id, !task.completed).then((_) {

        _taskService.dismissProgressDialog();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task updated successfully')),
        );
      }).catchError((error) {

        _taskService.dismissProgressDialog();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update task')),
        );
      });
    });
  }

  void _deleteTask(int id) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.deleteTask(id).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task deleted successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete task')),
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(title: const Text('Task Manager')),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.isLoading && taskProvider.tasks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            controller: _scrollController,
            itemCount: taskProvider.tasks.length + (taskProvider.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < taskProvider.tasks.length) {
                final task = taskProvider.tasks[index];
                return Dismissible(
                  key: Key(task.id.toString()),
                  background: Container(color: Colors.red, child: Icon(Icons.delete, color: Colors.white)),
                  onDismissed: (direction) {
                    _deleteTask(task.id);
                  },
                  child: ListTile(
                    title: Text(task.todo),
                    trailing: Icon(task.completed ? Icons.check : Icons.close),
                    onTap: () => _toggleTaskCompletion(task),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          );
        },
      ),
    );
  }
}
