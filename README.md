# Todo List – Flutter Productivity App

A modern, mobile‑first todo app built with Flutter.  
Plan your day, break tasks into subtasks, track progress, and stay focused with a clean, dark UI and offline‑first storage.

---

## ✨ Features

- **Today dashboard**
  - Shows today’s tasks, progress bar, and overdue status.
  - Highlights incoming tasks and completed tasks in separate sections.
- **Rich task details**
  - Title & description
  - Priority (Low / Medium / High)
  - Due date (or “no date”)
  - Tags for quick context (e.g. `#flutter`, `#work`, `#urgent`)
  - Editable subtasks (add, toggle, rename, delete)
- **Smart completion**
  - Tasks with subtasks are only considered *done* when all subtasks are done.
  - Today progress uses this “smart” completion instead of just a simple checkbox.
- **Onboarding**
  - Collects user name and profile photo on first launch.
  - Skips onboarding automatically on future launches.
- **Settings**
  - Manage profile (name + photo)
  - Theme selection: light / dark (UI optimized for dark)
  - Language selection: English / Arabic, with proper RTL layout.
  - App version section.
- **Offline‑first storage**
  - All tasks, subtasks, and user profile data are stored locally using Hive.

---

## 🧱 Tech Stack & Architecture

- **Framework**: Flutter (Dart)
- **State management**: `flutter_bloc`
  - `TasksCubit` – loads and manages all tasks, subtasks, filters, and completion logic.
  - `SettingsCubit` – manages theme mode, language, and profile data.
- **Local storage**: Hive
  - `TaskModel`, `SubTaskModel`, and user profile stored in Hive boxes.
  - `TasksRepository` wraps Hive access.
- **Localization**: Flutter `gen-l10n`
  - `app_en.arb` and `app_ar.arb` for English/Arabic strings.
- **UI**
  - Custom theming with `AppTheme` and `theme_x.dart` extensions.
  - Responsive sizing using `R(context)` helper.
  - Feature‑oriented folder structure.

---

## 🗂 Project Structure (high level)

lib/
  app/                    # App shell & routing
  core/                   # Theme, widgets, utils, SFX
  data/
    local/                # Hive init, adapters, prefs
    models/               # TaskModel, SubTaskModel, enums, user profile
    repositories/         # TasksRepository
  features/
    onboarding/           # Onboarding flow (name + photo)
    today/                # Today dashboard
    tasks/                # All tasks list, task details, quick add, widgets
    settings/             # Settings screen & cubit
  l10n/                   # Generated localization files (en/ar)
