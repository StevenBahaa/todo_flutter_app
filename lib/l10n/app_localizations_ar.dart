// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get settings => 'الإعدادات';

  @override
  String get manageProfile => 'إدارة الملف الشخصي';

  @override
  String get theme => 'المظهر';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get language => 'اللغة';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get welcomeBack => 'مرحبًا بعودتك،';

  @override
  String get today => 'اليوم';

  @override
  String get upcoming => 'القادم';

  @override
  String get urgentForToday => 'المهم لليوم';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get nothingScheduled => 'لا يوجد مهام لليوم ✨';

  @override
  String get addTaskStartDay => 'أضف مهمة وابدأ يومك.';

  @override
  String get done => 'تم';

  @override
  String get allDone => 'تم الكل';

  @override
  String get allTasksDoneToday => 'كل مهام اليوم تمت 🎉';

  @override
  String get todayCompleted => 'اليوم (مكتمل)';

  @override
  String tasksLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مهمة متبقية',
      many: '$count مهمة متبقية',
      few: '$count مهام متبقية',
      two: 'مهمتان متبقيتان',
      one: 'مهمة واحدة متبقية',
      zero: 'لا توجد مهام متبقية',
    );
    return '$_temp0';
  }

  @override
  String get overdue => 'متأخرة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get deleteTaskTitle => 'حذف المهمة؟';

  @override
  String deleteTaskBody(String title) {
    return 'سيتم حذف “$title”.';
  }

  @override
  String moreCount(int count) {
    return '+$count المزيد';
  }

  @override
  String get priorityLow => 'منخفض';

  @override
  String get priorityMedium => 'متوسط';

  @override
  String get priorityHigh => 'مرتفع';

  @override
  String get quickAddTaskTitle => 'إضافة مهمة بسرعة';

  @override
  String get add => 'إضافة';

  @override
  String get taskTitleHint => 'عنوان المهمة...';

  @override
  String get due => 'الموعد';

  @override
  String get addTagsHint => 'أضف وسوم (مثال: عمل، عاجل)';

  @override
  String get allTasksTitle => 'كل المهام';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterOverdue => 'متأخرة';

  @override
  String get filterToday => 'اليوم';

  @override
  String get filterHighPriority => 'أولوية عالية';

  @override
  String get overdueTitle => 'متأخرة';

  @override
  String get todayTitle => 'اليوم';

  @override
  String get highPriorityTitle => 'أولوية عالية';

  @override
  String get noOverdueTasks => 'لا توجد مهام متأخرة 🎉';

  @override
  String get noTasksForToday => 'لا توجد مهام لليوم';

  @override
  String get noHighPriorityTasks => 'لا توجد مهام بأولوية عالية';

  @override
  String get noTasksYet => 'لا توجد مهام بعد. اضغط + لإضافة مهمة.';

  @override
  String get sectionOverdueUpper => 'متأخرة';

  @override
  String get sectionTodayUpper => 'اليوم';

  @override
  String get sectionUpcomingUpper => 'قادمة';

  @override
  String get sectionNoDateUpper => 'بدون موعد';

  @override
  String get completedLabel => 'مكتمل';

  @override
  String get completedTodayTitle => 'مكتمل اليوم';

  @override
  String get view => 'عرض';

  @override
  String get addTask => 'إضافة مهمة';

  @override
  String get taskDetailsTitle => 'تفاصيل المهمة';

  @override
  String get titleLabel => 'العنوان';

  @override
  String get descriptionLabel => 'الوصف';

  @override
  String get descriptionHint => 'أضف ملاحظات...';

  @override
  String get priorityLabel => 'الأولوية';

  @override
  String get deleteTaskCannotUndo => 'لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get noDueDate => 'بدون موعد';

  @override
  String get pick => 'اختيار';

  @override
  String get clear => 'مسح';

  @override
  String get tagsLabel => 'الوسوم';

  @override
  String get noTags => 'لا توجد وسوم';

  @override
  String get user => 'مستخدم';

  @override
  String get todayTasks => 'مهام اليوم';

  @override
  String get incoming => 'القادم';

  @override
  String overdueCount(int count) {
    return '$count متأخرة';
  }

  @override
  String get editName => 'تعديل الاسم';

  @override
  String get yourName => 'اسمك';

  @override
  String get changePhoto => 'تغيير الصورة';

  @override
  String get removePhoto => 'حذف الصورة';

  @override
  String get save => 'حفظ';

  @override
  String get tags => 'الوسوم';
}
