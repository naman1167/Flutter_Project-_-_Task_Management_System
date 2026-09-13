import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import 'member_avatar.dart';
import 'priority_badge.dart';
import 'status_badge.dart';
import 'task_detail_modal.dart';

class TaskCard extends StatelessWidget {
  final TaskItem task;
  final bool showProjectTag;

  const TaskCard({
    super.key,
    required this.task,
    this.showProjectTag = true,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final project = appState.getProjectById(task.projectId);
    final assignee = appState.getMemberById(task.assigneeId);
    final dateFormat = DateFormat('MMM d');

    final isOverdue = task.isOverdue;
    final isDueSoon = task.isDueSoon;

    Color dueDateColor = const Color(0xFF64748B);
    if (task.status == TaskStatus.completed) {
      dueDateColor = const Color(0xFF16A34A);
    } else if (isOverdue) {
      dueDateColor = const Color(0xFFEF4444);
    } else if (isDueSoon) {
      dueDateColor = const Color(0xFFF59E0B);
    }

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => TaskDetailModal(taskId: task.id),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top tags: Priority & Project (if enabled)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  PriorityBadge(priority: task.priority, compact: true),
                  if (showProjectTag && project != null) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Color(project.colorValue).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          project.title,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(project.colorValue),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  // Quick popup menu for status advance
                  PopupMenuButton<TaskStatus>(
                    tooltip: 'Change Status',
                    icon: Icon(
                      Icons.more_vert_rounded,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onSelected: (newStatus) {
                      appState.updateTaskStatus(task.id, newStatus);
                    },
                    itemBuilder: (ctx) => TaskStatus.values.map((s) {
                      return PopupMenuItem<TaskStatus>(
                        value: s,
                        child: Row(
                          children: [
                            Icon(s.icon, color: s.color, size: 18),
                            const SizedBox(width: 10),
                            Text(
                              s.label,
                              style: TextStyle(
                                fontWeight: s == task.status
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Title
              Text(
                task.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: task.status == TaskStatus.completed
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF0F172A),
                  decoration: task.status == TaskStatus.completed
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),

              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    height: 1.3,
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // Bottom row: Due date indicator, Comments count, Assignee avatar
              Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showProjectTag) ...[
                          StatusBadge(status: task.status, compact: true),
                          const SizedBox(width: 6),
                        ],
                        // Due date chip
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isOverdue
                                    ? Icons.error_outline_rounded
                                    : Icons.calendar_today_rounded,
                                size: 13,
                                color: dueDateColor,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  isOverdue
                                      ? 'Overdue'
                                      : dateFormat.format(task.dueDate),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isOverdue || isDueSoon
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: dueDateColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (task.comments.isNotEmpty) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 13,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${task.comments.length}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                  ],
                  MemberAvatar(member: assignee, size: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
