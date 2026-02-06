import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list/core/theme/app_theme.dart';
import 'package:todo_list/data/local/hive_init.dart';
import 'package:todo_list/data/repositories/tasks_repository.dart';
import 'package:todo_list/features/tasks/cubit/tasks_cubit.dart';
import 'package:todo_list/features/tasks/view/tasks_list_screen.dart';
import 'package:todo_list/features/tasks/view/tasks_test_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveInit.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => TasksRepository(),
      child: BlocProvider(
        create: (context) =>
            TasksCubit(context.read<TasksRepository>())..loadTasks(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme(),
          home: TasksListScreen(),
        ),
      ),
    );
  }
}
