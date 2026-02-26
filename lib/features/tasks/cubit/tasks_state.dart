import 'package:equatable/equatable.dart';
import 'package:todo_list/data/models/task_model.dart';
import 'package:todo_list/features/tasks/cubit/tasks_filter.dart';

enum TasksStatus { initial, loading, success, failure }

class TasksState extends Equatable {
  final TasksStatus status;
  final List<TaskModel> tasks;
  final String? errorMessage;
  final TasksFilter filter;

  const TasksState({
    this.status = TasksStatus.initial,
    this.tasks = const [],
    this.errorMessage,
    this.filter = TasksFilter.all,
  });

  

  TasksState copyWith({
    TasksStatus? status,
    List<TaskModel>? tasks,
    String? errorMessage,
    TasksFilter? filter,
  }) {
    return TasksState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      errorMessage: errorMessage ?? this.errorMessage,
      filter: filter ?? this.filter,
    );
  }
  @override
  List<Object?> get props => [status, tasks, errorMessage, filter];
}