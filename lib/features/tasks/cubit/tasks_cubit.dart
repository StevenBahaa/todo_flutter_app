import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list/data/models/sub_task_model.dart';
import 'package:todo_list/data/models/task_enums.dart';
import 'package:todo_list/data/models/task_model.dart';
import 'package:todo_list/data/repositories/tasks_repository.dart';
import 'package:todo_list/features/tasks/cubit/tasks_filter.dart';
import 'package:todo_list/features/tasks/cubit/tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  final TasksRepository _repo;

  TasksCubit(this._repo) : super(const TasksState());

  TaskModel? _findTask(List<TaskModel> tasks, String taskId) {
    try {
      return tasks.firstWhere((t) => t.id == taskId);
    } catch (_) {
      return null;
    }
  }

  int _smartStatusFromSubTasks(List<SubTaskModel> subs) {
    if (subs.isEmpty) return TaskStatus.todo.index;
    return subs.every((s) => s.isDone)
        ? TaskStatus.done.index
        : TaskStatus.todo.index;
  }

  List<TaskModel> _replaceTask(List<TaskModel> tasks, TaskModel updated) {
    return tasks.map((t) => t.id == updated.id ? updated : t).toList();
  }

  void loadTasks() {
    final prev = state.tasks;
    emit(state.copyWith(status: TasksStatus.loading));
    try {
      var tasks = _repo.getAll();

      // Seed demo data once when box is empty (useful for screenshots / first run)
      if (tasks.isEmpty) {
        tasks = _seedDemoTasks();
      }

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

  List<TaskModel> _seedDemoTasks() {
    final now = DateTime.now();

    TaskModel build({
      required String id,
      required String title,
      String? description,
      required TaskPriority priority,
      DateTime? due,
      List<String> tags = const [],
      List<SubTaskModel> subtasks = const [],
      bool markDone = false,
    }) {
      final base = TaskModel.newTask(
        id: id,
        title: title,
        dueDateTime: due,
        priority: priority,
        tags: tags,
      );

      final status = markDone
          ? TaskStatus.done.index
          : base.status;

      return base.copyWith(
        description: description,
        status: status,
        subtasks: subtasks.isEmpty ? null : List<SubTaskModel>.unmodifiable(subtasks),
      );
    }

    final demoTasks = <TaskModel>[
      build(
        id: 'demo_t1',
        title: 'Finish Flutter portfolio app',
        description:
            'Polish UI, fix small bugs, and prepare screenshots for LinkedIn.',
        priority: TaskPriority.high,
        due: now.add(const Duration(days: 1)),
        tags: const ['flutter', 'portfolio', 'urgent'],
        subtasks: [
          SubTaskModel(id: 'demo_t1s1', title: 'Review Today dashboard UI'),
          SubTaskModel(id: 'demo_t1s2', title: 'Test subtasks editing'),
          SubTaskModel(id: 'demo_t1s3', title: 'Capture screenshots'),
        ],
      ),
      build(
        id: 'demo_t2',
        title: 'Apply to 3 Flutter roles',
        description:
            'Find roles that match my skills and send tailored applications.',
        priority: TaskPriority.medium,
        due: now.add(const Duration(days: 2)),
        tags: const ['career', 'job-search'],
        subtasks: [
          SubTaskModel(id: 'demo_t2s1', title: 'Update CV with this app', isDone: true),
          SubTaskModel(id: 'demo_t2s2', title: 'Find 3 suitable job posts'),
          SubTaskModel(id: 'demo_t2s3', title: 'Send applications'),
        ],
      ),
      build(
        id: 'demo_t3',
        title: 'Daily planning and review',
        description: 'Short daily ritual to keep track of my goals.',
        priority: TaskPriority.low,
        due: now.subtract(const Duration(days: 1)),
        tags: const ['routine', 'personal'],
        subtasks: [
          SubTaskModel(id: 'demo_t3s1', title: 'Review yesterday’s tasks', isDone: true),
          SubTaskModel(id: 'demo_t3s2', title: 'Plan top 3 tasks for today', isDone: true),
        ],
        markDone: true,
      ),
      build(
        id: 'demo_t4',
        title: 'Refactor task details screen',
        description: 'Improve code structure and reduce rebuilds.',
        priority: TaskPriority.high,
        due: now.add(const Duration(days: 4)),
        tags: const ['code', 'refactor'],
        subtasks: [
          SubTaskModel(id: 'demo_t4s1', title: 'Analyze rebuilds in DevTools'),
          SubTaskModel(id: 'demo_t4s2', title: 'Extract smaller widgets'),
        ],
      ),
      build(
        id: 'demo_t5',
        title: 'Backup and sync tasks',
        description:
            'Export tasks and plan future sync with a backend or n8n.',
        priority: TaskPriority.medium,
        due: null,
        tags: const ['idea', 'future'],
      ),
    ];

    for (final task in demoTasks) {
      _repo.add(task);
    }

    return demoTasks;
  }

  Future<void> createTask(TaskModel task) async {
    final update = [task, ...state.tasks];
    emit(state.copyWith(status: TasksStatus.success, tasks: update));
    try {
      await _repo.add(task);
    } catch (e) {
      emit(
        state.copyWith(status: TasksStatus.failure, errorMessage: e.toString()),
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

    TaskModel updatedTask;

    final subs = task.safeSubTasks;
    if (subs.isNotEmpty) {
      final allDone = subs.every((s) => s.isDone);
      final newSubs = subs
          .map((s) => s.copyWith(isDone: !allDone))
          .toList(growable: false);

      final newStatus = (!allDone)
          ? TaskStatus.done.index
          : TaskStatus.todo.index;

      updatedTask = task.copyWith(status: newStatus, subtasks: newSubs);
    } else {
      final isDone = task.status == TaskStatus.done.index;
      updatedTask = task.copyWith(
        status: isDone ? TaskStatus.todo.index : TaskStatus.done.index,
      );
    }

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

  Future<void> addSubTask({
    required String taskId,
    required String title,
  }) async {
    final prev = state.tasks;
    final task = prev.firstWhere((t) => t.id == taskId);

    final trimmed = title.trim();
    if (trimmed.isEmpty) return;

    final newSub = SubTaskModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: trimmed,
      isDone: false,
    );

    final newSubs = [...task.safeSubTasks, newSub];

    final updatedTask = task.copyWith(
      subtasks: List.unmodifiable(newSubs),
      status: _smartStatusFromSubTasks(newSubs), // ✅ will be todo
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

  Future<void> toggleSubTask({
    required String taskId,
    required String subTaskId,
  }) async {
    final prev = state.tasks;

    final task = prev.firstWhere((t) => t.id == taskId);

    final subs = task.safeSubTasks;
    final idx = subs.indexWhere((s) => s.id == subTaskId);
    if (idx == -1) return;

    final toggled = subs[idx].copyWith(isDone: !subs[idx].isDone);
    final newSubs = [...subs]..[idx] = toggled;

    final updatedTask = task.copyWith(
      subtasks: List.unmodifiable(newSubs),
      status: _smartStatusFromSubTasks(newSubs), // ✅ auto sync
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

  Future<void> deleteSubTask({
    required String taskId,
    required String subTaskId,
  }) async {
    final prev = state.tasks;
    final task = prev.firstWhere((t) => t.id == taskId);

    final newSubs = task.safeSubTasks.where((s) => s.id != subTaskId).toList();

    final updatedTask = task.copyWith(
      subtasks: List.unmodifiable(newSubs),
      status: _smartStatusFromSubTasks(newSubs),
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
}
