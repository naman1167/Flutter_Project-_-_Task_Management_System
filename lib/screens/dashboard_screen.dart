import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../widgets/create_project_dialog.dart';
import '../widgets/create_task_dialog.dart';
import '../widgets/task_card.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onNavigateTab;
  final Function(String) onOpenProject;

  const DashboardScreen({
    super.key,
    required this.onNavigateTab,
    required this.onOpenProject,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final urgentTasks = appState.tasks
        .where((t) =>
            t.status != TaskStatus.completed &&
            (t.priority == TaskPriority.urgent || t.isOverdue || t.isDueSoon))
        .toList();

    final recentLogs = appState.activityLogs.take(5).toList();
    final dateFormat = DateFormat('MMM d, h:mm a');

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 600;

                final titleContent = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${appState.currentUser} 👋',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Workspace Overview & Real-Time Audit Metrics',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                );

                final actionButtons = isCompact
                    ? Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => const CreateProjectDialog(),
                                );
                              },
                              icon: const Icon(Icons.create_new_folder_rounded,
                                  size: 16),
                              label: const Text('New Project'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => const CreateTaskDialog(),
                                );
                              },
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text('Add Task'),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => const CreateProjectDialog(),
                              );
                            },
                            icon: const Icon(Icons.create_new_folder_rounded,
                                size: 16),
                            label: const Text('New Project'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => const CreateTaskDialog(),
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
                      titleContent,
                      const SizedBox(height: 14),
                      actionButtons,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: titleContent),
                    const SizedBox(width: 16),
                    actionButtons,
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Top Metric Cards Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;
                return GridView.count(
                  crossAxisCount: isWide ? 4 : 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: isWide ? 1.6 : 1.25,
                  children: [
                    _buildMetricCard(
                      title: 'Active Projects',
                      value: '${appState.projects.length}',
                      subtitle: 'Active workspaces',
                      icon: Icons.folder_copy_rounded,
                      color: const Color(0xFF4F46E5),
                      onTap: () => onNavigateTab(1),
                    ),
                    _buildMetricCard(
                      title: 'Pending Tasks',
                      value:
                          '${appState.todoTasksCount + appState.inProgressTasksCount + appState.inReviewTasksCount}',
                      subtitle: '${appState.completedTasksCount} completed',
                      icon: Icons.task_alt_rounded,
                      color: const Color(0xFF0284C7),
                      onTap: () => onNavigateTab(1),
                    ),
                    _buildMetricCard(
                      title: 'Urgent / Due Soon',
                      value: '${appState.overdueTasksCount + appState.dueSoonTasksCount}',
                      subtitle: '${appState.overdueTasksCount} overdue',
                      icon: Icons.alarm_rounded,
                      color: appState.overdueTasksCount > 0
                          ? const Color(0xFFEF4444)
                          : const Color(0xFFF59E0B),
                      onTap: () => onNavigateTab(1),
                    ),
                    _buildMetricCard(
                      title: 'Completion Rate',
                      value: '${(appState.overallCompletionRate * 100).toInt()}%',
                      subtitle: '${appState.totalTasksCount} total tasks',
                      icon: Icons.donut_large_rounded,
                      color: const Color(0xFF10B981),
                      onTap: () => onNavigateTab(1),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 28),

            // Urgent / Due Soon Tasks section
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 460;
                return Row(
                  children: [
                    const Icon(Icons.bolt_rounded,
                        color: Color(0xFFF59E0B), size: 22),
                    const SizedBox(width: 6),
                    const Flexible(
                      child: Text(
                        'Attention Required',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${urgentTasks.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        appState.generateUpcomingDeadlineReminders();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Scanned deadlines and updated reminders!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.refresh_rounded, size: 16),
                          if (!isCompact) ...[
                            const SizedBox(width: 4),
                            const Text('Scan Deadlines'),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 12),

            if (urgentTasks.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        size: 38, color: Colors.green.shade400),
                    const SizedBox(height: 8),
                    const Text(
                      'All caught up! No urgent or overdue tasks.',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155)),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: urgentTasks.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) => TaskCard(task: urgentTasks[i]),
              ),

            const SizedBox(height: 28),

            // Projects Quick Overview Carousel
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Projects in Flight',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => onNavigateTab(1),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 145,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: appState.projects.length,
                separatorBuilder: (context, index) => const SizedBox(width: 14),
                itemBuilder: (ctx, i) {
                  final p = appState.projects[i];
                  final progress = appState.getProjectProgress(p.id);
                  final taskCount = appState.getProjectTaskCount(p.id);
                  final completedCount = appState.getProjectCompletedTaskCount(p.id);

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => onOpenProject(p.id),
                    child: Container(
                      width: 260,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  p.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$completedCount / $taskCount tasks',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
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
                              backgroundColor: const Color(0xFFE2E8F0),
                              color: Color(p.colorValue),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 28),

            // Recent Audit Activity Log stream
            Row(
              children: [
                const Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history_edu_rounded,
                          color: Color(0xFF4F46E5), size: 20),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Live Audit Trail',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => onNavigateTab(2),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentLogs.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final log = recentLogs[i];
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: log.actionColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(log.actionIcon,
                            size: 16, color: log.actionColor),
                      ),
                      title: Text(
                        log.entityTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${log.actorName} • ${log.details}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      trailing: Text(
                        dateFormat.format(log.timestamp),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
