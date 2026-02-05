import 'package:equatable/equatable.dart';
import 'package:todo_list/data/models/task_model.dart';

enum TasksStatus { initial, loading, success, failure }

class TasksState extends Equatable {
  final TasksStatus status;
  final List<TaskModel> tasks;
  final String? errorMessage;

  const TasksState({
    this.status = TasksStatus.initial,
    this.tasks = const [],
    this.errorMessage,
  });

  TasksState copyWith({
    TasksStatus? status,
    List<TaskModel>? tasks,
    String? errorMessage,
  }) {
    return TasksState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, tasks, errorMessage];
}
