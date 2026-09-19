# MASTER PROMPT: TASKPULSE SYSTEM DOCUMENTATION & TECHNICAL REPORT GENERATOR

> **HOW TO USE THIS PROMPT:**
> Copy the entire prompt text below (everything inside the block) and paste it into **Claude** (Claude 3.5 Sonnet / Opus). Claude will generate an exhaustive, publication-grade, 25+ page equivalent Software Engineering Project Report & System Architecture Specification for your college submission, project viva, portfolio, or enterprise review.

---

```markdown
You are an Elite Principal Software Architect, Cloud Solutions Specialist, and Technical Author. 
Your task is to generate a comprehensive, publication-ready, formal, and exhaustive **Software Requirements & Technical Architecture Specification Document** for a modern enterprise-grade application named **"TaskPulse — Project & Task Management System"**.

Generate the documentation in full depth, with complete technical rigor, detailed architecture diagrams (using Mermaid.js and ASCII), database schemas, API contracts, security models, test suites, and team contribution breakdowns. Do NOT use placeholders, ellipsis ("..."), or lazy abbreviations. Every section must be written out with granular clarity.

---

# PROJECT IDENTIFIER & META INFORMATION
- **Application Name**: TaskPulse — Project & Task Management System
- **Repository**: https://github.com/naman1167/Flutter_Project-_-_Task_Management_System
- **Core Technology Stack**: Flutter (v3.41.6+), Dart (v3.11.4+), Provider Architecture (v6.1.5+), Firebase Ecosystem (Firebase Auth, Cloud Firestore, Firebase Core)
- **Target Platforms**: Web (Chrome, Safari, Edge), Android (Native ARM64 APK), macOS Desktop, iOS
- **Database Engine**: Google Cloud Firestore (NoSQL Document Store)
- **Authentication Provider**: Firebase Authentication (Email/Password Protocol)
- **Firebase Project ID**: `mini-project-flutter-59761`
- **Firebase Auth Domain**: `mini-project-flutter-59761.firebaseapp.com`
- **Firebase Storage Bucket**: `mini-project-flutter-59761.firebasestorage.app`

---

# PROJECT TEAM ROSTER & CORE CONTRIBUTIONS

Document the project team members, designated roles, and exact architectural responsibilities in a formal contribution matrix:

1. **Soham Karandikar** — *Tech Lead & Software Architect*
   - Core Responsibilities: High-level system architecture design, Data Models schema definition (`TaskItem`, `Project`, `TeamMember`, `ActivityLog`, `AppNotification`), State Management engine using Provider (`AppState`), immutability patterns (`copyWith`), and domain integrity.
2. **Naman Sethi** — *Project Lead & Senior Software Engineer*
   - Core Responsibilities: End-to-end UI/UX Engineering, Multi-platform Responsive Layouts (`LayoutBuilder` & dynamic breakpoints), Navigation Shell, Kanban Board drag-and-drop lifecycle, Authentication workflows (Sign In, Sign Up, Guest session fallback), and APK compilation pipeline.
3. **Aavani Perumbessi** — *Backend & Cloud Systems Specialist*
   - Core Responsibilities: Google Firebase integration (`firebase_core`, `firebase_auth`, `cloud_firestore`), NoSQL collection architecture, database synchronization protocols, real-time optimistic UI update pipelines, and Tamper-Evident Audit Ledger persistence.
4. **Naaz Ahmedi** — *Product Designer (UI/UX) & Frontend Specialist*
   - Core Responsibilities: Design system specification (`AppTheme`), typography scales (Google Fonts Inter), semantic color tokens (Indigo `#4F46E5`, Sky Blue `#0EA5E9`, Emerald `#10B981`, Amber `#F59E0B`, Crimson `#EF4444`), visual accessibility (contrast ratios, zero overflow constraints), and component library (`TaskCard`, `StatusBadge`, `PriorityBadge`, `MemberAvatar`).

---

# REQUIRED DOCUMENTATION STRUCTURE & SECTIONS

Please generate the documentation structured across the following 12 detailed chapters:

## CHAPTER 1: EXECUTIVE SUMMARY & PROBLEM STATEMENT
- 1.1 Executive Overview: Purpose and mission of TaskPulse.
- 1.2 Industry Context & Problem Statement: The challenges of fragmented project management tools (lack of transparency, disconnected communication, absent audit trails, untracked deadline slips, and poor cross-device responsiveness).
- 1.3 Proposed Architectural Solution: How TaskPulse solves these problems with a unified, real-time, responsive Flutter/Firebase system.
- 1.4 Target Audience & Use Cases: Fast-paced agile software development teams, cross-functional student engineering groups, and project managers requiring verifiable accountability.

## CHAPTER 2: HIGH-LEVEL ARCHITECTURE & DESIGN PATTERNS
- 2.1 Architectural Pattern: Clean Architecture & Modular Layering (Presentation Layer, Domain Model Layer, State/Business Logic Layer, Cloud Service Layer).
- 2.2 Mermaid Diagram: End-to-End System Architecture (User Interface -> Provider State Manager -> Firebase Service -> Cloud Firestore & Firebase Auth).
- 2.3 State Management Rationale: Why Provider with `ChangeNotifier` was selected over BLoC, Riverpod, or Redux for this application (predictable reactive binding, low boilerplate, memory efficiency, decoupled widget rebuilding).
- 2.4 Immutability & Data Integrity: Use of Dart's `copyWith` pattern for transactional entity updates.

## CHAPTER 3: FRONTEND ARCHITECTURE & RESPONSIVE UI SYSTEM
- 3.1 Framework Selection: Flutter 3.x and Dart 3.x strengths (single codebase, 60+ FPS Skia/Impeller rendering, native ARM64 compilation).
- 3.2 Responsive & Adaptive Layout Strategy:
  - Breakpoint taxonomy: Compact Mobile (<600px), Tablet / Mid-size (600px - 800px), Desktop / Large Display (>800px).
  - Implementation mechanisms: `LayoutBuilder`, `MediaQuery`, responsive AppBar with collapsed profile popups, multi-row wrapping, and flexible typography.
  - Zero-Overflow Guarantee: How RenderFlex layout exceptions were structurally prevented across extreme constraints (380x800 mobile viewport testing).
- 3.3 Design System & Visual Identity:
  - Color Tokens (Primary Indigo `#4F46E5`, Secondary Cyan `#0EA5E9`, Neutral Dark `#0F172A`, Slate Border `#E2E8F0`).
  - Typography: Google Fonts Inter hierarchy (Display, Headlines, Title, Body, Caption).
  - Semantic Badging: Priority levels (Low, Medium, High, Urgent) and Status indicators.

## CHAPTER 4: BACKEND & DATABASE SPECIFICATION (CLOUD FIRESTORE)
- 4.1 Cloud Infrastructure: Google Firebase BaaS architecture.
- 4.2 Data Models & Schema Design (Provide complete JSON schema for every collection):
  - Collection 1: `users` (`uid`, `name`, `email`, `role`, `colorValue`, `createdAt`)
  - Collection 2: `projects` (`id`, `title`, `description`, `colorValue`, `memberIds`, `createdAt`, `deadline`)
  - Collection 3: `tasks` (`id`, `projectId`, `title`, `description`, `assigneeId`, `priority`, `status`, `dueDate`, `createdAt`, `comments`)
  - Collection 4: `activityLogs` (`id`, `timestamp`, `actorName`, `actionType`, `entityType`, `entityTitle`, `details`, `projectId`)
  - Collection 5: `notifications` (`id`, `title`, `message`, `timestamp`, `isRead`, `type`, `relatedTaskId`, `relatedProjectId`)
- 4.3 Offline Resilience & Optimistic UI Updates: How the app updates state in memory immediately while writing to Firestore asynchronously in background threads.
- 4.4 Firestore Security Rules: Production-grade security rules validating authenticated read/write access.

## CHAPTER 5: AUTHENTICATION & ACCESS CONTROL SPECIFICATION
- 5.1 Authentication Mechanism: Firebase Auth with Email & Password.
- 5.2 User Lifecycle Flows:
  - Account Creation (Sign Up): Client-side validation, password strength rules (min 6 characters), role selection, profile persistence in Firestore, and auto-insertion into team roster.
  - Authentication (Sign In): Credential verification, token retrieval, error mapping (`user-not-found`, `wrong-password`, `invalid-email`).
  - Session Management: Real-time listener (`authStateChanges()`), dynamic user role propagation, and clean Session Termination (Sign Out).
  - Presentation / Viva Demo Mode: One-click test credential fill chips for rapid examination and grading.

## CHAPTER 6: CORE MODULE SPECIFICATIONS & WORKFLOWS
Detail the functionality, user experience, and technical execution of each module:
- 6.1 Executive Dashboard (`dashboard_screen.dart`):
  - KPI Metrics calculations: Total Projects, Pending Tasks, Overdue count, Workspace Completion Percentage formula.
  - Attention Required Queue: Automated query for overdue/urgent tasks.
  - Live Activity Preview: Recent audit trail stream.
- 6.2 Project Workspace Management (`projects_screen.dart`):
  - Project Cards: Dynamic progress indicators, squad avatars, target deadline countdowns.
  - Creation & Deletion Dialogs: Input validation and cascading task cleanup.
- 6.3 Interactive Kanban Board & List Views (`project_detail_screen.dart`):
  - 4-Column Workflow (To Do ➔ In Progress ➔ In Review ➔ Completed).
  - Drag & Drop interaction and 1-tap 3-dots context menu status transitions.
  - Dual View Toggle: Kanban cards vs. tabular List View.
  - Multi-Parameter Filter Engine: Real-time filtering by Priority, Assignee, and keyword search.
- 6.4 In-Context Collaboration & Threaded Comments (`task_detail_modal.dart`):
  - Per-task bottom sheet modal.
  - Dynamic reassignment dropdown.
  - Threaded comment system with author avatars, role badges, and relative timestamps.
- 6.5 Immutable Audit Trail & Black Box Ledger (`activity_log_screen.dart`):
  - Tamper-evident activity logging for every event (`PROJECT_CREATED`, `TASK_CREATED`, `STATUS_CHANGE`, `ASSIGNMENT`, `COMMENT_ADDED`, `MEMBER_JOINED`, `REMINDER_CHECK`).
  - Real-time search by Actor, Entity Title, and action descriptions.
  - Multi-category filter bars (Action Filter & Project Filter).
- 6.6 Proactive Deadline Scanner & Notification Center (`notifications_screen.dart`):
  - Background scanning engine (`scanUpcomingDeadlines()`).
  - Critical deadline rules (<24h alert, overdue alert).
  - Notification badge in AppBar and "Mark All as Read" functionality.
- 6.7 Team & Workload Balancing Directory (`team_screen.dart`):
  - Team member roster with initials avatars (`SK`, `NS`, `AP`, `NA`).
  - Real-time Workload Balancer: Dynamic classification (`Available`, `Active`, `High Workload`) based on uncompleted task distribution.

## CHAPTER 7: CODEBASE STRUCTURE & DIRECTORY WALKTHROUGH
Provide a complete breakdown of the codebase file tree and the role of every single file:
- Root: `pubspec.yaml`, `analysis_options.yaml`, `README.md`, `.gitignore`
- `lib/models/models.dart`: Enums (`TaskStatus`, `TaskPriority`, `NotificationType`), domain entities, getters (`isOverdue`, `isDueSoon`, `initials`), `copyWith`.
- `lib/providers/app_state.dart`: Central state controller, ChangeNotifier, getters, operations, audit dispatchers, and Firestore sync.
- `lib/services/firebase_service.dart`: Firebase Auth & Firestore CRUD operations.
- `lib/firebase_options.dart`: Multi-platform Firebase configuration options.
- `lib/screens/`: Detailed purpose of all 7 screens (`auth_screen.dart`, `dashboard_screen.dart`, `projects_screen.dart`, `project_detail_screen.dart`, `activity_log_screen.dart`, `notifications_screen.dart`, `team_screen.dart`).
- `lib/widgets/`: Reusable components (`task_card.dart`, `task_detail_modal.dart`, `create_task_dialog.dart`, `create_project_dialog.dart`, `member_avatar.dart`, `priority_badge.dart`, `status_badge.dart`).
- `lib/theme/app_theme.dart`: Design system, color tokens, and Google Fonts Inter configuration.
- `lib/main.dart`: App bootstrap, Firebase initialization, Auth Gate, and responsive navigation shell.

## CHAPTER 8: AUDIT TRAIL, SECURITY & COMPLIANCE
- 8.1 Audit Trail as an Enterprise Compliance Feature (ISO 27001 / SOC 2 style traceability).
- 8.2 Log Schema immutability and actor non-repudiation.
- 8.3 Data Protection: Password hashing via Firebase Auth, secure communication over TLS 1.3, and Firestore rule constraints.

## CHAPTER 9: VERIFICATION, TESTING & QUALITY ASSURANCE
- 9.1 Unit Testing (`app_state_test.dart`): Verification of state initialization, project creation, task assignment, status transitions, comments, and deadline scans.
- 9.2 Widget & Responsive UI Testing (`widget_test.dart`):
  - End-to-end user navigation flow across all tabs.
  - Extreme viewport test: Narrow mobile viewport (380x800) verifying **Zero Overflows**.
- 9.3 Static Code Analysis: `dart analyze` execution report confirming 0 errors, 0 warnings, and 100% linter compliance.

## CHAPTER 10: DEPLOYMENT, BUILD PIPELINE & RELEASE ARTIFACTS
- 10.1 Web Deployment Pipeline: Flutter Web compilation with HTML5 Canvas/HTML renderer.
- 10.2 Android Release Build Pipeline:
  - Gradle task `assembleRelease`.
  - Icon tree-shaking (MaterialIcons optimization by 99.3%).
  - Standalone Android APK artifact generation (`TaskPulse.apk`, 48 MB) and export.
- 10.3 Version Control & GitHub Repository: Branch management, commit history, and release tracking on `naman1167/Flutter_Project-_-_Task_Management_System`.

## CHAPTER 11: USER MANUAL & STEP-BY-STEP OPERATIONAL GUIDE
- Provide an end-to-end visual walkthrough guide explaining how an end user or project manager operates TaskPulse from Sign Up to Project Creation, Task Assignment, Kanban Drag-and-Drop, Team Commenting, and Audit Review.

## CHAPTER 12: CONCLUSION, PROJECT IMPACT & FUTURE ROADMAP
- 12.1 Project Conclusion: Summary of architectural accomplishments.
- 12.2 Academic & Industry Significance: Demonstration of state-of-the-art Flutter cross-platform software engineering.
- 12.3 Future Roadmap: Real-time WebSockets / FCM push notifications, offline SQLite synchronization, automated sprint burndown velocity charts, and role-based workspace permissions (RBAC).

---

# INSTRUCTIONS FOR WRITING
- Write with extreme depth, technical rigor, and clarity.
- Use professional Markdown formatting, tables, ASCII diagrams, Mermaid diagrams, and code snippets.
- Ensure the four team members (Soham Karandikar, Naman Sethi, Aavani Perumbessi, Naaz Ahmedi) and their distinct roles are prominently featured in the project credits and contribution matrix.
- Generate the complete document from start to finish without omitting any chapter.
```
