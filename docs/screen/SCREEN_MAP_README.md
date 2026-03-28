# HabitHub – Screen Map

## Overview

**HabitHub** is a comprehensive habit-tracking and task management app with **collaborative and social accountability features**. This screen map outlines all the app screens, key components, and the features they support. It’s intended as a **reference for designers, developers, and product managers** when building or reviewing the app.

---

## Screen Map

### 1. Authentication / Login Screens

| Screen | Components / Sections | Features Supported |
|--------|--------------------|-----------------|
| Login / Sign Up | Email / Google / Apple login buttons, Forgot password, Signup link | AUTH-001 → AUTH-003 |
| Logout Confirmation | Confirmation modal | AUTH-004 |
| Multi-device login info | Active sessions list, revoke button | AUTH-008 |

---

### 2. User Profile Screens

| Screen | Components | Features Supported |
|--------|------------|-----------------|
| Profile View | Avatar, username, bio, timezone, language, dark mode toggle, visibility settings | USER-001 → USER-010 |
| Edit Profile | Form to edit name, bio, avatar, timezone, language | USER-002, USER-003 |
| Public Profile | Profile visible to other users | USER-004, USER-005 |

---

### 3. Habit Screens

| Screen | Components | Features Supported |
|--------|------------|-----------------|
| Habit List / Dashboard | Cards for each habit, color/icon, streak, category, completion status | HABIT-001 → HABIT-020 |
| Habit Detail | Notes, history, difficulty, tags, pause/resume | HABIT-009 → HABIT-018 |
| Habit Creation | Title, schedule, reminders, category, icon/color | HABIT-001, HABIT-006 → HABIT-008 |
| Habit Sharing | Share to friends/groups, followers, public/private visibility | SHARE-001, SOCIAL-001 → SOCIAL-008 |

---

### 4. Task Screens

| Screen | Components | Features Supported |
|--------|------------|-----------------|
| Task List | Tasks grouped by date / priority, tags, progress status | TASK-001 → TASK-014 |
| Task Detail | Subtasks, checklist, notes, attachments, assign users, progress | TASK-011 → TASK-014 |
| Task Creation | Title, description, due date, repeat, priority, assign user | TASK-001 → TASK-008 |

---

### 5. Calendar Screens

| Screen | Components | Features Supported |
|--------|------------|-----------------|
| Daily View | Timeline, habits & tasks marked, drag to reschedule | CAL-001, CAL-005, CAL-006 |
| Weekly View | Week grid, habits & tasks, filters | CAL-002, CAL-008 |
| Monthly View | Monthly overview, events, search | CAL-003, CAL-009 |
| Event Detail | Habit/task detail, comments, assign | CAL-010 |
| Calendar Navigation | Date picker, next/previous, today button | CAL-004 |

---

### 6. Sharing & Collaboration Screens

| Screen | Components | Features Supported |
|--------|------------|-----------------|
| Share Habit/Task | Select users, generate links, revoke access | SHARE-001 → SHARE-010 |
| Invite User | Invite modal with permissions | SHARE-004 → SHARE-006 |
| Permission Management | View/edit permissions per user | PERM-001 → PERM-005 |
| Social Feed | Activity feed, comments, reactions | SOCIAL-008, SOCIAL-004 → SOCIAL-005 |

---

### 7. Reminder & Notification Screens

| Screen | Components | Features Supported |
|--------|------------|-----------------|
| Reminder Settings | Habit/task reminders, friend reminders, daily summary | REM-001 → REM-005 |
| Notification Settings | Push, in-app, email notifications | NOTIF-001 → NOTIF-004 |
| Missed Habits / Alerts | List of missed habits, mark as completed | REM-003 |

---

### 8. Statistics / Analytics Screens

| Screen | Components | Features Supported |
|--------|------------|-----------------|
| Habit Stats Dashboard | Completion %, streaks, charts | STATS-001 → STATS-006 |
| Weekly Report | Summary of habits & tasks | STATS-003 |
| Monthly Report | Visual analytics, comparison charts | STATS-004 |

---

### 9. Search & Explore Screens

| Screen | Components | Features Supported |
|--------|------------|-----------------|
| Search Bar | Search habits, tasks, users | SEARCH-001 → SEARCH-003 |
| Search Results | Filterable list with preview | SEARCH-001 → SEARCH-003 |

---

### 10. Sync & Backup Screens

| Screen | Components | Features Supported |
|--------|------------|-----------------|
| Sync Status | Cloud sync, offline mode | SYNC-001 → SYNC-004 |
| Backup & Restore | Export / import / restore data | DATA-001 → DATA-004 |

---

### 11. AI / Future Features Screens

| Screen | Components | Features Supported |
|--------|------------|-----------------|
| AI Suggestions | Recommended habits/tasks | AI-001 → AI-004 |
| AI Insights | Productivity tips, progress analysis | AI-002, AI-003 |
| AI Planning | Suggest daily / weekly plans | AI-004 |

---

## Notes

- Each **module** (Habits, Tasks, Calendar) typically has a **dashboard + detail + creation screen**.  
- **Sharing & social features** are accessible from habit/task detail screens.  
- **Reminders/notifications** have global settings and per-habit/task overrides.  
- **Statistics / AI insights** are available in profile/dashboard menu.