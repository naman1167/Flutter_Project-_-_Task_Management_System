# TaskPulse — Project & Task Management System

A production-grade, responsive Flutter application designed for high-velocity teams to organize projects, track task lifecycles across Kanban boards, collaborate in real-time, scan upcoming deadlines, and maintain a verifiable audit trail of every workspace action.

---

## 👥 Project Team

| Team Member | Role | Responsibilities |
| :--- | :--- | :--- |
| **Soham Karandikar** | Tech Lead & Architect | System Architecture, Data Models, State Management |
| **Naman Sethi** | Project Lead & Senior Engineer | UI/UX Engineering, Responsive Layouts, Navigation & Workflows |
| **Aavani Perumbessi** | Backend & Cloud Specialist | Service Contracts, Audit Logging, Data Synchronization |
| **Naaz Ahmedi** | Product Designer (UI/UX) | Design Tokens, Visual Aesthetics, Component Library |

---

## 🌟 Key Features

### 1. 📊 Executive Dashboard
- **Real-Time Workspace Metrics**: Track Active Projects, Pending Tasks, Urgent/Overdue Tasks, and Workspace Completion Percentage.
- **Attention Required Queue**: Highlights overdue and high-priority items needing immediate resolution.
- **Automated Deadline Scanner**: Scan deadlines at any time to generate automated system alerts.
- **Live Activity Feed**: Stream of latest workspace updates.

### 2. 📁 Project Lifecycle & Workspace Management
- Create, manage, and track progress across multiple concurrent projects.
- Set target deadlines, descriptions, custom color branding, and assign member squads.
- Dynamic completion percentage based on child task completion status.

### 3. 📋 Interactive Kanban Board & List Views
- **4-Stage Kanban Workflow**:
  - 📝 **To Do**: Backlog items awaiting sprint kickoff.
  - ⚡ **In Progress**: Active development tasks.
  - 🔍 **In Review**: Tasks undergoing peer review or QA testing.
  - ✅ **Completed**: Verified deliverables with strike-through presentation.
- **Dual View Modes**: Switch between Kanban cards and a dense, filterable table/list view.
- **Multi-Factor Filtering**: Filter tasks in real-time by Priority (Low, Medium, High, Urgent), Assignee, or keyword search.

### 4. 💬 Task Details & In-Context Collaboration
- Comprehensive bottom-sheet modal for task editing.
- Dynamic assignment to any team member.
- Priority tagging with semantic badges.
- **Team Comments**: Add threaded comments with author avatars and precise timestamps.
- **Per-Task History**: Scoped view of audit actions taken specifically on that task.

### 5. 🛡️ Audit Trail & Activity Logging (Black Box Ledger)
- Immutable, tamper-evident audit logging for every workspace action:
  - `PROJECT_CREATED`
  - `TASK_CREATED`
  - `STATUS_CHANGE`
  - `ASSIGNMENT`
  - `COMMENT_ADDED`
- Filterable audit logs by Project and Action Type.

### 6. 🔔 Proactive Notifications & Reminders
- Critical alerts for overdue deliverables and upcoming deadlines (<24h).
- Review requests and assignment pings.
- One-click "Mark All as Read" and instant deadline audit refresh.

### 7. 👥 Team & Workload Directory
- Directory of all team members with roles, emails, and initials avatars.
- **Live Workload Tracking**: Real-time badges indicating member capacity (`Available`, `Active`, or `High Workload`).

---

## 📱 Responsive & Adaptive Design
- Built for all screen sizes:
  - **Mobile Viewports (<600px)**: Compact adaptive headers, stacked metric cards, mobile navigation drawer/bottom navigation.
  - **Desktop / Tablet Viewports (>600px)**: Persistent rail navigation, multi-column Kanban board, wide filter toolbars.
- **Zero Pixel Overflows**: Thoroughly tested across narrow mobile viewports (380x800) and wide desktop displays.

---

## 🛠️ Technology Stack

- **Framework**: [Flutter](https://flutter.dev) (v3.41.6+, Dart 3.11.4+)
- **Architecture & State Management**: [Provider](https://pub.dev/packages/provider) (`ChangeNotifier` reactive architecture)
- **Typography & Icons**: [Google Fonts](https://pub.dev/packages/google_fonts) (Inter font family), Material Icons
- **Formatting & Utilities**: [intl](https://pub.dev/packages/intl)
- **Target Platforms**: Web (Chrome, Safari, Edge), Android (APK), iOS, macOS Desktop

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed (`>=3.41.0`)
- Android SDK (for Android builds) or Google Chrome (for Web)

### Installation
```bash
# Clone repository
git clone https://github.com/naman1167/Flutter_Project-_-_Task_Management_System.git

# Navigate to project folder
cd Flutter_Project-_-_Task_Management_System

# Install dependencies
flutter pub get
```

### Running the App
```bash
# Run on Google Chrome
flutter run -d chrome

# Run on Android emulator or connected device
flutter run -d android

# Run on macOS desktop
flutter run -d macos
```

### Running Tests
```bash
# Run all unit and widget tests
flutter test

# Run static analysis
dart analyze
```

---

## 📦 Building Android APK

To generate a standalone APK:

```bash
flutter build apk --release
```
The resulting APK will be located at:
`build/app/outputs/flutter-apk/app-release.apk`
