import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/todo.dart';
import 'models/deleted_todo.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters for Hive
  Hive.registerAdapter(TodoAdapter());
  Hive.registerAdapter(DeletedTodoAdapter());

  // Open boxes
  await Hive.openBox<Todo>('todosBox');
  await Hive.openBox<DeletedTodo>('deletedTodosBox');

  // Initialize notification service
  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}