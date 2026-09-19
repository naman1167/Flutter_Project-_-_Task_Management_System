import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:task_management_system/main.dart';
import 'package:task_management_system/providers/app_state.dart';

void main() {
  testWidgets('Full TaskPulse Flow: Navigation, Kanban Board, Task Modal, and Audit Logs', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final appState = AppState()..loginAsDemoUser();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const TaskManagementApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Dashboard & Metric Cards
    expect(find.text('TaskPulse'), findsOneWidget);
    expect(find.text('Active Projects'), findsOneWidget);
    expect(find.text('Pending Tasks'), findsOneWidget);

    // 2. Navigate to Projects
    await tester.tap(find.text('Projects'));
    await tester.pumpAndSettle();
    expect(find.text('FinTech Mobile App Redesign'), findsOneWidget);

    // 3. Open Project Detail (Kanban Board)
    await tester.tap(find.text('FinTech Mobile App Redesign'));
    await tester.pumpAndSettle();

    // Verify Kanban columns
    expect(find.text('To Do'), findsWidgets);
    expect(find.text('In Progress'), findsWidgets);
    expect(find.text('In Review'), findsWidgets);
    expect(find.text('Completed'), findsWidgets);

    // Switch to List View
    await tester.tap(find.text('List'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget); // Search bar

    // Switch back to Kanban
    await tester.tap(find.text('Kanban'));
    await tester.pumpAndSettle();

    // Go back to Projects
    await tester.tap(find.byTooltip('Back to Projects'));
    await tester.pumpAndSettle();

    // 4. Navigate to Audit Trail
    await tester.tap(find.text('Audit Trail'));
    await tester.pumpAndSettle();
    expect(find.text('Audit Trail & Activity Log'), findsOneWidget);
    expect(find.textContaining('Audited Events'), findsOneWidget);

    // 5. Navigate to Alerts / Notifications
    await tester.tap(find.text('Alerts'));
    await tester.pumpAndSettle();
    expect(find.text('Notifications & Reminders'), findsOneWidget);

    // 6. Navigate to Team
    await tester.tap(find.text('Team'));
    await tester.pumpAndSettle();
    expect(find.text('Team & Collaboration'), findsOneWidget);
  });

  testWidgets('Narrow Mobile Viewport (380x800) Renders with Zero Overflows', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(380, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final appState = AppState()..loginAsDemoUser();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const TaskManagementApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Dashboard
    expect(find.text('TaskPulse'), findsOneWidget);
    expect(find.text('Active Projects'), findsOneWidget);

    // Verify Navigation to Projects
    await tester.tap(find.text('Projects'));
    await tester.pumpAndSettle();

    // Verify Navigation to Audit Log
    await tester.tap(find.text('Audit Log'));
    await tester.pumpAndSettle();

    // Verify Navigation to Alerts
    await tester.tap(find.text('Alerts'));
    await tester.pumpAndSettle();

    // Verify Navigation to Team
    await tester.tap(find.text('Team'));
    await tester.pumpAndSettle();
  });
}
