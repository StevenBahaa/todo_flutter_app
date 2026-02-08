import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list/data/models/task_enums.dart';
import 'package:todo_list/data/models/task_model.dart';
import 'package:todo_list/data/repositories/tasks_repository.dart';
import 'package:todo_list/features/tasks/cubit/tasks_filter.dart';
import 'package:todo_list/features/tasks/cubit/tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  final TasksRepository _repo;

  TasksCubit(this._repo) : super(const TasksState());

  void loadTasks() {
    final prev = state.tasks;
    emit(state.copyWith(status: TasksStatus.loading));
    try {
      final tasks = _repo.getAll();
      emit(state.copyWith(status: TasksStatus.success, tasks: tasks));
    } catch (e) {
      emit(
        state.copyWith(
          status: TasksStatus.failure,
          errorMessage: e.toString(),
          tasks: prev,
        ),
      );
    }
  }

  Future<void> createTask(TaskModel task) async {
    final update = [task, ...state.tasks];

    emit(state.copyWith(status: TasksStatus.success, tasks: update));

    try {
      await _repo.add(task);
    } catch (e) {
      state.copyWith(
        status: TasksStatus.failure,
        errorMessage: e.toString(),
        tasks: state.tasks,
      );
    }
  }

  Future<void> updateTask(TaskModel task) async {
    final prev = state.tasks;
    final updated = prev.map((t) => t.id == task.id ? task : t).toList();
    emit(state.copyWith(status: TasksStatus.success, tasks: updated));

    try {
      await _repo.update(task);
    } catch (e) {
      emit(
        state.copyWith(
          status: TasksStatus.failure,
          errorMessage: e.toString(),
          tasks: prev,
        ),
      );
    }
  }

  Future<void> deleteTask(String id) async {
    final prev = state.tasks;
    final updated = prev.where((t) => t.id != id).toList();
    emit(state.copyWith(status: TasksStatus.success, tasks: updated));

    try {
      await _repo.delete(id);
    } catch (e) {
      emit(
        state.copyWith(
          status: TasksStatus.failure,
          errorMessage: e.toString(),
          tasks: prev,
        ),
      );
    }
  }

  Future<void> toggleDone(TaskModel task) async {
    final prev = state.tasks;
    final isDone = task.status == TaskStatus.done.index;
    final updatedTask = task.copyWith(
      status: isDone ? TaskStatus.todo.index : TaskStatus.done.index,
    );

    final updatedList = prev
        .map((t) => t.id == updatedTask.id ? updatedTask : t)
        .toList();

    emit(state.copyWith(status: TasksStatus.success, tasks: updatedList));

    try {
      await _repo.update(updatedTask);
    } catch (e) {
      emit(
        state.copyWith(
          status: TasksStatus.failure,
          errorMessage: e.toString(),
          tasks: prev,
        ),
      );
    }
  }

  void setFilter(TasksFilter f) {
    emit(state.copyWith(filter: f));
  }
}
