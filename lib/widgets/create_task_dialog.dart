import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import 'member_avatar.dart';

class CreateTaskDialog extends StatefulWidget {
  final String? initialProjectId;

  const CreateTaskDialog({super.key, this.initialProjectId});

  @override
  State<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<CreateTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  late String? _selectedProjectId;
  String? _selectedAssigneeId;
  TaskPriority _selectedPriority = TaskPriority.medium;
  TaskStatus _selectedStatus = TaskStatus.todo;
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 3));

  @override
  void initState() {
    super.initState();
    _selectedProjectId = widget.initialProjectId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveTask(AppState appState) {
    if (_formKey.currentState!.validate()) {
      if (_selectedProjectId == null && appState.projects.isNotEmpty) {
        _selectedProjectId = appState.projects.first.id;
      }

      if (_selectedProjectId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please create a project first.')),
        );
        return;
      }

      appState.createTask(
        projectId: _selectedProjectId!,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        assigneeId: _selectedAssigneeId,
        priority: _selectedPriority,
        status: _selectedStatus,
        dueDate: _selectedDueDate,
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final dateFormat = DateFormat('EEE, MMM d, yyyy');

    if (_selectedProjectId == null && appState.projects.isNotEmpty) {
      _selectedProjectId = appState.projects.first.id;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 520),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add_task_rounded,
                          color: Color(0xFF4F46E5), size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Create New Task',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Project Selector
                const Text('Project',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155))),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedProjectId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  items: appState.projects.map((p) {
                    return DropdownMenuItem<String>(
                      value: p.id,
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Color(p.colorValue),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(p.title, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedProjectId = val),
                  validator: (val) => val == null ? 'Select a project' : null,
                ),
                const SizedBox(height: 14),

                // Task Title
                const Text('Task Title',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155))),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Implement OAuth2 token refresh flow',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a title for the task';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Description
                const Text('Description (Optional)',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155))),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Provide context, scope, or requirements...',
                  ),
                ),
                const SizedBox(height: 14),

                // Responsive fields: Priority, Status, Assignee, Due Date
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 440;

                    final priorityField = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Priority',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF334155))),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<TaskPriority>(
                          initialValue: _selectedPriority,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                          items: TaskPriority.values.map((p) {
                            return DropdownMenuItem(
                              value: p,
                              child: Row(
                                children: [
                                  Icon(p.icon, color: p.color, size: 16),
                                  const SizedBox(width: 6),
                                  Text(p.label,
                                      style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedPriority = val);
                            }
                          },
                        ),
                      ],
                    );

                    final statusField = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Initial Status',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF334155))),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<TaskStatus>(
                          initialValue: _selectedStatus,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                          items: TaskStatus.values.map((s) {
                            return DropdownMenuItem(
                              value: s,
                              child: Row(
                                children: [
                                  Icon(s.icon, color: s.color, size: 16),
                                  const SizedBox(width: 6),
                                  Text(s.label,
                                      style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedStatus = val);
                            }
                          },
                        ),
                      ],
                    );

                    final assigneeField = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Assign To',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF334155))),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String?>(
                          initialValue: _selectedAssigneeId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
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
                                        size: 20,
                                        showTooltip: false),
                                    const SizedBox(width: 6),
                                    Text(m.name,
                                        style: const TextStyle(fontSize: 13)),
                                  ],
                                ),
                              );
                            }),
                          ],
                          onChanged: (val) =>
                              setState(() => _selectedAssigneeId = val),
                        ),
                      ],
                    );

                    final dueDateField = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Due Date',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF334155))),
                        const SizedBox(height: 6),
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDueDate,
                              firstDate: DateTime.now()
                                  .subtract(const Duration(days: 365)),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365 * 3)),
                            );
                            if (picked != null) {
                              setState(() => _selectedDueDate = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded,
                                    size: 16, color: Color(0xFF64748B)),
                                const SizedBox(width: 8),
                                Text(
                                  dateFormat.format(_selectedDueDate),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );

                    if (isCompact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          priorityField,
                          const SizedBox(height: 14),
                          statusField,
                          const SizedBox(height: 14),
                          assigneeField,
                          const SizedBox(height: 14),
                          dueDateField,
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: priorityField),
                            const SizedBox(width: 12),
                            Expanded(child: statusField),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(child: assigneeField),
                            const SizedBox(width: 12),
                            Expanded(child: dueDateField),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => _saveTask(appState),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Create Task'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
