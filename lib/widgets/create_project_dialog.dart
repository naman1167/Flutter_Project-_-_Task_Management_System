import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'member_avatar.dart';

class CreateProjectDialog extends StatefulWidget {
  const CreateProjectDialog({super.key});

  @override
  State<CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends State<CreateProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  final List<int> _palette = const [
    0xFF4F46E5, // Indigo
    0xFF0284C7, // Cyan/Blue
    0xFF059669, // Emerald
    0xFFD97706, // Amber
    0xFFDC2626, // Red
    0xFF9333EA, // Purple
    0xFFDB2777, // Pink
  ];

  late int _selectedColor;
  final List<String> _selectedMemberIds = [];
  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    _selectedColor = _palette.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveProject(AppState appState) {
    if (_formKey.currentState!.validate()) {
      appState.createProject(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        colorValue: _selectedColor,
        memberIds: _selectedMemberIds,
        deadline: _selectedDeadline,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final dateFormat = DateFormat('EEE, MMM d, yyyy');

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
                        color: Color(_selectedColor).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.create_new_folder_rounded,
                          color: Color(_selectedColor), size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Create New Project',
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

                // Project Title
                const Text('Project Name',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155))),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Enterprise Cloud Portal',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a project name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Description
                const Text('Description',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155))),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'High-level goals and project charter...',
                  ),
                ),
                const SizedBox(height: 14),

                // Theme Color Picker
                const Text('Color Theme',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: _palette.map((colorVal) {
                    final isSelected = _selectedColor == colorVal;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = colorVal),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Color(colorVal),
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.black, width: 2.5)
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),

                // Deadline
                const Text('Target Completion Deadline',
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
                      initialDate: _selectedDeadline,
                      firstDate: DateTime.now(),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365 * 5)),
                    );
                    if (picked != null) {
                      setState(() => _selectedDeadline = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_available_rounded,
                            size: 18, color: Color(0xFF64748B)),
                        const SizedBox(width: 10),
                        Text(
                          dateFormat.format(_selectedDeadline),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Assign Team Members
                const Text('Assign Team Members',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: appState.teamMembers.map((member) {
                    final isAssigned = _selectedMemberIds.contains(member.id);
                    return FilterChip(
                      selected: isAssigned,
                      avatar:
                          MemberAvatar(member: member, size: 20, showTooltip: false),
                      label: Text(member.name,
                          style: const TextStyle(fontSize: 12)),
                      selectedColor:
                          Color(_selectedColor).withValues(alpha: 0.18),
                      checkmarkColor: Color(_selectedColor),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedMemberIds.add(member.id);
                          } else {
                            _selectedMemberIds.remove(member.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => _saveProject(appState),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Create Project'),
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
