// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get manageProfile => 'Manage Profile';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get welcomeBack => 'Welcome back,';

  @override
  String get today => 'Today';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get urgentForToday => 'Urgent for Today';

  @override
  String get seeAll => 'See all';

  @override
  String get nothingScheduled => 'Nothing scheduled for today ✨';

  @override
  String get addTaskStartDay => 'Add a task and start your day.';

  @override
  String get done => 'DONE';

  @override
  String get allDone => 'ALL DONE';

  @override
  String get allTasksDoneToday => 'All tasks done for today 🎉';

  @override
  String get todayCompleted => 'Today (Completed)';

  @override
  String tasksLeft(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks left',
      one: '1 task left',
      zero: 'No tasks left',
    );
    return '$_temp0';
  }

  @override
  String get overdue => 'OVERDUE';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get deleteTaskTitle => 'Delete task?';

  @override
  String deleteTaskBody(String title) {
    return '“$title” will be removed.';
  }

  @override
  String moreCount(num count) {
    return '+$count more';
  }

  @override
  String get priorityLow => 'LOW';

  @override
  String get priorityMedium => 'MEDIUM';

  @override
  String get priorityHigh => 'HIGH';

  @override
  String get quickAddTaskTitle => 'Quick Add Task';

  @override
  String get add => 'Add';

  @override
  String get taskTitleHint => 'Task title...';

  @override
  String get due => 'Due';

  @override
  String get addTagsHint => 'Add tags (e.g. work, urgent)';

  @override
  String get allTasksTitle => 'All Tasks';

  @override
  String get filterAll => 'All';

  @override
  String get filterOverdue => 'Overdue';

  @override
  String get filterToday => 'Today';

  @override
  String get filterHighPriority => 'High Priority';

  @override
  String get overdueTitle => 'Overdue';

  @override
  String get todayTitle => 'Today';

  @override
  String get highPriorityTitle => 'High Priority';

  @override
  String get noOverdueTasks => 'No overdue tasks 🎉';

  @override
  String get noTasksForToday => 'No tasks for today';

  @override
  String get noHighPriorityTasks => 'No high priority tasks';

  @override
  String get noTasksYet => 'No tasks yet. Tap + to add one.';

  @override
  String get sectionOverdueUpper => 'OVERDUE';

  @override
  String get sectionTodayUpper => 'TODAY';

  @override
  String get sectionUpcomingUpper => 'UPCOMING';

  @override
  String get sectionNoDateUpper => 'NO DATE';

  @override
  String get completedLabel => 'Completed';

  @override
  String get completedTodayTitle => 'Completed Today';

  @override
  String get view => 'View';

  @override
  String get addTask => 'Add task';

  @override
  String get taskDetailsTitle => 'Task Details';

  @override
  String get titleLabel => 'Title';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get descriptionHint => 'Add notes...';

  @override
  String get priorityLabel => 'Priority';

  @override
  String get deleteTaskCannotUndo => 'This action can\'t be undone.';

  @override
  String get noDueDate => 'No due date';

  @override
  String get pick => 'Pick';

  @override
  String get clear => 'Clear';

  @override
  String get tagsLabel => 'Tags';

  @override
  String get noTags => 'No tags';
}
