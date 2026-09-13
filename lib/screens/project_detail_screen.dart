import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../widgets/create_task_dialog.dart';
import '../widgets/member_avatar.dart';
import '../widgets/task_card.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String projectId;
  final VoidCallback onBack;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
    required this.onBack,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  int _viewMode = 0; // 0 = Kanban Board, 1 = List View
  String _searchQuery = '';
  TaskPriority? _filterPriority;
  String? _filterAssigneeId;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final project = appState.getProjectById(widget.projectId);

    if (project == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Project not found'),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: widget.onBack, child: const Text('Go Back')),
            ],
          ),
        ),
      );
    }

    final allProjectTasks = appState.getTasksForProject(project.id);
    final progress = appState.getProjectProgress(project.id);
    final dateFormat = DateFormat('MMM d, yyyy');

    // Filtered tasks for List View
    final filteredTasks = allProjectTasks.where((t) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = t.title.toLowerCase().contains(q);
        final matchDesc = t.description.toLowerCase().contains(q);
        if (!matchTitle && !matchDesc) return false;
      }
      if (_filterPriority != null && t.priority != _filterPriority) {
        return false;
      }
      if (_filterAssigneeId != null && t.assigneeId != _filterAssigneeId) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          // Project Top Bar & Details Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 650;

                    final titleRow = Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          onPressed: widget.onBack,
                          tooltip: 'Back to Projects',
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Color(project.colorValue),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                project.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                'Due: ${dateFormat.format(project.deadline)} • ${allProjectTasks.length} Tasks',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );

                    final actionRow = Row(
                      mainAxisSize:
                          isCompact ? MainAxisSize.max : MainAxisSize.min,
                      children: [
                        SegmentedButton<int>(
                          segments: const [
                            ButtonSegment(
                              value: 0,
                              label: Text('Kanban'),
                              icon: Icon(Icons.view_kanban_outlined, size: 16),
                            ),
                            ButtonSegment(
                              value: 1,
                              label: Text('List'),
                              icon: Icon(Icons.list_alt_rounded, size: 16),
                            ),
                          ],
                          selected: {_viewMode},
                          onSelectionChanged: (set) {
                            setState(() => _viewMode = set.first);
                          },
                          style: const ButtonStyle(
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isCompact) const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => CreateTaskDialog(
                                initialProjectId: project.id,
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Add Task'),
                        ),
                      ],
                    );

                    if (isCompact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          titleRow,
                          const SizedBox(height: 10),
                          actionRow,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: titleRow),
                        const SizedBox(width: 12),
                        actionRow,
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Progress Bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFF1F5F9),
                          color: Color(project.colorValue),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${(progress * 100).toInt()}% completed',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Main View Content
          Expanded(
            child: _viewMode == 0
                ? _buildKanbanBoard(context, appState, allProjectTasks)
                : _buildListView(context, appState, filteredTasks),
          ),
        ],
      ),
    );
  }

  // --- Kanban Board Implementation ---
  Widget _buildKanbanBoard(
    BuildContext context,
    AppState appState,
    List<TaskItem> allTasks,
  ) {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: TaskStatus.values.map((status) {
                final tasksInStatus =
                    allTasks.where((t) => t.status == status).toList();
                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DragTarget<String>(
                    onWillAcceptWithDetails: (details) => true,
                    onAcceptWithDetails: (details) {
                      appState.updateTaskStatus(details.data, status);
                    },
                    builder: (context, candidateData, rejectedData) {
                      final isHovered = candidateData.isNotEmpty;
                      return Container(
                        decoration: BoxDecoration(
                              color: isHovered
                                  ? status.color.withValues(alpha: 0.08)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Column Header
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  Icon(status.icon,
                                      size: 16, color: status.color),
                                  const SizedBox(width: 8),
                                  Text(
                                    status.label,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: status.color,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: const Color(0xFFCBD5E1)),
                                    ),
                                    child: Text(
                                      '${tasksInStatus.length}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF475569),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),

                            // Column Tasks List
                            Flexible(
                              child: ListView.separated(
                                padding: const EdgeInsets.all(12),
                                shrinkWrap: true,
                                itemCount: tasksInStatus.length,
                                 separatorBuilder: (context, index) =>
                                     const SizedBox(height: 10),
                                itemBuilder: (ctx, i) {
                                  final task = tasksInStatus[i];
                                  return Draggable<String>(
                                    data: task.id,
                                    feedback: Material(
                                      elevation: 6,
                                      borderRadius: BorderRadius.circular(16),
                                      child: SizedBox(
                                        width: 280,
                                        child: TaskCard(
                                          task: task,
                                          showProjectTag: false,
                                        ),
                                      ),
                                    ),
                                    childWhenDragging: Opacity(
                                      opacity: 0.3,
                                      child: TaskCard(
                                        task: task,
                                        showProjectTag: false,
                                      ),
                                    ),
                                    child: TaskCard(
                                      task: task,
                                      showProjectTag: false,
                                    ),
                                  );
                                },
                              ),
                            ),

                            // Quick add task in column
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(36),
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => CreateTaskDialog(
                                      initialProjectId: widget.projectId,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('Add Card',
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  // --- List View Implementation with Filters ---
  Widget _buildListView(
    BuildContext context,
    AppState appState,
    List<TaskItem> tasks,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Filter Bar
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 650;
              final searchField = TextField(
                decoration: InputDecoration(
                  hintText: 'Search tasks by title or details...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 18),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              );

              final priorityDropdown = Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<TaskPriority?>(
                    isExpanded: isCompact,
                    value: _filterPriority,
                    hint: const Text('All Priorities',
                        style: TextStyle(fontSize: 12)),
                    items: [
                      const DropdownMenuItem(
                          value: null,
                          child: Text('All Priorities',
                              style: TextStyle(fontSize: 12))),
                      ...TaskPriority.values.map(
                        (p) => DropdownMenuItem(
                          value: p,
                          child: Row(
                            children: [
                              Icon(p.icon, color: p.color, size: 14),
                              const SizedBox(width: 6),
                              Text(p.label,
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                    onChanged: (val) => setState(() => _filterPriority = val),
                  ),
                ),
              );

              final assigneeDropdown = Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    isExpanded: isCompact,
                    value: _filterAssigneeId,
                    hint: const Text('All Members',
                        style: TextStyle(fontSize: 12)),
                    items: [
                      const DropdownMenuItem(
                          value: null,
                          child: Text('All Members',
                              style: TextStyle(fontSize: 12))),
                      ...appState.teamMembers.map(
                        (m) => DropdownMenuItem(
                          value: m.id,
                          child: Row(
                            children: [
                              MemberAvatar(
                                  member: m, size: 18, showTooltip: false),
                              const SizedBox(width: 6),
                              Text(
                                m.name,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    onChanged: (val) => setState(() => _filterAssigneeId = val),
                  ),
                ),
              );

              if (isCompact) {
                return Column(
                  children: [
                    searchField,
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: priorityDropdown),
                        const SizedBox(width: 10),
                        Expanded(child: assigneeDropdown),
                      ],
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: searchField),
                  const SizedBox(width: 12),
                  priorityDropdown,
                  const SizedBox(width: 12),
                  assigneeDropdown,
                ],
              );
            },
          ),

          const SizedBox(height: 16),

          // List results
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'No tasks matching criteria',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: tasks.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) =>
                        TaskCard(task: tasks[i], showProjectTag: false),
                  ),
          ),
        ],
      ),
    );
  }
}
