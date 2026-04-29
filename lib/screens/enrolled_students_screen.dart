import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';

class EnrolledStudentsScreen extends StatefulWidget {
  final CourseModel course;
  const EnrolledStudentsScreen({super.key, required this.course});

  @override
  State<EnrolledStudentsScreen> createState() => _EnrolledStudentsScreenState();
}

class _EnrolledStudentsScreenState extends State<EnrolledStudentsScreen> {
  final FirestoreService _db = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Enrolled Students', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: StreamBuilder<CourseModel?>(
        stream: _db.getCourse(widget.course.id),
        builder: (context, snapshot) {
          final course = snapshot.data ?? widget.course;
          
          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textLight,
                  indicatorColor: AppColors.primary,
                  tabs: [
                    Tab(text: 'Enrolled (${course.enrolledStudentIds.length})'),
                    Tab(text: 'Requests (${course.enrollmentPendingIds.length})'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildEnrolledList(course.enrolledStudentIds),
                      _buildRequestList(course),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnrolledList(List<String> studentIds) {
    if (studentIds.isEmpty) return const Center(child: Text('No students enrolled yet.'));
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: studentIds.length,
      itemBuilder: (context, index) {
        return FutureBuilder<UserModel?>(
          future: _db.getUserFuture(studentIds[index]),
          builder: (context, userSnap) {
            final user = userSnap.data;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  foregroundImage: user?.profileImageUrl != null ? NetworkImage(user!.profileImageUrl!) : null,
                  child: Text(user?.avatarInitials ?? '?', style: const TextStyle(color: AppColors.primary)),
                ),
                title: Text(user?.name ?? 'Loading...', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(user?.email ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.person_remove_rounded, color: AppColors.error, size: 20),
                  onPressed: () {
                    if (user != null) {
                      _showDeleteDialog(context, user);
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRequestList(CourseModel course) {
    final pendingIds = course.enrollmentPendingIds;
    if (pendingIds.isEmpty) return const Center(child: Text('No pending requests.'));

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: pendingIds.length,
      itemBuilder: (context, index) {
        final uid = pendingIds[index];
        return FutureBuilder<UserModel?>(
          future: _db.getUserFuture(uid),
          builder: (context, userSnap) {
            final user = userSnap.data;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.warning.withValues(alpha: 0.1),
                  foregroundImage: user?.profileImageUrl != null ? NetworkImage(user!.profileImageUrl!) : null,
                  child: Text(user?.avatarInitials ?? '?', style: const TextStyle(color: AppColors.warning)),
                ),
                title: Text(user?.name ?? 'Loading...', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Requested enrollment'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: AppColors.success),
                      onPressed: () => _handleRequest(course, uid, true),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: AppColors.error),
                      onPressed: () => _handleRequest(course, uid, false),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Student?'),
        content: Text('This will permanently delete ${user.name} and all their associated data including attendance, grades, and messages. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _db.deleteUserAndData(user.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Student ${user.name} and all their data removed.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }

  void _handleRequest(CourseModel course, String uid, bool approve) async {
    final newPending = List<String>.from(course.enrollmentPendingIds)..remove(uid);
    final newEnrolled = List<String>.from(course.enrolledStudentIds);
    if (approve) newEnrolled.add(uid);

    final updatedCourse = CourseModel(
      id: course.id,
      courseCode: course.courseCode,
      title: course.title,
      instructor: course.instructor,
      duration: course.duration,
      totalLessons: course.totalLessons,
      completedLessons: course.completedLessons,
      rating: course.rating,
      category: course.category,
      difficulty: course.difficulty,
      isEnrolled: course.isEnrolled,
      gradientIndex: course.gradientIndex,
      lessons: course.lessons,
      liveSessions: course.liveSessions,
      enrolledStudentIds: newEnrolled,
      enrollmentPendingIds: newPending,
      mentorId: course.mentorId,
      status: course.status,
    );

    await _db.updateCourse(updatedCourse);
    
    // Create notification for student
    final mentorId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final mentor = await _db.getUserFuture(mentorId);
    await _db.createNotification(NotificationModel(
      id: '',
      receiverId: uid,
      senderId: mentorId,
      senderName: mentor?.name ?? 'Mentor',
      title: approve ? 'Enrollment Approved!' : 'Enrollment Rejected',
      message: approve 
          ? 'You have been accepted into "${course.title}"' 
          : 'Your request to join "${course.title}" was declined',
      courseId: course.id,
      type: 'enrollment_response',
      timestamp: DateTime.now(),
    ));

    if (approve) {
      await _db.createEnrollment(uid, course.id, course.title);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(approve ? 'Enrollment approved!' : 'Request rejected.')),
      );
    }
  }
}
