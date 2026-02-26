import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:todo_list/core/theme/app_theme.dart';
import 'package:todo_list/data/local/hive_init.dart';
import 'package:todo_list/data/local/user_profile_prefs.dart';
import 'package:todo_list/data/repositories/tasks_repository.dart';
import 'package:todo_list/features/onboarding/view/onboarding_screen.dart';
import 'package:todo_list/features/tasks/cubit/tasks_cubit.dart';
import 'package:todo_list/features/today/view/today_dashboard_screen.dart';

// ✅ Settings
import 'package:todo_list/features/settings/cubit/settings_cubit.dart';
import 'package:todo_list/features/settings/cubit/settings_state.dart';

// ✅ Generated localizations (gen-l10n)
import 'package:todo_list/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveInit.init();

  final seenOnboarding = UserProfilePrefs().getOnboardingDone();

  runApp(MyApp(seenOnboarding: seenOnboarding));
}

class MyApp extends StatelessWidget {
  final bool seenOnboarding;
  const MyApp({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [RepositoryProvider(create: (_) => TasksRepository())],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                TasksCubit(context.read<TasksRepository>())..loadTasks(),
          ),
          BlocProvider(create: (_) => SettingsCubit()..load()),
        ],
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, s) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,

              // THEME
              theme: AppTheme.lightTheme(),
              darkTheme: AppTheme.darkTheme(),
              themeMode: s.themeMode,

              // LOCALE
              locale: Locale(s.langCode.isEmpty ? 'en' : s.langCode),

              // ✅ This makes AppLocalizations.of(context) NOT NULL
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,

              home: seenOnboarding
                  ? const TodayDashboardScreen()
                  : const OnboardingScreen(),
            );
          },
        ),
      ),
    );
  }
}
