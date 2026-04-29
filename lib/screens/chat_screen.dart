import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_detail_screen.dart';
import 'mentor_chat_students_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirestoreService _db = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Gradient Header
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
              bottom: 24,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Messages',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Chat with your course mentors',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.search_rounded,
                      color: Colors.white, size: 22),
                ),
              ],
            ),
          ),

          // Chat List
          Expanded(
            child: StreamBuilder<List<CourseModel>>(
              stream: _db.courses,
              builder: (context, snapshot) {
                final allCourses = snapshot.data ?? [];
                
                final studentCourses = uid != null
                    ? allCourses.where((c) => c.enrolledStudentIds.contains(uid)).toList()
                    : <CourseModel>[];
                
                final mentorCourses = uid != null
                    ? allCourses.where((c) => c.mentorId == uid).toList()
                    : <CourseModel>[];

                final totalCourses = studentCourses.length + mentorCourses.length;

                if (totalCourses == 0) {
                  return _buildEmptyState();
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: [
                    if (studentCourses.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Text(
                          'Your Mentors',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textLight),
                        ),
                      ),
                      ...studentCourses.map((course) => _ChatListItem(
                            title: course.instructor,
                            subtitle: 'Tap to chat with mentor about ${course.title}',
                            courseName: course.title,
                            time: '',
                            unreadCount: 0,
                            onTap: () {
                              if (course.mentorId != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatDetailScreen(
                                      course: course,
                                      studentId: uid!,
                                      mentorId: course.mentorId!,
                                      title: course.instructor,
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Mentor not assigned yet.')),
                                );
                              }
                            },
                          )),
                    ],
                    if (mentorCourses.isNotEmpty) ...[
                      if (studentCourses.isNotEmpty)
                        const Divider(height: 32, indent: 20, endIndent: 20),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Text(
                          'Your Students (Mentor View)',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textLight),
                        ),
                      ),
                      ...mentorCourses.map((course) => _ChatListItem(
                            title: course.title,
                            subtitle: 'View your students and their messages',
                            courseName: 'Mentoring',
                            time: '',
                            unreadCount: 0,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MentorChatStudentsScreen(course: course),
                                ),
                              );
                            },
                          )),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded,
                size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          const Text('No conversations yet',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text('Enroll in a course to chat with your mentors.',
              style: TextStyle(color: AppColors.textLight)),
        ],
      ),
    );
  }
}

class _ChatListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String courseName;
  final String time;
  final int unreadCount;
  final VoidCallback onTap;

  const _ChatListItem({
    required this.title,
    required this.subtitle,
    required this.courseName,
    required this.time,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            title.isNotEmpty ? title[0] : '?',
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(time, style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtitle,
              style: TextStyle(
                color: unreadCount > 0 ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                courseName,
                style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      trailing: unreadCount > 0
          ? Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: Text(
                '$unreadCount',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }
}
