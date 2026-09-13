import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/activity_log_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/project_detail_screen.dart';
import 'screens/projects_screen.dart';
import 'screens/team_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/create_task_dialog.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const TaskManagementApp(),
    ),
  );
}

class TaskManagementApp extends StatelessWidget {
  const TaskManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskPulse - Project & Task Management System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedTabIndex = 0;
  String? _activeProjectId;

  void _onSelectTab(int index) {
    setState(() {
      _selectedTabIndex = index;
      _activeProjectId = null;
    });
  }

  void _openProject(String projectId) {
    setState(() {
      _activeProjectId = projectId;
      _selectedTabIndex = 1; // Projects tab
    });
  }

  void _closeProject() {
    setState(() {
      _activeProjectId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final unreadNotifs = appState.unreadNotificationsCount;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800;

        return Scaffold(
          // Top Navigation Header
          appBar: AppBar(
            titleSpacing: isWide ? 20 : 12,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF0EA5E9)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.dashboard_customize_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'TaskPulse',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (isWide)
                      Text(
                        'Project & Task Management System',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            actions: [
              // Current User Badge (Compact on mobile, full on desktop)
              if (isWide)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        radius: 12,
                        backgroundColor: Color(0xFF4F46E5),
                        child: Text(
                          'NS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        appState.currentUser,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${appState.currentUserRole})',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Tooltip(
                  message: '${appState.currentUser} (${appState.currentUserRole})',
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Color(0xFF4F46E5),
                      child: Text(
                        'NS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

              // Notifications Bell with Badge
              IconButton(
                tooltip: 'Notifications',
                onPressed: () {
                  _onSelectTab(3); // Go to Notifications
                },
                icon: Badge(
                  isLabelVisible: unreadNotifs > 0,
                  label: Text('$unreadNotifs'),
                  child: const Icon(Icons.notifications_none_rounded, size: 22),
                ),
              ),

              // Quick Add Task Button (Icon button on mobile, full labeled button on desktop)
              if (isWide)
                Padding(
                  padding: const EdgeInsets.only(left: 4, right: 16),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => CreateTaskDialog(
                          initialProjectId: _activeProjectId,
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('New Task'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(left: 2, right: 10),
                  child: IconButton.filled(
                    tooltip: 'New Task',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => CreateTaskDialog(
                          initialProjectId: _activeProjectId,
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_rounded, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(8),
                      minimumSize: const Size(32, 32),
                    ),
                  ),
                ),
            ],
          ),

          body: Row(
            children: [
              // Left Navigation Rail for Wide Screens
              if (isWide)
                NavigationRail(
                  selectedIndex: _selectedTabIndex,
                  onDestinationSelected: _onSelectTab,
                  labelType: NavigationRailLabelType.all,
                  leading: const SizedBox(height: 10),
                  destinations: [
                    const NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard_rounded),
                      label: Text('Dashboard'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.folder_outlined),
                      selectedIcon: Icon(Icons.folder_rounded),
                      label: Text('Projects'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.history_outlined),
                      selectedIcon: Icon(Icons.history_rounded),
                      label: Text('Audit Trail'),
                    ),
                    NavigationRailDestination(
                      icon: Badge(
                        isLabelVisible: unreadNotifs > 0,
                        label: Text('$unreadNotifs'),
                        child: const Icon(Icons.notifications_outlined),
                      ),
                      selectedIcon: Badge(
                        isLabelVisible: unreadNotifs > 0,
                        label: Text('$unreadNotifs'),
                        child: const Icon(Icons.notifications_rounded),
                      ),
                      label: const Text('Alerts'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.group_outlined),
                      selectedIcon: Icon(Icons.group_rounded),
                      label: Text('Team'),
                    ),
                  ],
                ),

              // Main Active Screen View
              Expanded(
                child: _buildCurrentScreen(),
              ),
            ],
          ),

          // Bottom Navigation Bar for Compact/Mobile screens
          bottomNavigationBar: isWide
              ? null
              : NavigationBar(
                  selectedIndex: _selectedTabIndex,
                  onDestinationSelected: _onSelectTab,
                  destinations: [
                    const NavigationDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard_rounded),
                      label: 'Dashboard',
                    ),
                    const NavigationDestination(
                      icon: Icon(Icons.folder_outlined),
                      selectedIcon: Icon(Icons.folder_rounded),
                      label: 'Projects',
                    ),
                    const NavigationDestination(
                      icon: Icon(Icons.history_outlined),
                      selectedIcon: Icon(Icons.history_rounded),
                      label: 'Audit Log',
                    ),
                    NavigationDestination(
                      icon: Badge(
                        isLabelVisible: unreadNotifs > 0,
                        label: Text('$unreadNotifs'),
                        child: const Icon(Icons.notifications_outlined),
                      ),
                      selectedIcon: Badge(
                        isLabelVisible: unreadNotifs > 0,
                        label: Text('$unreadNotifs'),
                        child: const Icon(Icons.notifications_rounded),
                      ),
                      label: 'Alerts',
                    ),
                    const NavigationDestination(
                      icon: Icon(Icons.group_outlined),
                      selectedIcon: Icon(Icons.group_rounded),
                      label: 'Team',
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildCurrentScreen() {
    switch (_selectedTabIndex) {
      case 0:
        return DashboardScreen(
          onNavigateTab: _onSelectTab,
          onOpenProject: _openProject,
        );
      case 1:
        if (_activeProjectId != null) {
          return ProjectDetailScreen(
            projectId: _activeProjectId!,
            onBack: _closeProject,
          );
        }
        return ProjectsScreen(
          onOpenProject: _openProject,
        );
      case 2:
        return const ActivityLogScreen();
      case 3:
        return const NotificationsScreen();
      case 4:
        return const TeamScreen();
      default:
        return DashboardScreen(
          onNavigateTab: _onSelectTab,
          onOpenProject: _openProject,
        );
    }
  }
}
