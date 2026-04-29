import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';
import 'chat_detail_screen.dart';

class MentorChatStudentsScreen extends StatefulWidget {
  final CourseModel course;
  
  const MentorChatStudentsScreen({super.key, required this.course});

  @override
  State<MentorChatStudentsScreen> createState() => _MentorChatStudentsScreenState();
}

class _MentorChatStudentsScreenState extends State<MentorChatStudentsScreen> {
  final FirestoreService _db = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Students', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: StreamBuilder<CourseModel?>(
        stream: _db.getCourse(widget.course.id),
        builder: (context, snapshot) {
          final course = snapshot.data ?? widget.course;
          final studentIds = course.enrolledStudentIds;

          if (studentIds.isEmpty) {
            return const Center(child: Text('No students enrolled yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: studentIds.length,
            itemBuilder: (context, index) {
              final studentId = studentIds[index];
              return FutureBuilder<UserModel?>(
                future: _db.getUserFuture(studentId),
                builder: (context, userSnap) {
                  final user = userSnap.data;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      onTap: () {
                        if (user != null && course.mentorId != null) {
                           Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatDetailScreen(
                                course: course,
                                studentId: studentId,
                                mentorId: course.mentorId!,
                                title: user.name,
                              ),
                            ),
                          );
                        }
                      },
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryLight,
                        foregroundImage: user?.profileImageUrl != null ? NetworkImage(user!.profileImageUrl!) : null,
                        child: Text(user?.avatarInitials ?? '?', style: const TextStyle(color: AppColors.primary)),
                      ),
                      title: Text(user?.name ?? 'Loading...', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Tap to chat'),
                      trailing: const Icon(Icons.chat_bubble_outline, color: AppColors.primary, size: 20),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
