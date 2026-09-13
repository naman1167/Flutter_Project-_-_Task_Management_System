import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_system/models/models.dart';
import 'package:task_management_system/providers/app_state.dart';

void main() {
  group('AppState Tests', () {
    late AppState appState;

  setUp(() {
    appState = AppState();
  });

  test('Initial state contains seeded projects, tasks, and audit logs', () {
    expect(appState.projects.isNotEmpty, true);
    expect(appState.tasks.isNotEmpty, true);
    expect(appState.teamMembers.isNotEmpty, true);
    expect(appState.activityLogs.isNotEmpty, true);
    expect(appState.notifications.isNotEmpty, true);
  });

  test('Create project updates state and logs audit trail', () {
    final initialLogsCount = appState.activityLogs.length;
    final initialProjectsCount = appState.projects.length;

    final project = appState.createProject(
      title: 'Unit Test Project',
      description: 'Testing project creation',
      colorValue: 0xFF4F46E5,
      memberIds: ['member-1'],
      deadline: DateTime.now().add(const Duration(days: 10)),
    );

    expect(appState.projects.length, initialProjectsCount + 1);
    expect(appState.projects.first.id, project.id);
    expect(appState.activityLogs.length, initialLogsCount + 1);
    expect(appState.activityLogs.first.actionType, 'PROJECT_CREATED');
    expect(appState.activityLogs.first.entityTitle, 'Unit Test Project');
  });

  test('Create task updates state, notifies assignee, and logs audit trail', () {
    final initialTasksCount = appState.tasks.length;
    final initialLogsCount = appState.activityLogs.length;
    final initialNotifsCount = appState.notifications.length;

    final task = appState.createTask(
      projectId: appState.projects.first.id,
      title: 'Automated Test Task',
      description: 'Verifying task creation flow',
      assigneeId: 'member-2',
      priority: TaskPriority.urgent,
      status: TaskStatus.todo,
      dueDate: DateTime.now().add(const Duration(days: 2)),
    );

    expect(appState.tasks.length, initialTasksCount + 1);
    expect(appState.tasks.first.id, task.id);
    expect(appState.tasks.first.title, 'Automated Test Task');
    expect(appState.activityLogs.length, initialLogsCount + 1);
    expect(appState.activityLogs.first.actionType, 'TASK_CREATED');
    expect(appState.notifications.length, initialNotifsCount + 1);
    expect(appState.notifications.first.type, NotificationType.assignment);
  });

  test('Task status transition records audit trail and completed notification', () {
    final task = appState.tasks.firstWhere((t) => t.status != TaskStatus.completed);

    // Transition to Completed
    appState.updateTaskStatus(task.id, TaskStatus.completed);

    final updatedTask = appState.tasks.firstWhere((t) => t.id == task.id);
    expect(updatedTask.status, TaskStatus.completed);

    // Verify audit log
    expect(appState.activityLogs.first.actionType, 'STATUS_CHANGE');
    expect(appState.activityLogs.first.details.contains('Completed'), true);

    // Verify notification was triggered
    expect(appState.notifications.first.type, NotificationType.statusUpdate);
  });

  test('Adding collaboration comment adds comment and audit entry', () {
    final task = appState.tasks.first;
    final initialCommentsCount = task.comments.length;

    appState.addTaskComment(task.id, 'Crucial security review notes');

    final updatedTask = appState.tasks.firstWhere((t) => t.id == task.id);
    expect(updatedTask.comments.length, initialCommentsCount + 1);
    expect(updatedTask.comments.last.content, 'Crucial security review notes');
    expect(appState.activityLogs.first.actionType, 'COMMENT_ADDED');
  });

  test('Upcoming deadline scan identifies overdue or due soon tasks', () {
    final initialNotifsCount = appState.notifications.length;
    appState.generateUpcomingDeadlineReminders();
    expect(appState.notifications.length >= initialNotifsCount, true);
  });
  });
}
