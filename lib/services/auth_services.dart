import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/services/task_services.dart';

class AuthService {
  final String _baseUrl = 'https://dummyjson.com';
  TaskService taskService = TaskService();

  Future<bool> login(BuildContext context,String username, String password) async {
    try {
      taskService.showProgressDialog(context);

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
          'expiresInMins': 30,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('username', username);
        await prefs.setString('password', password);
        return true;
      } else {
        return false;
      }
    } finally {
      taskService.dismissProgressDialog();
    }
  }
}
