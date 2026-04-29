import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_detail_screen.dart';
import 'mentor_chat_students_screen.dart';
import 'course_detail_screen.dart';

class NotificationsScreen extends StatelessWidget {
  final String userId;
  const NotificationsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final db = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () => db.markAllNotificationsAsRead(userId),
            child: const Text('Mark all as read', style: TextStyle(color: AppColors.primary)),
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Column(
        children: [
          _EnableNotificationsToggle(userId: userId),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<List<NotificationModel>>(
              stream: db.getNotifications(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final notifications = snapshot.data ?? [];
                if (notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.textLight.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        const Text('No notifications yet', style: TextStyle(color: AppColors.textLight)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final note = notifications[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: AppDecorations.cardDecoration.copyWith(
                        color: note.isRead ? Colors.white.withValues(alpha: 0.7) : Colors.white,
                      ),
                      child: ListTile(
                        onTap: () async {
                          if (!note.isRead) db.markNotificationAsRead(note.id);
                          _handleNotificationTap(context, note);
                        },
                        leading: CircleAvatar(
                          backgroundColor: _getNoteColor(note.type).withValues(alpha: 0.1),
                          child: Icon(_getNoteIcon(note.type), color: _getNoteColor(note.type), size: 18),
                        ),
                        title: Text(note.title, 
                          style: TextStyle(
                            fontWeight: note.isRead ? FontWeight.w500 : FontWeight.bold,
                            fontSize: 14,
                          )
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(note.message, style: const TextStyle(fontSize: 13, height: 1.3)),
                            const SizedBox(height: 6),
                            Text(
                              DateFormat('MMM dd, hh:mm a').format(note.timestamp),
                              style: TextStyle(fontSize: 10, color: AppColors.textLight),
                            ),
                          ],
                        ),
                        trailing: note.isRead ? null : const CircleAvatar(radius: 4, backgroundColor: AppColors.primary),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNotificationTap(BuildContext context, NotificationModel note) async {
    final db = FirestoreService();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    if (note.type == 'chat' && note.courseId != null) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final courseSnap = await db.getCourse(note.courseId!).first;
        if (context.mounted) Navigator.pop(context); // Pop loading

        if (courseSnap != null) {
          if (courseSnap.mentorId == uid) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MentorChatStudentsScreen(course: courseSnap)),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatDetailScreen(
                  course: courseSnap,
                  studentId: uid,
                  mentorId: courseSnap.mentorId ?? '',
                  title: courseSnap.instructor,
                ),
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) Navigator.pop(context);
      }
    } else if (note.courseId != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final courseSnap = await db.getCourse(note.courseId!).first;
        if (context.mounted) Navigator.pop(context);

        if (courseSnap != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CourseDetailScreen(course: courseSnap)),
          );
        }
      } catch (e) {
        if (context.mounted) Navigator.pop(context);
      }
    }
  }

  IconData _getNoteIcon(String type) {
    switch (type) {
      case 'enrollment_request': return Icons.person_add_rounded;
      case 'enrollment_response': return Icons.fact_check_rounded;
      case 'chat': return Icons.chat_bubble_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _getNoteColor(String type) {
    switch (type) {
      case 'enrollment_request': return AppColors.info;
      case 'enrollment_response': return AppColors.success;
      case 'chat': return AppColors.primary;
      default: return AppColors.textLight;
    }
  }
}

class _EnableNotificationsToggle extends StatelessWidget {
  final String userId;
  const _EnableNotificationsToggle({required this.userId});

  @override
  Widget build(BuildContext context) {
    final db = FirestoreService();

    return StreamBuilder<UserModel?>(
      stream: db.getUserModel(userId),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final isEnabled = user?.isNotificationsEnabled ?? true;

        return SwitchListTile(
          value: isEnabled,
          onChanged: (val) {
            if (user != null) {
              final updated = UserModel(
                id: user.id,
                name: user.name,
                email: user.email,
                role: user.role,
                avatarInitials: user.avatarInitials,
                completedModules: user.completedModules,
                totalModules: user.totalModules,
                streakDays: user.streakDays,
                overallProgress: user.overallProgress,
                phoneNumber: user.phoneNumber,
                bio: user.bio,
                skills: user.skills,
                socialLinks: user.socialLinks,
                password: user.password,
                profileImageUrl: user.profileImageUrl,
                isNotificationsEnabled: val,
                fcmToken: user.fcmToken,
              );
              db.updateUserModel(updated);
            }
          },
          title: const Text('Enable Notifications', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          subtitle: const Text('Get real-time alerts for requests and chats', style: TextStyle(fontSize: 12)),
          activeColor: AppColors.primary,
        );
      },
    );
  }
}
