import 'package:flutter/material.dart';

import '../models/task_model.dart';


class TaskDetailScreen extends StatelessWidget {
  final Task task;

  TaskDetailScreen({required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:const Text('Task Details')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${task.todo}', style:const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text('Completed: ${task.completed ? "Yes" : "No"}', style:const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
