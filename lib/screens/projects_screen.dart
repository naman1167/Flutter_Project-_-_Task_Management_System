import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../widgets/create_project_dialog.dart';
import '../widgets/member_avatar.dart';

class ProjectsScreen extends StatelessWidget {
  final Function(String) onOpenProject;

  const ProjectsScreen({super.key, required this.onOpenProject});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final projects = appState.projects;
    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Projects',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage team workspaces, deliverables, and timelines',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => const CreateProjectDialog(),
                    );
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('New Project'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Projects List / Grid
            Expanded(
              child: projects.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open_rounded,
                              size: 56, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          const Text(
                            'No projects found',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => const CreateProjectDialog(),
                              );
                            },
                            child: const Text('Create First Project'),
                          ),
                        ],
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 700;
                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isWide ? 2 : 1,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: isWide ? 1.7 : 1.35,
                          ),
                          itemCount: projects.length,
                          itemBuilder: (ctx, index) {
                            final p = projects[index];
                            final progress = appState.getProjectProgress(p.id);
                            final totalTasks =
                                appState.getProjectTaskCount(p.id);
                            final completedTasks =
                                appState.getProjectCompletedTaskCount(p.id);
                            final daysLeft =
                                p.deadline.difference(DateTime.now()).inDays;

                            return Card(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => onOpenProject(p.id),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Top Row: Color indicator, Title & Delete
                                      Row(
                                        children: [
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: Color(p.colorValue),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              p.title,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF0F172A),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          PopupMenuButton<String>(
                                            icon: const Icon(
                                                Icons.more_vert_rounded,
                                                size: 18),
                                            onSelected: (val) {
                                              if (val == 'delete') {
                                                _confirmDelete(
                                                    context, appState, p);
                                              }
                                            },
                                            itemBuilder: (ctx) => [
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                        Icons
                                                            .delete_outline_rounded,
                                                        color: Colors.red,
                                                        size: 18),
                                                    SizedBox(width: 8),
                                                    Text('Delete Project',
                                                        style: TextStyle(
                                                            color: Colors.red)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),

                                      if (p.description.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          p.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF64748B),
                                            height: 1.35,
                                          ),
                                        ),
                                      ],

                                      const Spacer(),

                                      // Progress bar & metrics
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '$completedTasks of $totalTasks tasks done',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                          Text(
                                            '${(progress * 100).toInt()}%',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Color(p.colorValue),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          backgroundColor:
                                              const Color(0xFFF1F5F9),
                                          color: Color(p.colorValue),
                                          minHeight: 7,
                                        ),
                                      ),

                                      const SizedBox(height: 16),

                                      // Bottom row: Team avatars & Deadline
                                      Row(
                                        children: [
                                          // Stack of member avatars
                                          SizedBox(
                                            height: 28,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: p.memberIds
                                                  .take(3)
                                                  .map((mId) {
                                                final m = appState
                                                    .getMemberById(mId);
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 4),
                                                  child: MemberAvatar(
                                                      member: m, size: 24),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Spacer(),
                                          Flexible(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.event_outlined,
                                                  size: 14,
                                                  color: daysLeft < 0
                                                      ? Colors.red
                                                      : const Color(0xFF64748B),
                                                ),
                                                const SizedBox(width: 4),
                                                Flexible(
                                                  child: Text(
                                                    daysLeft < 0
                                                        ? 'Overdue (${dateFormat.format(p.deadline)})'
                                                        : '${daysLeft}d left (${dateFormat.format(p.deadline)})',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: daysLeft < 0
                                                          ? Colors.red
                                                          : const Color(
                                                              0xFF64748B),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppState appState, Project project) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${project.title}"?'),
        content: const Text(
            'This will permanently delete this project and all its tasks from the system. This action is audited.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              appState.deleteProject(project.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
