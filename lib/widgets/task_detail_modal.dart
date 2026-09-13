import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import 'member_avatar.dart';
import 'status_badge.dart';

class TaskDetailModal extends StatefulWidget {
  final String taskId;

  const TaskDetailModal({super.key, required this.taskId});

  @override
  State<TaskDetailModal> createState() => _TaskDetailModalState();
}

class _TaskDetailModalState extends State<TaskDetailModal> {
  final _commentController = TextEditingController();
  int _activeTab = 0; // 0 = Collaboration & Details, 1 = Audit Trail

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment(AppState appState) {
    final text = _commentController.text.trim();
    if (text.isNotEmpty) {
      appState.addTaskComment(widget.taskId, text);
      _commentController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    TaskItem? task;
    try {
      task = appState.tasks.firstWhere((t) => t.id == widget.taskId);
    } catch (_) {
      task = null;
    }

    if (task == null) {
      return Container(
        height: 200,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: const Center(child: Text('Task no longer exists.')),
      );
    }

    final project = appState.getProjectById(task.projectId);
    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    final currentTask = task;
    // Filter audit logs relevant to this task
    final taskLogs = appState.activityLogs.where((log) {
      return log.entityTitle == currentTask.title ||
          (log.projectId == currentTask.projectId &&
              log.details.contains(currentTask.title));
    }).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Header: Project badge & Close / Delete buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                if (project != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(project.colorValue).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.folder_rounded,
                          size: 14,
                          color: Color(project.colorValue),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          project.title,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(project.colorValue),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                IconButton(
                  tooltip: 'Delete Task',
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Colors.redAccent, size: 20),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Task'),
                        content: const Text(
                            'Are you sure you want to permanently delete this task? All logged comments will be removed.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: () {
                              Navigator.pop(ctx);
                              Navigator.pop(context);
                              appState.deleteTask(widget.taskId);
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(),

          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  if (task.description.isNotEmpty) ...[
                    Text(
                      task.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF475569),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Lifecycle Status Progression Bar
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Task Lifecycle Status',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF64748B),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Spacer(),
                            StatusBadge(status: task.status, compact: true),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Segmented Status Buttons
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: TaskStatus.values.map((status) {
                            final isSelected = task!.status == status;
                            return ChoiceChip(
                              label: Text(status.label),
                              selected: isSelected,
                              selectedColor: status.color.withValues(alpha: 0.2),
                              avatar: Icon(
                                status.icon,
                                size: 16,
                                color: isSelected
                                    ? status.color
                                    : const Color(0xFF64748B),
                              ),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? status.color
                                    : const Color(0xFF334155),
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 12,
                              ),
                              side: BorderSide(
                                color: isSelected
                                    ? status.color
                                    : const Color(0xFFCBD5E1),
                              ),
                              onSelected: (_) {
                                appState.updateTaskStatus(task!.id, status);
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Metadata Grid: Assignee, Priority, Due Date
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        // Assignee Row
                        Row(
                          children: [
                            const Icon(Icons.person_pin_rounded,
                                size: 20, color: Color(0xFF64748B)),
                            const SizedBox(width: 10),
                            const Text(
                              'Assignee',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String?>(
                                value: task.assigneeId,
                                hint: const Text('Unassigned',
                                    style: TextStyle(fontSize: 13)),
                                items: [
                                  const DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text('Unassigned',
                                        style: TextStyle(fontSize: 13)),
                                  ),
                                  ...appState.teamMembers.map((m) {
                                    return DropdownMenuItem<String?>(
                                      value: m.id,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          MemberAvatar(
                                              member: m,
                                              size: 22,
                                              showTooltip: false),
                                          const SizedBox(width: 8),
                                          Text(m.name,
                                              style:
                                                  const TextStyle(fontSize: 13)),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (newAssigneeId) {
                                  appState.updateTask(task!.copyWith(
                                    assigneeId: newAssigneeId,
                                  ));
                                },
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 18),

                        // Priority Row
                        Row(
                          children: [
                            const Icon(Icons.flag_rounded,
                                size: 20, color: Color(0xFF64748B)),
                            const SizedBox(width: 10),
                            const Text(
                              'Priority',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<TaskPriority>(
                                value: task.priority,
                                items: TaskPriority.values.map((p) {
                                  return DropdownMenuItem<TaskPriority>(
                                    value: p,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(p.icon, color: p.color, size: 16),
                                        const SizedBox(width: 8),
                                        Text(p.label,
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (newPriority) {
                                  if (newPriority != null) {
                                    appState.updateTask(
                                        task!.copyWith(priority: newPriority));
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 18),

                        // Due Date Row
                        Row(
                          children: [
                            Icon(
                              task.isOverdue
                                  ? Icons.error_outline_rounded
                                  : Icons.calendar_month_rounded,
                              size: 20,
                              color: task.isOverdue
                                  ? Colors.red
                                  : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Due Date',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: task!.dueDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null) {
                                  appState.updateTask(
                                      task.copyWith(dueDate: picked));
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: Row(
                                  children: [
                                    Text(
                                      dateFormat.format(task.dueDate),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: task.isOverdue
                                            ? Colors.red
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.edit_calendar_rounded,
                                        size: 16, color: Color(0xFF64748B)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Section Tabs: Comments (Collaboration) vs Audit Trail
                  Row(
                    children: [
                      _buildTabButton(
                        title: 'Comments (${task.comments.length})',
                        icon: Icons.forum_rounded,
                        index: 0,
                      ),
                      const SizedBox(width: 12),
                      _buildTabButton(
                        title: 'Audit Trail (${taskLogs.length})',
                        icon: Icons.history_rounded,
                        index: 1,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  if (_activeTab == 0) ...[
                    // Collaboration comments list
                    if (task.comments.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        alignment: Alignment.center,
                        child: Text(
                          'No team comments yet. Start the conversation!',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: task.comments.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (ctx, i) {
                          final c = task!.comments[i];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: const Color(0xFF6366F1),
                                      child: Text(
                                        c.authorName.isNotEmpty
                                            ? c.authorName[0].toUpperCase()
                                            : 'U',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      c.authorName,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '• ${c.authorRole}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${dateFormat.format(c.timestamp)} ${timeFormat.format(c.timestamp)}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  c.content,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF334155),
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 14),

                    // Add comment input
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: 'Add a comment or update...',
                              prefixIcon: const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 18),
                              filled: true,
                              fillColor: const Color(0xFFF1F5F9),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onSubmitted: (_) => _submitComment(appState),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: () => _submitComment(appState),
                          icon: const Icon(Icons.send_rounded, size: 18),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Audit Trail for this task
                    if (taskLogs.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        alignment: Alignment.center,
                        child: Text(
                          'No recent activity recorded for this task.',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: taskLogs.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (ctx, i) {
                          final log = taskLogs[i];
                          return Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: log.actionColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(log.actionIcon,
                                      size: 14, color: log.actionColor),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            log.actorName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            '${dateFormat.format(log.timestamp)} ${timeFormat.format(log.timestamp)}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        log.details,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required IconData icon,
    required int index,
  }) {
    final isSelected = _activeTab == index;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4F46E5).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4F46E5)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? const Color(0xFF4F46E5)
                  : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF4F46E5)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
