import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/services/auth_services.dart';
import 'package:task_manager/view/authentications/login.dart';
import 'package:provider/provider.dart' as provider_lib;
import 'package:task_manager/view/home_screen.dart';

void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});

  SharedPreferences? preferences;
  @override
  Widget build(BuildContext context) {
    final userName = preferences?.getString('username');
    final password = preferences?.getString('password');
    return MultiProvider(
      providers: [
        provider_lib.ChangeNotifierProvider(create: (_) => TaskProvider()),
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<TaskProvider>(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home:
        userName!=null && password!=null?HomeScreen():
        LoginScreen(),
      ),
    );
  }
}



