import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => auth.authStateChanges();
  User? get currentUser => auth.currentUser;

  /// Sign up a new user with Email, Password, Name, and Role
  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final credential = await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user != null) {
      await user.updateDisplayName(name.trim());

      // Save user profile in Firestore
      try {
        await firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name.trim(),
          'email': email.trim(),
          'role': role,
          'colorValue': 0xFF0EA5E9,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('Firestore write error during sign up: $e');
      }
    }

    return credential;
  }

  /// Sign in existing user with Email and Password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Sign out current user
  Future<void> signOut() async {
    await auth.signOut();
  }

  /// Fetch user profile from Firestore
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      debugPrint('Error getting user profile: $e');
    }
    return null;
  }

  /// Save Project to Firestore
  Future<void> saveProject(Project project) async {
    try {
      await firestore.collection('projects').doc(project.id).set({
        'id': project.id,
        'title': project.title,
        'description': project.description,
        'colorValue': project.colorValue,
        'memberIds': project.memberIds,
        'createdAt': project.createdAt.toIso8601String(),
        'deadline': project.deadline.toIso8601String(),
      });
    } catch (e) {
      debugPrint('Firestore saveProject error: $e');
    }
  }

  /// Save Task to Firestore
  Future<void> saveTask(TaskItem task) async {
    try {
      await firestore.collection('tasks').doc(task.id).set({
        'id': task.id,
        'projectId': task.projectId,
        'title': task.title,
        'description': task.description,
        'assigneeId': task.assigneeId,
        'priority': task.priority.index,
        'status': task.status.index,
        'dueDate': task.dueDate.toIso8601String(),
        'createdAt': task.createdAt.toIso8601String(),
        'comments': task.comments.map((c) => {
          'id': c.id,
          'authorName': c.authorName,
          'authorRole': c.authorRole,
          'content': c.content,
          'timestamp': c.timestamp.toIso8601String(),
        }).toList(),
      });
    } catch (e) {
      debugPrint('Firestore saveTask error: $e');
    }
  }

  /// Save Activity Log to Firestore
  Future<void> saveActivityLog(ActivityLog log) async {
    try {
      await firestore.collection('activityLogs').doc(log.id).set({
        'id': log.id,
        'timestamp': log.timestamp.toIso8601String(),
        'actorName': log.actorName,
        'actionType': log.actionType,
        'entityType': log.entityType,
        'entityTitle': log.entityTitle,
        'details': log.details,
        'projectId': log.projectId,
      });
    } catch (e) {
      debugPrint('Firestore saveActivityLog error: $e');
    }
  }

  /// Save Notification to Firestore
  Future<void> saveNotification(AppNotification notification) async {
    try {
      await firestore.collection('notifications').doc(notification.id).set({
        'id': notification.id,
        'title': notification.title,
        'message': notification.message,
        'timestamp': notification.timestamp.toIso8601String(),
        'isRead': notification.isRead,
        'type': notification.type.index,
        'relatedTaskId': notification.relatedTaskId,
        'relatedProjectId': notification.relatedProjectId,
      });
    } catch (e) {
      debugPrint('Firestore saveNotification error: $e');
    }
  }
}
