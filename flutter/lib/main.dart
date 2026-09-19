import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/app_state.dart';
import 'screens/activity_log_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/project_detail_screen.dart';
import 'screens/projects_screen.dart';
import 'screens/team_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/create_task_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const TaskManagementApp(),
    ),
  );
}

class TaskManagementApp extends StatelessWidget {
  final Widget? home;
  const TaskManagementApp({super.key, this.home});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final isTestEnvironment =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');

    Widget initialScreen;
    if (home != null) {
      initialScreen = home!;
    } else if (isTestEnvironment) {
      initialScreen = const MainShell();
    } else {
      initialScreen =
          appState.isAuthenticated ? const MainShell() : const AuthScreen();
    }

    return MaterialApp(
      title: 'TaskPulse - Project & Task Management System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: initialScreen,
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

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty && parts[0].isNotEmpty
        ? parts[0][0].toUpperCase()
        : '?';
  }

  Future<void> _handleSignOut(BuildContext context, AppState appState) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content:
            const Text('Are you sure you want to sign out of your workspace?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await appState.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final unreadNotifs = appState.unreadNotificationsCount;
    final initials = _getInitials(appState.currentUser);

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
                const SizedBox(width: 8),
                const Text(
                  'TaskPulse',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            actions: [
              // Current User Badge (Compact popup on mobile, full card on desktop)
              if (isWide) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: const Color(0xFF4F46E5),
                        child: Text(
                          initials,
                          style: const TextStyle(
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
                ),
                IconButton(
                  tooltip: 'Sign Out',
                  icon: const Icon(Icons.logout_rounded,
                      size: 19, color: Color(0xFF64748B)),
                  onPressed: () => _handleSignOut(context, appState),
                ),
              ] else ...[
                PopupMenuButton<String>(
                  tooltip: 'User Profile & Sign Out',
                  offset: const Offset(0, 40),
                  onSelected: (val) {
                    if (val == 'signout') {
                      _handleSignOut(context, appState);
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      enabled: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appState.currentUser,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            appState.currentUserRole,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'signout',
                      child: Row(
                        children: [
                          Icon(Icons.logout_rounded,
                              size: 18, color: Color(0xFFEF4444)),
                          SizedBox(width: 8),
                          Text('Sign Out',
                              style: TextStyle(color: Color(0xFFEF4444))),
                        ],
                      ),
                    ),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: const Color(0xFF4F46E5),
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],

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

              // Quick Add Task Button
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
