import 'package:flutter/material.dart';

enum TaskStatus {
  todo,
  inProgress,
  inReview,
  completed,
}

extension TaskStatusExtension on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.inReview:
        return 'In Review';
      case TaskStatus.completed:
        return 'Completed';
    }
  }

  Color get color {
    switch (this) {
      case TaskStatus.todo:
        return const Color(0xFF64748B); // Slate
      case TaskStatus.inProgress:
        return const Color(0xFF2563EB); // Royal Blue
      case TaskStatus.inReview:
        return const Color(0xFFD97706); // Amber
      case TaskStatus.completed:
        return const Color(0xFF16A34A); // Emerald Green
    }
  }

  IconData get icon {
    switch (this) {
      case TaskStatus.todo:
        return Icons.radio_button_unchecked;
      case TaskStatus.inProgress:
        return Icons.pending_actions_rounded;
      case TaskStatus.inReview:
        return Icons.rate_review_rounded;
      case TaskStatus.completed:
        return Icons.check_circle_rounded;
    }
  }
}

enum TaskPriority {
  low,
  medium,
  high,
  urgent,
}

extension TaskPriorityExtension on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return const Color(0xFF10B981); // Green
      case TaskPriority.medium:
        return const Color(0xFF0284C7); // Sky blue
      case TaskPriority.high:
        return const Color(0xFFF97316); // Orange
      case TaskPriority.urgent:
        return const Color(0xFFEF4444); // Red
    }
  }

  IconData get icon {
    switch (this) {
      case TaskPriority.low:
        return Icons.low_priority;
      case TaskPriority.medium:
        return Icons.remove_circle_outline;
      case TaskPriority.high:
        return Icons.priority_high;
      case TaskPriority.urgent:
        return Icons.warning_amber_rounded;
    }
  }
}

class TeamMember {
  final String id;
  final String name;
  final String email;
  final String role;
  final int colorValue;

  const TeamMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.colorValue,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty && parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }
}

class TaskComment {
  final String id;
  final String authorName;
  final String authorRole;
  final String content;
  final DateTime timestamp;

  TaskComment({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.content,
    required this.timestamp,
  });
}

class TaskItem {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final String? assigneeId;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime dueDate;
  final DateTime createdAt;
  final List<TaskComment> comments;

  TaskItem({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    this.assigneeId,
    required this.priority,
    required this.status,
    required this.dueDate,
    required this.createdAt,
    List<TaskComment>? comments,
  }) : comments = comments ?? [];

  bool get isOverdue =>
      status != TaskStatus.completed &&
      dueDate.isBefore(DateTime.now());

  bool get isDueSoon {
    if (status == TaskStatus.completed || isOverdue) return false;
    final diff = dueDate.difference(DateTime.now()).inDays;
    return diff <= 2;
  }

  TaskItem copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    String? assigneeId,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
    DateTime? createdAt,
    List<TaskComment>? comments,
  }) {
    return TaskItem(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      assigneeId: assigneeId ?? this.assigneeId,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      comments: comments ?? List.from(this.comments),
    );
  }
}

class Project {
  final String id;
  final String title;
  final String description;
  final int colorValue;
  final List<String> memberIds;
  final DateTime createdAt;
  final DateTime deadline;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.colorValue,
    required this.memberIds,
    required this.createdAt,
    required this.deadline,
  });

  Project copyWith({
    String? id,
    String? title,
    String? description,
    int? colorValue,
    List<String>? memberIds,
    DateTime? createdAt,
    DateTime? deadline,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      colorValue: colorValue ?? this.colorValue,
      memberIds: memberIds ?? List.from(this.memberIds),
      createdAt: createdAt ?? this.createdAt,
      deadline: deadline ?? this.deadline,
    );
  }
}

class ActivityLog {
  final String id;
  final DateTime timestamp;
  final String actorName;
  final String actionType; // e.g. "TASK_CREATED", "STATUS_CHANGE", "ASSIGNMENT", "PROJECT_CREATED", "COMMENT_ADDED"
  final String entityType; // "Task", "Project", "Team"
  final String entityTitle;
  final String details;
  final String? projectId;

  ActivityLog({
    required this.id,
    required this.timestamp,
    required this.actorName,
    required this.actionType,
    required this.entityType,
    required this.entityTitle,
    required this.details,
    this.projectId,
  });

  IconData get actionIcon {
    switch (actionType) {
      case 'PROJECT_CREATED':
        return Icons.folder_special_rounded;
      case 'TASK_CREATED':
        return Icons.add_task_rounded;
      case 'STATUS_CHANGE':
        return Icons.sync_alt_rounded;
      case 'ASSIGNMENT':
        return Icons.person_pin_rounded;
      case 'DEADLINE_CHANGED':
        return Icons.event_repeat_rounded;
      case 'COMMENT_ADDED':
        return Icons.chat_bubble_outline_rounded;
      case 'TASK_DELETED':
        return Icons.delete_outline_rounded;
      default:
        return Icons.history_rounded;
    }
  }

  Color get actionColor {
    switch (actionType) {
      case 'PROJECT_CREATED':
        return const Color(0xFF6366F1); // Indigo
      case 'TASK_CREATED':
        return const Color(0xFF0EA5E9); // Ocean Blue
      case 'STATUS_CHANGE':
        return const Color(0xFF10B981); // Emerald
      case 'ASSIGNMENT':
        return const Color(0xFF8B5CF6); // Violet
      case 'DEADLINE_CHANGED':
        return const Color(0xFFF59E0B); // Amber
      case 'COMMENT_ADDED':
        return const Color(0xFFEC4899); // Pink
      case 'TASK_DELETED':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF64748B);
    }
  }
}

enum NotificationType {
  reminder,
  assignment,
  statusUpdate,
  system,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;
  final String? relatedTaskId;
  final String? relatedProjectId;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    required this.type,
    this.relatedTaskId,
    this.relatedProjectId,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    NotificationType? type,
    String? relatedTaskId,
    String? relatedProjectId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      relatedTaskId: relatedTaskId ?? this.relatedTaskId,
      relatedProjectId: relatedProjectId ?? this.relatedProjectId,
    );
  }

  IconData get icon {
    switch (type) {
      case NotificationType.reminder:
        return Icons.alarm_rounded;
      case NotificationType.assignment:
        return Icons.assignment_ind_rounded;
      case NotificationType.statusUpdate:
        return Icons.update_rounded;
      case NotificationType.system:
        return Icons.notifications_active_rounded;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.reminder:
        return const Color(0xFFF59E0B); // Amber
      case NotificationType.assignment:
        return const Color(0xFF3B82F6); // Blue
      case NotificationType.statusUpdate:
        return const Color(0xFF10B981); // Emerald
      case NotificationType.system:
        return const Color(0xFF8B5CF6); // Purple
    }
  }
}
