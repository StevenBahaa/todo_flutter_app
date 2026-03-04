# 🚀 Todo List – Flutter Productivity App

A modern, production-ready productivity app built with **Flutter**.  
Designed to help users plan their day, manage subtasks, and stay focused through a clean and scalable mobile architecture.

This project demonstrates real-world Flutter practices including feature-based structure, Cubit state management, offline-first storage, and polished UI/UX.

---

## 📱 App Preview

### 🧭 Onboarding & Today Dashboard

<p>
  <img src="screenshots/onboarding_profile.jpeg" alt="Onboarding – profile" width="200" />
  &nbsp;&nbsp;&nbsp;
  <img src="screenshots/today_dashboard.jpeg" alt="Today Dashboard" width="200" />
</p>

### ✅ All Done & Task Details

<p>
  <img src="screenshots/today_all_done.jpeg" alt="Today all done" width="200" />
  &nbsp;&nbsp;&nbsp;
  <img src="screenshots/task_details.jpeg" alt="Task Details" width="200" />
</p>

### 🧩 Subtasks & All Tasks

<p>
  <img src="screenshots/sub_tasks.jpeg" alt="Sub Tasks" width="200" />
  &nbsp;&nbsp;&nbsp;
  <img src="screenshots/all_tasks.jpeg" alt="All Tasks & Filters" width="200" />
</p>

### ⚙️ Settings & 🌍 Localization (Arabic)

<p>
  <img src="screenshots/settings.jpeg" alt="Settings" width="200" />
  &nbsp;&nbsp;&nbsp;
  <img src="screenshots/today_dashboard_ar.jpeg" alt="Today Dashboard – Arabic" width="200" />
</p>

---

## ✨ Key Features

### 🌤 Today Dashboard
- Animated progress indicator
- Smart completion tracking
- Urgent tasks section
- Expandable "Completed Today" section
- Upcoming tasks preview
- Overdue highlighting
- Smooth completion animations

---

### 📝 Advanced Task Management

Each task includes:

- Title & description
- Priority levels (Low / Medium / High)
- Optional due date
- Custom tags (e.g. `#flutter`, `#work`, `#urgent`)
- Editable subtasks:
  - Add
  - Rename
  - Toggle
  - Delete

---

### 🧠 Smart Completion Logic

Tasks containing subtasks are marked as completed **only when all subtasks are completed**.

The Today dashboard progress indicator reflects this smart logic instead of relying on a simple checkbox.

---

### 👤 Onboarding Flow

- Collects user name and profile image
- Stores user data locally
- Automatically skips onboarding after first launch

---

### ⚙️ Settings

- Profile management
- Theme selection (Light / Dark)
- Language selection (English / Arabic)
- Full RTL support
- App version section

---

## 🧱 Technical Architecture

### 🔹 Tech Stack

- **Flutter**
- **flutter_bloc (Cubit)**
- **Hive (Local storage)**
- **Feature-based architecture**
- **Flutter gen-l10n localization**

---

## 🏗 Project Structure

```bash
lib/
  app/                    # App shell & routing
  core/                   # Theme, widgets, utilities
  data/
    local/                # Hive initialization & adapters
    models/               # TaskModel, SubTaskModel, enums
    repositories/         # Data abstraction layer
  features/
    onboarding/
    today/
    tasks/
    settings/
  l10n/                   # Localization files (en/ar)