import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  String _searchQuery = '';
  String? _selectedActionFilter;
  String? _selectedProjectFilter;

  final List<String> _actionFilters = [
    'ALL',
    'STATUS_CHANGE',
    'TASK_CREATED',
    'ASSIGNMENT',
    'COMMENT_ADDED',
    'PROJECT_CREATED',
    'REMINDER_CHECK',
  ];

  String _formatActionFilterLabel(String key) {
    switch (key) {
      case 'ALL':
        return 'All Actions';
      case 'STATUS_CHANGE':
        return 'Status Transitions';
      case 'TASK_CREATED':
        return 'Task Creation';
      case 'ASSIGNMENT':
        return 'Assignments';
      case 'COMMENT_ADDED':
        return 'Team Comments';
      case 'PROJECT_CREATED':
        return 'Project Milestones';
      case 'REMINDER_CHECK':
        return 'Audit Checks';
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final allLogs = appState.activityLogs;
    final dateFormat = DateFormat('MMM d, yyyy • h:mm:ss a');

    // Filter logs
    final filteredLogs = allLogs.where((log) {
      if (_selectedActionFilter != null &&
          _selectedActionFilter != 'ALL' &&
          log.actionType != _selectedActionFilter) {
        return false;
      }
      if (_selectedProjectFilter != null &&
          log.projectId != _selectedProjectFilter) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesActor = log.actorName.toLowerCase().contains(q);
        final matchesTitle = log.entityTitle.toLowerCase().contains(q);
        final matchesDetails = log.details.toLowerCase().contains(q);
        if (!matchesActor && !matchesTitle && !matchesDetails) return false;
      }
      return true;
    }).toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 600;
                final headerText = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Flexible(
                          child: Text(
                            'Audit Trail & Activity Log',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.verified_user_rounded,
                            size: 20, color: Color(0xFF10B981)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Comprehensive historical ledger of all project modifications, assignments, and transitions',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                );

                final badge = Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.security_rounded,
                          size: 15, color: Color(0xFF10B981)),
                      const SizedBox(width: 6),
                      Text(
                        '${allLogs.length} Audited Events',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF047857),
                        ),
                      ),
                    ],
                  ),
                );

                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      headerText,
                      const SizedBox(height: 10),
                      badge,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: headerText),
                    const SizedBox(width: 12),
                    badge,
                  ],
                );
              },
            ),

            const SizedBox(height: 18),

            // Filter row
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 650;
                final searchField = TextField(
                  decoration: InputDecoration(
                    hintText:
                        'Search audit records by actor, task, or keywords...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                );

                final actionDropdown = Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: isCompact,
                      value: _selectedActionFilter ?? 'ALL',
                      items: _actionFilters.map((act) {
                        return DropdownMenuItem(
                          value: act,
                          child: Text(_formatActionFilterLabel(act),
                              style: const TextStyle(fontSize: 12)),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => _selectedActionFilter = val),
                    ),
                  ),
                );

                final projectDropdown = Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      isExpanded: isCompact,
                      value: _selectedProjectFilter,
                      hint: const Text('All Projects',
                          style: TextStyle(fontSize: 12)),
                      items: [
                        const DropdownMenuItem(
                            value: null,
                            child: Text('All Projects',
                                style: TextStyle(fontSize: 12))),
                        ...appState.projects.map((p) {
                          return DropdownMenuItem(
                            value: p.id,
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Color(p.colorValue),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  p.title,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                      onChanged: (val) =>
                          setState(() => _selectedProjectFilter = val),
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
                          Expanded(child: actionDropdown),
                          const SizedBox(width: 10),
                          Expanded(child: projectDropdown),
                        ],
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: searchField),
                    const SizedBox(width: 12),
                    actionDropdown,
                    const SizedBox(width: 12),
                    projectDropdown,
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            // Audit records list
            Expanded(
              child: filteredLogs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_toggle_off_rounded,
                              size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text(
                            'No matching audit log entries found',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Card(
                      child: ListView.separated(
                        itemCount: filteredLogs.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                          final log = filteredLogs[i];
                          final project =
                              appState.getProjectById(log.projectId);

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Action icon avatar
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: log.actionColor.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(log.actionIcon,
                                      size: 18, color: log.actionColor),
                                ),
                                const SizedBox(width: 14),

                                // Main Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          Text(
                                            log.actorName,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF1F5F9),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              log.actionType.replaceAll('_', ' '),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: log.actionColor,
                                              ),
                                            ),
                                          ),
                                          if (project != null)
                                            Text(
                                              '• in ${project.title}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                          Text(
                                            '• ${dateFormat.format(log.timestamp)}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        log.entityTitle,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        log.details,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF475569),
                                          height: 1.35,
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
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
