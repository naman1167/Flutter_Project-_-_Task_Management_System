import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';

class AppState extends ChangeNotifier {
  final _uuid = const Uuid();
  final FirebaseService _firebaseService = FirebaseService();

  // Current logged in user profile (for audit logging & collaboration)
  String _currentUser = 'Naman Sethi';
  String _currentUserRole = 'Project Lead & Senior Engineer';
  String _currentUserEmail = 'naman.sethi@example.com';
  User? _firebaseUser;
  StreamSubscription<User?>? _authSubscription;

  String get currentUser => _currentUser;
  String get currentUserRole => _currentUserRole;
  String get currentUserEmail => _currentUserEmail;
  User? get firebaseUser => _firebaseUser;
  bool get isAuthenticated => _firebaseUser != null;

  // State collections
  List<TeamMember> _teamMembers = [];
  List<Project> _projects = [];
  List<TaskItem> _tasks = [];
  List<ActivityLog> _activityLogs = [];
  List<AppNotification> _notifications = [];

  // Selected project filter in board/list (null = All projects)
  String? _selectedProjectId;

  // Getters
  List<TeamMember> get teamMembers => List.unmodifiable(_teamMembers);
  List<Project> get projects => List.unmodifiable(_projects);
  List<TaskItem> get tasks => List.unmodifiable(_tasks);
  List<ActivityLog> get activityLogs => List.unmodifiable(_activityLogs);
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  String? get selectedProjectId => _selectedProjectId;

  int get unreadNotificationsCount =>
      _notifications.where((n) => !n.isRead).length;

  int get totalTasksCount => _tasks.length;
  int get completedTasksCount =>
      _tasks.where((t) => t.status == TaskStatus.completed).length;
  int get inProgressTasksCount =>
      _tasks.where((t) => t.status == TaskStatus.inProgress).length;
  int get inReviewTasksCount =>
      _tasks.where((t) => t.status == TaskStatus.inReview).length;
  int get todoTasksCount =>
      _tasks.where((t) => t.status == TaskStatus.todo).length;

  int get overdueTasksCount => _tasks.where((t) => t.isOverdue).length;
  int get dueSoonTasksCount => _tasks.where((t) => t.isDueSoon).length;

  double get overallCompletionRate {
    if (_tasks.isEmpty) return 0.0;
    return completedTasksCount / _tasks.length;
  }

  AppState() {
    _seedInitialData();
    _initAuthListener();
  }

  void _initAuthListener() {
    try {
      _authSubscription = _firebaseService.authStateChanges.listen((user) async {
        _firebaseUser = user;
        if (user != null) {
          _currentUser = user.displayName ?? user.email?.split('@').first ?? 'Member';
          _currentUserEmail = user.email ?? '';

          final profile = await _firebaseService.getUserProfile(user.uid);
          if (profile != null && profile['role'] != null) {
            _currentUserRole = profile['role'];
          }

          final exists = _teamMembers.any(
              (m) => m.email.toLowerCase() == _currentUserEmail.toLowerCase());
          if (!exists && _currentUserEmail.isNotEmpty) {
            _teamMembers.add(TeamMember(
              id: user.uid,
              name: _currentUser,
              email: _currentUserEmail,
              role: _currentUserRole,
              colorValue: 0xFF0EA5E9,
            ));
          }
        }
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Auth listener error: $e');
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  // --- Auth Operations ---

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    await _firebaseService.signUp(
      name: name,
      email: email,
      password: password,
      role: role,
    );
    _currentUser = name;
    _currentUserEmail = email;
    _currentUserRole = role;
    _firebaseUser = _firebaseService.currentUser;

    final exists = _teamMembers
        .any((m) => m.email.toLowerCase() == email.toLowerCase());
    if (!exists) {
      _teamMembers.add(TeamMember(
        id: _firebaseUser?.uid ?? 'member-${_uuid.v4()}',
        name: name,
        email: email,
        role: role,
        colorValue: 0xFF0EA5E9,
      ));
    }

    logActivity(
      actorName: _currentUser,
      actionType: 'MEMBER_JOINED',
      entityType: 'Team',
      entityTitle: name,
      details: 'Registered new workspace account as $role.',
    );
    notifyListeners();
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final cred = await _firebaseService.signIn(email: email, password: password);
    final user = cred.user;
    if (user != null) {
      _firebaseUser = user;
      _currentUser = user.displayName ?? email.split('@').first;
      _currentUserEmail = email;
      final profile = await _firebaseService.getUserProfile(user.uid);
      if (profile != null && profile['role'] != null) {
        _currentUserRole = profile['role'];
      }
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await _firebaseService.signOut();
    _firebaseUser = null;
    notifyListeners();
  }

  void setSelectedProject(String? projectId) {
    _selectedProjectId = projectId;
    notifyListeners();
  }

  TeamMember? getMemberById(String? id) {
    if (id == null) return null;
    try {
      return _teamMembers.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  Project? getProjectById(String? id) {
    if (id == null) return null;
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<TaskItem> getTasksForProject(String? projectId) {
    if (projectId == null || projectId.isEmpty) {
      return _tasks;
    }
    return _tasks.where((t) => t.projectId == projectId).toList();
  }

  int getProjectTaskCount(String projectId) {
    return _tasks.where((t) => t.projectId == projectId).length;
  }

  int getProjectCompletedTaskCount(String projectId) {
    return _tasks
        .where((t) => t.projectId == projectId && t.status == TaskStatus.completed)
        .length;
  }

  double getProjectProgress(String projectId) {
    final total = getProjectTaskCount(projectId);
    if (total == 0) return 0.0;
    final completed = getProjectCompletedTaskCount(projectId);
    return completed / total;
  }

  int getMemberWorkload(String memberId) {
    return _tasks
        .where((t) => t.assigneeId == memberId && t.status != TaskStatus.completed)
        .length;
  }

  // --- Project Operations ---

  Project createProject({
    required String title,
    required String description,
    required int colorValue,
    required List<String> memberIds,
    required DateTime deadline,
  }) {
    final newProject = Project(
      id: _uuid.v4(),
      title: title.trim(),
      description: description.trim(),
      colorValue: colorValue,
      memberIds: memberIds,
      createdAt: DateTime.now(),
      deadline: deadline,
    );

    _projects.insert(0, newProject);
    _firebaseService.saveProject(newProject);

    logActivity(
      actorName: currentUser,
      actionType: 'PROJECT_CREATED',
      entityType: 'Project',
      entityTitle: newProject.title,
      details: 'Created new project with ${memberIds.length} team members assigned.',
      projectId: newProject.id,
    );

    addNotification(
      title: 'New Project Created',
      message: 'Project "${newProject.title}" was launched by $currentUser.',
      type: NotificationType.system,
      relatedProjectId: newProject.id,
    );

    notifyListeners();
    return newProject;
  }

  void updateProject(Project updatedProject) {
    final index = _projects.indexWhere((p) => p.id == updatedProject.id);
    if (index != -1) {
      _projects[index] = updatedProject;
      _firebaseService.saveProject(updatedProject);
      logActivity(
        actorName: currentUser,
        actionType: 'PROJECT_UPDATED',
        entityType: 'Project',
        entityTitle: updatedProject.title,
        details: 'Project details and settings were updated.',
        projectId: updatedProject.id,
      );
      notifyListeners();
    }
  }

  void deleteProject(String projectId) {
    final proj = getProjectById(projectId);
    if (proj != null) {
      _projects.removeWhere((p) => p.id == projectId);
      // Remove or unassign tasks
      _tasks.removeWhere((t) => t.projectId == projectId);

      if (_selectedProjectId == projectId) {
        _selectedProjectId = null;
      }

      logActivity(
        actorName: currentUser,
        actionType: 'PROJECT_DELETED',
        entityType: 'Project',
        entityTitle: proj.title,
        details: 'Project and all associated tasks were deleted.',
      );
      notifyListeners();
    }
  }

  // --- Task Operations (Lifecycle Management) ---

  TaskItem createTask({
    required String projectId,
    required String title,
    required String description,
    required String? assigneeId,
    required TaskPriority priority,
    required TaskStatus status,
    required DateTime dueDate,
  }) {
    final newTask = TaskItem(
      id: _uuid.v4(),
      projectId: projectId,
      title: title.trim(),
      description: description.trim(),
      assigneeId: assigneeId,
      priority: priority,
      status: status,
      dueDate: dueDate,
      createdAt: DateTime.now(),
    );

    _tasks.insert(0, newTask);
    _firebaseService.saveTask(newTask);

    final project = getProjectById(projectId);
    final assignee = getMemberById(assigneeId);

    logActivity(
      actorName: currentUser,
      actionType: 'TASK_CREATED',
      entityType: 'Task',
      entityTitle: newTask.title,
      details: 'Created task in "${project?.title ?? "Project"}" (Priority: ${priority.label}, Status: ${status.label}). Assigned to: ${assignee?.name ?? "Unassigned"}.',
      projectId: projectId,
    );

    if (assignee != null) {
      addNotification(
        title: 'Task Assignment',
        message: 'You have been assigned to "${newTask.title}" in ${project?.title ?? "Project"}.',
        type: NotificationType.assignment,
        relatedTaskId: newTask.id,
        relatedProjectId: projectId,
      );
    }

    notifyListeners();
    return newTask;
  }

  void updateTaskStatus(String taskId, TaskStatus newStatus) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final oldTask = _tasks[index];
      if (oldTask.status == newStatus) return;

      final updatedTask = oldTask.copyWith(status: newStatus);
      _tasks[index] = updatedTask;
      _firebaseService.saveTask(updatedTask);

      logActivity(
        actorName: currentUser,
        actionType: 'STATUS_CHANGE',
        entityType: 'Task',
        entityTitle: updatedTask.title,
        details: 'Transitioned status from [${oldTask.status.label}] to [${newStatus.label}].',
        projectId: updatedTask.projectId,
      );

      // Trigger notification if task moved to Review or Completed
      if (newStatus == TaskStatus.completed) {
        addNotification(
          title: 'Task Completed 🎉',
          message: '"${updatedTask.title}" has been completed by $currentUser.',
          type: NotificationType.statusUpdate,
          relatedTaskId: updatedTask.id,
          relatedProjectId: updatedTask.projectId,
        );
      } else if (newStatus == TaskStatus.inReview) {
        addNotification(
          title: 'Task Needs Review 🔍',
          message: '"${updatedTask.title}" is ready for QA/Review.',
          type: NotificationType.statusUpdate,
          relatedTaskId: updatedTask.id,
          relatedProjectId: updatedTask.projectId,
        );
      }

      notifyListeners();
    }
  }

  void updateTask(TaskItem updatedTask) {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      final oldTask = _tasks[index];
      _tasks[index] = updatedTask;
      _firebaseService.saveTask(updatedTask);

      // Check differences for audit trail
      final List<String> changeNotes = [];
      if (oldTask.status != updatedTask.status) {
        changeNotes.add('Status: ${oldTask.status.label} ➔ ${updatedTask.status.label}');
      }
      if (oldTask.priority != updatedTask.priority) {
        changeNotes.add('Priority: ${oldTask.priority.label} ➔ ${updatedTask.priority.label}');
      }
      if (oldTask.assigneeId != updatedTask.assigneeId) {
        final newAssignee = getMemberById(updatedTask.assigneeId);
        changeNotes.add('Reassigned to: ${newAssignee?.name ?? "Unassigned"}');
      }
      if (oldTask.dueDate != updatedTask.dueDate) {
        changeNotes.add('Deadline updated');
      }

      final details = changeNotes.isNotEmpty
          ? changeNotes.join(' • ')
          : 'Task details updated.';

      logActivity(
        actorName: currentUser,
        actionType: oldTask.assigneeId != updatedTask.assigneeId ? 'ASSIGNMENT' : 'TASK_UPDATED',
        entityType: 'Task',
        entityTitle: updatedTask.title,
        details: details,
        projectId: updatedTask.projectId,
      );

      notifyListeners();
    }
  }

  void deleteTask(String taskId) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      _tasks.removeAt(index);

      logActivity(
        actorName: currentUser,
        actionType: 'TASK_DELETED',
        entityType: 'Task',
        entityTitle: task.title,
        details: 'Task was removed from project.',
        projectId: task.projectId,
      );

      notifyListeners();
    }
  }

  // --- Team Collaboration (Comments & Members) ---

  void addTaskComment(String taskId, String content) {
    if (content.trim().isEmpty) return;

    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final comment = TaskComment(
        id: _uuid.v4(),
        authorName: currentUser,
        authorRole: currentUserRole,
        content: content.trim(),
        timestamp: DateTime.now(),
      );

      _tasks[index].comments.add(comment);

      logActivity(
        actorName: currentUser,
        actionType: 'COMMENT_ADDED',
        entityType: 'Task',
        entityTitle: _tasks[index].title,
        details: 'Added comment: "${content.trim()}"',
        projectId: _tasks[index].projectId,
      );

      notifyListeners();
    }
  }

  void addTeamMember({
    required String name,
    required String email,
    required String role,
    required int colorValue,
  }) {
    final member = TeamMember(
      id: _uuid.v4(),
      name: name.trim(),
      email: email.trim(),
      role: role.trim(),
      colorValue: colorValue,
    );
    _teamMembers.add(member);

    logActivity(
      actorName: currentUser,
      actionType: 'TEAM_MEMBER_ADDED',
      entityType: 'Team',
      entityTitle: member.name,
      details: 'Added ${member.name} (${member.role}) to workspace directory.',
    );

    notifyListeners();
  }

  // --- Notifications & Reminders ---

  void addNotification({
    required String title,
    required String message,
    required NotificationType type,
    String? relatedTaskId,
    String? relatedProjectId,
  }) {
    final notif = AppNotification(
      id: _uuid.v4(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: type,
      relatedTaskId: relatedTaskId,
      relatedProjectId: relatedProjectId,
    );
    _notifications.insert(0, notif);
    _firebaseService.saveNotification(notif);
    notifyListeners();
  }

  void markNotificationAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllNotificationsAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  void generateUpcomingDeadlineReminders() {
    int generatedCount = 0;
    for (final task in _tasks) {
      if (task.status != TaskStatus.completed) {
        if (task.isOverdue) {
          addNotification(
            title: 'Overdue Task Alert ⚠️',
            message: '"${task.title}" was due on ${task.dueDate.day}/${task.dueDate.month}. Action required!',
            type: NotificationType.reminder,
            relatedTaskId: task.id,
            relatedProjectId: task.projectId,
          );
          generatedCount++;
        } else if (task.isDueSoon) {
          addNotification(
            title: 'Deadline Approaching ⏰',
            message: '"${task.title}" is due soon (${task.dueDate.difference(DateTime.now()).inDays + 1} day(s) left).',
            type: NotificationType.reminder,
            relatedTaskId: task.id,
            relatedProjectId: task.projectId,
          );
          generatedCount++;
        }
      }
    }

    if (generatedCount > 0) {
      logActivity(
        actorName: 'System Scheduler',
        actionType: 'REMINDER_CHECK',
        entityType: 'Notification',
        entityTitle: 'Deadline Scanner',
        details: 'Ran automated audit and generated $generatedCount reminder alert(s).',
      );
    }
  }

  // --- Activity Audit Logging ---

  void logActivity({
    required String actorName,
    required String actionType,
    required String entityType,
    required String entityTitle,
    required String details,
    String? projectId,
  }) {
    final log = ActivityLog(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      actorName: actorName,
      actionType: actionType,
      entityType: entityType,
      entityTitle: entityTitle,
      details: details,
      projectId: projectId,
    );
    _activityLogs.insert(0, log);
    _firebaseService.saveActivityLog(log);
  }

  // Seed sample data for high quality preview
  void _seedInitialData() {
    // 1. Team members
    _teamMembers = [
      const TeamMember(
        id: 'member-1',
        name: 'Soham Karandikar',
        email: 'soham.karandikar@example.com',
        role: 'Tech Lead & Architect',
        colorValue: 0xFF6366F1, // Indigo
      ),
      const TeamMember(
        id: 'member-2',
        name: 'Naman Sethi',
        email: 'naman.sethi@example.com',
        role: 'Project Lead & Senior Engineer',
        colorValue: 0xFF0EA5E9, // Sky Blue
      ),
      const TeamMember(
        id: 'member-3',
        name: 'Aavani Perumbessi',
        email: 'aavani.perumbessi@example.com',
        role: 'Backend & Cloud Specialist',
        colorValue: 0xFF10B981, // Emerald
      ),
      const TeamMember(
        id: 'member-4',
        name: 'Naaz Ahmedi',
        email: 'naaz.ahmedi@example.com',
        role: 'Product Designer (UI/UX)',
        colorValue: 0xFFF59E0B, // Amber
      ),
    ];

    // 2. Projects
    final now = DateTime.now();
    _projects = [
      Project(
        id: 'proj-1',
        title: 'FinTech Mobile App Redesign',
        description:
            'Comprehensive overhaul of our core banking & payments mobile app with biometric auth and dark mode.',
        colorValue: 0xFF4F46E5, // Indigo
        memberIds: ['member-1', 'member-2', 'member-4'],
        createdAt: now.subtract(const Duration(days: 14)),
        deadline: now.add(const Duration(days: 18)),
      ),
      Project(
        id: 'proj-2',
        title: 'Microservices & Cloud Migration',
        description:
            'Migrate monolithic billing and identity services to Kubernetes on Google Cloud with zero downtime.',
        colorValue: 0xFF0284C7, // Cyan/Blue
        memberIds: ['member-1', 'member-3'],
        createdAt: now.subtract(const Duration(days: 20)),
        deadline: now.add(const Duration(days: 8)),
      ),
      Project(
        id: 'proj-3',
        title: 'Real-time Analytics Dashboard',
        description:
            'Develop an internal operational portal for streaming transactions, error budgets, and SLA tracking.',
        colorValue: 0xFF059669, // Emerald
        memberIds: ['member-2', 'member-3', 'member-4'],
        createdAt: now.subtract(const Duration(days: 7)),
        deadline: now.add(const Duration(days: 25)),
      ),
    ];

    // 3. Tasks
    _tasks = [
      // Project 1 tasks
      TaskItem(
        id: 'task-1',
        projectId: 'proj-1',
        title: 'Design Figma token system & component library',
        description:
            'Construct typography scales, dark theme color palettes, and standard button/input components in Figma.',
        assigneeId: 'member-4',
        priority: TaskPriority.high,
        status: TaskStatus.completed,
        dueDate: now.subtract(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 10)),
        comments: [
          TaskComment(
            id: 'c-1',
            authorName: 'Soham Karandikar',
            authorRole: 'Tech Lead',
            content: 'Approved tokens, ready for frontend implementation.',
            timestamp: now.subtract(const Duration(days: 3)),
          ),
        ],
      ),
      TaskItem(
        id: 'task-2',
        projectId: 'proj-1',
        title: 'Implement FaceID / Biometric login flow',
        description:
            'Integrate LocalAuth on iOS and BiometricPrompt on Android with secure enclave credential encryption.',
        assigneeId: 'member-2',
        priority: TaskPriority.urgent,
        status: TaskStatus.inProgress,
        dueDate: now.add(const Duration(days: 1)), // Due soon!
        createdAt: now.subtract(const Duration(days: 4)),
        comments: [
          TaskComment(
            id: 'c-2',
            authorName: 'Naman Sethi',
            authorRole: 'Project Lead',
            content: 'iOS keychain storage verified. Testing fallback PIN prompt now.',
            timestamp: now.subtract(const Duration(hours: 5)),
          ),
        ],
      ),
      TaskItem(
        id: 'task-3',
        projectId: 'proj-1',
        title: 'Wireframe transaction history filters',
        description:
            'Create interactive prototypes for multi-currency filtering, category tags, and PDF statement export.',
        assigneeId: 'member-4',
        priority: TaskPriority.medium,
        status: TaskStatus.inReview,
        dueDate: now.add(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      TaskItem(
        id: 'task-4',
        projectId: 'proj-1',
        title: 'Setup automated CI/CD App Center distribution',
        description:
            'Configure fastlane scripts for auto-signing debug builds and triggering internal test track releases.',
        assigneeId: 'member-1',
        priority: TaskPriority.low,
        status: TaskStatus.todo,
        dueDate: now.add(const Duration(days: 12)),
        createdAt: now.subtract(const Duration(days: 2)),
      ),

      // Project 2 tasks
      TaskItem(
        id: 'task-5',
        projectId: 'proj-2',
        title: 'Stress test billing gateway Redis cluster',
        description:
            'Simulate 15,000 concurrent checkout webhook calls using k6 and record connection pool exhaustion.',
        assigneeId: 'member-3',
        priority: TaskPriority.urgent,
        status: TaskStatus.inProgress,
        dueDate: now.subtract(const Duration(days: 1)), // Overdue!
        createdAt: now.subtract(const Duration(days: 8)),
      ),
      TaskItem(
        id: 'task-6',
        projectId: 'proj-2',
        title: 'Containerize auth service with multi-stage Docker build',
        description:
            'Reduce container image footprint below 40MB using Alpine/Distroless and run vulnerability scanning.',
        assigneeId: 'member-3',
        priority: TaskPriority.high,
        status: TaskStatus.completed,
        dueDate: now.subtract(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(days: 12)),
      ),
      TaskItem(
        id: 'task-7',
        projectId: 'proj-2',
        title: 'Migrate PostgreSQL schemas with Flyway',
        description:
            'Prepare zero-downtime database migration scripts for user accounts and permission roles.',
        assigneeId: 'member-1',
        priority: TaskPriority.medium,
        status: TaskStatus.todo,
        dueDate: now.add(const Duration(days: 6)),
        createdAt: now.subtract(const Duration(days: 1)),
      ),

      // Project 3 tasks
      TaskItem(
        id: 'task-8',
        projectId: 'proj-3',
        title: 'Websocket connection for real-time transaction ticker',
        description:
            'Establish resilient WebSocket client with automatic reconnection and heartbeat ping/pong.',
        assigneeId: 'member-2',
        priority: TaskPriority.high,
        status: TaskStatus.inReview,
        dueDate: now.add(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 4)),
      ),
    ];

    // 4. Initial Activity Logs (Audit Trail)
    _activityLogs = [
      ActivityLog(
        id: 'log-1',
        timestamp: now.subtract(const Duration(minutes: 15)),
        actorName: 'Naman Sethi',
        actionType: 'STATUS_CHANGE',
        entityType: 'Task',
        entityTitle: 'Websocket connection for real-time transaction ticker',
        details: 'Transitioned status from [In Progress] to [In Review]. Ready for peer testing.',
        projectId: 'proj-3',
      ),
      ActivityLog(
        id: 'log-2',
        timestamp: now.subtract(const Duration(hours: 2)),
        actorName: 'Soham Karandikar',
        actionType: 'COMMENT_ADDED',
        entityType: 'Task',
        entityTitle: 'Implement FaceID / Biometric login flow',
        details: 'Added comment: "Remember to verify user cancellation callbacks on FaceID."',
        projectId: 'proj-1',
      ),
      ActivityLog(
        id: 'log-3',
        timestamp: now.subtract(const Duration(hours: 4)),
        actorName: 'Naman Sethi',
        actionType: 'ASSIGNMENT',
        entityType: 'Task',
        entityTitle: 'Stress test billing gateway Redis cluster',
        details: 'Assigned task to Aavani Perumbessi (Backend Specialist). Set priority to Urgent.',
        projectId: 'proj-2',
      ),
      ActivityLog(
        id: 'log-4',
        timestamp: now.subtract(const Duration(hours: 9)),
        actorName: 'Aavani Perumbessi',
        actionType: 'STATUS_CHANGE',
        entityType: 'Task',
        entityTitle: 'Containerize auth service with multi-stage Docker build',
        details: 'Marked task as [Completed]. Image footprint down to 34MB.',
        projectId: 'proj-2',
      ),
      ActivityLog(
        id: 'log-5',
        timestamp: now.subtract(const Duration(days: 1)),
        actorName: 'Naaz Ahmedi',
        actionType: 'STATUS_CHANGE',
        entityType: 'Task',
        entityTitle: 'Design Figma token system & component library',
        details: 'Transitioned status from [In Review] to [Completed]. Shared Figma handoff link.',
        projectId: 'proj-1',
      ),
      ActivityLog(
        id: 'log-6',
        timestamp: now.subtract(const Duration(days: 2)),
        actorName: 'Naman Sethi',
        actionType: 'PROJECT_CREATED',
        entityType: 'Project',
        entityTitle: 'FinTech Mobile App Redesign',
        details: 'Created project charter and initialized repository sprint boards.',
        projectId: 'proj-1',
      ),
    ];

    // 5. Initial Notifications
    _notifications = [
      AppNotification(
        id: 'notif-1',
        title: 'Task Overdue ⚠️',
        message: '"Stress test billing gateway Redis cluster" deadline was yesterday.',
        timestamp: now.subtract(const Duration(hours: 1)),
        isRead: false,
        type: NotificationType.reminder,
        relatedTaskId: 'task-5',
        relatedProjectId: 'proj-2',
      ),
      AppNotification(
        id: 'notif-2',
        title: 'Task Needs Review 🔍',
        message: 'Naman submitted "Websocket connection" for code review.',
        timestamp: now.subtract(const Duration(minutes: 15)),
        isRead: false,
        type: NotificationType.statusUpdate,
        relatedTaskId: 'task-8',
        relatedProjectId: 'proj-3',
      ),
      AppNotification(
        id: 'notif-3',
        title: 'Deadline Approaching ⏰',
        message: '"Implement FaceID / Biometric login flow" is due tomorrow.',
        timestamp: now.subtract(const Duration(hours: 6)),
        isRead: false,
        type: NotificationType.reminder,
        relatedTaskId: 'task-2',
        relatedProjectId: 'proj-1',
      ),
      AppNotification(
        id: 'notif-4',
        title: 'Task Assigned',
        message: 'You were assigned to "Setup automated CI/CD App Center distribution".',
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
        type: NotificationType.assignment,
        relatedTaskId: 'task-4',
        relatedProjectId: 'proj-1',
      ),
    ];
  }
}
